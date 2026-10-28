import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/ota/ota_manifest.dart';
import 'package:infibo_app/ota/ota_service.dart';
import 'package:infibo_app/ota/ota_checksums.dart';
import 'package:infibo_app/ota/firmware_ota_service.dart';

class FakeBoard implements FirmwareTransport {
  int state = 0,
      error = 0,
      progress = 0,
      current = 0x0124,
      system = 0,
      maxSize = 32768;
  bool opened = false,
      closed = false,
      loseWriteAck = false,
      dropWrite = false,
      rebootAckLost = false,
      neverBoot = false,
      finishError = false;
  // 记录真实总线地址，避免只核对命令值而漏掉新板误写旧 WBVV 地址的回归。
  bool capabilitiesUnavailable = false;
  List<int>? capabilities;
  final readAddresses = <int>[];
  final writeAddresses = <int>[];
  int get otaBase => current >= 0x0130 ? 0x0380 : 0x0300;
  final commands = <int>[];
  final headers = <List<int>>[];
  final packets = <List<int>>[];
  List<int> imageHeader = [], chunkHeader = [], chunkData = [];
  @override
  Future<void> open() async {
    opened = true;
  }

  @override
  Future<void> close() async {
    closed = true;
  }

  @override
  Future<List<int>> read(int address, int count) async {
    readAddresses.add(address);
    if (address == 6) return [system];
    if (address == 2) return [current];
    if (address == otaBase + 0x11) {
      if (capabilitiesUnavailable) throw StateError('capabilities unavailable');
      if (capabilities != null) return capabilities!;
      return [0x4000, 0x0800, maxSize & 65535, maxSize >> 16, 1];
    }
    if (address == otaBase + 1) {
      final value = List<int>.filled(count, 0);
      value[0] = state;
      value[1] = error;
      value[14] = progress & 65535;
      value[15] = progress >> 16;
      return value;
    }
    throw StateError('Unexpected read $address');
  }

  @override
  Future<void> writeMultiple(int address, List<int> values) async {
    writeAddresses.add(address);
    if (address == otaBase + 4) {
      imageHeader = List.of(values);
    } else if (address == otaBase + 0x0a) {
      chunkHeader = List.of(values);
      headers.add(List.of(values));
    } else if (address == otaBase + 0x20) {
      chunkData = List.of(values);
      packets.add(List.of(values));
    } else {
      throw StateError('Unexpected write');
    }
  }

  @override
  Future<void> writeSingle(int address, int value) async {
    writeAddresses.add(address);
    expect(address, otaBase);
    commands.add(value);
    if (value == 0xa005) {
      state = 0;
      error = 0;
      progress = 0;
    }
    if (value == 0xa001) {
      state = 1;
    }
    if (value == 0xa002) {
      if (dropWrite) {
        dropWrite = false;
        throw TimeoutException('not received');
      }
      final size = imageHeader[0] | imageHeader[1] << 16;
      final offset = chunkHeader[0] | chunkHeader[1] << 16;
      expect(offset, progress);
      expect(chunkData.length, chunkHeader[2]);
      expect(chunkData.length, lessThanOrEqualTo(64));
      final bytes = <int>[
        for (final word in chunkData) ...[word >> 8, word & 255],
      ];
      final real = bytes.take((size - offset).clamp(0, bytes.length)).toList();
      expect(crc32(real), chunkHeader[3] | chunkHeader[4] << 16);
      progress += real.length;
      if (loseWriteAck) {
        loseWriteAck = false;
        throw TimeoutException('reply lost');
      }
    }
    if (value == 0xa003) {
      state = finishError ? 3 : 2;
      error = finishError ? 3 : 0;
    }
    if (value == 0xa004) {
      if (!neverBoot) current = imageHeader[4];
      if (rebootAckLost) throw TimeoutException('reset before reply');
    }
  }
}

