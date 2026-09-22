import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infibo_app/pages/WifiBluetooth/connection_prompt_controller.dart';
import 'package:infibo_app/pages/WifiBluetooth/logic.dart';
import 'package:infibo_app/pages/settingpage/wifi_ble_settings_panel.dart';
import 'package:infibo_app/translation/app_translations.dart';

void main() {
  testWidgets('checking status uses blue for its dot and label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('zh', 'CN'),
        home: Scaffold(
          body: WifiBleSettingsPanel(
            gateway: PendingPanelGateway(),
            refreshInterval: const Duration(days: 1),
          ),
        ),
      ),
    );

    final Finder wifiRow = find.byKey(
      const ValueKey<String>('settings_wifi_row'),
    );
    final Text checkingText = tester.widget<Text>(
      _styledTextInside(wifiRow, '检测中', 16),
    );
    final Container checkingDot = tester.widget<Container>(
      _sizedContainerInside(wifiRow, 8, 8),
    );

    expect(checkingText.style?.color, const Color(0xFF42B7FF));
    expect(
      (checkingDot.decoration as BoxDecoration).color,
      const Color(0xFF42B7FF),
    );
  });

  testWidgets('disconnected status uses gray for its dot and label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('zh', 'CN'),
        home: Scaffold(
          body: WifiBleSettingsPanel(
            gateway: FakePanelGateway(wifiConnected: false),
            refreshInterval: const Duration(days: 1),
          ),
        ),
      ),
    );
    await tester.pump();

    final Finder wifiRow = find.byKey(
      const ValueKey<String>('settings_wifi_row'),
    );
    final Text disconnectedText = tester.widget<Text>(
      find.descendant(of: wifiRow, matching: find.text('未连接')),
    );
    final Container disconnectedDot = tester.widget<Container>(
      _sizedContainerInside(wifiRow, 8, 8),
    );

    expect(disconnectedText.style?.color, const Color(0xFFB6B6B6));
    expect(
      (disconnectedDot.decoration as BoxDecoration).color,
      const Color(0xFFB6B6B6),
    );
  });

  testWidgets('connected status remains green for its dot and label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('zh', 'CN'),
        home: Scaffold(
          body: WifiBleSettingsPanel(
            gateway: FakePanelGateway(wifiName: 'HOME-SJSK-5G'),
            refreshInterval: const Duration(days: 1),
          ),
        ),
      ),
    );
    await tester.pump();

    final Finder wifiRow = find.byKey(
      const ValueKey<String>('settings_wifi_row'),
    );
    final Text connectedText = tester.widget<Text>(
      find.descendant(of: wifiRow, matching: find.text('已连接')),
    );
    final Container connectedDot = tester.widget<Container>(
      _sizedContainerInside(wifiRow, 8, 8),
    );

    expect(connectedText.style?.color, const Color(0xFF48F46D));
    expect(
      (connectedDot.decoration as BoxDecoration).color,
      const Color(0xFF48F46D),
    );
  });

  testWidgets('connection rows use silent gestures without ink effects', (
    WidgetTester tester,
  ) async {
    final FakePanelGateway gateway = FakePanelGateway(
      wifiName: 'HOME-SJSK-5G',
      bluetoothName: 'Inmortal Speaker',
    );

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('zh', 'CN'),
        home: Scaffold(
          body: WifiBleSettingsPanel(
            gateway: gateway,
            refreshInterval: const Duration(days: 1),
          ),
        ),
      ),
    );
    await tester.pump();

    for (final String key in <String>[
      'settings_wifi_row',
      'settings_ble_row',
    ]) {
      final Finder row = find.byKey(ValueKey<String>(key));
      expect(
        find.descendant(of: row, matching: find.byType(InkWell)),
        findsNothing,
      );
      expect(
        find.descendant(of: row, matching: find.byType(GestureDetector)),
        findsOneWidget,
      );
    }

    await tester.tap(find.byKey(const ValueKey<String>('settings_wifi_row')));
    await tester.tap(find.byKey(const ValueKey<String>('settings_ble_row')));
    await tester.pump();
    expect(gateway.openWifiSettingsCalls, 1);
    expect(gateway.openBluetoothSettingsCalls, 1);
  });

  testWidgets('panel follows the specified title and row geometry', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('zh', 'CN'),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 429,
              height: 900,
              child: WifiBleSettingsPanel(
                gateway: FakePanelGateway(
                  wifiName: 'HOME-SJSK-5G',
                  bluetoothName: 'Inmortal Speaker',
                ),
                refreshInterval: const Duration(days: 1),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final Finder title = find.text('WIFI & BLE');
    final Finder wifiRow = find.byKey(
      const ValueKey<String>('settings_wifi_row'),
    );
    final Text titleText = tester.widget<Text>(title);

    expect(titleText.style?.color, Colors.white);
    expect(titleText.style?.fontSize, 24);
    expect(titleText.style?.fontWeight, isNull);
    expect(tester.getTopLeft(title), Offset.zero);
    expect(tester.getTopLeft(wifiRow), const Offset(6, 78));
    expect(tester.getSize(wifiRow).width, 411);
  });

  testWidgets('connection row uses the specified spacing and typography', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('zh', 'CN'),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 429,
              height: 900,
              child: WifiBleSettingsPanel(
                gateway: FakePanelGateway(
                  wifiName: 'HOME-SJSK-5G',
                  bluetoothName: 'Inmortal Speaker',
                ),
                refreshInterval: const Duration(days: 1),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final Finder wifiRow = find.byKey(
      const ValueKey<String>('settings_wifi_row'),
    );
    final Finder wifiIcon = _assetImageInside(
      wifiRow,
      'assets/WifiBLE/wifi.png',
    );
    final Finder wifiTitle = find.descendant(
      of: wifiRow,
      matching: find.text('WIFI'),
    );
    final Finder statusDot = _sizedContainerInside(wifiRow, 8, 8);
    final Finder statusText = find.descendant(
      of: wifiRow,
      matching: find.text('已连接'),
    );
    final Finder detailText = find.descendant(
      of: wifiRow,
      matching: find.text('HOME-SJSK-5G'),
    );
    final Finder enterIcon = _assetImageInside(
      wifiRow,
      'assets/WifiBLE/enter.png',
    );

    expect(
      tester.getTopLeft(wifiTitle).dx - tester.getTopRight(wifiIcon).dx,
      20,
    );
    expect(
      tester.getTopLeft(statusDot).dx - tester.getTopRight(wifiTitle).dx,
      12,
    );
    expect(
      tester.getTopLeft(statusText).dx - tester.getTopRight(statusDot).dx,
      6,
    );
    expect(
      tester.getTopLeft(detailText).dy - tester.getBottomLeft(wifiTitle).dy,
      10,
    );

    final Text wifiTitleText = tester.widget<Text>(wifiTitle);
    final Text connectedText = tester.widget<Text>(statusText);
    final Text wifiDetailText = tester.widget<Text>(detailText);
    final Image enterImage = tester.widget<Image>(enterIcon);
    expect(wifiTitleText.style?.fontSize, 22);
    expect(wifiTitleText.style?.color, Colors.white);
    expect(wifiTitleText.style?.fontWeight, isNull);
    expect(connectedText.style?.fontSize, 16);
    expect(connectedText.style?.fontWeight, isNull);
    expect(wifiDetailText.style?.fontSize, 14);
    expect(wifiDetailText.style?.color, const Color(0xFFB6B6B6));
    expect(wifiDetailText.style?.fontWeight, isNull);
    expect(enterImage.color, const Color(0xFFB6B6B6));
  });

  testWidgets('divider is 411 wide with 32 pixel vertical gaps', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('zh', 'CN'),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 429,
              height: 900,
              child: WifiBleSettingsPanel(
                gateway: FakePanelGateway(
                  wifiName: 'HOME-SJSK-5G',
                  bluetoothName: 'Inmortal Speaker',
                ),
                refreshInterval: const Duration(days: 1),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final Finder wifiDetail = find.text('HOME-SJSK-5G');
    final Finder divider = find.byType(Divider);
    final Finder bleTitle = find.text('BLE');

    expect(tester.getTopLeft(divider).dx, 6);
    expect(tester.getSize(divider), const Size(411, 1));
    expect(
      tester.getTopLeft(divider).dy - tester.getBottomLeft(wifiDetail).dy,
      32,
    );
    expect(
      tester.getTopLeft(bleTitle).dy - tester.getBottomLeft(divider).dy,
      32,
    );
  });

  testWidgets('panel displays real connection names and opens settings', (
    WidgetTester tester,
  ) async {
    final FakePanelGateway gateway = FakePanelGateway(
      wifiName: 'HOME-SJSK-5G',
      bluetoothName: 'Inmortal Speaker',
    );

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('zh', 'CN'),
        home: Scaffold(
          body: WifiBleSettingsPanel(
            gateway: gateway,
            refreshInterval: const Duration(days: 1),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('WIFI & BLE'), findsOneWidget);
    expect(find.text('HOME-SJSK-5G'), findsOneWidget);
    expect(find.text('Inmortal Speaker'), findsOneWidget);
    expect(find.text('已连接'), findsNWidgets(2));

    await tester.tap(find.byKey(const ValueKey('settings_wifi_row')));
    await tester.tap(find.byKey(const ValueKey('settings_ble_row')));
    await tester.pump();

    expect(gateway.openWifiSettingsCalls, 1);
    expect(gateway.openBluetoothSettingsCalls, 1);
  });

  testWidgets('connected Wi-Fi without a readable SSID uses fallback text', (
    WidgetTester tester,
  ) async {
    final FakePanelGateway gateway = FakePanelGateway(wifiName: null);

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('zh', 'CN'),
        home: Scaffold(
          body: WifiBleSettingsPanel(
            gateway: gateway,
            refreshInterval: const Duration(days: 1),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('无法获取网络名称'), findsOneWidget);
    expect(find.text('已连接'), findsOneWidget);
    expect(find.text('未连接任何设备'), findsOneWidget);
    final Image wifiIcon = tester.widget<Image>(
      _assetImageInside(
        find.byKey(const ValueKey('settings_wifi_row')),
        'assets/WifiBLE/wifi.png',
      ),
    );
    final Image bleIcon = tester.widget<Image>(
      _assetImageInside(
        find.byKey(const ValueKey('settings_ble_row')),
        'assets/WifiBLE/ble.png',
      ),
    );
    expect(wifiIcon.color, isNull);
    expect(bleIcon.color, const Color(0xFFB6B6B6));
  });

  testWidgets(
    'disconnected Wi-Fi icon is gray while connected BLE stays blue',
    (WidgetTester tester) async {
      final FakePanelGateway gateway = FakePanelGateway(
        wifiConnected: false,
        bluetoothName: 'Inmortal Speaker',
      );

      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('zh', 'CN'),
          home: Scaffold(
            body: WifiBleSettingsPanel(
              gateway: gateway,
              refreshInterval: const Duration(days: 1),
            ),
          ),
        ),
      );
      await tester.pump();

      final Image wifiIcon = tester.widget<Image>(
        _assetImageInside(
          find.byKey(const ValueKey('settings_wifi_row')),
          'assets/WifiBLE/wifi.png',
        ),
      );
      final Image bleIcon = tester.widget<Image>(
        _assetImageInside(
          find.byKey(const ValueKey('settings_ble_row')),
          'assets/WifiBLE/ble.png',
        ),
      );
      expect(wifiIcon.color, const Color(0xFFB6B6B6));
      expect(bleIcon.color, isNull);
    },
  );
}

