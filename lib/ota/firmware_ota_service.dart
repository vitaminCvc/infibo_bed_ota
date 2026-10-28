import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'ota_checksums.dart';
import 'ota_manifest.dart';
import 'ota_service.dart';

abstract interface class FirmwareTransport {
  Future<void> open();
  Future<void> close();
  Future<List<int>> read(int address, int count);
  Future<void> writeSingle(int address, int value);
  Future<void> writeMultiple(int address, List<int> values);
}

class FirmwareOtaFailure extends OtaFailure {
  const FirmwareOtaFailure(this.errorCode) : super('ota_board_error');
  final int errorCode;
}

class _BoardStatus {
  const _BoardStatus(this.state, this.error, this.progress);
  final int state, error, progress;
}

/// 寄存器布局由「当前运行的主板固件」决定，不能依据下载包的目标版本。
/// 例如 1.2.5 升到 1.3.0，重启前仍由旧 App 处理全部请求，必须一直用旧地址。
/// 每次 upgrade 只选择一次，并显式传给状态、命令及异常清理路径，避免跨会话残留。
class _OtaRegisters {
  const _OtaRegisters(this.base);

  factory _OtaRegisters.forCurrentVersion(int current) {
    if (current <= 0x0125) return const _OtaRegisters(0x0300);
    if (current >= 0x0130) return const _OtaRegisters(0x0380);
    // 文档未定义 1.2.6～1.2.F 的布局。禁止试写两个地址区探测，旧区在新板上
    // 已用于 WBVV；必须在任何 ABORT/升级头等写操作之前拒绝未知布局。
    throw const OtaFailure('ota_protocol_unsupported');
  }

  final int base;
  int get status => base + 0x01;
  int get imageHeader => base + 0x04;
  int get chunkHeader => base + 0x0a;
  int get chunkData => base + 0x20;
}

class FirmwareOtaService {
  FirmwareOtaService({
    required this.transport,
    Future<void> Function(Duration)? wait,
    this.installDelay = const Duration(seconds: 10),
    this.verifyAttempts = 20,
    this.maxRetries = 3,
  }) : wait = wait ?? Future<void>.delayed;
  final FirmwareTransport transport;
  final Future<void> Function(Duration) wait;
  final Duration installDelay;
  final int verifyAttempts, maxRetries;
  bool _active = false;
  void _cancel(CancelToken? token) {
    if (token?.isCancelled == true) throw const OtaFailure('ota_cancelled');
  }

