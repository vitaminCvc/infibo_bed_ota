import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/pages/WifiBluetooth/connection_prompt_controller.dart';
import 'package:infibo_app/pages/WifiBluetooth/logic.dart';
import 'package:infibo_app/pages/settingpage/wifi_ble_settings_controller.dart';

void main() {
  test('refresh exposes the real Wi-Fi and matching Bluetooth names', () async {
    final FakeConnectionDetailsGateway gateway = FakeConnectionDetailsGateway(
      wifiStatus: WifiConnectionStatus.connected,
      wifiName: 'HOME-SJSK-5G',
      bluetoothName: 'Inmortal Speaker',
    );
    final WifiBleSettingsController controller = WifiBleSettingsController(
      gateway: gateway,
    );
    addTearDown(controller.dispose);

    await controller.initialize();

    expect(controller.wifiStatus, ConnectionCheckStatus.connected);
    expect(controller.wifiName, 'HOME-SJSK-5G');
    expect(controller.bleStatus, ConnectionCheckStatus.connected);
    expect(controller.bluetoothName, 'Inmortal Speaker');
  });

  test('connected Wi-Fi stays connected when Android hides its SSID', () async {
    final FakeConnectionDetailsGateway gateway = FakeConnectionDetailsGateway(
      wifiStatus: WifiConnectionStatus.connected,
      wifiName: null,
      bluetoothName: null,
    );
    final WifiBleSettingsController controller = WifiBleSettingsController(
      gateway: gateway,
    );
    addTearDown(controller.dispose);

    await controller.initialize();

    expect(controller.wifiStatus, ConnectionCheckStatus.connected);
    expect(controller.wifiName, isNull);
    expect(controller.bleStatus, ConnectionCheckStatus.disconnected);
  });

  test('settings actions use the same gateway as connection checks', () async {
    final FakeConnectionDetailsGateway gateway = FakeConnectionDetailsGateway();
    final WifiBleSettingsController controller = WifiBleSettingsController(
      gateway: gateway,
    );
    addTearDown(controller.dispose);

    await controller.openWifiSettings();
    await controller.openBluetoothSettings();

    expect(gateway.openWifiSettingsCalls, 1);
    expect(gateway.openBluetoothSettingsCalls, 1);
  });
}

class FakeConnectionDetailsGateway implements ConnectionDetailsGateway {
  FakeConnectionDetailsGateway({
    this.wifiStatus = WifiConnectionStatus.disconnected,
    this.wifiName,
    this.bluetoothName,
  });

  WifiConnectionStatus wifiStatus;
  String? wifiName;
  String? bluetoothName;
  int openWifiSettingsCalls = 0;
  int openBluetoothSettingsCalls = 0;
  final StreamController<WifiConnectionStatus> _wifiStatuses =
      StreamController<WifiConnectionStatus>.broadcast();

  @override
  Stream<WifiConnectionStatus> get wifiStatusStream => _wifiStatuses.stream;

  @override
  Future<bool> hasConnectedBleDevice() async => bluetoothName != null;

  @override
  Future<void> openBluetoothSettings() async {
    openBluetoothSettingsCalls++;
  }

  @override
  Future<void> openWifiSettings() async {
    openWifiSettingsCalls++;
  }

  @override
  Future<String?> readConnectedBleDeviceName() async => bluetoothName;

  @override
  Future<String?> readWifiName() async => wifiName;

  @override
  Future<WifiConnectionStatus> readWifiStatus() async => wifiStatus;
}