void main() {
  late Directory directory;
  late File file;
  late FirmwareRelease release;
  late FakeBoard board;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('board-ota-test-');
    file = File('${directory.path}/image.bin');
    final bytes = Uint8List.fromList(List.generate(259, (i) => i & 255));
    final view = ByteData.sublistView(bytes);
    view.setUint32(0, 0x20008000, Endian.little);
    view.setUint32(4, 0x08004009, Endian.little);
    await file.writeAsBytes(bytes);
    release = FirmwareRelease(
      version: '1.2.5',
      url: Uri.parse('https://example.test/main_APP_OTA.bin'),
      size: bytes.length,
      sha256: sha256.convert(bytes).toString(),
      versionRegister: 0x0125,
      crc32: crc32(bytes),
    );
    board = FakeBoard();
  });
  tearDown(() async => directory.delete(recursive: true));
  FirmwareOtaService service() => FirmwareOtaService(
    transport: board,
    wait: (_) async {},
    installDelay: Duration.zero,
    verifyAttempts: 2,
  );
  FirmwareRelease target(int version) => FirmwareRelease(
    version: 'test',
    url: release.url,
    size: release.size,
    sha256: release.sha256,
    versionRegister: version,
    crc32: release.crc32,
  );

  test(
    'current 1.2.5 upgrading to 1.3.0 locks legacy addresses until reboot',
    () async {
      board.current = 0x0125;
      await service().upgrade(file, target(0x0130));
      expect(board.current, 0x0130);
      expect(board.readAddresses.where((address) => address >= 0x0300), [
        0x0311,
        0x0301,
        0x0301,
        0x0301,
        0x0301,
        0x0301,
      ]);
      expect(board.writeAddresses.toSet(), {0x0300, 0x0304, 0x030a, 0x0320});
    },
  );

  test('current 1.3.0 uses relocated addresses for all operations', () async {
    board.current = 0x0130;
    await service().upgrade(file, target(0x0131));
    expect(board.current, 0x0131);
    expect(board.readAddresses.where((address) => address >= 0x0300), [
      0x0381,
      0x0381,
      0x0381,
      0x0381,
      0x0381,
    ]);
    expect(board.writeAddresses.toSet(), {0x0380, 0x0384, 0x038a, 0x03a0});
    expect(board.commands.last, 0xa004);
  });

  for (final version in [0x0130, 0x0125]) {
    test(
      'administrator target ${version.toRadixString(16)} can reinstall or downgrade',
      () async {
        board.current = 0x0130;
        final phases = <String>[];
        await service().upgrade(file, target(version), onPhase: phases.add);
        expect(board.current, version);
        // 地址由刷写前运行的版本决定，降级到旧固件也不能中途改写旧区。
        expect(board.writeAddresses.toSet(), {0x0380, 0x0384, 0x038a, 0x03a0});
        expect(board.commands.last, 0xa004);
        expect(
          phases.last,
          version == 0x0130
              ? 'ota_board_reinstall_unverified'
              : 'ota_board_success',
        );
      },
    );
  }

  test(
    'v1.3 guide needs no undocumented capability read or protocol word',
    () async {
      board.current = 0x0130;
      board.capabilitiesUnavailable = true;
      await service().upgrade(file, target(0x0131));
      expect(board.current, 0x0131);
      expect(board.readAddresses.toSet(), {0x0006, 0x0002, 0x0381});
      expect(board.writeAddresses.toSet(), {0x0380, 0x0384, 0x038a, 0x03a0});
    },
  );

  test('new-board failure cleanup ABORT stays on relocated control', () async {
    board.current = 0x0130;
    board.finishError = true;
    await expectLater(
      service().upgrade(file, target(0x0131)),
      throwsA(
        isA<FirmwareOtaFailure>().having((e) => e.errorCode, 'board error', 3),
      ),
    );
    expect(board.commands.last, 0xa005);
    expect(board.writeAddresses.last, 0x0380);
    expect(board.writeAddresses.toSet(), {0x0380, 0x0384, 0x038a, 0x03a0});
    expect(board.closed, isTrue);
  });

  for (var current = 0x0126; current <= 0x012f; current++) {
    test(
      'unmapped current version ${current.toRadixString(16)} rejects without writes',
      () async {
        board.current = current;
        await expectLater(
          service().upgrade(file, target(0x0130)),
          throwsA(
            isA<OtaFailure>().having(
              (e) => e.key,
              'reason',
              'ota_protocol_unsupported',
            ),
          ),
        );
        expect(board.writeAddresses, isEmpty);
        expect(board.readAddresses, [0x0006, 0x0002]);
        expect(board.closed, isTrue);
      },
    );
  }

  final invalidCapabilities = <String, List<int>>{
    'short response': [0x4000, 0x0800],
    'unsupported protocol': [0x4000, 0x0800, 32768, 0, 0],
    'zero app base': [0, 0, 32768, 0, 1],
    'zero capacity': [0x4000, 0x0800, 0, 0, 1],
  };
  for (final entry in invalidCapabilities.entries) {
    test(
      'legacy documented capabilities ${entry.key} refuses all writes',
      () async {
        board.current = 0x0124;
        board.capabilities = entry.value;
        await expectLater(
          service().upgrade(file, target(0x0125)),
          throwsA(isA<OtaFailure>()),
        );
        expect(board.readAddresses, [0x0006, 0x0002, 0x0311]);
        expect(board.writeAddresses, isEmpty);
        expect(board.closed, isTrue);
      },
    );
  }

  test(
    'unavailable documented legacy capabilities rejects before writes',
    () async {
      board.current = 0x0124;
      board.capabilitiesUnavailable = true;
      await expectLater(
        service().upgrade(file, target(0x0125)),
        throwsA(
          isA<OtaFailure>().having(
            (e) => e.key,
            'reason',
            'ota_protocol_unsupported',
          ),
        ),
      );
      expect(board.readAddresses, [0x0006, 0x0002, 0x0311]);
      expect(board.writeAddresses, isEmpty);
      expect(board.closed, isTrue);
    },
  );

  test(
    'manifest size mismatch rejects before opening or writing transport',
    () async {
      final mismatched = FirmwareRelease(
        version: release.version,
        url: release.url,
        size: release.size + 1,
        sha256: release.sha256,
        versionRegister: release.versionRegister,
        crc32: release.crc32,
      );
      await expectLater(
        service().upgrade(file, mismatched),
        throwsA(
          isA<OtaFailure>().having((e) => e.key, 'reason', 'ota_file_invalid'),
        ),
      );
      expect(board.opened, isFalse);
      expect(board.readAddresses, isEmpty);
      expect(board.writeAddresses, isEmpty);
    },
  );

  test('standard CRC32 and Modbus CRC16 test vectors', () {
    expect(crc32('123456789'.codeUnits), 0xcbf43926);
    expect(modbusCrc16([1, 3, 0, 0, 0, 10]), 0xcdc5);
  });
  test(
    'transfers sequential chunks, odd final byte padding and confirms boot version',
    () async {
      await service().upgrade(file, release);
      expect(board.commands, [
        0xa005,
        0xa001,
        0xa002,
        0xa002,
        0xa002,
        0xa003,
        0xa004,
      ]);
      expect(board.headers.map((e) => e[0]), [0, 128, 256]);
      expect(board.packets.last.last, 0x02ff);
      expect(board.closed, isTrue);
    },
  );
  test(
    'lost WRITE response is resolved by progress without duplicate submission',
    () async {
      board.loseWriteAck = true;
      await service().upgrade(file, release);
      expect(board.commands.where((c) => c == 0xa002).length, 3);
    },
  );
  test('unreceived chunk is retried after querying progress', () async {
    board.dropWrite = true;
    await service().upgrade(file, release);
    expect(board.commands.where((c) => c == 0xa002).length, 4);
  });
  test(
    'reboot response timeout is accepted only after target version is read',
    () async {
      board.rebootAckLost = true;
      await service().upgrade(file, release);
      expect(board.current, 0x0125);
    },
  );
  test(
    'unknown boot result does not ABORT an installation already started',
    () async {
      board.neverBoot = true;
      await expectLater(
        service().upgrade(file, release),
        throwsA(
          isA<OtaFailure>().having(
            (e) => e.key,
            'reason',
            'ota_firmware_unknown',
          ),
        ),
      );
      expect(board.commands.last, 0xa004);
      expect(board.closed, isTrue);
    },
  );
  test(
    'running device and oversized image are rejected before flash commands',
    () async {
      board.system = 1;
      await expectLater(
        service().upgrade(file, release),
        throwsA(isA<OtaFailure>()),
      );
      expect(board.commands, isEmpty);
      board = FakeBoard()..maxSize = 10;
      await expectLater(
        service().upgrade(file, release),
        throwsA(isA<OtaFailure>()),
      );
      expect(board.commands, isEmpty);
    },
  );
  test('finish CRC error never requests reboot', () async {
    board.finishError = true;
    await expectLater(
      service().upgrade(file, release),
      throwsA(
        isA<FirmwareOtaFailure>().having((e) => e.errorCode, 'board error', 3),
      ),
    );
    expect(board.commands, isNot(contains(0xa004)));
  });
  test(
    'cancel during transfer aborts receive session and releases transport',
    () async {
      final token = CancelToken();
      await expectLater(
        service().upgrade(
          file,
          release,
          cancelToken: token,
          onProgress: (progress) {
            token.cancel();
          },
        ),
        throwsA(
          isA<OtaFailure>().having((e) => e.key, 'reason', 'ota_cancelled'),
        ),
      );
      expect(board.commands.last, 0xa005);
      expect(board.closed, isTrue);
    },
  );
}
