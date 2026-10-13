import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/api/modbus/hydrogen_runtime_recorder.dart';
import 'package:infibo_app/api/modbus/modbus_rtu_service.dart';
import 'package:infibo_app/pages/start/logic.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordingRuntimeService extends ModbusRtuService {
  RecordingRuntimeService({
    this.currentMinutes = 100,
    super.portName,
    super.slaveId,
  }) : super(maxRetries: 0, timeout: const Duration(milliseconds: 500));

  int currentMinutes;
  final reads = <int>[];
  final writes = <ModbusWriteCommand>[];
  final writeFailures = <Object>[];
  Completer<void>? pendingWrite;
  bool failWrite = false;
  bool failRead = false;
  bool applyBeforeError = false;

  @override
  Future<int> readHoldingRegister(int address) async {
    reads.add(address);
    if (failRead) throw TimeoutException('read timeout');
    return currentMinutes;
  }

  @override
  Future<void> writeSingleRegister({
    required int address,
    required int value,
    bool waitForResponse = true,
  }) async {
    writes.add(ModbusWriteCommand(address: address, value: value));
    if (failWrite) throw StateError('disconnected');
    await pendingWrite?.future;
    if (writeFailures.isNotEmpty) {
      if (applyBeforeError) currentMinutes = value;
      throw writeFailures.removeAt(0);
    }
    currentMinutes = value;
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  StartLogic session() => StartLogic()
    ..totalSeconds = 900
    ..customizedPhases = [
      ['hydrogen'],
      ['red'],
      ['hydrogen'],
    ];

  test(
    'countdown completion adds summary minutes to the board total',
    () async {
      final logic = session()..play();
      for (var second = 0; second < 900; second++) {
        logic.tick();
      }
      expect(logic.isRunning, isFalse);
      final summary = logic.actualWorkSecondsByDevice('');
      expect(summary['hydrogen'], 600);
      final service = RecordingRuntimeService();
      await HydrogenRuntimeRecorder(service: service).recordSession(summary);
      expect(service.writes, hasLength(1));
      expect(service.writes.single.address, 0x01E9);
      expect(service.reads, [0x01E9]);
      expect(service.writes.single.value, 110);
    },
  );

  test(
    'manual stop uses partial summary duration and excludes pauses',
    () async {
      final logic = session()..play();
      for (var second = 0; second < 630; second++) {
        logic.tick();
      }
      logic.pause();
      for (var second = 0; second < 60; second++) {
        logic.tick();
      }
      logic.play();
      logic.tick();
      logic.stop();
      final summary = logic.actualWorkSecondsByDevice('');
      expect(summary['hydrogen'], 331);
      final service = RecordingRuntimeService();
      await HydrogenRuntimeRecorder(service: service).recordSession(summary);
      expect(service.writes.single.address, 0x01E9);
      expect(service.reads, [0x01E9]);
      expect(service.writes.single.value, 106);
    },
  );

  for (final summary in <Map<String, int>>[
    {'red': 600},
    {'hydrogen': 0},
    {'hydrogen': -1},
  ]) {
    test(
      'no hydrogen runtime leaves device total unchanged: $summary',
      () async {
        final service = RecordingRuntimeService();
        await HydrogenRuntimeRecorder(service: service).recordSession(summary);
        expect(service.writes, isEmpty);
        expect(service.reads, isEmpty);
      },
    );
  }

  test('overlapping and repeated completion records a session once', () async {
    final service = RecordingRuntimeService()..pendingWrite = Completer<void>();
    final recorder = HydrogenRuntimeRecorder(service: service);
    final first = recorder.recordSession({'hydrogen': 60});
    final second = recorder.recordSession({'hydrogen': 60});
    await Future<void>.delayed(Duration.zero);
    expect(service.writes, hasLength(1));
    service.pendingWrite!.complete();
    await Future.wait([first, second]);
    await recorder.recordSession({'hydrogen': 60});
    expect(service.writes, hasLength(1));
    expect(service.reads, [0x01E9]);
    expect(service.writes.single.value, 101);
  });

  for (final entry in {1: 1, 60: 1, 61: 2, 3932100: 65535}.entries) {
    test('writes ${entry.key} seconds as ${entry.value} minutes', () async {
      final service = RecordingRuntimeService(currentMinutes: 0);
      await HydrogenRuntimeRecorder(
        service: service,
      ).recordSession({'hydrogen': entry.key});
      expect(service.writes, hasLength(1));
      expect(service.writes.single.address, 0x01E9);
      expect(service.writes.single.value, entry.value);
    });
  }

  test('failed acknowledgement never submits the session twice', () async {
    final service = RecordingRuntimeService()..failWrite = true;
    final recorder = HydrogenRuntimeRecorder(service: service);
    await expectLater(
      recorder.recordSession({'hydrogen': 60}),
      throwsStateError,
    );
    await expectLater(
      recorder.recordSession({'hydrogen': 60}),
      throwsStateError,
    );
    expect(service.writes, hasLength(1));
  });

  test(
    'out of range duration is rejected instead of wrapping the register',
    () async {
      final service = RecordingRuntimeService();
      await expectLater(
        HydrogenRuntimeRecorder(
          service: service,
        ).recordSession({'hydrogen': 3932101}),
        throwsRangeError,
      );
      expect(service.writes, isEmpty);
    },
  );

  test(
    'a new session uses the larger confirmed App total when board is lower',
    () async {
      final first = RecordingRuntimeService();
      await HydrogenRuntimeRecorder(
        service: first,
      ).recordSession({'hydrogen': 600});
      expect(first.currentMinutes, 110);

      final next = RecordingRuntimeService(currentMinutes: 90);
      await HydrogenRuntimeRecorder(
        service: next,
      ).recordSession({'hydrogen': 120});
      expect(next.writes.single.value, 112);
    },
  );

  test(
    'a higher board total replaces the older confirmed App baseline',
    () async {
      await HydrogenRuntimeRecorder(
        service: RecordingRuntimeService(),
      ).recordSession({'hydrogen': 600});
      final next = RecordingRuntimeService(currentMinutes: 150);
      await HydrogenRuntimeRecorder(
        service: next,
      ).recordSession({'hydrogen': 180});
      expect(next.writes.single.value, 153);
      final later = RecordingRuntimeService(currentMinutes: 120);
      await HydrogenRuntimeRecorder(
        service: later,
      ).recordSession({'hydrogen': 60});
      expect(later.writes.single.value, 154);
    },
  );

  test(
    'read failure performs no writes and drops this session duration',
    () async {
      final failed = RecordingRuntimeService()..failRead = true;
      final recorder = HydrogenRuntimeRecorder(service: failed);
      await expectLater(
        recorder.recordSession({'hydrogen': 300}),
        throwsA(isA<TimeoutException>()),
      );
      expect(failed.reads, [0x01E9]);
      expect(failed.writes, isEmpty);

      final next = RecordingRuntimeService();
      await HydrogenRuntimeRecorder(
        service: next,
      ).recordSession({'hydrogen': 60});
      expect(next.writes.single.value, 101);
    },
  );

  test(
    'acknowledgement loss retries the exact same target without rereading',
    () async {
      final service = RecordingRuntimeService()
        ..applyBeforeError = true
        ..writeFailures.add(TimeoutException('write timeout'));
      await HydrogenRuntimeRecorder(
        service: service,
      ).recordSession({'hydrogen': 360});
      expect(service.reads, [0x01E9]);
      expect(service.writes.map((write) => write.value), [106, 106]);
      expect(service.currentMinutes, 106);
      final later = RecordingRuntimeService(currentMinutes: 90);
      await HydrogenRuntimeRecorder(
        service: later,
      ).recordSession({'hydrogen': 60});
      expect(later.writes.single.value, 107);
    },
  );

  testWidgets('native timeout retries once after 200 milliseconds', (
    tester,
  ) async {
    final service = RecordingRuntimeService()
      ..writeFailures.add(
        const ModbusRtuException('Serial read timeout after 500ms.'),
      );
    final completion = HydrogenRuntimeRecorder(
      service: service,
    ).recordSession({'hydrogen': 360});
    await tester.pump();
    expect(service.writes.map((write) => write.value), [106]);
    await tester.pump(const Duration(milliseconds: 199));
    expect(service.writes, hasLength(1));
    await tester.pump(const Duration(milliseconds: 1));
    await completion;
    expect(service.writes.map((write) => write.value), [106, 106]);
  });

  test(
    'two timeouts stop retrying and never carry duration into next session',
    () async {
      final service = RecordingRuntimeService()
        ..writeFailures.addAll([
          TimeoutException('write timeout'),
          TimeoutException('write timeout'),
        ]);
      final recorder = HydrogenRuntimeRecorder(service: service);
      await expectLater(
        recorder.recordSession({'hydrogen': 300}),
        throwsA(isA<TimeoutException>()),
      );
      await expectLater(
        recorder.recordSession({'hydrogen': 300}),
        throwsA(isA<TimeoutException>()),
      );
      expect(service.reads, [0x01E9]);
      expect(service.writes.map((write) => write.value), [105, 105]);

      final next = RecordingRuntimeService();
      await HydrogenRuntimeRecorder(
        service: next,
      ).recordSession({'hydrogen': 60});
      expect(next.writes.single.value, 101);
    },
  );

  test(
    'a successfully read board baseline is kept even if the write fails',
    () async {
      final failed = RecordingRuntimeService(currentMinutes: 150)
        ..failWrite = true;
      await expectLater(
        HydrogenRuntimeRecorder(
          service: failed,
        ).recordSession({'hydrogen': 300}),
        throwsStateError,
      );
      final next = RecordingRuntimeService(currentMinutes: 140);
      await HydrogenRuntimeRecorder(
        service: next,
      ).recordSession({'hydrogen': 60});
      expect(next.writes.single.value, 151);
    },
  );

  test(
    'confirmed totals are kept separately for different board connections',
    () async {
      await HydrogenRuntimeRecorder(
        service: RecordingRuntimeService(),
      ).recordSession({'hydrogen': 600});
      final other = RecordingRuntimeService(currentMinutes: 2, slaveId: 17);
      await HydrogenRuntimeRecorder(
        service: other,
      ).recordSession({'hydrogen': 60});
      expect(other.writes.single.value, 3);
    },
  );

  test('overlapping sessions on one board preserve both durations', () async {
    final service = RecordingRuntimeService()..pendingWrite = Completer<void>();
    final first = HydrogenRuntimeRecorder(
      service: service,
    ).recordSession({'hydrogen': 360});
    await Future<void>.delayed(Duration.zero);
    final second = HydrogenRuntimeRecorder(
      service: service,
    ).recordSession({'hydrogen': 60});
    await Future<void>.delayed(Duration.zero);
    final readsBeforeAcknowledgement = service.reads.length;
    service.pendingWrite!.complete();
    await Future.wait([first, second]);
    expect(readsBeforeAcknowledgement, 1);
    expect(service.writes.map((write) => write.value), [106, 107]);
    expect(service.currentMinutes, 107);
  });

  for (final raw in [-1, 65536]) {
    test('invalid board reading $raw is rejected without writing', () async {
      final service = RecordingRuntimeService(currentMinutes: raw);
      await expectLater(
        HydrogenRuntimeRecorder(
          service: service,
        ).recordSession({'hydrogen': 60}),
        throwsRangeError,
      );
      expect(service.writes, isEmpty);
      expect(service.reads, [0x01E9]);
    });
  }
}
