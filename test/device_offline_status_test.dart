import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infibo_app/api/modbus/modbus_rtu_service.dart';
import 'package:infibo_app/constants/layout.dart';
import 'package:infibo_app/components/designCanvas/design.dart';
import 'package:infibo_app/pages/main/ui.dart';
import 'package:infibo_app/pages/settingpage/DeviceInfo.dart';
import 'package:infibo_app/routes/route_observer.dart';
import 'package:infibo_app/stores/app_header_clock_store.dart';
import 'package:infibo_app/stores/user_store.dart';
import 'package:infibo_app/translation/app_translations.dart';

class DeviceStatusService extends ModbusRtuService {
  int status = 0;
  Object? error;
  Completer<int>? pendingStatus;
  final reads = <int>[];

  @override
  Future<int> readHoldingRegister(int address) async {
    reads.add(address);
    if (address == 0x0006) {
      if (error != null) throw error!;
      return pendingStatus?.future ?? status;
    }
    if (address == 0x0002) return 0x0130;
    if (address == 0x01E5) return 2;
    return 0;
  }

  @override
  Future<void> sendCommandQueue(List<ModbusWriteCommand> commands) async {}
}

class _TestHeaderClock extends AppHeaderClockController {
  @override
  void startClock() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader('InfiboDeviceStatusTest')
          ..addFont(rootBundle.load('assets/fonts/MicrosoftYaHei-Regular.ttf')))
        .load();
  });
  setUp(() {
    Get.testMode = true;
    Get.put(UserStore());
    Get.put<AppHeaderClockController>(_TestHeaderClock());
  });
  tearDown(() {
    if (Get.isRegistered<AppHeaderClockController>()) {
      Get.find<AppHeaderClockController>().onClose();
      Get.delete<AppHeaderClockController>(force: true);
    }
    Get.reset();
  });

  Future<void> mount(
    WidgetTester tester,
    DeviceStatusService service, {
    required bool home,
    AppLayoutMetrics? layout,
    Locale locale = const Locale('zh', 'CN'),
  }) async {
    final metrics = layout ?? AppLayout.ratio16x10;
    tester.view.physicalSize = metrics.designSize;
    tester.view.devicePixelRatio = 1;
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      GetMaterialApp(
        theme: ThemeData(fontFamily: 'InfiboDeviceStatusTest'),
        translations: AppTranslations(),
        locale: locale,
        navigatorObservers: [appRouteObserver],
        home: AppLayoutScope(
          layout: metrics,
          child: home
              ? MainPage(modbusService: service)
              : Scaffold(
                  body: SizedBox(
                    width: 436,
                    height: 900,
                    child: DeviceInfoPanel(
                      readRegister: service.readHoldingRegister,
                    ),
                  ),
                ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  Future<void> tick(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
    await tester.pump();
  }

  void expectStatus(WidgetTester tester, String text, Color color) {
    final label = find.text(text);
    expect(label, findsOneWidget);
    expect(tester.widget<Text>(label).style?.color, color);
    final row = find.ancestor(of: label, matching: find.byType(Row)).first;
    final icons = find.descendant(of: row, matching: find.byType(Icon));
    if (icons.evaluate().isNotEmpty) {
      expect(tester.widget<Icon>(icons.first).color, color);
    } else {
      final dots = find.descendant(
        of: row,
        matching: find.byWidgetPredicate(
          (w) =>
              w is DecoratedBox &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).shape == BoxShape.circle,
        ),
      );
      expect(dots, findsOneWidget);
      expect(
        (tester.widget<DecoratedBox>(dots).decoration as BoxDecoration).color,
        color,
      );
    }
  }

  for (final home in [true, false]) {
    for (final (locale, label) in [
      (const Locale('en', 'US'), 'Device Offline'),
      (const Locale('fr', 'FR'), 'Appareil hors ligne'),
      (const Locale('ar', 'SA'), 'الجهاز غير متصل'),
    ]) {
      testWidgets(
        '${home ? 'home' : 'device info'} localizes offline in $locale',
        (tester) async {
          final service = DeviceStatusService()
            ..error = StateError('not connected');
          await mount(tester, service, home: home, locale: locale);
          expectStatus(tester, label, const Color(0xFF999999));
          expect(tester.takeException(), isNull);
        },
      );
    }
    for (final layout in [AppLayout.ratio16x10, AppLayout.ratio16x9]) {
      testWidgets(
        '${home ? 'home' : 'device info'} ${layout.profile} starts offline and recovers through ready fault offline',
        (tester) async {
          final pending = Completer<int>();
          final service = DeviceStatusService()..pendingStatus = pending;
          await mount(tester, service, home: home, layout: layout);
          expectStatus(tester, '设备离线', const Color(0xFF999999));
          expect(find.text('设备就绪'), findsNothing);
          service.pendingStatus = null;
          pending.complete(0);
          await tester.pump();
          await tester.pump();
          expect(find.text('设备就绪'), findsOneWidget);
          service.status = 3;
          await tick(tester);
          expect(find.text('设备故障'), findsOneWidget);
          service.error = TimeoutException('No board response');
          await tick(tester);
          expectStatus(tester, '设备离线', const Color(0xFF999999));
          expect(find.text('设备故障'), findsNothing);
          service.error = null;
          service.status = 0;
          await tick(tester);
          expect(find.text('设备就绪'), findsOneWidget);
          service.status = 5;
          await tick(tester);
          expect(find.text('设备故障'), findsOneWidget);
          service.error = StateError('serial disconnected');
          await tick(tester);
          expectStatus(tester, '设备离线', const Color(0xFF999999));
          service.error = null;
          await tick(tester);
          expect(find.text('设备故障'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets(
      '${home ? 'home' : 'device info'} remains offline without responses and recovers after reconnect',
      (tester) async {
        final service = DeviceStatusService()
          ..error = StateError('not connected');
        await mount(tester, service, home: home);
        expectStatus(tester, '设备离线', const Color(0xFF999999));
        await tick(tester);
        expectStatus(tester, '设备离线', const Color(0xFF999999));
        service.error = null;
        service.status = -1;
        await tick(tester);
        expectStatus(tester, '设备离线', const Color(0xFF999999));
        service.status = 0;
        await tick(tester);
        expect(find.text('设备就绪'), findsOneWidget);
      },
    );

    for (final fail in [false, true]) {
      testWidgets(
        '${home ? 'home' : 'device info'} ignores late ${fail ? 'failure' : 'success'} after leaving',
        (tester) async {
          final pending = Completer<int>();
          final service = DeviceStatusService()..pendingStatus = pending;
          await mount(tester, service, home: home);
          await tester.pumpWidget(const SizedBox.shrink());
          if (fail) {
            pending.completeError(TimeoutException('late failure'));
          } else {
            pending.complete(0);
          }
          await tester.pump();
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
