import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infibo_app/pages/WifiBluetooth/connection_prompt_controller.dart';
import 'package:infibo_app/pages/WifiBluetooth/connection_prompt_dialog.dart';
import 'package:infibo_app/pages/WifiBluetooth/connection_prompt_host.dart';
import 'package:infibo_app/pages/WifiBluetooth/logic.dart';
import 'package:infibo_app/translation/app_translations.dart';

void main() {
  testWidgets('dialog enter arrows use the specified gray color', (
    WidgetTester tester,
  ) async {
    final FakeConnectionPromptGateway gateway = FakeConnectionPromptGateway(
      wifiConnected: true,
      bleConnected: false,
    );
    addTearDown(gateway.dispose);

    await tester.pumpWidget(_hostApp(gateway: gateway));
    await tester.pump();

    for (final String rowKey in <String>[
      'connection_prompt_wifi_row',
      'connection_prompt_ble_row',
    ]) {
      final Image arrow = tester.widget<Image>(
        _assetImageInside(
          find.byKey(ValueKey<String>(rowKey)),
          'assets/WifiBLE/enter.png',
        ),
      );
      expect(arrow.color, const Color(0xFFB6B6B6));
      expect(arrow.colorBlendMode, BlendMode.srcIn);
    }
  });

  test('every supported locale provides all connection prompt messages', () {
    const List<String> promptKeys = <String>[
      'connection_prompt_title',
      'connection_prompt_subtitle',
      'connection_prompt_wifi',
      'connection_prompt_ble',
      'connection_status_checking',
      'connection_status_connected',
      'connection_status_disconnected',
      'connection_prompt_skip',
    ];

    for (final MapEntry<String, Map<String, String>> locale
        in AppTranslations().keys.entries) {
      for (final String key in promptKeys) {
        expect(
          locale.value[key],
          isNotNull,
          reason: '${locale.key} is missing $key',
        );
      }
      expect(
        locale.value['connection_prompt_ble'],
        'BLE',
        reason: '${locale.key} must use the BLE row label',
      );
    }
  });

  test('every locale uses the approved short prompt headings', () {
    const Map<String, (String, String)> expected = <String, (String, String)>{
      'zh_CN': ('未连接', '请连接后继续'),
      'en_US': ('Not connected', 'Connect to continue'),
      'es_ES': ('No conectado', 'Conecta para continuar'),
      'pt_PT': ('Não conectado', 'Conecte para continuar'),
      'ru_RU': ('Не подключено', 'Сначала подключитесь'),
      'fr_FR': ('Non connecté', 'Connectez-vous d’abord'),
      'ko_KR': ('연결 안 됨', '연결 후 계속하세요'),
      'ar_SA': ('غير متصل', 'يرجى الاتصال للمتابعة'),
      'de_DE': ('Nicht verbunden', 'Zum Fortfahren verbinden'),
      'tr_TR': ('Bağlı değil', 'Bağlanıp devam edin'),
    };

    for (final MapEntry<String, (String, String)> entry in expected.entries) {
      final Map<String, String> messages = AppTranslations().keys[entry.key]!;
      expect(messages['connection_prompt_title'], entry.value.$1);
      expect(messages['connection_prompt_subtitle'], entry.value.$2);
    }
  });

  testWidgets('German locale translates the prompt without wrapping headers', (
    WidgetTester tester,
  ) async {
    final FakeConnectionPromptGateway gateway = FakeConnectionPromptGateway();
    addTearDown(gateway.dispose);

    await tester.pumpWidget(
      _hostApp(gateway: gateway, locale: const Locale('de', 'DE')),
    );
    await tester.pump();

    final Finder title = _headerText('Nicht verbunden', 24);
    final Finder subtitle = _headerText('Zum Fortfahren verbinden', 18);
    expect(title, findsOneWidget);
    expect(subtitle, findsOneWidget);
    expect(find.text('Nicht verbunden'), findsNWidgets(3));
    expect(tester.widget<Text>(title).maxLines, 1);
    expect(tester.widget<Text>(subtitle).maxLines, 1);
    final Size titleSize = tester.getSize(
      find.ancestor(of: title, matching: find.byType(FittedBox)),
    );
    final Size subtitleSize = tester.getSize(
      find.ancestor(of: subtitle, matching: find.byType(FittedBox)),
    );
    expect(titleSize.width, lessThanOrEqualTo(448));
    expect(titleSize.height, lessThanOrEqualTo(30));
    expect(subtitleSize.width, 448);
    expect(subtitleSize.height, lessThanOrEqualTo(24));
    final RenderBox titleTextBox = tester.renderObject<RenderBox>(title);
    final RenderBox titleFittedBox = tester.renderObject<RenderBox>(
      find.ancestor(of: title, matching: find.byType(FittedBox)),
    );
    expect(
      titleTextBox.getTransformTo(titleFittedBox).storage[0],
      closeTo(1, 0.0001),
    );
  });

  testWidgets('Arabic locale mirrors the rows and their settings arrows', (
    WidgetTester tester,
  ) async {
    final FakeConnectionPromptGateway gateway = FakeConnectionPromptGateway();
    addTearDown(gateway.dispose);

    await tester.pumpWidget(
      _hostApp(gateway: gateway, locale: const Locale('ar', 'SA')),
    );
    await tester.pump();

    expect(_headerText('غير متصل', 24), findsOneWidget);
    expect(
      Directionality.of(
        tester.element(
          find.byKey(const ValueKey<String>('connection_prompt_wifi_row')),
        ),
      ),
      TextDirection.rtl,
    );
    final Transform arrow = tester.widget<Transform>(
      find.byKey(
        const ValueKey<String>('connection_prompt_wifi_enter_transform'),
      ),
    );
    expect(arrow.transform.entry(0, 0), -1);
  });

  testWidgets('matches the reference dialog structure and geometry', (
    WidgetTester tester,
  ) async {
    final FakeConnectionPromptGateway gateway = FakeConnectionPromptGateway(
      wifiConnected: true,
    );
    addTearDown(gateway.dispose);

    await tester.pumpWidget(_hostApp(gateway: gateway));
    await tester.pump();

    final Finder dialog = find.byType(WifiBluetoothConnectionDialog);
    final Finder wifiRow = find.byKey(
      const ValueKey<String>('connection_prompt_wifi_row'),
    );
    final Finder bleRow = find.byKey(
      const ValueKey<String>('connection_prompt_ble_row'),
    );
    final Rect dialogRect = tester.getRect(dialog);

    expect(dialogRect.size, const Size(448, 480));
    expect(tester.getCenter(_headerText('未连接', 24)).dx, dialogRect.center.dx);
    expect(
      tester.getCenter(_headerText('请连接后继续', 18)).dx,
      dialogRect.center.dx,
    );
    expect(find.text('BLE'), findsOneWidget);
    expect(tester.getSize(wifiRow), const Size(384, 104));
    expect(
      tester.getTopLeft(wifiRow) - dialogRect.topLeft,
      const Offset(32, 138),
    );
    expect(
      tester.getTopLeft(bleRow) - dialogRect.topLeft,
      const Offset(32, 262),
    );
    expect(
      tester.getSize(
        find.byKey(const ValueKey<String>('connection_prompt_wifi_icon_bg')),
      ),
      const Size.square(64),
    );
    expect(
      tester.getSize(
        find.byKey(const ValueKey<String>('connection_prompt_ble_icon_bg')),
      ),
      const Size.square(64),
    );
    final Image connectedWifiIcon = tester.widget<Image>(
      _assetImageInside(wifiRow, 'assets/WifiBLE/wifi.png'),
    );
    final Image disconnectedBleIcon = tester.widget<Image>(
      _assetImageInside(bleRow, 'assets/WifiBLE/ble.png'),
    );
    expect(connectedWifiIcon.color, isNull);
    expect(disconnectedBleIcon.color, const Color(0xFFB6B6B6));
    for (final Key iconKey in <Key>[
      const ValueKey<String>('connection_prompt_wifi_icon_bg'),
      const ValueKey<String>('connection_prompt_ble_icon_bg'),
    ]) {
      final Container iconBackground = tester.widget<Container>(
        find.byKey(iconKey),
      );
      final BoxDecoration decoration =
          iconBackground.decoration! as BoxDecoration;
      expect(decoration.color, const Color(0x0FFFFFFF));
      expect(decoration.shape, BoxShape.circle);
    }
    for (final String label in <String>['WIFI', 'BLE']) {
      final Text rowLabel = tester.widget<Text>(find.text(label));
      expect(rowLabel.style?.fontSize, 22);
      expect(rowLabel.style?.color, Colors.white);
      expect(rowLabel.style?.fontWeight, FontWeight.w400);
    }
    final Finder connectedDot = _statusDotInside(wifiRow);
    final Finder disconnectedDot = _statusDotInside(bleRow);
    expect(
      (tester.widget<Container>(connectedDot).decoration! as BoxDecoration)
          .color,
      const Color(0xFF48F46D),
    );
    expect(
      (tester.widget<Container>(disconnectedDot).decoration! as BoxDecoration)
          .color,
      const Color(0xFFB6B6B6),
    );
    expect(
      find.descendant(
        of: wifiRow,
        matching: find.byWidgetPredicate(
          (Widget widget) => widget is SizedBox && widget.width == 9,
        ),
      ),
      findsOneWidget,
    );
    expect(
      tester.getTopLeft(find.text('已连接')).dy,
      greaterThan(tester.getBottomLeft(find.text('WIFI')).dy),
    );
    expect(
      find.byKey(const ValueKey<String>('connection_prompt_divider')),
      findsOneWidget,
    );
  });

  testWidgets('header text does not inherit the fallback double underline', (
    WidgetTester tester,
  ) async {
    final FakeConnectionPromptGateway gateway = FakeConnectionPromptGateway();
    addTearDown(gateway.dispose);

    await tester.pumpWidget(_hostApp(gateway: gateway));
    await tester.pump();

    for (final (String text, double fontSize) in <(String, double)>[
      ('未连接', 24),
      ('请连接后继续', 18),
    ]) {
      final RichText renderedText = tester.widget<RichText>(
        find.descendant(
          of: _headerText(text, fontSize),
          matching: find.byType(RichText),
        ),
      );
      expect(
        renderedText.text.style?.decoration,
        isNot(TextDecoration.underline),
      );
      expect(
        renderedText.text.style?.decorationStyle,
        isNot(TextDecorationStyle.double),
      );
    }
  });

  testWidgets('short Chinese headings keep their declared font sizes', (
    WidgetTester tester,
  ) async {
    final FakeConnectionPromptGateway gateway = FakeConnectionPromptGateway();
    addTearDown(gateway.dispose);

    await tester.pumpWidget(_hostApp(gateway: gateway));
    await tester.pump();

    for (final (String value, double fontSize) in <(String, double)>[
      ('未连接', 24),
      ('请连接后继续', 18),
    ]) {
      final Finder textFinder = _headerText(value, fontSize);
      final Finder fittedFinder = find.ancestor(
        of: textFinder,
        matching: find.byType(FittedBox),
      );
      final Text text = tester.widget<Text>(textFinder);
      final RenderBox textBox = tester.renderObject<RenderBox>(textFinder);
      final RenderBox fittedBox = tester.renderObject<RenderBox>(fittedFinder);

      expect(text.style?.fontSize, fontSize);
      expect(text.style?.height, 1);
      expect(textBox.getTransformTo(fittedBox).storage[0], closeTo(1, 0.0001));
    }
  });

  testWidgets('shows checking state until delayed initial reads connect', (
    WidgetTester tester,
  ) async {
    final Completer<WifiConnectionStatus> wifiRead =
        Completer<WifiConnectionStatus>();
    final Completer<bool> bleRead = Completer<bool>();
    final FakeConnectionPromptGateway gateway = FakeConnectionPromptGateway(
      wifiReader: () => wifiRead.future,
      bleReader: () => bleRead.future,
    );

    await tester.pumpWidget(_hostApp(gateway: gateway));
    await tester.pump();

    expect(find.text('检测中'), findsNWidgets(2));
    for (final Finder row in <Finder>[
      find.byKey(const ValueKey<String>('connection_prompt_wifi_row')),
      find.byKey(const ValueKey<String>('connection_prompt_ble_row')),
    ]) {
      expect(
        (tester.widget<Container>(_statusDotInside(row)).decoration!
                as BoxDecoration)
            .color,
        const Color(0xFF42B7FF),
      );
    }

    wifiRead.complete(WifiConnectionStatus.connected);
    bleRead.complete(true);
    await tester.pump();
    await tester.pump();

    expect(_headerText('未连接', 24), findsNothing);
    await gateway.dispose();
  });

  testWidgets('shows connection states and opens both system settings', (
    WidgetTester tester,
  ) async {
    final FakeConnectionPromptGateway gateway = FakeConnectionPromptGateway();

    await tester.pumpWidget(_hostApp(gateway: gateway));
    await tester.pump();

    expect(_headerText('未连接', 24), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('connection_prompt_wifi_row')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('connection_prompt_ble_row')),
      findsOneWidget,
    );
    expect(find.text('跳过'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('connection_prompt_wifi_row')),
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('connection_prompt_ble_row')),
    );
    await tester.pump();

    expect(gateway.openWifiSettingsCalls, 1);
    expect(gateway.openBluetoothSettingsCalls, 1);
    await gateway.dispose();
  });

  testWidgets('skip remains hidden until both connections recover', (
    WidgetTester tester,
  ) async {
    final FakeConnectionPromptGateway gateway = FakeConnectionPromptGateway();
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      _hostApp(gateway: gateway, navigatorKey: navigatorKey),
    );
    await tester.pump();

    await tester.tap(find.text('跳过'));
    await tester.pump();
    expect(_headerText('未连接', 24), findsNothing);

    unawaited(
      navigatorKey.currentState!.push<void>(
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              const Scaffold(body: Text('next route')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    gateway.emitWifiStatus();
    await tester.pump();
    expect(_headerText('未连接', 24), findsNothing);

    gateway
      ..wifiConnected = true
      ..bleConnected = true;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump();

    gateway.bleConnected = false;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump();
    expect(_headerText('未连接', 24), findsOneWidget);
    await gateway.dispose();
  });

  testWidgets(
    'system back keeps the underlying route while prompt is visible',
    (WidgetTester tester) async {
      final FakeConnectionPromptGateway gateway = FakeConnectionPromptGateway(
        wifiConnected: true,
        bleConnected: true,
      );
      final GlobalKey<NavigatorState> navigatorKey =
          GlobalKey<NavigatorState>();
      addTearDown(gateway.dispose);

      await tester.pumpWidget(
        _hostApp(gateway: gateway, navigatorKey: navigatorKey),
      );
      await tester.pump();
      unawaited(
        navigatorKey.currentState!.push<void>(
          MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                const Scaffold(body: Text('second route')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      gateway.bleConnected = false;
      gateway.emitWifiStatus();
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(_headerText('未连接', 24), findsOneWidget);
      expect(find.text('second route'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('second route'), findsOneWidget);
      expect(_headerText('未连接', 24), findsOneWidget);
    },
  );

  testWidgets('modal barrier prevents taps from reaching the page', (
    WidgetTester tester,
  ) async {
    final FakeConnectionPromptGateway gateway = FakeConnectionPromptGateway();
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
    int count = 0;

    await tester.pumpWidget(
      _withPromptAssets(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: TextButton(
                key: const ValueKey<String>('underlying_counter'),
                onPressed: () => count++,
                child: const Text('counter'),
              ),
            ),
          ),
          builder: (BuildContext context, Widget? child) {
            return ConnectionPromptHost(
              navigatorKey: navigatorKey,
              gateway: gateway,
              blePollInterval: const Duration(days: 1),
              child: child!,
            );
          },
        ),
      ),
    );
    await tester.pump();

    await tester.tapAt(
      tester.getCenter(
        find.byKey(const ValueKey<String>('underlying_counter')),
      ),
    );
    await tester.pump();

    expect(count, 0);
    await gateway.dispose();
  });
}

Widget _hostApp({
  required FakeConnectionPromptGateway gateway,
  GlobalKey<NavigatorState>? navigatorKey,
  Locale locale = const Locale('zh', 'CN'),
}) {
  final GlobalKey<NavigatorState> effectiveNavigatorKey =
      navigatorKey ?? GlobalKey<NavigatorState>();
  return _withPromptAssets(
    GetMaterialApp(
      navigatorKey: effectiveNavigatorKey,
      translations: AppTranslations(),
      locale: locale,
      fallbackLocale: const Locale('zh', 'CN'),
      builder: (BuildContext context, Widget? child) {
        return ConnectionPromptHost(
          navigatorKey: effectiveNavigatorKey,
          gateway: gateway,
          blePollInterval: const Duration(days: 1),
          child: child!,
        );
      },
      home: const Scaffold(body: Text('home')),
    ),
  );
}

Finder _statusDotInside(Finder row) {
  return find.descendant(
    of: row,
    matching: find.byWidgetPredicate(
      (Widget widget) =>
          widget is Container &&
          widget.constraints ==
              const BoxConstraints.tightFor(width: 8, height: 8),
    ),
  );
}

Finder _headerText(String value, double fontSize) {
  return find.byWidgetPredicate(
    (Widget widget) =>
        widget is Text &&
        widget.data == value &&
        widget.style?.fontSize == fontSize,
  );
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

Widget _withPromptAssets(Widget child) {
  return DefaultAssetBundle(bundle: _PromptAssetBundle(), child: child);
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
  int openWifiSettingsCalls = 0;
  int openBluetoothSettingsCalls = 0;
  final StreamController<WifiConnectionStatus> _wifiStatuses =
      StreamController<WifiConnectionStatus>.broadcast();

  @override
  Stream<WifiConnectionStatus> get wifiStatusStream => _wifiStatuses.stream;

  @override
  Future<bool> hasConnectedBleDevice() =>
      bleReader?.call() ?? Future<bool>.value(bleConnected);

  @override
  Future<void> openBluetoothSettings() async {
    openBluetoothSettingsCalls++;
  }

  @override
  Future<void> openWifiSettings() async {
    openWifiSettingsCalls++;
  }

  @override
  Future<WifiConnectionStatus> readWifiStatus() =>
      wifiReader?.call() ??
      Future<WifiConnectionStatus>.value(
        wifiConnected
            ? WifiConnectionStatus.connected
            : WifiConnectionStatus.disconnected,
      );

  void emitWifiStatus() {
    _wifiStatuses.add(
      wifiConnected
          ? WifiConnectionStatus.connected
          : WifiConnectionStatus.disconnected,
    );
  }

  Future<void> dispose() => _wifiStatuses.close();
}

class _PromptAssetBundle extends CachingAssetBundle {
  static const List<String> _assetKeys = <String>[
    'assets/WifiBLE/bg.png',
    'assets/WifiBLE/wifi.png',
    'assets/WifiBLE/ble.png',
    'assets/WifiBLE/enter.png',
  ];
  static final ByteData _assetManifest = const StandardMessageCodec()
      .encodeMessage(<String, List<Map<String, Object?>>>{
        for (final String key in _assetKeys)
          key: <Map<String, Object?>>[
            <String, Object?>{'asset': key, 'dpr': null},
          ],
      })!;
  static final Uint8List _transparentPixel = Uint8List.fromList(<int>[
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1F,
    0x15,
    0xC4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x44,
    0x41,
    0x54,
    0x08,
    0xD7,
    0x63,
    0xF8,
    0xCF,
    0xC0,
    0xF0,
    0x1F,
    0x00,
    0x05,
    0x00,
    0x01,
    0xFF,
    0x89,
    0x99,
    0x3D,
    0x1D,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
    0x42,
    0x60,
    0x82,
  ]);

  @override
  Future<ByteData> load(String key) async {
    if (key == 'AssetManifest.bin') return _assetManifest;
    return ByteData.sublistView(_transparentPixel);
  }
}
