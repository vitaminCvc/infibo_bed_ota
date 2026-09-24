import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/api/dio/therapy_report/therapy_report_models.dart';
import 'package:infibo_app/api/dio/login/login_models.dart';
import 'package:infibo_app/api/modbus/modbus_rtu_service.dart';
import 'package:infibo_app/components/water_level_state_dialog.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/pages/customized/logic.dart';
import 'package:infibo_app/pages/music/logic.dart';
import 'package:infibo_app/pages/main/ui.dart';
import 'package:infibo_app/pages/settingpage/logic.dart';
import 'package:infibo_app/pages/start/logic.dart';
import 'package:infibo_app/routes/route_observer.dart';
import 'package:infibo_app/stores/app_header_clock_store.dart';
import 'package:infibo_app/stores/hifem_setting_store.dart';
import 'package:infibo_app/stores/user_store.dart';
import 'package:infibo_app/translation/app_translations.dart';
import 'package:infibo_app/utils/email_utils.dart';
import 'package:infibo_app/utils/gender_utils.dart';
import 'package:infibo_app/utils/localized_api_message.dart';

void main() {
  test('logout labels stay compact in constrained menu', () {
    const Map<String, String> compactLabels = <String, String>{
      'pt_PT': 'Sair',
      'fr_FR': 'Quitter',
      'ar_SA': 'خروج',
    };

    final Map<String, Map<String, String>> translations =
        AppTranslations().keys;
    for (final MapEntry<String, String> expected in compactLabels.entries) {
      expect(translations[expected.key]?['logout'], expected.value);
    }
  });

  test('chakra power uses compact labels in every locale', () {
    const Map<String, String> expectedLabels = <String, String>{
      'zh_CN': '强度',
      'en_US': 'Power',
      'es_ES': 'Pot.',
      'pt_PT': 'Pot.',
      'ru_RU': 'Мощ.',
      'fr_FR': 'Puis.',
      'ko_KR': '출력',
      'ar_SA': 'قدرة',
      'de_DE': 'Leist.',
      'tr_TR': 'Güç',
    };

    final Map<String, Map<String, String>> translations =
        AppTranslations().keys;
    for (final MapEntry<String, String> expected in expectedLabels.entries) {
      expect(
        translations[expected.key]?['chakra_power'],
        expected.value,
        reason: '${expected.key} needs a compact chakra power label',
      );
    }
  });

  test('gender values are localized for the current language', () {
    Get.addTranslations(AppTranslations().keys);
    Get.updateLocale(const Locale('en', 'US'));

    expect(localizedGenderText('女'), 'F');
    expect(localizedGenderText('男'), 'M');
    expect(localizedGenderText('female'), 'F');
    expect(localizedGenderText('unknown'), 'unknown');
  });

  test('Chinese backend messages use translated fallback outside Chinese', () {
    Get.addTranslations(AppTranslations().keys);
    Get.updateLocale(const Locale('en', 'US'));

    expect(
      localizedApiMessage('登录成功', fallbackKey: 'login_success'),
      'Login successful',
    );
    expect(
      localizedApiMessage('Account locked', fallbackKey: 'login_failed'),
      'Account locked',
    );
  });

  test('authentication translation keys exist in every locale', () {
    const Set<String> requiredKeys = <String>{
      'code_sent_backend_email',
      'confirm_new_password_hint',
      'confirm_new_password_required',
      'confirm_reset',
      'email_required',
      'error',
      'login_failed',
      'login_request_failed',
      'login_success',
      'login_success_empty_user',
      'new_password_hint',
      'new_password_required',
      'password_required',
      'password_reset_failed',
      'password_reset_success',
      'passwords_not_match',
      'resetting_password',
      'verify_code_required',
    };

    final Map<String, Map<String, String>> translations =
        AppTranslations().keys;
    for (final MapEntry<String, Map<String, String>> locale
        in translations.entries) {
      for (final String key in requiredKeys) {
        expect(
          locale.value[key],
          isNotNull,
          reason: '${locale.key} is missing $key',
        );
        expect(
          locale.value[key],
          isNot(key),
          reason: '${locale.key} has not translated $key',
        );
      }
    }
  });

  test('water level state translations exist in every locale', () {
    const Set<String> requiredKeys = <String>{
      'water_level_shortage_title',
      'water_level_shortage_message',
      'water_level_filling_title',
      'water_level_filling_message',
      'water_level_complete_title',
      'water_level_complete_message',
      'water_level_ready_button',
      'water_level_start_filling_button',
    };
    final Map<String, Map<String, String>> translations =
        AppTranslations().keys;

    for (final MapEntry<String, Map<String, String>> locale
        in translations.entries) {
      for (final String key in requiredKeys) {
        expect(
          locale.value[key],
          isNotNull,
          reason: '${locale.key} is missing $key',
        );
        expect(
          locale.value[key],
          isNot(key),
          reason: '${locale.key} has not translated $key',
        );
      }
    }
  });

  testWidgets('water level state dialog renders shortage state (1)', (
    WidgetTester tester,
  ) async {
    Get.addTranslations(AppTranslations().keys);
    Get.updateLocale(const Locale('zh', 'CN'));

    final ValueNotifier<int> notifier = ValueNotifier<int>(1);
    int startFillingCalls = 0;

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Center(
            child: WaterLevelStateDialog(
              notifier: notifier,
              onStartFilling: () => startFillingCalls++,
            ),
          ),
        ),
      ),
    );

    expect(find.text('设备缺水提醒'), findsOneWidget);
    expect(find.text('水量不足，请连接水源自动加水'), findsOneWidget);
    expect(find.text('分子氢功能暂不可用'), findsOneWidget);

    // 第一次点击只确认水源：按钮文案切到 Start Filling，不触发加水。
    expect(find.text('已备好水源？'), findsOneWidget);
    await tester.tap(find.text('已备好水源？'));
    await tester.pump();
    expect(find.text('开始加水'), findsOneWidget);
    expect(startFillingCalls, 0);

    // 第二次点击才开始自动加水。
    await tester.tap(find.text('开始加水'));
    await tester.pump();
    expect(startFillingCalls, 1);
  });

  testWidgets('water level state dialog transitions to filling state (2)', (
    WidgetTester tester,
  ) async {
    Get.addTranslations(AppTranslations().keys);
    Get.updateLocale(const Locale('zh', 'CN'));

    final ValueNotifier<int> notifier = ValueNotifier<int>(1);

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Center(
            child: WaterLevelStateDialog(
              notifier: notifier,
              onStartFilling: () {},
            ),
          ),
        ),
      ),
    );

    // Initial state: shortage
    expect(find.text('设备缺水提醒'), findsOneWidget);

    // Transition to filling
    notifier.value = 2;
    await tester.pump();

    expect(find.text('注水中'), findsOneWidget);
    expect(find.text('正在注水，请稍候...'), findsOneWidget);
    expect(find.text('设备缺水提醒'), findsNothing);
  });

  testWidgets('shortage dialog cannot be dismissed manually', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1024, 1366));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Get.testMode = true;
    Get.addTranslations(AppTranslations().keys);
    Get.updateLocale(const Locale('zh', 'CN'));
    Get.put(UserStore());
    addTearDown(() {
      if (Get.isRegistered<AppHeaderClockController>()) {
        Get.delete<AppHeaderClockController>(force: true);
      }
      Get.reset();
    });

    final _FakeWaterLevelModbusService modbusService =
        _FakeWaterLevelModbusService(waterLevelStates: const <int>[1]);

    await tester.pumpWidget(
      GetMaterialApp(
        navigatorObservers: [appRouteObserver],
        home: MainPage(modbusService: modbusService),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('设备缺水提醒'), findsOneWidget);

    // 缺水弹窗不能手动关闭：遮罩没有关闭手势，点击外部也不生效。
    final Finder barrier = find.byKey(
      const ValueKey<String>('water_level_dialog_barrier'),
    );
    expect(tester.widget<GestureDetector>(barrier).onTap, isNull);
    await tester.tapAt(const Offset(50, 1000));
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    expect(find.text('设备缺水提醒'), findsOneWidget);
    expect(find.text('已备好水源？'), findsOneWidget);

    // 离开首页再回来依然保持提醒（弹窗从未被关闭）。
    final BuildContext mainContext = tester.element(find.byType(MainPage));
    Navigator.of(mainContext).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(
          key: ValueKey<String>('water_level_reentry_test_page'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    final Finder reentryPage = find.byKey(
      const ValueKey<String>('water_level_reentry_test_page'),
    );
    expect(reentryPage, findsOneWidget);
    Navigator.of(tester.element(reentryPage)).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('设备缺水提醒'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    if (Get.isRegistered<AppHeaderClockController>()) {
      Get.find<AppHeaderClockController>().onClose();
      Get.delete<AppHeaderClockController>(force: true);
    }
  });

  testWidgets('mode card header places icon and translated title in one row', (
    WidgetTester tester,
  ) async {
    Get.testMode = true;
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    Get.put(UserStore());
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      Get.reset();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('zh', 'CN'),
        navigatorObservers: [appRouteObserver],
        home: MainPage(
          modbusService: _FakeWaterLevelModbusService(
            waterLevelStates: const <int>[0],
          ),
        ),
      ),
    );
    await tester.pump();

    final Finder headerRowFinder = find.byWidgetPredicate((Widget widget) {
      if (widget is! Row || widget.children.length != 3) return false;
      final Widget titleSlot = widget.children[2];
      if (titleSlot is! Expanded) return false;
      final Widget titlePadding = titleSlot.child;
      if (titlePadding is! Padding) return false;
      final Widget? title = titlePadding.child;
      return title is Text && title.data == '深度放松';
    });

    expect(headerRowFinder, findsOneWidget);
    final Row headerRow = tester.widget<Row>(headerRowFinder);
    expect(headerRow.children[0], isA<SizedBox>());
    final SizedBox iconBox = headerRow.children[0] as SizedBox;
    expect(iconBox.width, 24);
    expect(iconBox.height, 24);
    final Image icon = iconBox.child! as Image;
    expect(
      (icon.image as AssetImage).assetName,
      'assets/Mode/DeepRelaxation_Icon.png',
    );
    expect(headerRow.children[1], isA<SizedBox>());
    expect((headerRow.children[1] as SizedBox).width, 5);
    expect(headerRow.children[2], isA<Expanded>());
    final Expanded titleSlot = headerRow.children[2] as Expanded;
    final Padding titlePadding = titleSlot.child as Padding;
    expect(titlePadding.padding.resolve(TextDirection.ltr).bottom, 6);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    if (Get.isRegistered<AppHeaderClockController>()) {
      Get.find<AppHeaderClockController>().onClose();
      Get.delete<AppHeaderClockController>(force: true);
    }
  });

  testWidgets('mode card title keeps its default position in English', (
    WidgetTester tester,
  ) async {
    Get.testMode = true;
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    Get.put(UserStore());
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      Get.reset();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en', 'US'),
        navigatorObservers: [appRouteObserver],
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(0.5)),
            child: child!,
          );
        },
        home: MainPage(
          modbusService: _FakeWaterLevelModbusService(
            waterLevelStates: const <int>[0],
          ),
        ),
      ),
    );
    await tester.pump();

    final Finder headerRowFinder = find.byWidgetPredicate((Widget widget) {
      if (widget is! Row || widget.children.length != 3) return false;
      final Widget titleSlot = widget.children[2];
      if (titleSlot is! Expanded) return false;
      final Widget titlePadding = titleSlot.child;
      if (titlePadding is! Padding) return false;
      final Widget? title = titlePadding.child;
      return title is Text && title.data == 'DEEP RELAX';
    });

    expect(headerRowFinder, findsOneWidget);
    final Row headerRow = tester.widget<Row>(headerRowFinder);
    final Expanded titleSlot = headerRow.children[2] as Expanded;
    final Padding titlePadding = titleSlot.child as Padding;
    expect(titlePadding.padding.resolve(TextDirection.ltr).bottom, 0);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    if (Get.isRegistered<AppHeaderClockController>()) {
      Get.find<AppHeaderClockController>().onClose();
      Get.delete<AppHeaderClockController>(force: true);
    }
  });

  testWidgets('home refreshes the ambient light icon from register 0x0012', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1024, 1366));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Get.testMode = true;
    Get.addTranslations(AppTranslations().keys);
    Get.updateLocale(const Locale('zh', 'CN'));
    Get.put(UserStore());
    addTearDown(() {
      if (Get.isRegistered<AppHeaderClockController>()) {
        Get.delete<AppHeaderClockController>(force: true);
      }
      Get.reset();
    });

    final _FakeWaterLevelModbusService modbusService =
        _FakeWaterLevelModbusService(
          waterLevelStates: const <int>[0],
          ambientLightState: 0,
        );

    await tester.pumpWidget(
      GetMaterialApp(
        navigatorObservers: [appRouteObserver],
        home: MainPage(modbusService: modbusService),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(_findAssetImage(Assets.lightCloseLogo), findsOneWidget);
    expect(modbusService.ambientLightReads, greaterThanOrEqualTo(1));

    modbusService.ambientLightState = 1;
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 250));

    expect(_findAssetImage(Assets.lightOpenLogo), findsOneWidget);
    expect(modbusService.ambientLightReads, greaterThanOrEqualTo(2));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    if (Get.isRegistered<AppHeaderClockController>()) {
      Get.find<AppHeaderClockController>().onClose();
      Get.delete<AppHeaderClockController>(force: true);
    }
  });

  testWidgets('water level state dialog appears on 0x01E5=1', (
    WidgetTester tester,
  ) async {
    Get.testMode = true;
    Get.addTranslations(AppTranslations().keys);
    Get.updateLocale(const Locale('zh', 'CN'));
    Get.put(UserStore());
    addTearDown(() {
      if (Get.isRegistered<AppHeaderClockController>()) {
        Get.delete<AppHeaderClockController>(force: true);
      }
      Get.reset();
    });

    final _FakeWaterLevelModbusService modbusService =
        _FakeWaterLevelModbusService();

    await tester.pumpWidget(
      GetMaterialApp(
        navigatorObservers: [appRouteObserver],
        home: MainPage(modbusService: modbusService),
      ),
    );

    // First read returns 0 → no dialog
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('设备缺水提醒'), findsNothing);

    // Second read returns 1 → dialog opens with "缺水" state
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('设备缺水提醒'), findsOneWidget);
    expect(modbusService.waterLevelReads, greaterThanOrEqualTo(2));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    if (Get.isRegistered<AppHeaderClockController>()) {
      Get.find<AppHeaderClockController>().onClose();
      Get.delete<AppHeaderClockController>(force: true);
    }
  });

  testWidgets(
    'water recovery keeps the shortage dialog open until completion',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1024, 1366));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      Get.testMode = true;
      Get.addTranslations(AppTranslations().keys);
      Get.updateLocale(const Locale('zh', 'CN'));
      Get.put(UserStore());
      addTearDown(() {
        if (Get.isRegistered<AppHeaderClockController>()) {
          Get.delete<AppHeaderClockController>(force: true);
        }
        Get.reset();
      });

      final _FakeWaterLevelModbusService modbusService =
          _FakeWaterLevelModbusService(waterLevelStates: const <int>[1]);

      await tester.pumpWidget(
        GetMaterialApp(
          navigatorObservers: [appRouteObserver],
          home: MainPage(modbusService: modbusService),
        ),
      );
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('设备缺水提醒'), findsOneWidget);

      final Finder barrier = find.byKey(
        const ValueKey<String>('water_level_dialog_barrier'),
      );
      expect(tester.widget<GestureDetector>(barrier).onTap, isNull);
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('设备缺水提醒'), findsOneWidget);

      // 水位回到正常(2)：按需求弹窗保持打开，等待用户继续加水流程。
      modbusService.waterLevelOverride = 2;
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('设备缺水提醒'), findsOneWidget);

      // 离开首页再回来依然保持提醒（弹窗从未被关闭）。
      final BuildContext mainContext = tester.element(find.byType(MainPage));
      Navigator.of(mainContext).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(
            key: ValueKey<String>('water_level_reentry_test_page'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      final Finder reentryPage = find.byKey(
        const ValueKey<String>('water_level_reentry_test_page'),
      );
      expect(reentryPage, findsOneWidget);
      Navigator.of(tester.element(reentryPage)).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('设备缺水提醒'), findsOneWidget);

      // 高水位(3) → 注水完成；点击屏幕任意位置关闭后，再次缺水可重新弹出。
      modbusService.waterLevelOverride = 3;
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('注水完成'), findsOneWidget);

      await tester.tapAt(const Offset(50, 1000));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('注水完成'), findsNothing);

      modbusService.waterLevelOverride = 1;
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('设备缺水提醒'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      if (Get.isRegistered<AppHeaderClockController>()) {
        Get.find<AppHeaderClockController>().onClose();
        Get.delete<AppHeaderClockController>(force: true);
      }
    },
  );

  testWidgets(
    'Ready? only switches the label and Start Filling writes 0x01EB=1',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1024, 1366));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      Get.testMode = true;
      Get.addTranslations(AppTranslations().keys);
      Get.updateLocale(const Locale('zh', 'CN'));
      Get.put(UserStore());
      addTearDown(() {
        if (Get.isRegistered<AppHeaderClockController>()) {
          Get.delete<AppHeaderClockController>(force: true);
        }
        Get.reset();
      });

      final _FakeWaterLevelModbusService modbusService =
          _FakeWaterLevelModbusService(waterLevelStates: const <int>[1]);

      await tester.pumpWidget(
        GetMaterialApp(
          navigatorObservers: [appRouteObserver],
          home: MainPage(modbusService: modbusService),
        ),
      );
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('已备好水源？'), findsOneWidget);

      // 第一次点击只切换按钮文案，不发送串口指令。
      await tester.tap(find.text('已备好水源？'));
      await tester.pump();
      expect(find.text('开始加水'), findsOneWidget);
      expect(modbusService.waterFillingCommands, isEmpty);

      // 第二次点击写 0x01EB=1 并切到注水中。
      await tester.tap(find.text('开始加水'));
      await tester.pump();
      expect(find.text('注水中'), findsOneWidget);
      expect(modbusService.waterFillingCommands, hasLength(1));
      expect(modbusService.waterFillingCommands.single.address, 0x01EB);
      expect(modbusService.waterFillingCommands.single.value, 1);

      // 注水中不能手动关闭。
      final Finder barrier = find.byKey(
        const ValueKey<String>('water_level_dialog_barrier'),
      );
      expect(tester.widget<GestureDetector>(barrier).onTap, isNull);
      await tester.tapAt(const Offset(50, 1000));
      await tester.pump();
      expect(find.text('注水中'), findsOneWidget);

      // 2=正常水位只是加水中的中间值，不能提前提示完成。
      modbusService.waterLevelOverride = 2;
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('注水中'), findsOneWidget);

      // 高水位(3) → 注水完成，点击屏幕任意位置关闭。
      modbusService.waterLevelOverride = 3;
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('注水完成'), findsOneWidget);
      expect(tester.widget<GestureDetector>(barrier).onTap, isNotNull);

      await tester.tap(find.text('注水完成'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('注水完成'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      if (Get.isRegistered<AppHeaderClockController>()) {
        Get.find<AppHeaderClockController>().onClose();
        Get.delete<AppHeaderClockController>(force: true);
      }
    },
  );

  testWidgets('water level complete dialog auto dismisses after five seconds', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1024, 1366));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Get.testMode = true;
    Get.addTranslations(AppTranslations().keys);
    Get.updateLocale(const Locale('zh', 'CN'));
    Get.put(UserStore());
    addTearDown(() {
      if (Get.isRegistered<AppHeaderClockController>()) {
        Get.delete<AppHeaderClockController>(force: true);
      }
      Get.reset();
    });

    final _FakeWaterLevelModbusService modbusService =
        _FakeWaterLevelModbusService(waterLevelStates: <int>[1, 3]);

    await tester.pumpWidget(
      GetMaterialApp(
        navigatorObservers: [appRouteObserver],
        home: MainPage(modbusService: modbusService),
      ),
    );

    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('设备缺水提醒'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('注水完成'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    expect(find.text('注水完成'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('注水完成'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    if (Get.isRegistered<AppHeaderClockController>()) {
      Get.find<AppHeaderClockController>().onClose();
      Get.delete<AppHeaderClockController>(force: true);
    }
  });

  testWidgets('water level complete dialog still dismisses on barrier tap', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1024, 1366));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Get.testMode = true;
    Get.addTranslations(AppTranslations().keys);
    Get.updateLocale(const Locale('zh', 'CN'));
    Get.put(UserStore());
    addTearDown(() {
      if (Get.isRegistered<AppHeaderClockController>()) {
        Get.delete<AppHeaderClockController>(force: true);
      }
      Get.reset();
    });

    final _FakeWaterLevelModbusService modbusService =
        _FakeWaterLevelModbusService(waterLevelStates: <int>[1, 3]);

    await tester.pumpWidget(
      GetMaterialApp(
        navigatorObservers: [appRouteObserver],
        home: MainPage(modbusService: modbusService),
      ),
    );

    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('注水完成'), findsOneWidget);

    await tester.tapAt(const Offset(1000, 1300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('注水完成'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    if (Get.isRegistered<AppHeaderClockController>()) {
      Get.find<AppHeaderClockController>().onClose();
      Get.delete<AppHeaderClockController>(force: true);
    }
  });

  test('LoginResult parses backend login data', () {
    final LoginResult result = LoginResult.fromJson({
      'id': '0',
      'email': '00000000',
      'role': 'user',
    });

    expect(result.id, 0);
    expect(result.email, '00000000');
    expect(result.role, 'user');
  });

  test('therapy report request serializes duration seconds', () {
    final Map<String, Object?> json = SaveTherapyReportRequestDto(
      clientId: 7,
      planName: 'Relax',
      planType: 'preset',
      reportTime: DateTime(2026, 6, 9, 9, 0),
      durationSeconds: 125,
      usedModulesJson: '["redlight"]',
      therapyFeedback: '',
      modules: const [],
    ).toJson();

    expect(json['durationSeconds'], 125);
    expect(json.containsKey('durationMinutes'), isFalse);
  });

  // 测试治疗记录报告用户列表解析
  test('history report user page parses backend data', () {
    final HistoryReportUserPageDto page = HistoryReportUserPageDto.fromJson({
      'items': [
        {
          'clientId': 3,
          'userName': 'Alice',
          'userAge': 28,
          'userPhone': '13800000000',
          'lastReportId': 11,
          'lastReportTime': '2026-06-09T10:00:00',
        },
      ],
      'page': 2,
      'pageSize': 10,
      'total': 21,
      'hasMore': true,
    });

    expect(page.items, hasLength(1));
    expect(page.items.first.clientId, 3);
    expect(page.items.first.userName, 'Alice');
    expect(page.items.first.lastReportId, 11);
    expect(page.page, 2);
    expect(page.pageSize, 10);
    expect(page.total, 21);
    expect(page.hasMore, isTrue);
  });

  test('therapy report detail parses backend data', () {
    final TherapyReportDetailDto detail = TherapyReportDetailDto.fromJson({
      'report': {
        'reportId': 11,
        'clientId': 3,
        'userNameSnapshot': 'Alice',
        'userAgeSnapshot': 28,
        'userPhoneSnapshot': '13800000000',
        'planNameSnapshot': 'Deep relax',
        'reportTime': '2026-06-09T10:00:00',
        'durationSeconds': 1493,
        'energyScore': 50,
        'cellScore': 51,
        'relaxScore': 52,
        'immuneScore': 53,
        'therapyFeedback': 'felt relaxed',
      },
      'modules': [
        {
          'moduleCode': 'red',
          'moduleName': '红光',
          'runDurationMinutes': 10,
          'runStatus': 'completed',
        },
      ],
      'vitals': [
        {
          'vitalCode': 'heart_rate',
          'vitalName': '心率',
          'vitalValue': 72,
          'vitalUnit': 'bpm',
        },
      ],
    });

    expect(detail.report.reportId, 11);
    expect(detail.report.userNameSnapshot, 'Alice');
    expect(detail.report.durationSeconds, 1493);
    expect(detail.modules.single.moduleName, '红光');
    expect(detail.vitals.single.vitalCode, 'heart_rate');
  });

  test('therapy report detail page parses backend data', () {
    final TherapyReportDetailPageDto page = TherapyReportDetailPageDto.fromJson(
      {
        'items': [
          {
            'report': {
              'reportId': 12,
              'clientId': 3,
              'userNameSnapshot': 'Alice',
              'userAgeSnapshot': 28,
              'userPhoneSnapshot': '13800000000',
              'planNameSnapshot': 'Deep relax',
              'reportTime': '2026-06-09T12:00:00',
              'durationSeconds': 1500,
            },
            'modules': [
              {
                'moduleCode': 'relax',
                'moduleName': '深度放松',
                'runDurationMinutes': 25,
                'runStatus': 'completed',
              },
            ],
            'vitals': [],
          },
        ],
        'page': 1,
        'pageSize': 5,
        'total': 6,
        'hasMore': true,
      },
    );

    expect(page.items, hasLength(1));
    expect(page.items.first.report.reportId, 12);
    expect(page.items.first.modules.single.moduleName, '深度放松');
    expect(page.pageSize, 5);
    expect(page.total, 6);
    expect(page.hasMore, isTrue);
  });

  test('history record logic refreshes and loads next page', () async {
    final FakeHistoryRecordRepository repository =
        FakeHistoryRecordRepository();
    final HistoryRecordLogic logic = HistoryRecordLogic(
      repository: repository,
      ownerUserId: 9,
      pageSize: 10,
    );

    await logic.refresh(keyword: ' Ali ');

    expect(logic.users, hasLength(1));
    expect(logic.users.first.userName, 'Alice');
    expect(logic.keyword, 'Ali');
    expect(logic.page, 1);
    expect(logic.hasMore, isTrue);

    await logic.loadNextPage();

    expect(logic.users, hasLength(2));
    expect(logic.users.last.userName, 'Bob');
    expect(logic.page, 2);
    expect(logic.hasMore, isFalse);
    expect(repository.requestedPages, [1, 2]);
    expect(repository.requestedKeywords, ['Ali', 'Ali']);
  });

  test('history record logic deletes user reports from list', () async {
    final FakeHistoryRecordRepository repository =
        FakeHistoryRecordRepository();
    final HistoryRecordLogic logic = HistoryRecordLogic(
      repository: repository,
      ownerUserId: 9,
      pageSize: 10,
    );

    await logic.refresh();
    await logic.deleteUserReports(3);

    expect(logic.users, isEmpty);
    expect(repository.deletedClientIds, [3]);
  });

  test('development account is not treated as a registration email', () {
    expect(isValidEmail('00000000'), isFalse);
    expect(isValidEmail('user@example.com'), isTrue);
  });

  test('HifemRegionSetting copyWith preserves and clamps percentages', () {
    const HifemRegionSetting setting = HifemRegionSetting(
      rfPercent: 20,
      hifesPercent: 30,
    );

    final HifemRegionSetting updated = setting.copyWith(rfPercent: 120);

    expect(updated.rfPercent, 100);
    expect(updated.hifesPercent, 30);
  });

  test('customized VAT shares music and intensity across phases', () {
    final StartLogic logic = StartLogic();
    logic.configure({
      'customizedPlan': const CustomizedPlanData(
        name: 'VAT',
        featureIds: [
          'phase:0:vat',
          'vat:0:frequency=20|intensity=55|songId=Aria 2',
          'phase:1:vat',
          'vat:1:frequency=40|intensity=80|songId=INMORTAL Love',
        ],
      ),
    });

    expect(logic.activeVatSetting?.frequency, 20);
    expect(logic.activeVatSetting?.intensity, 55);
    expect(logic.activeVatSetting?.songId, 'Aria 2');

    logic.elapsedSeconds = StartLogic.phaseSeconds;

    expect(logic.activeVatSetting?.frequency, 40);
    expect(logic.activeVatSetting?.intensity, 55);
    expect(logic.activeVatSetting?.songId, 'Aria 2');
  });

  test('VAT default song exists in the playlist', () {
    expect(findSongById(defaultSongId), isNotNull);
  });
}

class _FakeWaterLevelModbusService extends ModbusRtuService {
  _FakeWaterLevelModbusService({
    List<int>? waterLevelStates,
    this.ambientLightState = 1,
  }) : _waterLevelStates = waterLevelStates ?? const <int>[0, 1],
       super();

  int waterLevelReads = 0;
  int ambientLightReads = 0;
  int ambientLightState;
  final List<int> _waterLevelStates;

  /// 设置后 0x01E5 恒定返回该值，便于测试中途切换水位。
  int? waterLevelOverride;

  /// 记录写 0x01EB（自动加水）的指令。
  final List<ModbusWriteCommand> waterFillingCommands = <ModbusWriteCommand>[];

  @override
  Future<int> readHoldingRegister(int address) async {
    if (address == 0x01E5) {
      waterLevelReads++;
      final int? override = waterLevelOverride;
      if (override != null) return override;
      final int index = waterLevelReads - 1;
      if (index < _waterLevelStates.length) {
        return _waterLevelStates[index];
      }
      return _waterLevelStates.last;
    }
    if (address == 0x0012) {
      ambientLightReads++;
      return ambientLightState;
    }
    if (address == 0x0006) return 0;
    return 1;
  }

  @override
  Future<void> sendCommandQueue(List<ModbusWriteCommand> commands) async {
    waterFillingCommands.addAll(
      commands.where((ModbusWriteCommand command) => command.address == 0x01EB),
    );
  }
}

Finder _findAssetImage(String assetName) {
  return find.byWidgetPredicate((Widget widget) {
    return widget is Image &&
        widget.image is AssetImage &&
        (widget.image as AssetImage).assetName == assetName;
  });
}

class FakeHistoryRecordRepository implements HistoryRecordRepository {
  final List<int> requestedPages = [];
  final List<String> requestedKeywords = [];
  final List<int> deletedClientIds = [];

  @override
  Future<HistoryReportUserPageDto> historyUsers({
    required int ownerUserId,
    required int page,
    required int pageSize,
    required String keyword,
  }) async {
    requestedPages.add(page);
    requestedKeywords.add(keyword);

    if (page == 1) {
      return HistoryReportUserPageDto(
        items: [
          HistoryReportUserItemDto(
            clientId: 3,
            userName: 'Alice',
            userAge: 28,
            userPhone: '13800000000',
            lastReportId: 11,
            lastReportTime: DateTime(2026, 6, 9, 10),
          ),
        ],
        page: 1,
        pageSize: pageSize,
        total: 2,
        hasMore: true,
      );
    }

    return HistoryReportUserPageDto(
      items: [
        HistoryReportUserItemDto(
          clientId: 4,
          userName: 'Bob',
          userAge: 36,
          userPhone: '13900000000',
          lastReportId: 12,
          lastReportTime: DateTime(2026, 6, 9, 11),
        ),
      ],
      page: 2,
      pageSize: pageSize,
      total: 2,
      hasMore: false,
    );
  }

  @override
  Future<void> deleteHistoryUser({
    required int ownerUserId,
    required int clientId,
  }) async {
    deletedClientIds.add(clientId);
  }
}
