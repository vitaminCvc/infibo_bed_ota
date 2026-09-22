import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/pages/WifiBluetooth/connection_prompt_controller.dart';
import 'package:infibo_app/pages/WifiBluetooth/logic.dart';

void main() {
  test('shows when either connection is missing', () async {
    final FakeConnectionPromptGateway gateway = FakeConnectionPromptGateway(
      wifiConnected: true,
      bleConnected: false,
    );
    final ConnectionPromptController controller = ConnectionPromptController(
      gateway: gateway,
    );

    await controller.initialize();

    expect(controller.wifiStatus, ConnectionCheckStatus.connected);
    expect(controller.bleStatus, ConnectionCheckStatus.disconnected);
    expect(controller.shouldShow, isTrue);
    controller.dispose();
    await gateway.dispose();
  });

  test('skip survives refresh until both connections recover', () async {
    final FakeConnectionPromptGateway gateway = FakeConnectionPromptGateway(
      wifiConnected: false,
      bleConnected: false,
    );
    final ConnectionPromptController controller = ConnectionPromptController(
      gateway: gateway,
    );
    await controller.initialize();

    controller.skipForCurrentRun();
    await controller.refresh();
    expect(controller.shouldShow, isFalse);

    gateway
      ..wifiConnected = true
      ..bleConnected = true;
    await controller.refresh();
    expect(controller.shouldShow, isFalse);

    gateway.bleConnected = false;
    await controller.refresh();
    expect(controller.shouldShow, isTrue);
    controller.dispose();
    await gateway.dispose();
  });

  test('manual display stays open while connected until skipped', () async {
    final FakeConnectionPromptGateway gateway = FakeConnectionPromptGateway(
      wifiConnected: true,
      bleConnected: true,
    );
    final ConnectionPromptController controller = ConnectionPromptController(
      gateway: gateway,
    );
    await controller.initialize();

    controller.showManually();
    await controller.refresh();
    expect(controller.shouldShow, isTrue);

    controller.skipForCurrentRun();
    expect(controller.shouldShow, isFalse);
    controller.dispose();
    await gateway.dispose();
  });

  test('refresh triggered during a read runs one trailing snapshot', () async {
    final Completer<WifiConnectionStatus> firstWifiRead =
        Completer<WifiConnectionStatus>();
    final Completer<bool> firstBleRead = Completer<bool>();
    late final FakeConnectionPromptGateway gateway;
    gateway = FakeConnectionPromptGateway(
      wifiConnected: true,
      bleConnected: true,
      wifiReader: () => gateway.readWifiStatusCalls == 1
          ? firstWifiRead.future
          : Future<WifiConnectionStatus>.value(WifiConnectionStatus.connected),
      bleReader: () => gateway.readBleStatusCalls == 1
          ? firstBleRead.future
          : Future<bool>.value(true),
    );
    final ConnectionPromptController controller = ConnectionPromptController(
      gateway: gateway,
    );
    addTearDown(() async {
      controller.dispose();
      await gateway.dispose();
    });

    final Future<void> firstRefresh = controller.initialize();
    final Future<void> trailingRefresh = controller.refresh();
    firstWifiRead.complete(WifiConnectionStatus.disconnected);
    firstBleRead.complete(false);

    await trailingRefresh;
    await firstRefresh;

    expect(gateway.readWifiStatusCalls, 2);
    expect(gateway.readBleStatusCalls, 2);
    expect(controller.wifiStatus, ConnectionCheckStatus.connected);
    expect(controller.bleStatus, ConnectionCheckStatus.connected);
  });

  test('Wi-Fi stream errors trigger a guarded connection refresh', () async {
    final FakeConnectionPromptGateway gateway = FakeConnectionPromptGateway(
      wifiConnected: true,
      bleConnected: true,
    );
    final ConnectionPromptController controller = ConnectionPromptController(
      gateway: gateway,
    );
    addTearDown(() async {
      controller.dispose();
      await gateway.dispose();
    });
    await controller.initialize();

    gateway.bleConnected = false;
    gateway.emitWifiError(StateError('wifi stream failed'));
    await pumpEventQueue();

    expect(gateway.readWifiStatusCalls, 2);
    expect(controller.bleStatus, ConnectionCheckStatus.disconnected);
  });

  test(
    'Wi-Fi error refresh finishing after disposal does not notify',
    () async {
      final Completer<WifiConnectionStatus> delayedWifiRead =
          Completer<WifiConnectionStatus>();
      final Completer<bool> delayedBleRead = Completer<bool>();
      late final FakeConnectionPromptGateway gateway;
      gateway = FakeConnectionPromptGateway(
        wifiConnected: true,
        bleConnected: true,
        wifiReader: () => gateway.readWifiStatusCalls == 1
            ? Future<WifiConnectionStatus>.value(WifiConnectionStatus.connected)
            : delayedWifiRead.future,
        bleReader: () => gateway.readBleStatusCalls == 1
            ? Future<bool>.value(true)
            : delayedBleRead.future,
      );
      final ConnectionPromptController controller = ConnectionPromptController(
        gateway: gateway,
      );
      bool controllerDisposed = false;
      addTearDown(() async {
        if (!delayedWifiRead.isCompleted) {
          delayedWifiRead.complete(WifiConnectionStatus.disconnected);
        }
        if (!delayedBleRead.isCompleted) delayedBleRead.complete(false);
        if (!controllerDisposed) controller.dispose();
        await gateway.dispose();
      });
      await controller.initialize();
      int notifications = 0;
      controller.addListener(() => notifications++);

      gateway.emitWifiError(StateError('wifi stream failed'));
      await pumpEventQueue();
      expect(gateway.readWifiStatusCalls, 2);

      controller.dispose();
      controllerDisposed = true;
      delayedWifiRead.complete(WifiConnectionStatus.disconnected);
      delayedBleRead.complete(false);
      await pumpEventQueue();

      expect(notifications, 0);
    },
  );

  test('manual display immediately refreshes stale connection state', () async {
    final Completer<WifiConnectionStatus> refreshedWifi =
        Completer<WifiConnectionStatus>();
    final Completer<bool> refreshedBle = Completer<bool>();
    late final FakeConnectionPromptGateway gateway;
    gateway = FakeConnectionPromptGateway(
      wifiReader: () => gateway.readWifiStatusCalls == 1
          ? Future<WifiConnectionStatus>.value(WifiConnectionStatus.connected)
          : refreshedWifi.future,
      bleReader: () => gateway.readBleStatusCalls == 1
          ? Future<bool>.value(true)
          : refreshedBle.future,
    );
    final ConnectionPromptController controller = ConnectionPromptController(
      gateway: gateway,
    );
    addTearDown(() async {
      if (!refreshedWifi.isCompleted) {
        refreshedWifi.complete(WifiConnectionStatus.disconnected);
      }
      if (!refreshedBle.isCompleted) refreshedBle.complete(false);
      controller.dispose();
      await gateway.dispose();
    });
    await controller.initialize();

    controller.showManually();

    expect(gateway.readWifiStatusCalls, 2);
    expect(controller.wifiStatus, ConnectionCheckStatus.checking);
    expect(controller.bleStatus, ConnectionCheckStatus.checking);
    expect(controller.shouldShow, isTrue);

    refreshedWifi.complete(WifiConnectionStatus.disconnected);
    refreshedBle.complete(false);
    await pumpEventQueue();

    expect(controller.wifiStatus, ConnectionCheckStatus.disconnected);
    expect(controller.bleStatus, ConnectionCheckStatus.disconnected);
  });

  test('initial checking state is visible until both reads connect', () async {
    final Completer<WifiConnectionStatus> wifiRead =
        Completer<WifiConnectionStatus>();
    final Completer<bool> bleRead = Completer<bool>();
    final FakeConnectionPromptGateway gateway = FakeConnectionPromptGateway(
      wifiReader: () => wifiRead.future,
      bleReader: () => bleRead.future,
    );
    final ConnectionPromptController controller = ConnectionPromptController(
      gateway: gateway,
    );
    addTearDown(() async {
      if (!wifiRead.isCompleted) {
        wifiRead.complete(WifiConnectionStatus.connected);
      }
      if (!bleRead.isCompleted) bleRead.complete(true);
      controller.dispose();
      await gateway.dispose();
    });

    final Future<void> initialization = controller.initialize();

    expect(controller.wifiStatus, ConnectionCheckStatus.checking);
    expect(controller.bleStatus, ConnectionCheckStatus.checking);
    expect(controller.shouldShow, isTrue);

    wifiRead.complete(WifiConnectionStatus.connected);
    bleRead.complete(true);
    await initialization;

    expect(controller.shouldShow, isFalse);
  });

  test('delegates both settings actions to the gateway', () async {
    final FakeConnectionPromptGateway gateway = FakeConnectionPromptGateway();
    final ConnectionPromptController controller = ConnectionPromptController(
      gateway: gateway,
    );

    await controller.openWifiSettings();
    await controller.openBluetoothSettings();

    expect(gateway.openWifiSettingsCalls, 1);
    expect(gateway.openBluetoothSettingsCalls, 1);
    controller.dispose();
    await gateway.dispose();
  });
}

