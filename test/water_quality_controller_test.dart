import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/components/water_quality/water_quality_controller.dart';

class RegisterDevice {
  int tds = 9;
  int status = 1;
  bool fail = false;
  final reads = <int>[];
  Completer<int>? pending;
  Future<int> read(int address) async {
    reads.add(address);
    if (fail) throw StateError('serial disconnected');
    if (pending != null) {
      final result = pending!;
      pending = null;
      return result.future;
    }
    return address == 0x01EC ? tds : status;
  }
}

void main() {
  late RegisterDevice device;
  late WaterQualityController controller;
  setUp(() {
    device = RegisterDevice();
    controller = WaterQualityController(readRegister: device.read);
  });
  tearDown(() => controller.dispose());

  test('normal entry reads EC only and does not announce success', () async {
    await controller.enterPage('/start');
    expect(device.reads, [0x01EC]);
    expect(controller.visible, isFalse);
    expect(controller.canUseHydrogen, isTrue);
  });

  test('threshold ten opens the initial popup before reading ED', () async {
    device.tds = 10;
    final phases = <WaterQualityPhase>[];
    controller.addListener(() {
      if (controller.visible) phases.add(controller.phase);
    });
    await controller.enterPage('/start');
    expect(device.reads, [0x01EC, 0x01ED]);
    expect(phases, contains(WaterQualityPhase.waiting));
    expect(controller.phase, WaterQualityPhase.treating);
    expect(controller.canUseHydrogen, isFalse);
  });

  test('dismissal keeps ED polling without reopening on same visit', () async {
    device.tds = 11;
    await controller.enterPage('/start');
    controller.dismiss();
    device.status = 2;
    await controller.poll();
    expect(controller.phase, WaterQualityPhase.failed);
    expect(controller.visible, isFalse);
    expect(controller.episodeActive, isTrue);
    expect(device.reads, [0x01EC, 0x01ED, 0x01ED]);
  });

  test(
    'returning to home rechecks EC and reopens unresolved failure',
    () async {
      device.tds = 10;
      device.status = 2;
      await controller.enterPage('/start');
      controller.dismiss();
      await controller.enterPage('/summary');
      expect(controller.visible, isFalse);
      await controller.enterPage('/main');
      expect(controller.visible, isTrue);
      expect(controller.phase, WaterQualityPhase.failed);
      expect(device.reads, [0x01EC, 0x01ED, 0x01EC, 0x01ED]);
    },
  );

  test(
    'dismissal during page entry read is not undone by its response',
    () async {
      device.tds = 10;
      await controller.enterPage('/start');
      device.pending = Completer<int>();
      final pending = device.pending!;
      final entry = controller.enterPage('/main');
      await Future<void>.delayed(Duration.zero);
      controller.dismiss();
      pending.complete(10);
      await entry;
      expect(controller.visible, isFalse);
      expect(controller.episodeActive, isTrue);
    },
  );

  test(
    'home defers EC during active episode until original water poll completes',
    () async {
      device.tds = 10;
      await controller.enterPage('/start');
      controller.dismiss();
      device.reads.clear();
      await controller.enterPage('/main', deferRead: true);
      await controller.poll();
      expect(device.reads, [0x01ED]);
      expect(controller.visible, isFalse);
      await controller.onHomeWaterPollComplete();
      expect(device.reads, [0x01ED, 0x01EC, 0x01ED]);
      expect(controller.visible, isTrue);
    },
  );

  test(
    'recovery EC also waits for original home water read sequence',
    () async {
      device.tds = 10;
      await controller.enterPage('/start');
      device.status = 0;
      device.tds = 8;
      device.reads.clear();
      await controller.enterPage('/main', deferRead: true);
      await controller.poll();
      expect(device.reads, [0x01ED]);
      expect(controller.episodeActive, isTrue);
      await controller.onHomeWaterPollComplete();
      expect(controller.phase, WaterQualityPhase.success);
    },
  );

  test('visible treatment survives summary and home transitions', () async {
    device.tds = 10;
    await controller.enterPage('/start');
    await controller.enterPage('/summary');
    expect(controller.visible, isTrue);
    await controller.enterPage('/main');
    expect(controller.visible, isTrue);
  });

  test('success requires ED zero and freshly rechecked normal EC', () async {
    device.tds = 10;
    await controller.enterPage('/start');
    device.status = 0;
    await controller.poll();
    expect(controller.episodeActive, isTrue);
    expect(controller.phase, isNot(WaterQualityPhase.success));
    device.tds = 9;
    await controller.poll();
    expect(controller.episodeActive, isFalse);
    expect(controller.phase, WaterQualityPhase.success);
    expect(controller.visible, isTrue);
    expect(controller.canUseHydrogen, isTrue);
    device.reads.clear();
    await controller.poll();
    expect(device.reads, [0x01EC]);
  });

  test(
    'manual recovery after dismissal stays silent and arms a new episode',
    () async {
      device.tds = 10;
      device.status = 2;
      await controller.enterPage('/start');
      controller.dismiss();
      device.status = 0;
      device.tds = 8;
      await controller.poll();
      expect(controller.visible, isFalse);
      expect(controller.episodeActive, isFalse);
      device.tds = 10;
      device.status = 1;
      await controller.poll();
      expect(controller.visible, isTrue);
      expect(controller.phase, WaterQualityPhase.treating);
    },
  );

  test('a new anomaly replaces an unconfirmed success popup', () async {
    device.tds = 10;
    await controller.enterPage('/start');
    device.status = 0;
    device.tds = 8;
    await controller.poll();
    device.status = 2;
    device.tds = 12;
    await controller.poll();
    expect(controller.visible, isTrue);
    expect(controller.phase, WaterQualityPhase.failed);
    expect(controller.episodeActive, isTrue);
  });

  test(
    'read failure cannot use stale normal value to permit hydrogen',
    () async {
      await controller.enterPage('/start');
      device.fail = true;
      expect(await controller.checkHydrogenBeforeCommand(), isFalse);
      expect(controller.canUseHydrogen, isFalse);
      expect(controller.readError, isNotNull);
    },
  );

  test(
    'treatment read failure preserves episode without declaring success',
    () async {
      device.tds = 10;
      await controller.enterPage('/start');
      device.fail = true;
      await controller.poll();
      expect(controller.episodeActive, isTrue);
      expect(controller.phase, WaterQualityPhase.treating);
      expect(controller.readError, isNotNull);
    },
  );

  test('undefined treatment status does not end anomaly', () async {
    device.tds = 10;
    device.status = 3;
    await controller.enterPage('/start');
    expect(controller.episodeActive, isTrue);
    expect(controller.readError, isNotNull);
  });

  test('fast success works even when polling missed treating state', () async {
    device.tds = 10;
    device.status = 0;
    final pending = Completer<int>();
    device.pending = pending;
    final entry = controller.enterPage('/start');
    device.tds = 8;
    pending.complete(10);
    await entry;
    expect(controller.phase, WaterQualityPhase.success);
    expect(controller.episodeActive, isFalse);
  });

  test('stale entry cannot reopen popup after navigating to summary', () async {
    final pending = Completer<int>();
    device.pending = pending;
    final entry = controller.enterPage('/start');
    await controller.enterPage('/summary');
    pending.complete(10);
    await entry;
    expect(controller.visible, isFalse);
    expect(controller.episodeActive, isFalse);
  });

  test('home detection waits for the existing water register cycle', () async {
    await controller.enterPage('/main', deferRead: true);
    expect(device.reads, isEmpty);
    await controller.poll();
    expect(device.reads, isEmpty);
    await controller.onHomeWaterPollComplete();
    expect(device.reads, [0x01EC]);
  });
}