  Future<_BoardStatus> _status(_OtaRegisters registers) async {
    List<int>? values;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        values = await transport.read(registers.status, 16);
        break;
      } catch (_) {
        if (attempt == 2) rethrow;
        await wait(const Duration(milliseconds: 100));
      }
    }
    if (values == null || values.length != 16) {
      throw const OtaFailure('ota_transfer_failed');
    }
    final status = _BoardStatus(
      values[0],
      values[1],
      values[14] | values[15] << 16,
    );
    if (status.state == 3 || status.error != 0) {
      throw FirmwareOtaFailure(status.error);
    }
    return status;
  }

  Future<void> _control(_OtaRegisters registers, int command) =>
      transport.writeSingle(registers.base, command);
  Future<void> upgrade(
    File file,
    FirmwareRelease release, {
    CancelToken? cancelToken,
    void Function(double)? onProgress,
    void Function(String)? onPhase,
  }) async {
    if (_active) throw const OtaFailure('ota_busy');
    _active = true;
    var opened = false, receiving = false, reboot = false;
    _OtaRegisters? sessionRegisters;
    try {
      _cancel(cancelToken);
      if (!file.existsSync() ||
          release.size < 8 ||
          release.size > 2 * 1024 * 1024) {
        throw const OtaFailure('ota_file_invalid');
      }
      final image = await file.readAsBytes();
      if (image.length != release.size ||
          sha256.convert(image).toString() != release.sha256.toLowerCase() ||
          crc32(image) != release.crc32) {
        throw const OtaFailure('ota_file_invalid');
      }
      await transport.open();
      opened = true;
      onPhase?.call('ota_checking_device');
      if ((await transport.read(0x0006, 1)).single != 0) {
        throw const OtaFailure('ota_device_busy');
      }
      final current = (await transport.read(0x0002, 1)).single;
      // 发布目标由管理员决定，允许重装及降级；不把文件或清单版本伪装成更高版本。
      // 实板/Bootloader 是否接受该镜像，仍由后续状态、错误及版本回读判断。

      // 检查当前版本是否支持新协议
      final registers = _OtaRegisters.forCurrentVersion(current);
      sessionRegisters = registers;
      int? legacyAppBase;
      if (registers.base == 0x0300) {
        // 仅旧版方案明确规定了 0x0311～0x0315 的能力寄存器。
        // V1.3.0 的新方案没有对应查询：不能把旧地址加偏移后当成新协议要求。
        final List<int> info;
        try {
          info = await transport.read(0x0311, 5);
        } catch (_) {
          throw const OtaFailure('ota_protocol_unsupported');
        }
        if (info.length != 5 ||
            info.any((word) => word < 0 || word > 0xffff) ||
            info[4] != 1) {
          throw const OtaFailure('ota_protocol_unsupported');
        }
        final base = info[0] | info[1] << 16;
        final maxSize = info[2] | info[3] << 16;
        if (release.size > maxSize || maxSize == 0) {
          throw const OtaFailure('ota_image_too_large');
        }
        if (base == 0 || base == 0xffffffff || base + maxSize > 0x100000000) {
          throw const OtaFailure('ota_image_incompatible');
        }
        legacyAppBase = base;
      }
      final vectors = ByteData.sublistView(image);
      final stack = vectors.getUint32(0, Endian.little),
          reset = vectors.getUint32(4, Endian.little);
      if (stack == 0 ||
          stack == 0xffffffff ||
          stack % 4 != 0 ||
          reset == 0xffffffff ||
          reset & ~1 == 0 ||
          reset & 1 == 0 ||
          (legacyAppBase != null &&
              ((reset & ~1) < legacyAppBase ||
                  (reset & ~1) >= legacyAppBase + image.length))) {
        throw const OtaFailure('ota_image_incompatible');
      }
      // 新协议按厂家已定义的 BEGIN 大小检查、分包/整包 CRC 和最终版本回读确认。
      // 这里不编造新的 Flash 起始地址或协议号，也不读取 WBVV 区作为能力替代。
      _cancel(cancelToken);
      try {
        await _control(registers, 0xa005);
      } catch (_) {
        if ((await _status(registers)).state != 0) rethrow;
      }
      // 发送 begin 命令
      await wait(const Duration(milliseconds: 200));
      await transport.writeMultiple(registers.imageHeader, [
        release.size & 65535,
        release.size >> 16,
        release.crc32 & 65535,
        release.crc32 >> 16,
        release.versionRegister,
        0,
      ]);
      receiving = true;
      try {
        await _control(registers, 0xa001);
      } catch (_) {
        /* BEGIN 命令发送失败，重试 */
      }
      final begun = await _status(registers);
      if (begun.state != 1 || begun.progress != 0) {
        throw const OtaFailure('ota_transfer_failed');
      }
      onPhase?.call('ota_board_transferring');
      for (var offset = 0; offset < image.length;) {
        _cancel(cancelToken);
        final end = (offset + 128).clamp(0, image.length),
            chunk = image.sublist(offset, end);
        final words = <int>[
          for (var i = 0; i < chunk.length; i += 2)
            (chunk[i] << 8) | (i + 1 < chunk.length ? chunk[i + 1] : 255),
        ];
        final checksum = crc32(chunk);
        var accepted = false;
        for (var attempt = 0; attempt <= maxRetries; attempt++) {
          _cancel(cancelToken);
          try {
            await transport.writeMultiple(registers.chunkHeader, [
              offset & 65535,
              offset >> 16,
              words.length,
              checksum & 65535,
              checksum >> 16,
            ]);
            await transport.writeMultiple(registers.chunkData, words);
            await _control(registers, 0xa002);
          } catch (_) {
            /* 没有回复，重试 */
          }
          final status = await _status(registers);
          if (status.state == 1 && status.progress == end) {
            accepted = true;
            break;
          }
          if (status.state != 1 || status.progress != offset) {
            throw const OtaFailure('ota_progress_invalid');
          }
          await wait(const Duration(milliseconds: 100));
        }
        if (!accepted) throw const OtaFailure('ota_transfer_failed');
        offset = end;
        onProgress?.call(offset / image.length);
      }
      _cancel(cancelToken);
      onPhase?.call('ota_board_verifying');
      try {
        await _control(registers, 0xa003);
      } catch (_) {
        /* FINISH 命令发送失败，重试 */
      }
      var ready = false;
      for (var attempt = 0; attempt < 40; attempt++) {
        _cancel(cancelToken);
        final status = await _status(registers);

        if (status.state == 2 && status.progress == image.length) {
          ready = true;
          break;
        }
        if (status.state != 1) throw const OtaFailure('ota_transfer_failed');
        await wait(const Duration(milliseconds: 300));
      }
      if (!ready) throw const OtaFailure('ota_transfer_failed');
      _cancel(cancelToken);
      onPhase?.call('ota_board_installing');
      reboot = true;
      try {
        await _control(registers, 0xa004);
      } catch (_) {
        /* Reset may happen before the reply. Do not resend. */
      }
      await wait(installDelay);
      onPhase?.call('ota_board_reconnecting');
      for (var attempt = 0; attempt < verifyAttempts; attempt++) {
        try {
          if ((await transport.read(0x0002, 1)).single ==
              release.versionRegister) {
            // 同版本回读只能证明通信恢复，不能区分真正重刷和旧程序继续运行。
            onPhase?.call(
              current == release.versionRegister
                  ? 'ota_board_reinstall_unverified'
                  : 'ota_board_success',
            );
            return;
          }
        } catch (_) {}
        await wait(const Duration(seconds: 1));
      }
      throw const OtaFailure('ota_firmware_unknown');
    } catch (_) {
      if (receiving && !reboot && sessionRegisters != null) {
        try {
          // 失败清理也必须使用本次会话锁定的布局，绝不能重新按目标版本选址。
          await _control(sessionRegisters, 0xa005);
        } catch (_) {}
      }
      rethrow;
    } finally {
      try {
        if (opened) await transport.close();
      } finally {
        _active = false;
      }
    }
  }
}
