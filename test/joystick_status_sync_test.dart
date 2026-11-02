import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/api/modbus/modbus_rtu_service.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/pages/joystick/ui.dart';
import 'package:infibo_app/pages/start/ui.dart';
import 'package:infibo_app/routes/route_observer.dart';

class LiftStatusService extends ModbusRtuService {
  int status = 0;
  int? control;
  bool failRead = false;
  bool failWrite = false;
  Completer<int>? pendingRead;
  Completer<void>? pendingWrite;
  final reads = <int>[];
  final writes = <(int, int)>[];

  @override
  Future<int> readHoldingRegister(int address) async {
    reads.add(address);
    if (address == 0x0010) {
      return control ?? status;
    }
    if (failRead) throw StateError('status unavailable');
    return pendingRead?.future ?? status;
  }

  @override
  Future<void> sendCommandQueue(List<ModbusWriteCommand> commands) async {
    writes.addAll(commands.map((command) => (command.address, command.value)));
    await pendingWrite?.future;
    if (failWrite) throw StateError('write failed');
    if (control != null) control = commands.last.value;
  }
}

Finder liftImage(String asset) => find.byWidgetPredicate(
  (widget) => widget is Image && widget.image == AssetImage(asset),
);

Future<void> poll(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump();
}

Future<void> mountLift(
  WidgetTester tester,
  LiftStatusService service, {
  GlobalKey<NavigatorState>? navigatorKey,
}) => tester.pumpWidget(
  MaterialApp(
    navigatorKey: navigatorKey,
    navigatorObservers: [appRouteObserver],
    home: Scaffold(body: JoystickControl(modbusService: service)),
  ),
);

