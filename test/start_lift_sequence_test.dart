import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/api/modbus/modbus_rtu_service.dart';
import 'package:infibo_app/pages/start/ui.dart';

class RecordingLiftService extends ModbusRtuService {
  final events = <String>[];
  final statuses = <int>[1, 0];
  int? failWrite;
  bool failRead = false;
  int readFailuresRemaining = 0;
  Completer<int>? pendingStatus;
  Completer<void>? pendingLightOff;

  @override
  Future<void> sendCommandQueue(List<ModbusWriteCommand> commands) async {
    for (final command in commands) {
      events.add('write:${command.address}:${command.value}');
      if (command.address == failWrite) throw StateError('write failed');
      if (command.address == 0x0012 && command.value == 0) {
        await pendingLightOff?.future;
      }
    }
  }

  @override
  Future<int> readHoldingRegister(int address) async {
    events.add('read:$address');
    if (failRead || readFailuresRemaining-- > 0) {
      throw StateError('read failed');
    }
    return pendingStatus == null ? statuses.removeAt(0) : pendingStatus!.future;
  }
}

void main() {
  StartLiftSequence sequence(
    RecordingLiftService service,
    bool britain, {
    bool Function()? isActive,
  }) => StartLiftSequence(
    service: service,
    isBritain: britain,
    isActive: isActive ?? () => true,
    delay: (duration) async =>
        service.events.add('delay:${duration.inMilliseconds}'),
  );

  test(
    'start replays all hydrogen parameters immediately before activation',
    () {
      const commands = <ModbusWriteCommand>[
        ModbusWriteCommand(address: 0x0064, value: 1),
        ModbusWriteCommand(address: 0x01C0, value: 1),
        ModbusWriteCommand(address: 0x01C1, value: 0),
        ModbusWriteCommand(address: 0x01C2, value: 80),
        ModbusWriteCommand(address: 0x01C3, value: 0),
        ModbusWriteCommand(address: 0x01C4, value: 0),
        ModbusWriteCommand(address: 0x01D0, value: 1),
        ModbusWriteCommand(address: 0x01D1, value: 1),
      ];

      final replay = StartHydrogenCommandReplay.parametersFrom(commands);

      expect(
        replay.map((command) => '${command.address}:${command.value}').toList(),
        <String>['448:1', '449:0', '450:80', '451:0', '452:0'],
      );
    },
  );

  test('Britain closes light before descending', () async {
    final service = RecordingLiftService();
    expect(await sequence(service, true).descend(), isTrue);
    expect(service.events, ['write:18:0', 'write:16:4']);
  });

  test('failed light off prevents descent', () async {
    final service = RecordingLiftService()..failWrite = 0x0012;
    await expectLater(sequence(service, true).descend(), throwsStateError);
    expect(service.events, ['write:18:0']);
  });

  test('descent waits for light off acknowledgement', () async {
    final service = RecordingLiftService()..pendingLightOff = Completer<void>();
    final completion = sequence(service, true).descend();
    await Future<void>.delayed(Duration.zero);
    expect(service.events, ['write:18:0']);
    service.pendingLightOff!.complete();
    expect(await completion, isTrue);
    expect(service.events, ['write:18:0', 'write:16:4']);
  });

  test(
    'Britain reaches summary without sending an ambient light command',
    () async {
      final service = RecordingLiftService()..failWrite = 0x0012;
      expect(await sequence(service, true).riseAfterStop(), isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(service.events, isNot(contains('write:18:1')));
    },
  );

  test(
    'Britain returns after rise acknowledgement and resets joystick later',
    () async {
      final status = Completer<int>();
      final service = RecordingLiftService()..pendingStatus = status;
      bool returned = false;

      final completion = sequence(service, true).riseAfterStop().then((value) {
        returned = value;
      });
      await Future<void>.delayed(Duration.zero);

      expect(returned, isTrue);
      expect(service.events, ['write:16:3', 'read:17']);

      status.complete(0);
      await completion;
      await Future<void>.delayed(Duration.zero);

      expect(service.events, ['write:16:3', 'read:17']);
    },
  );

  test('Britain keeps polling after the start page becomes inactive', () async {
    var active = true;
    final status = Completer<int>();
    final service = RecordingLiftService()..pendingStatus = status;
    final completion = sequence(
      service,
      true,
      isActive: () => active,
    ).riseAfterStop();

    expect(await completion, isTrue);
    active = false;
    status.complete(0);
    await Future<void>.delayed(Duration.zero);

    expect(service.events, ['write:16:3', 'read:17']);
  });

  test(
    'Britain polls nonzero status until zero without turning on light',
    () async {
      final service = RecordingLiftService();
      expect(await sequence(service, true).riseAfterStop(), isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(service.events, ['write:16:3', 'read:17', 'delay:500', 'read:17']);
    },
  );

  test('Britain continues polling after a status read failure', () async {
    final service = RecordingLiftService()..readFailuresRemaining = 1;
    service.statuses
      ..clear()
      ..add(0);

    expect(await sequence(service, true).riseAfterStop(), isTrue);
    await Future<void>.delayed(Duration.zero);

    expect(service.events, ['write:16:3', 'read:17', 'delay:500', 'read:17']);
  });

  test('failed rise prevents Britain summary navigation and light', () async {
    final service = RecordingLiftService()..failWrite = 0x0010;
    await expectLater(
      sequence(service, true).riseAfterStop(),
      throwsStateError,
    );
    expect(service.events, isNot(contains('write:18:1')));
  });

  test('other versions descend without changing light first', () async {
    final service = RecordingLiftService();
    await sequence(service, false).descend();
    expect(service.events, ['write:16:4']);
  });

  test(
    'other versions rise without a two second delay or light command',
    () async {
      final service = RecordingLiftService();
      await sequence(service, false).riseAfterStop();
      expect(service.events, ['write:16:3']);
    },
  );

  test('other versions do not turn on light after rise failure', () async {
    final service = RecordingLiftService()..failWrite = 0x0010;
    await sequence(service, false).riseAfterStop();
    expect(service.events, ['write:16:3']);
  });
}
