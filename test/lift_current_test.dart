/* 原 0x0017 电流测试随功能一起注释停用。
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/api/modbus/modbus_rtu_service.dart';
import 'package:infibo_app/pages/joystick/ui.dart';

class FakeLiftService extends ModbusRtuService {
  final List<int> reads = [];
  int status = 1;
  bool failCurrent = false;
  Completer<int>? pendingCurrent;

  @override
  Future<int> readHoldingRegister(int address) async {
    reads.add(address);
    if (address == 0x0011) return status;
    if (failCurrent) throw StateError('current unavailable');
    return pendingCurrent?.future ?? Future.value(321);
  }

  @override
  Future<void> sendCommandQueue(List<ModbusWriteCommand> commands) async {}
}

void main() {
  setUp(() => JoystickCommandBus.instance.reset());

  for (final y in [45.0, 140.0]) {
    testWidgets('hold at y=$y reads only after debounce and stops on release', (
      tester,
    ) async {
      final service = FakeLiftService();
      final values = <int?>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JoystickControl(
              modbusService: service,
              onLiftCurrentChanged: values.add,
            ),
          ),
        ),
      );
      final origin = tester.getTopLeft(find.byType(JoystickControl));
      final gesture = await tester.startGesture(origin + Offset(140, y));
      await tester.pump(const Duration(milliseconds: 200));
      expect(service.reads, isEmpty);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 500));
      expect(service.reads, [0x0017]);
      expect(values, [321]);
      await gesture.up();
      await tester.pump(const Duration(seconds: 2));
      expect(service.reads, [0x0017]);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('other pages without a current subscriber only read status', (
    tester,
  ) async {
    final service = FakeLiftService();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: JoystickControl(modbusService: service)),
      ),
    );
    JoystickCommandBus.instance.lockLeftTop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(service.reads, [0x0011]);
    await tester.pumpWidget(const SizedBox());
  });

  Future<void> mount(
    WidgetTester tester,
    FakeLiftService service,
    List<int?> values,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JoystickControl(
            modbusService: service,
            onLiftCurrentChanged: values.add,
          ),
        ),
      ),
    );
    JoystickCommandBus.instance.lockLeftBottom();
    await tester.pump();
  }

  testWidgets('reads raw current while moving and stops at idle', (
    tester,
  ) async {
    final service = FakeLiftService();
    final values = <int?>[];
    await mount(tester, service, values);
    await tester.pump(const Duration(milliseconds: 500));
    expect(service.reads, [0x0011, 0x0017]);
    expect(values, [321]);
    service.status = 0;
    await tester.pump(const Duration(milliseconds: 500));
    final count = service.reads.length;
    await tester.pump(const Duration(seconds: 2));
    expect(service.reads.length, count);
    expect(
      JoystickCommandBus.instance.lastLiftCommand,
      JoystickExternalCommand.reset,
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('current failure does not prevent idle detection', (
    tester,
  ) async {
    final service = FakeLiftService()..failCurrent = true;
    final values = <int?>[];
    await mount(tester, service, values);
    await tester.pump(const Duration(milliseconds: 500));
    expect(values, [null]);
    service.status = 0;
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      JoystickCommandBus.instance.lastLiftCommand,
      JoystickExternalCommand.reset,
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('slow read cannot overlap or notify after disposal', (
    tester,
  ) async {
    final service = FakeLiftService()..pendingCurrent = Completer<int>();
    final values = <int?>[];
    await mount(tester, service, values);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 2));
    expect(service.reads, [0x0011, 0x0017]);
    await tester.pumpWidget(const SizedBox());
    service.pendingCurrent!.complete(456);
    await tester.pump();
    expect(values, isEmpty);
    expect(tester.takeException(), isNull);
  });
}

*/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/api/modbus/modbus_rtu_service.dart';
import 'package:infibo_app/pages/joystick/ui.dart';

class StatusOnlyService extends ModbusRtuService {
  final reads = <int>[];
  final writes = <int>[];
  int status = 1;

  @override
  Future<int> readHoldingRegister(int address) async {
    reads.add(address);
    return status;
  }

  @override
  Future<void> sendCommandQueue(List<ModbusWriteCommand> commands) async {
    writes.addAll(commands.map((command) => command.value));
  }
}

void main() {
  setUp(() => JoystickCommandBus.instance.reset());

  testWidgets(
    'automatic lift keeps polling status and control without reading current',
    (tester) async {
      final service = StatusOnlyService();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: JoystickControl(modbusService: service)),
        ),
      );
      JoystickCommandBus.instance.lockLeftBottom();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(service.reads, [0x0011, 0x0010]);
      service.status = 0;
      await tester.pump(const Duration(milliseconds: 500));
      final idleReads = service.reads.length;
      await tester.pump(const Duration(seconds: 2));
      expect(service.reads.length, greaterThan(idleReads));
      expect(service.reads, everyElement(isIn([0x0011, 0x0010])));
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('manual lift sends move and stop without polling current', (
    tester,
  ) async {
    final service = StatusOnlyService();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: JoystickControl(modbusService: service)),
      ),
    );
    final origin = tester.getTopLeft(find.byType(JoystickControl));
    final gesture = await tester.startGesture(origin + const Offset(140, 45));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 2));
    expect(service.writes, [1]);
    expect(service.reads, isNotEmpty);
    expect(service.reads, everyElement(0x0011));
    await gesture.up();
    await tester.pump();
    expect(service.writes, [1, 0]);
    await tester.pumpWidget(const SizedBox());
  });
}