void main() {
  setUp(() => JoystickCommandBus.instance.reset());

  testWidgets(
    'stop queued before rise acknowledgement cancels its old background poll',
    (tester) async {
      final pending = Completer<void>();
      final service = LiftStatusService()
        ..status = 3
        ..control = 4
        ..pendingWrite = pending;
      await mountLift(tester, service);
      final rise = StartLiftSequence(
        service: service,
        isBritain: true,
        isActive: () => true,
      ).riseAfterStop();
      await tester.pump();
      final bus = JoystickCommandBus.instance;
      bus.noteLocalCommand(0);
      final stop = bus.runLiftWrite(
        () => service.sendCommandQueue([
          const ModbusWriteCommand(address: 0x0010, value: 0),
        ]),
      );
      pending.complete();
      expect(await rise, isFalse);
      await stop;
      await tester.pump();
      expect(service.reads, isEmpty);
      await poll(tester);
      expect(service.writes, [(0x0010, 3), (0x0010, 0)]);
      await tester.pumpWidget(const SizedBox());
    },
  );

  for (final (status, initialControl) in [(3, 4), (4, 3), (0, 4)]) {
    testWidgets(
      'status $status updates display without rewriting control $initialControl',
      (tester) async {
        final service = LiftStatusService()
          ..status = status
          ..control = initialControl;
        await mountLift(tester, service);
        await poll(tester);
        await poll(tester);
        expect(service.control, initialControl);
        expect(service.writes, isEmpty);
        expect(service.reads, [0x0011, 0x0011]);
        if (status == 0) {
          expect(find.byType(Image), findsOneWidget);
        } else {
          expect(
            liftImage(
              status == 3 ? Assets.joystickLeftTop : Assets.joystickLeftBottom,
            ),
            findsOneWidget,
          );
        }
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  testWidgets(
    'legacy manual status cannot replace an automatic light or latch a manual light',
    (tester) async {
      final service = LiftStatusService()..status = 3;
      await mountLift(tester, service);
      await poll(tester);
      for (final status in [1, 2]) {
        service.status = status;
        await poll(tester);
        expect(liftImage(Assets.joystickLeftTop), findsOneWidget);
        expect(liftImage(Assets.joystickRightTop), findsNothing);
        expect(liftImage(Assets.joystickRightBottom), findsNothing);
      }
      service.status = 0;
      await poll(tester);
      for (final status in [1, 2]) {
        service.status = status;
        await poll(tester);
        expect(find.byType(Image), findsOneWidget);
      }
      expect(service.writes, isEmpty);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'delayed idle feedback never sends stop after a new automatic rise',
    (tester) async {
      final service = LiftStatusService()..control = 0;
      await mountLift(tester, service);
      final origin = tester.getTopLeft(find.byType(JoystickControl));
      await tester.tapAt(origin + const Offset(45, 45));
      await tester.pump();
      await poll(tester);
      expect(service.writes, [(0x0010, 3)]);
      expect(service.control, 3);
      expect(find.byType(Image), findsOneWidget);
      service.status = 3;
      await poll(tester);
      expect(liftImage(Assets.joystickLeftTop), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  for (final (y, command, asset) in [
    (45.0, 1, Assets.joystickRightTop),
    (140.0, 2, Assets.joystickRightBottom),
  ]) {
    testWidgets('manual $command owns light and pauses reads until release', (
      tester,
    ) async {
      final service = LiftStatusService();
      await mountLift(tester, service);
      final origin = tester.getTopLeft(find.byType(JoystickControl));
      final press = await tester.startGesture(origin + Offset(140, y));
      await tester.pump(const Duration(milliseconds: 150));
      await poll(tester);
      expect(service.writes, isEmpty);
      expect(liftImage(asset), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      for (final status in [0, 1, 2, 3, 4]) {
        service.status = status;
        await poll(tester);
        expect(liftImage(asset), findsOneWidget);
      }
      expect(service.reads, isEmpty);
      expect(service.writes, [(0x0010, command)]);
      await press.up();
      await tester.pump();
      expect(find.byType(Image), findsOneWidget);
      expect(service.writes, [(0x0010, command), (0x0010, 0)]);
      service.status = 0;
      await poll(tester);
      expect(service.reads, [0x0011]);
      await tester.pumpWidget(const SizedBox());
    });

    for (final cancel in [false, true]) {
      testWidgets(
        'manual $command ${cancel ? 'cancel' : 'short release'} sends stop only after debounce',
        (tester) async {
          final service = LiftStatusService();
          await mountLift(tester, service);
          final origin = tester.getTopLeft(find.byType(JoystickControl));
          final press = await tester.startGesture(origin + Offset(140, y));
          await tester.pump(Duration(milliseconds: cancel ? 1200 : 150));
          if (cancel) {
            await press.cancel();
          } else {
            await press.up();
          }
          await tester.pump();
          expect(
            service.writes,
            cancel ? [(0x0010, command), (0x0010, 0)] : isEmpty,
          );
          expect(find.byType(Image), findsOneWidget);
          await tester.pumpWidget(const SizedBox());
        },
      );
    }
  }

  testWidgets(
    'external automatic broadcast cannot overwrite a locally held manual light',
    (tester) async {
      final service = LiftStatusService();
      await mountLift(tester, service);
      final origin = tester.getTopLeft(find.byType(JoystickControl));
      final press = await tester.startGesture(origin + const Offset(140, 45));
      await tester.pump(const Duration(seconds: 1));
      JoystickCommandBus.instance.syncStatus(4);
      await tester.pump();
      await tester.pump();
      expect(liftImage(Assets.joystickRightTop), findsOneWidget);
      await press.up();
      await tester.pump();
      expect(service.writes, [(0x0010, 1), (0x0010, 0)]);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'a status read started before a manual hold cannot overwrite its light',
    (tester) async {
      final pending = Completer<int>();
      final service = LiftStatusService()..pendingRead = pending;
      await mountLift(tester, service);
      await poll(tester);
      final origin = tester.getTopLeft(find.byType(JoystickControl));
      final press = await tester.startGesture(origin + const Offset(140, 45));
      await tester.pump(const Duration(seconds: 1));
      pending.complete(4);
      service.pendingRead = null;
      await tester.pump();
      expect(liftImage(Assets.joystickRightTop), findsOneWidget);
      expect(service.reads, [0x0011]);
      await press.up();
      await tester.pump();
      expect(service.writes, [(0x0010, 1), (0x0010, 0)]);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('old background rise feedback cannot clear a newer manual stop', (
    tester,
  ) async {
    final oldStatus = Completer<int>();
    final service = LiftStatusService()
      ..control = 0
      ..pendingRead = oldStatus;
    await mountLift(tester, service);
    await StartLiftSequence(
      service: service,
      isBritain: true,
      isActive: () => true,
    ).riseAfterStop();
    service.pendingRead = null;
    JoystickCommandBus.instance.syncStatus(0);
    await tester.pump();
    await tester.pump();
    final origin = tester.getTopLeft(find.byType(JoystickControl));
    final gesture = await tester.startGesture(origin + const Offset(140, 45));
    await tester.pump(const Duration(seconds: 1));
    service.status = 1;
    await poll(tester);
    await gesture.up();
    await tester.pump();
    oldStatus.complete(0);
    await tester.pump();
    await poll(tester);
    expect(service.writes, [(0x0010, 3), (0x0010, 1), (0x0010, 0)]);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'device status selects automatic directions and returns to idle',
    (tester) async {
      final service = LiftStatusService();
      await mountLift(tester, service);
      for (final (status, asset) in [
        (4, Assets.joystickLeftBottom),
        (3, Assets.joystickLeftTop),
      ]) {
        service.status = status;
        await poll(tester);
        expect(liftImage(asset), findsOneWidget, reason: '0x0011=$status');
      }
      service.status = 0;
      await poll(tester);
      expect(find.byType(Image), findsOneWidget);
      expect(service.writes, isEmpty);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('idle polling discovers motion after a completed movement', (
    tester,
  ) async {
    final service = LiftStatusService();
    await mountLift(tester, service);
    JoystickCommandBus.instance.lockLeftBottom();
    await tester.pump();
    await poll(tester);
    expect(find.byType(Image), findsOneWidget);
    service.status = 3;
    await poll(tester);
    expect(liftImage(Assets.joystickLeftTop), findsOneWidget);
    expect(service.writes, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('feedback corrects a locally requested automatic direction', (
    tester,
  ) async {
    final service = LiftStatusService()..status = 4;
    await mountLift(tester, service);
    JoystickCommandBus.instance.lockLeftTop();
    await tester.pump();
    await poll(tester);
    expect(liftImage(Assets.joystickLeftBottom), findsOneWidget);
    expect(
      JoystickCommandBus.instance.lastLiftCommand,
      JoystickExternalCommand.lockLeftBottom,
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('unknown or failed feedback preserves UI and polling recovers', (
    tester,
  ) async {
    final service = LiftStatusService()..status = 4;
    await mountLift(tester, service);
    await poll(tester);
    service.status = 99;
    await poll(tester);
    expect(liftImage(Assets.joystickLeftBottom), findsOneWidget);
    service.failRead = true;
    await poll(tester);
    expect(liftImage(Assets.joystickLeftBottom), findsOneWidget);
    service.failRead = false;
    service.status = 0;
    await poll(tester);
    expect(find.byType(Image), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('slow feedback does not overlap or update a disposed widget', (
    tester,
  ) async {
    final pending = Completer<int>();
    final service = LiftStatusService()..pendingRead = pending;
    await mountLift(tester, service);
    await poll(tester);
    await poll(tester);
    expect(service.reads, [0x0011]);
    await tester.pumpWidget(const SizedBox());
    pending.complete(4);
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(
      JoystickCommandBus.instance.lastLiftCommand,
      JoystickExternalCommand.reset,
    );
  });

  testWidgets('covered page stops polling and refreshes after returning', (
    tester,
  ) async {
    final navigator = GlobalKey<NavigatorState>();
    final service = LiftStatusService()..status = 4;
    await mountLift(tester, service, navigatorKey: navigator);
    await poll(tester);
    unawaited(
      navigator.currentState!.push<void>(
        MaterialPageRoute(
          builder: (_) => const Scaffold(body: Text('covered')),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    final count = service.reads.length;
    service.status = 3;
    await poll(tester);
    expect(service.reads.length, count);
    navigator.currentState!.pop();
    await tester.pump();
    await poll(tester);
    expect(liftImage(Assets.joystickLeftTop), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  for (final (y, command) in [(45.0, 1), (140.0, 2)]) {
    testWidgets(
      'manual $command keeps light until release without polling feedback',
      (tester) async {
        final service = LiftStatusService();
        await mountLift(tester, service);
        final origin = tester.getTopLeft(find.byType(JoystickControl));
        final gesture = await tester.startGesture(origin + Offset(140, y));
        await tester.pump(const Duration(seconds: 1));
        await poll(tester);
        expect(service.writes, [(0x0010, command)]);
        expect(
          liftImage(
            command == 1 ? Assets.joystickRightTop : Assets.joystickRightBottom,
          ),
          findsOneWidget,
        );
        expect(service.reads, isEmpty);
        await gesture.up();
        await tester.pump();
        expect(service.writes, [(0x0010, command), (0x0010, 0)]);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  testWidgets('old feedback cannot overwrite a newer local command', (
    tester,
  ) async {
    final pending = Completer<int>();
    final service = LiftStatusService()..pendingRead = pending;
    await mountLift(tester, service);
    await poll(tester);
    final origin = tester.getTopLeft(find.byType(JoystickControl));
    await tester.tapAt(origin + const Offset(45, 140));
    await tester.pump();
    pending.complete(0);
    await tester.pump();
    expect(liftImage(Assets.joystickLeftBottom), findsOneWidget);
    expect(service.writes, [(0x0010, 4)]);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'a second finger after idle feedback cannot erase a pending manual stop',
    (tester) async {
      final service = LiftStatusService();
      await mountLift(tester, service);
      final origin = tester.getTopLeft(find.byType(JoystickControl));
      final first = await tester.startGesture(
        origin + const Offset(140, 45),
        pointer: 1,
      );
      await tester.pump(const Duration(seconds: 1));
      await poll(tester);
      final second = await tester.startGesture(
        origin + const Offset(140, 45),
        pointer: 2,
      );
      await first.up();
      await second.up();
      await tester.pump();
      expect(service.writes, [(0x0010, 1), (0x0010, 0)]);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('a stop during automatic acknowledgement is not re-latched', (
    tester,
  ) async {
    final pending = Completer<void>();
    final service = LiftStatusService()..pendingWrite = pending;
    await mountLift(tester, service);
    final origin = tester.getTopLeft(find.byType(JoystickControl));
    await tester.tapAt(origin + const Offset(45, 140));
    await tester.pump();
    await tester.tapAt(origin + const Offset(45, 140));
    await tester.pump();
    pending.complete();
    await tester.pump();
    expect(service.writes, [(0x0010, 4), (0x0010, 0)]);
    expect(find.byType(Image), findsOneWidget);
    expect(
      JoystickCommandBus.instance.lastLiftCommand,
      JoystickExternalCommand.reset,
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'manual release queues stop while its move is awaiting acknowledgement',
    (tester) async {
      final pending = Completer<void>();
      final service = LiftStatusService()..pendingWrite = pending;
      await mountLift(tester, service);
      final origin = tester.getTopLeft(find.byType(JoystickControl));
      final gesture = await tester.startGesture(origin + const Offset(140, 45));
      await tester.pump(const Duration(seconds: 1));
      await gesture.up();
      await tester.pump();
      expect(service.writes, [(0x0010, 1)]);
      pending.complete();
      await tester.pump();
      expect(service.writes, [(0x0010, 1), (0x0010, 0)]);
      expect(find.byType(Image), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
