import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/pages/WifiBluetooth/logic.dart';

void main() {
  test('initializes the current Wi-Fi and Bluetooth radio states', () async {
    final FakeWifiBluetoothGateway gateway = FakeWifiBluetoothGateway(
      wifiStatus: WifiConnectionStatus.connected,
      bluetoothStatus: BluetoothRadioStatus.ready,
    );
    final WifiBluetoothController controller = WifiBluetoothController(
      gateway: gateway,
    );

    await controller.initialize();

    expect(controller.wifiStatus, WifiConnectionStatus.connected);
    expect(controller.bluetoothStatus, BluetoothRadioStatus.ready);
    expect(controller.initializing, isFalse);
    controller.dispose();
    await gateway.dispose();
  });

  test('keeps one scan result per device and orders strongest first', () async {
    final FakeWifiBluetoothGateway gateway = FakeWifiBluetoothGateway();
    final WifiBluetoothController controller = WifiBluetoothController(
      gateway: gateway,
    );
    await controller.initialize();

    gateway.emitDevice(
      const NearbyBluetoothDevice(id: 'weak', name: 'Weak', rssi: -85),
    );
    gateway.emitDevice(
      const NearbyBluetoothDevice(id: 'strong', name: 'Strong', rssi: -42),
    );
    gateway.emitDevice(
      const NearbyBluetoothDevice(id: 'weak', name: 'Weak updated', rssi: -55),
    );
    await Future<void>.delayed(Duration.zero);

    expect(
      controller.devices.map((NearbyBluetoothDevice device) => device.id),
      <String>['strong', 'weak'],
    );
    expect(controller.devices.last.name, 'Weak updated');
    expect(controller.devices.last.rssi, -55);
    controller.dispose();
    await gateway.dispose();
  });

  test('reports a connection failure and clears the busy device', () async {
    final FakeWifiBluetoothGateway gateway = FakeWifiBluetoothGateway(
      connectError: StateError('device unavailable'),
    );
    final WifiBluetoothController controller = WifiBluetoothController(
      gateway: gateway,
    );
    await controller.initialize();

    await controller.connect('device-1');

    expect(controller.busyDeviceIds, isEmpty);
    expect(controller.errorMessage, contains('device unavailable'));
    controller.dispose();
    await gateway.dispose();
  });

  test('starts and stops scanning only while Bluetooth is ready', () async {
    final FakeWifiBluetoothGateway gateway = FakeWifiBluetoothGateway();
    final WifiBluetoothController controller = WifiBluetoothController(
      gateway: gateway,
    );
    await controller.initialize();
    gateway.emitDevice(
      const NearbyBluetoothDevice(id: 'old', name: 'Old', rssi: -60),
    );
    await Future<void>.delayed(Duration.zero);

    await controller.startScan();

    expect(controller.scanning, isTrue);
    expect(controller.devices, isEmpty);
    expect(gateway.startScanCalls, 1);

    await controller.stopScan();

    expect(controller.scanning, isFalse);
    expect(gateway.stopScanCalls, 1);
    controller.dispose();
    await gateway.dispose();
  });

  test('connection updates change the matching discovered device', () async {
    final FakeWifiBluetoothGateway gateway = FakeWifiBluetoothGateway();
    final WifiBluetoothController controller = WifiBluetoothController(
      gateway: gateway,
    );
    await controller.initialize();
    gateway.emitDevice(
      const NearbyBluetoothDevice(id: 'device-1', name: 'Infibo', rssi: -45),
    );
    await Future<void>.delayed(Duration.zero);

    gateway.emitConnection(
      const DeviceConnectionUpdate(
        deviceId: 'device-1',
        status: BluetoothLinkStatus.connected,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(controller.devices.single.linkStatus, BluetoothLinkStatus.connected);
    controller.dispose();
    await gateway.dispose();
  });

  test('refreshes Wi-Fi after returning from system settings', () async {
    final FakeWifiBluetoothGateway gateway = FakeWifiBluetoothGateway(
      wifiStatus: WifiConnectionStatus.disconnected,
    );
    final WifiBluetoothController controller = WifiBluetoothController(
      gateway: gateway,
    );
    await controller.initialize();
    gateway.nextWifiStatus = WifiConnectionStatus.connected;

    await controller.refreshWifiStatus();

    expect(controller.wifiStatus, WifiConnectionStatus.connected);
    controller.dispose();
    await gateway.dispose();
  });

  test('does not scan while the Bluetooth radio is unavailable', () async {
    final FakeWifiBluetoothGateway gateway = FakeWifiBluetoothGateway(
      bluetoothStatus: BluetoothRadioStatus.poweredOff,
    );
    final WifiBluetoothController controller = WifiBluetoothController(
      gateway: gateway,
    );
    await controller.initialize();

    await controller.startScan();

    expect(gateway.startScanCalls, 0);
    expect(controller.scanning, isFalse);
    expect(controller.errorMessage, isNotNull);
    controller.dispose();
    await gateway.dispose();
  });

  test('forwards system settings and device disconnect actions', () async {
    final FakeWifiBluetoothGateway gateway = FakeWifiBluetoothGateway();
    final WifiBluetoothController controller = WifiBluetoothController(
      gateway: gateway,
    );
    await controller.initialize();

    await controller.openWifiSettings();
    await controller.openBluetoothSettings();
    await controller.disconnect('device-1');

    expect(gateway.openWifiSettingsCalls, 1);
    expect(gateway.openBluetoothSettingsCalls, 1);
    expect(gateway.disconnectedDeviceIds, <String>['device-1']);
    expect(controller.busyDeviceIds, isEmpty);
    controller.dispose();
    await gateway.dispose();
  });

  test(
    'keeps connected devices and connection state across a rescan',
    () async {
      final FakeWifiBluetoothGateway gateway = FakeWifiBluetoothGateway();
      final WifiBluetoothController controller = WifiBluetoothController(
        gateway: gateway,
      );
      await controller.initialize();
      gateway.emitDevice(
        const NearbyBluetoothDevice(id: 'device-1', name: 'Infibo', rssi: -60),
      );
      gateway.emitConnection(
        const DeviceConnectionUpdate(
          deviceId: 'device-1',
          status: BluetoothLinkStatus.connected,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      await controller.startScan();
      gateway.emitDevice(
        const NearbyBluetoothDevice(
          id: 'device-1',
          name: 'Infibo updated',
          rssi: -40,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(controller.devices, hasLength(1));
      expect(controller.devices.single.name, 'Infibo updated');
      expect(
        controller.devices.single.linkStatus,
        BluetoothLinkStatus.connected,
      );
      controller.dispose();
      await gateway.dispose();
    },
  );

  test('rolls back transient connection states when commands fail', () async {
    final FakeWifiBluetoothGateway gateway = FakeWifiBluetoothGateway(
      connectError: StateError('connect failed'),
      disconnectError: StateError('disconnect failed'),
      emitTransientConnectionStates: true,
    );
    final WifiBluetoothController controller = WifiBluetoothController(
      gateway: gateway,
    );
    await controller.initialize();
    gateway.emitDevice(
      const NearbyBluetoothDevice(id: 'device-1', name: 'Infibo', rssi: -50),
    );
    await Future<void>.delayed(Duration.zero);

    await controller.connect('device-1');
    expect(
      controller.devices.single.linkStatus,
      BluetoothLinkStatus.disconnected,
    );

    gateway.emitConnection(
      const DeviceConnectionUpdate(
        deviceId: 'device-1',
        status: BluetoothLinkStatus.connected,
      ),
    );
    await Future<void>.delayed(Duration.zero);
    await controller.disconnect('device-1');
    expect(controller.devices.single.linkStatus, BluetoothLinkStatus.connected);
    expect(controller.busyDeviceIds, isEmpty);
    controller.dispose();
    await gateway.dispose();
  });

  test('stops scanning when the Bluetooth radio becomes unavailable', () async {
    final FakeWifiBluetoothGateway gateway = FakeWifiBluetoothGateway();
    final WifiBluetoothController controller = WifiBluetoothController(
      gateway: gateway,
    );
    await controller.initialize();
    await controller.startScan();

    gateway.emitBluetoothStatus(BluetoothRadioStatus.poweredOff);
    await Future<void>.delayed(Duration.zero);

    expect(controller.scanning, isFalse);
    expect(gateway.stopScanCalls, 1);
    controller.dispose();
    await gateway.dispose();
  });

  test('does not update state after disposal during a pending scan', () async {
    final Completer<void> scanCompleter = Completer<void>();
    final FakeWifiBluetoothGateway gateway = FakeWifiBluetoothGateway(
      startScanCompleter: scanCompleter,
    );
    final WifiBluetoothController controller = WifiBluetoothController(
      gateway: gateway,
    );
    await controller.initialize();

    final Future<void> pendingScan = controller.startScan();
    await Future<void>.delayed(Duration.zero);
    controller.dispose();
    scanCompleter.complete();
    await pendingScan;

    expect(controller.scanning, isFalse);
    await gateway.dispose();
  });

  test('stops scanning before starting a device connection', () async {
    final FakeWifiBluetoothGateway gateway = FakeWifiBluetoothGateway();
    final WifiBluetoothController controller = WifiBluetoothController(
      gateway: gateway,
    );
    await controller.initialize();
    gateway.emitDevice(
      const NearbyBluetoothDevice(id: 'device-1', name: 'Infibo', rssi: -45),
    );
    await Future<void>.delayed(Duration.zero);
    await controller.startScan();

    await controller.connect('device-1');

    expect(controller.scanning, isFalse);
    expect(gateway.actionLog, <String>[
      'startScan',
      'stopScan',
      'connect:device-1',
    ]);
    controller.dispose();
    await gateway.dispose();
  });

  test(
    'does not restart scanning while a connection command is pending',
    () async {
      final Completer<void> connectCompleter = Completer<void>();
      final FakeWifiBluetoothGateway gateway = FakeWifiBluetoothGateway(
        connectCompleter: connectCompleter,
        emitTransientConnectionStates: true,
      );
      final WifiBluetoothController controller = WifiBluetoothController(
        gateway: gateway,
      );
      await controller.initialize();
      gateway.emitDevice(
        const NearbyBluetoothDevice(id: 'device-1', name: 'Infibo', rssi: -45),
      );
      await Future<void>.delayed(Duration.zero);

      final Future<void> pendingConnect = controller.connect('device-1');
      await Future<void>.delayed(Duration.zero);
      await controller.startScan();

      expect(gateway.startScanCalls, 0);
      expect(controller.devices, hasLength(1));
      expect(controller.errorMessage, isNotNull);
      connectCompleter.complete();
      await pendingConnect;
      controller.dispose();
      await gateway.dispose();
    },
  );
}

class FakeWifiBluetoothGateway implements WifiBluetoothGateway {
  FakeWifiBluetoothGateway({
    this.wifiStatus = WifiConnectionStatus.disconnected,
    this.bluetoothStatus = BluetoothRadioStatus.ready,
    this.connectError,
    this.disconnectError,
    this.emitTransientConnectionStates = false,
    this.startScanCompleter,
    this.connectCompleter,
  });

  final WifiConnectionStatus wifiStatus;
  final BluetoothRadioStatus bluetoothStatus;
  final Object? connectError;
  final Object? disconnectError;
  final bool emitTransientConnectionStates;
  final Completer<void>? startScanCompleter;
  final Completer<void>? connectCompleter;
  WifiConnectionStatus? nextWifiStatus;
  int startScanCalls = 0;
  int stopScanCalls = 0;
  int openWifiSettingsCalls = 0;
  int openBluetoothSettingsCalls = 0;
  final List<String> disconnectedDeviceIds = <String>[];
  final List<String> actionLog = <String>[];
  final StreamController<NearbyBluetoothDevice> _devices =
      StreamController<NearbyBluetoothDevice>.broadcast();
  final StreamController<BluetoothRadioStatus> _bluetoothStatuses =
      StreamController<BluetoothRadioStatus>.broadcast();
  final StreamController<DeviceConnectionUpdate> _connections =
      StreamController<DeviceConnectionUpdate>.broadcast();

  @override
  Stream<BluetoothRadioStatus> get bluetoothStatusStream =>
      _bluetoothStatuses.stream;

  @override
  Stream<DeviceConnectionUpdate> get connectionStream => _connections.stream;

  @override
  Stream<NearbyBluetoothDevice> get scanResultStream => _devices.stream;

  @override
  Future<BluetoothRadioStatus> readBluetoothStatus() async => bluetoothStatus;

  @override
  Future<WifiConnectionStatus> readWifiStatus() async =>
      nextWifiStatus ?? wifiStatus;

  @override
  Future<void> connect(String deviceId) async {
    actionLog.add('connect:$deviceId');
    if (emitTransientConnectionStates) {
      emitConnection(
        DeviceConnectionUpdate(
          deviceId: deviceId,
          status: BluetoothLinkStatus.connecting,
        ),
      );
      await Future<void>.delayed(Duration.zero);
    }
    await connectCompleter?.future;
    if (connectError != null) throw connectError!;
  }

  @override
  Future<void> disconnect(String deviceId) async {
    disconnectedDeviceIds.add(deviceId);
    if (emitTransientConnectionStates) {
      emitConnection(
        DeviceConnectionUpdate(
          deviceId: deviceId,
          status: BluetoothLinkStatus.disconnecting,
        ),
      );
      await Future<void>.delayed(Duration.zero);
    }
    if (disconnectError != null) throw disconnectError!;
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
  Future<void> startScan() async {
    startScanCalls++;
    actionLog.add('startScan');
    await startScanCompleter?.future;
  }

  @override
  Future<void> stopScan() async {
    stopScanCalls++;
    actionLog.add('stopScan');
  }

  void emitDevice(NearbyBluetoothDevice device) => _devices.add(device);

  void emitConnection(DeviceConnectionUpdate update) =>
      _connections.add(update);

  void emitBluetoothStatus(BluetoothRadioStatus status) =>
      _bluetoothStatuses.add(status);

  Future<void> dispose() async {
    await _devices.close();
    await _bluetoothStatuses.close();
    await _connections.close();
  }
}
