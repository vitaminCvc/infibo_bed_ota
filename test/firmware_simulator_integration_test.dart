import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/ota/firmware_ota_service.dart';
import 'package:infibo_app/ota/ota_checksums.dart';
import 'package:infibo_app/ota/ota_manifest.dart';
import 'package:infibo_app/ota/ota_service.dart';

/// 仅用于跨项目回归测试：通过回环 TCP 连接本测试启动的 C# 协议进程，
/// 其内部使用产品 RegisterBank/ModbusCommandHandler，不连接任何真实设备。
/// 不配置 INFIBO_OTA_HARNESS 时跳过，因此日常 Flutter 测试无需安装 .NET。
class _SimulatorTransport implements FirmwareTransport {
  _SimulatorTransport(
    this.executable,
    this.version, {
    this.fault = 0,
    this.appBase = 0x08004000,
  });

  final String executable;
  final int version, fault, appBase;
  final reads = <int>[];
  final writes = <int>[];
  final commands = <int>[];
  final versionReads = <int>[];
  Process? _process;
  Socket? _socket;
  StreamIterator<Uint8List>? _input;
  StreamSubscription<String>? _stdout, _stderr;
  final _buffer = <int>[];
  int _transaction = 0;

  @override
  Future<void> open() async {
    try {
      final process = await Process.start(executable, [
        version.toRadixString(16),
        '$fault',
        appBase.toRadixString(16),
      ]);
      _process = process;
      final ready = Completer<int>();
      final errors = StringBuffer();
      _stderr = process.stderr.transform(utf8.decoder).listen(errors.write);
      _stdout = process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            if (line.startsWith('READY:') && !ready.isCompleted) {
              ready.complete(int.parse(line.substring(6)));
            }
          });
      unawaited(
        process.exitCode.then((code) {
          if (!ready.isCompleted) {
            ready.completeError(StateError('Harness exited $code: $errors'));
          }
        }),
      );
      final port = await ready.future.timeout(const Duration(seconds: 10));
      _socket = await Socket.connect(InternetAddress.loopbackIPv4, port);
      _input = StreamIterator<Uint8List>(_socket!);
    } catch (_) {
      // 服务只会在 open 成功后 close，因此启动失败必须由适配器自行回收进程。
      await close();
      rethrow;
    }
  }

  @override
  Future<void> close() async {
    await _input?.cancel();
    _socket?.destroy();
    final process = _process;
    _process = null;
    if (process != null) {
      try {
        process.stdin.writeln();
        await process.stdin.flush();
        await process.stdin.close();
      } catch (_) {}
      try {
        await process.exitCode.timeout(const Duration(seconds: 2));
      } on TimeoutException {
        // 仅清理此测试通过 Process.start 拥有的进程，禁止按名称批量结束进程。
        process.kill();
        await process.exitCode.timeout(const Duration(seconds: 2));
      }
    }
    await _stdout?.cancel();
    await _stderr?.cancel();
  }

  List<int> _word(int value) => [value >> 8 & 0xff, value & 0xff];

  Future<List<int>> _exchange(List<int> pdu) async {
    final transaction = _transaction++ & 0xffff;
    _socket!.add([
      ..._word(transaction),
      0,
      0,
      ..._word(pdu.length + 1),
      0x10,
      ...pdu,
    ]);
    await _socket!.flush();
    // TCP 的一次数据事件可以包含半帧或多帧，按 MBAP 长度取完整应答并保留余量。
    while (true) {
      if (_buffer.length >= 6) {
        final length = _buffer[4] << 8 | _buffer[5];
        if (length < 2 || length > 254) throw StateError('Invalid MBAP length');
        if (_buffer.length >= length + 6) {
          final frame = _buffer.sublist(0, length + 6);
          _buffer.removeRange(0, length + 6);
          if ((frame[0] << 8 | frame[1]) != transaction ||
              frame[2] != 0 ||
              frame[3] != 0 ||
              frame[6] != 0x10) {
            throw StateError('Unexpected Modbus TCP response');
          }
          if (frame[7] == (pdu[0] | 0x80)) {
            throw StateError('Modbus exception ${frame[8]}');
          }
          if (frame[7] != pdu[0]) throw StateError('Unexpected function');
          return frame.sublist(7);
        }
      }
      if (!await _input!.moveNext().timeout(const Duration(seconds: 5))) {
        throw StateError('Harness connection closed');
      }
      _buffer.addAll(_input!.current);
    }
  }

  @override
  Future<List<int>> read(int address, int count) async {
    reads.add(address);
    final pdu = await _exchange([3, ..._word(address), ..._word(count)]);
    if (pdu.length != 2 + count * 2 || pdu[1] != count * 2) {
      throw StateError('Invalid register response');
    }
    final values = [
      for (var i = 0; i < count; i++) pdu[2 + i * 2] << 8 | pdu[3 + i * 2],
    ];
    if (address == 0x0002) versionReads.add(values.single);
    return values;
  }

  @override
  Future<void> writeSingle(int address, int value) async {
    writes.add(address);
    commands.add(value);
    final request = [6, ..._word(address), ..._word(value)];
    expect(await _exchange(request), request);
  }

  @override
  Future<void> writeMultiple(int address, List<int> values) async {
    writes.add(address);
    final header = [0x10, ..._word(address), ..._word(values.length)];
    expect(
      await _exchange([
        ...header,
        values.length * 2,
        for (final value in values) ..._word(value),
      ]),
      header,
    );
  }
}

