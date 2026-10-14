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

  Future<_BoardStatus> _status() async {
    List<int>? values;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        values = await transport.read(0x0301, 16);
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

  Future<void> _control(int command) => transport.writeSingle(0x0300, command);
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
    try {
      _cancel(cancelToken);
      if (!await file.exists() ||
          await file.length() != release.size ||
          release.size < 8 ||
          release.size > 2 * 1024 * 1024) {
        throw const OtaFailure('ota_file_invalid');
      }
      final image = await file.readAsBytes();
      if (sha256.convert(image).toString() != release.sha256.toLowerCase() ||
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
      if (release.versionRegister <= current) {
        throw const OtaFailure('ota_latest_installed');
      }
      final info = await transport.read(0x0311, 5);
      if (info.length != 5 || info[4] != 1) {
        throw const OtaFailure('ota_protocol_unsupported');
      }
      final base = info[0] | info[1] << 16, maxSize = info[2] | info[3] << 16;
      if (release.size > maxSize || maxSize == 0) {
        throw const OtaFailure('ota_image_too_large');
      }
      final vectors = ByteData.sublistView(image);
      final stack = vectors.getUint32(0, Endian.little),
          reset = vectors.getUint32(4, Endian.little);
      if (stack == 0 ||
          stack == 0xffffffff ||
          stack % 4 != 0 ||
          reset & 1 == 0 ||
          (reset & ~1) < base ||
          (reset & ~1) >= base + image.length) {
        throw const OtaFailure('ota_image_incompatible');
      }
      _cancel(cancelToken);
      try {
        await _control(0xa005);
      } catch (_) {
        if ((await _status()).state != 0) rethrow;
      }
      await wait(const Duration(milliseconds: 200));
      await transport.writeMultiple(0x0304, [
        release.size & 65535,
        release.size >> 16,
        release.crc32 & 65535,
        release.crc32 >> 16,
        release.versionRegister,
        0,
      ]);
      receiving = true;
      try {
        await _control(0xa001);
      } catch (_) {
        /* State determines whether BEGIN was received. */
      }
      final begun = await _status();
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
            await transport.writeMultiple(0x030a, [
              offset & 65535,
              offset >> 16,
              words.length,
              checksum & 65535,
              checksum >> 16,
            ]);
            await transport.writeMultiple(0x0320, words);
            await _control(0xa002);
          } catch (_) {
            /* Never retry WRITE before checking the board's actual progress. */
          }
          final status = await _status();
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
        await _control(0xa003);
      } catch (_) {
        /* FINISH response may be lost; poll status. */
      }
      var ready = false;
      for (var attempt = 0; attempt < 40; attempt++) {
        _cancel(cancelToken);
        final status = await _status();
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
        await _control(0xa004);
      } catch (_) {
        /* Reset may happen before the reply. Do not resend. */
      }
      await wait(installDelay);
      onPhase?.call('ota_board_reconnecting');
      for (var attempt = 0; attempt < verifyAttempts; attempt++) {
        try {
          if ((await transport.read(0x0002, 1)).single ==
              release.versionRegister) {
            onPhase?.call('ota_board_success');
            return;
          }
        } catch (_) {}
        await wait(const Duration(seconds: 1));
      }
      throw const OtaFailure('ota_firmware_unknown');
    } catch (_) {
      if (receiving && !reboot) {
        try {
          await _control(0xa005);
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
