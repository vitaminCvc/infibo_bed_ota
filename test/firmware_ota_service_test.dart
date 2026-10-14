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
    if (address == 6) return [system];
    if (address == 2) return [current];
    if (address == 0x0311)
      return [0x4000, 0x0800, maxSize & 65535, maxSize >> 16, 1];
    if (address == 0x0301) {
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
    if (address == 0x0304)
      imageHeader = List.of(values);
    else if (address == 0x030a) {
      chunkHeader = List.of(values);
      headers.add(List.of(values));
    } else if (address == 0x0320) {
      chunkData = List.of(values);
      packets.add(List.of(values));
    } else
      throw StateError('Unexpected write');
  }

  @override
  Future<void> writeSingle(int address, int value) async {
    expect(address, 0x0300);
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
