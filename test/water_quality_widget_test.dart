import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/water_quality/water_quality_dialog.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/components/water_quality/water_quality_controller.dart';
import 'package:infibo_app/components/water_quality/water_quality_host.dart';
import 'package:infibo_app/translation/app_translations.dart';

void main() {
  late WaterQualityController controller;
  late GlobalKey<NavigatorState> navigator;
  late int tds;
  late int status;
  late bool failRead;
  Completer<int>? pendingTreatment;
  setUp(() {
    Get.testMode = true;
    tds = 10;
    status = 1;
    failRead = false;
    pendingTreatment = null;
    navigator = GlobalKey<NavigatorState>();
    controller = WaterQualityController(
      readRegister: (address) async {
        if (failRead) throw StateError('device still starting');
        return address == 0x01EC
            ? tds
            : await (pendingTreatment?.future ?? Future.value(status));
      },
    );
  });
  tearDown(() {
    controller.dispose();
    Get.reset();
  });

  Widget app({Locale locale = const Locale('en', 'US')}) => GetMaterialApp(
    navigatorKey: navigator,
    initialRoute: '/start',
    locale: locale,
    translations: AppTranslations(),
    navigatorObservers: [WaterQualityRouteObserver(controller)],
    builder: (context, child) =>
        WaterQualityHost(controller: controller, child: child!),
    getPages: ['/start', '/summary', '/main']
        .map(
          (name) => GetPage(
            name: name,
            page: () => Scaffold(body: Text(name)),
          ),
        )
        .toList(),
  );

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
  }

  // 处理中持续动画不会 settle；只等待路由和状态过渡完成。
  Future<void> pumpUi(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();
  }

  testWidgets('startup failure leaves page usable until real anomaly arrives', (
    tester,
  ) async {
    failRead = true;
    await tester.pumpWidget(app(locale: const Locale('zh', 'CN')));
    await pumpUi(tester);
    expect(find.byType(WaterQualityDialog), findsNothing);
    expect(find.text('/start').hitTestable(), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await pumpUi(tester);
    expect(find.byType(WaterQualityDialog), findsNothing);
    failRead = false;
    await tester.pump(const Duration(seconds: 3));
    await pumpUi(tester);
    expect(find.byType(WaterQualityDialog), findsOneWidget);
    expect(controller.phase, WaterQualityPhase.treating);
    await unmount(tester);
  });

  testWidgets('processing animates only after ED one and stops on result', (
    tester,
  ) async {
    pendingTreatment = Completer<int>();
    await tester.pumpWidget(app());
    await pumpUi(tester);
    final spinner = find.byKey(const ValueKey('water_quality_orbit_spinner'));
    expect(spinner, findsNothing);
    pendingTreatment!.complete(1);
    pendingTreatment = null;
    await pumpUi(tester);
    expect(spinner, findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.binding.hasScheduledFrame, isTrue);
    status = 2;
    await controller.poll();
    await pumpUi(tester);
    expect(spinner, findsNothing);
    expect(find.text('Water Treatment Failed'), findsOneWidget);
    controller.dismiss();
    await pumpUi(tester);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('same popup survives start summary and home replacements', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await pumpUi(tester);
    expect(find.text('Water Issue'), findsOneWidget);
    final popup = tester.element(
      find.byKey(const ValueKey('water_quality_dialog')),
    );
    navigator.currentState!.pushReplacementNamed('/summary');
    await pumpUi(tester);
    expect(find.text('/summary'), findsOneWidget);
    expect(find.text('Water Issue'), findsOneWidget);
    navigator.currentState!.pushNamedAndRemoveUntil('/main', (_) => false);
    await pumpUi(tester);
    await controller.onHomeWaterPollComplete();
    await tester.pump();
    expect(find.text('/main'), findsOneWidget);
    expect(
      tester.element(find.byKey(const ValueKey('water_quality_dialog'))),
      same(popup),
    );
    await unmount(tester);
  });

  testWidgets('close removes overlay without popping the running page', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await pumpUi(tester);
    await tester.tap(find.byKey(const ValueKey('water_quality_close')));
    await tester.pump();
    expect(find.text('/start'), findsOneWidget);
    expect(find.text('Water Issue'), findsNothing);
    status = 2;
    await controller.poll();
    await tester.pump();
    expect(find.text('Water Treatment Failed'), findsNothing);
    expect(controller.episodeActive, isTrue);
    await unmount(tester);
  });

  testWidgets(
    'system back dismisses water overlay and keeps underlying route',
    (tester) async {
      await tester.pumpWidget(app());
      await pumpUi(tester);
      await tester.binding.handlePopRoute();
      await pumpUi(tester);
      expect(controller.visible, isFalse);
      expect(find.text('/start'), findsOneWidget);
      await unmount(tester);
    },
  );

  testWidgets('back closes water overlay before an underlying dialog', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await pumpUi(tester);
    showDialog<void>(
      context: navigator.currentContext!,
      builder: (_) => const AlertDialog(content: Text('underlying dialog')),
    );
    await pumpUi(tester);
    await tester.binding.handlePopRoute();
    await pumpUi(tester);
    expect(controller.visible, isFalse);
    expect(find.text('underlying dialog'), findsOneWidget);
    navigator.currentState!.pop();
    await pumpUi(tester);
    await unmount(tester);
  });

  testWidgets('ordinary popup dismissal does not reset water reminder', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await pumpUi(tester);
    controller.dismiss();
    await tester.pump();
    showDialog<void>(
      context: navigator.currentContext!,
      builder: (_) => const AlertDialog(content: Text('other prompt')),
    );
    await pumpUi(tester);
    navigator.currentState!.pop();
    await pumpUi(tester);
    expect(controller.visible, isFalse);
    expect(find.text('/start'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets(
    'failure and success reuse popup and confirmation does not navigate',
    (tester) async {
      status = 2;
      await tester.pumpWidget(app());
      await pumpUi(tester);
      expect(find.text('Water Treatment Failed'), findsOneWidget);
      expect(find.text('Got it'), findsOneWidget);
      expect(
        tester.getSize(find.byType(WaterQualityDialog)).width,
        lessThanOrEqualTo(340),
      );
      status = 0;
      tds = 8;
      await controller.poll();
      await tester.pump();
      expect(find.text('Water Treatment Complete'), findsOneWidget);
      final completeIcon = find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == Assets.ok,
      );
      expect(completeIcon, findsOneWidget);
      expect(tester.getSize(completeIcon), const Size(30, 30));
      await tester.tap(find.text('Confirm'));
      await tester.pump();
      expect(find.text('/start'), findsOneWidget);
      expect(find.text('Water Treatment Complete'), findsNothing);
      await unmount(tester);
    },
  );

  for (final locale in const [
    Locale('zh', 'CN'),
    Locale('en', 'US'),
    Locale('de', 'DE'),
    Locale('fr', 'FR'),
    Locale('ar', 'SA'),
  ]) {
    testWidgets('long water text fits small viewport in $locale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      status = 2;
      await tester.pumpWidget(app(locale: locale));
      await pumpUi(tester);
      expect(
        find.byKey(const ValueKey('water_quality_dialog')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await unmount(tester);
    });
  }
}