class FakePanelGateway implements ConnectionDetailsGateway {
  FakePanelGateway({
    this.wifiConnected = true,
    this.wifiName,
    this.bluetoothName,
  });

  bool wifiConnected;
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
  Future<WifiConnectionStatus> readWifiStatus() async => wifiConnected
      ? WifiConnectionStatus.connected
      : WifiConnectionStatus.disconnected;
}

class PendingPanelGateway extends FakePanelGateway {
  final Completer<WifiConnectionStatus> _pendingWifiStatus =
      Completer<WifiConnectionStatus>();
  final Completer<String?> _pendingBluetoothName = Completer<String?>();

  @override
  Future<WifiConnectionStatus> readWifiStatus() => _pendingWifiStatus.future;

  @override
  Future<String?> readConnectedBleDeviceName() => _pendingBluetoothName.future;
}

Finder _assetImageInside(Finder parent, String assetName) {
  return find.descendant(
    of: parent,
    matching: find.byWidgetPredicate(
      (Widget widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName == assetName,
    ),
  );
}

Finder _sizedContainerInside(Finder parent, double width, double height) {
  return find.descendant(
    of: parent,
    matching: find.byWidgetPredicate(
      (Widget widget) =>
          widget is Container &&
          widget.constraints ==
              BoxConstraints.tightFor(width: width, height: height),
    ),
  );
}

Finder _styledTextInside(Finder parent, String text, double fontSize) {
  return find.descendant(
    of: parent,
    matching: find.byWidgetPredicate(
      (Widget widget) =>
          widget is Text &&
          widget.data == text &&
          widget.style?.fontSize == fontSize,
    ),
  );
}