void main() {
  final harness = Platform.environment['INFIBO_OTA_HARNESS'];
  final skip = harness == null || !File(harness).existsSync()
      ? 'Set INFIBO_OTA_HARNESS to the built C# OtaProtocolHarness.exe'
      : false;
  final firmwarePath = Platform.environment['INFIBO_OTA_FIRMWARE_FILE'];
  final firmwareSkip = firmwarePath == null || !File(firmwarePath).existsSync()
      ? 'Set INFIBO_OTA_FIRMWARE_FILE to the v1.3.0 APP_OTA.bin'
      : skip;
  late Directory directory;
  late File file;
  late Uint8List image;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('ota-simulator-');
    image = Uint8List.fromList(List.generate(259, (i) => i & 0xff));
    ByteData.sublistView(image)
      ..setUint32(0, 0x20008000, Endian.little)
      ..setUint32(4, 0x08004009, Endian.little);
    file = await File(
      '${directory.path}/synthetic_APP_OTA.bin',
    ).writeAsBytes(image);
  });
  tearDown(() async => directory.delete(recursive: true));

  FirmwareRelease release(int version) => FirmwareRelease(
    version: 'synthetic',
    url: Uri.parse('https://example.test/synthetic_APP_OTA.bin'),
    size: image.length,
    sha256: sha256.convert(image).toString(),
    versionRegister: version,
    crc32: crc32(image),
  );
  FirmwareOtaService service(_SimulatorTransport transport) =>
      FirmwareOtaService(
        transport: transport,
        wait: (_) async {},
        installDelay: Duration.zero,
        verifyAttempts: 2,
      );

  test(
    'real simulator transfers actual v1.3.0 BIN using explicit simulated memory layout',
    () async {
      final firmware = File(firmwarePath!);
      final bytes = await firmware.readAsBytes();
      const expectedHash =
          'bdd9bf82beb2411c128ea80cc0c1ed89e7da35bbefee98bb622e313c712a820a';
      expect(bytes.length, 30372);
      expect(sha256.convert(bytes).toString(), expectedHash);
      final vectors = ByteData.sublistView(bytes);
      expect(vectors.getUint32(0, Endian.little), 0x20001760);
      expect(vectors.getUint32(4, Endian.little), 0x08010229);
      // 此包只在显式的模拟内存布局中联测；不代表已确认真实主板 APP_BASE。
      // 客户端仍必须从当前主板的能力寄存器读取地址并校验复位向量。
      final transport = _SimulatorTransport(
        harness!,
        0x0125,
        appBase: 0x08010000,
      );
      addTearDown(transport.close);
      await service(transport).upgrade(
        firmware,
        FirmwareRelease(
          version: '1.3.0',
          url: Uri.parse('https://example.test/real_v1_3_0_APP_OTA.bin'),
          size: bytes.length,
          sha256: expectedHash,
          versionRegister: 0x0130,
          crc32: crc32(bytes),
        ),
      );
      expect(transport.versionReads, [0x0125, 0x0130]);
      expect(transport.writes.toSet(), {0x0300, 0x0304, 0x030a, 0x0320});
      expect(
        transport.commands.where((command) => command == 0xa002),
        hasLength(238),
      );
      expect(transport.commands.last, 0xa004);
    },
    skip: firmwareSkip,
    timeout: const Timeout(Duration(minutes: 3)),
  );

  for (final versions in [
    (0x0125, 0x0130),
    (0x0130, 0x0131),
    (0x0130, 0x0130),
    (0x0130, 0x0125),
  ]) {
    final (current, target) = versions;
    final base = current == 0x0125 ? 0x0300 : 0x0380;
    test(
      'real simulator ${current.toRadixString(16)} -> ${target.toRadixString(16)}',
      () async {
        final transport = _SimulatorTransport(harness!, current);
        addTearDown(transport.close);
        await service(transport).upgrade(file, release(target));
        expect(transport.writes.toSet(), {
          base,
          base + 4,
          base + 0xa,
          base + 0x20,
        });
        expect(transport.reads.where((address) => address >= 0x0300).toSet(), {
          base + 1,
          if (current <= 0x0125) 0x0311,
        });
        expect(transport.commands, [
          0xa005,
          0xa001,
          0xa002,
          0xa002,
          0xa002,
          0xa003,
          0xa004,
        ]);
      },
      skip: skip,
    );
  }

  for (final fault in [1, 2]) {
    test(
      'real simulator fault $fault propagates board error without reboot',
      () async {
        final transport = _SimulatorTransport(harness!, 0x0130, fault: fault);
        addTearDown(transport.close);
        await expectLater(
          service(transport).upgrade(file, release(0x0131)),
          throwsA(
            isA<FirmwareOtaFailure>().having(
              (e) => e.errorCode,
              'board error',
              fault == 1 ? 3 : 4,
            ),
          ),
        );
        expect(transport.commands, isNot(contains(0xa004)));
        expect(transport.commands.last, 0xa005);
        expect(transport.writes.last, 0x0380);
        expect(transport.writes.every((address) => address >= 0x0380), isTrue);
      },
      skip: skip,
    );
  }

  test(
    'real simulator unchanged reboot version reports unknown and does not abort',
    () async {
      final transport = _SimulatorTransport(harness!, 0x0130, fault: 3);
      addTearDown(transport.close);
      await expectLater(
        service(transport).upgrade(file, release(0x0131)),
        throwsA(
          isA<OtaFailure>().having(
            (e) => e.key,
            'reason',
            'ota_firmware_unknown',
          ),
        ),
      );
      expect(transport.commands.last, 0xa004);
      expect(
        transport.commands.where((command) => command == 0xa005),
        hasLength(1),
      );
      expect(transport.writes.every((address) => address >= 0x0380), isTrue);
    },
    skip: skip,
  );
}
