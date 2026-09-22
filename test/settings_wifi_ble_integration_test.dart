import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/designCanvas/design.dart';
import 'package:infibo_app/pages/WifiBluetooth/connection_prompt_controller.dart';
import 'package:infibo_app/pages/WifiBluetooth/logic.dart';
import 'package:infibo_app/pages/settingpage/ui.dart';
import 'package:infibo_app/stores/app_header_clock_store.dart';
import 'package:infibo_app/stores/user_store.dart';
import 'package:infibo_app/translation/app_translations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('settings menu opens the WIFI & BLE details panel', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    Get.put(UserStore());
    await tester.binding.setSurfaceSize(const Size(800, 1280));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
      Get.reset();
    });
    final FakeSettingsGateway gateway = FakeSettingsGateway();

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('zh', 'CN'),
        home: DesignCanvas(child: SettingWidget(connectionGateway: gateway)),
      ),
    );

    await tester.tap(find.text('WIFI & BLE'));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const ValueKey('settings_wifi_row')), findsOneWidget);
    expect(find.text('Office-WiFi'), findsOneWidget);
    expect(find.text('Inmortal Test'), findsOneWidget);

    // 先卸载页面，再关闭全局页头时钟，避免测试环境残留周期计时器。
    await tester.pumpWidget(const SizedBox.shrink());
    Get.delete<AppHeaderClockController>(force: true);
  });
}

class FakeSettingsGateway implements ConnectionDetailsGateway {
  final StreamController<WifiConnectionStatus> _wifiStatuses =
      StreamController<WifiConnectionStatus>.broadcast();

  @override
  Stream<WifiConnectionStatus> get wifiStatusStream => _wifiStatuses.stream;

  @override
  Future<bool> hasConnectedBleDevice() async => true;

  @override
  Future<void> openBluetoothSettings() async {}

  @override
  Future<void> openWifiSettings() async {}

  @override
  Future<String?> readConnectedBleDeviceName() async => 'Inmortal Test';

  @override
  Future<String?> readWifiName() async => 'Office-WiFi';

  @override
  Future<WifiConnectionStatus> readWifiStatus() async =>
      WifiConnectionStatus.connected;
}