class FakeConnectionPromptGateway implements ConnectionPromptGateway {
  FakeConnectionPromptGateway({
    this.wifiConnected = false,
    this.bleConnected = false,
    this.wifiReader,
    this.bleReader,
  });

  bool wifiConnected;
  bool bleConnected;
  final Future<WifiConnectionStatus> Function()? wifiReader;
  final Future<bool> Function()? bleReader;
  int readWifiStatusCalls = 0;
  int readBleStatusCalls = 0;
  int openWifiSettingsCalls = 0;
  int openBluetoothSettingsCalls = 0;
  final StreamController<WifiConnectionStatus> _wifiStatuses =
      StreamController<WifiConnectionStatus>.broadcast();

  @override
  Stream<WifiConnectionStatus> get wifiStatusStream => _wifiStatuses.stream;

  @override
  Future<bool> hasConnectedBleDevice() {
    readBleStatusCalls++;
    return bleReader?.call() ?? Future<bool>.value(bleConnected);
  }

  @override
  Future<void> openBluetoothSettings() async {
    openBluetoothSettingsCalls++;
  }

  @override
  Future<void> openWifiSettings() async {
    openWifiSettingsCalls++;
  }

  @override
  Future<WifiConnectionStatus> readWifiStatus() {
    readWifiStatusCalls++;
    return wifiReader?.call() ??
        Future<WifiConnectionStatus>.value(
          wifiConnected
              ? WifiConnectionStatus.connected
              : WifiConnectionStatus.disconnected,
        );
  }

  void emitWifiError(Object error) => _wifiStatuses.addError(error);

  Future<void> dispose() => _wifiStatuses.close();
}
