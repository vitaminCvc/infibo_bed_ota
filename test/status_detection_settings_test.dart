import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/designCanvas/design.dart';
import 'package:infibo_app/pages/settingpage/status_detection_panel.dart';
import 'package:infibo_app/pages/settingpage/ui.dart';
import 'package:infibo_app/stores/app_header_clock_store.dart';
import 'package:infibo_app/stores/user_store.dart';
import 'package:infibo_app/translation/app_translations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Widget app(Widget child) => GetMaterialApp(
    locale: const Locale('zh', 'CN'),
    translations: AppTranslations(),
    home: Scaffold(body: child),
  );

  tearDown(Get.reset);

  testWidgets('reads only on status menu entry and rereads after reentry', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    Get.put(UserStore());
    await tester.binding.setSurfaceSize(const Size(800, 1280));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final addresses = <int>[];
    var value = 8;
    await tester.pumpWidget(
      app(
        DesignCanvas(
          child: SettingWidget(
            statusReadRegister: (address) async {
              addresses.add(address);
              return value;
            },
          ),
        ),
      ),
    );
    await tester.pump();
    expect(addresses, isEmpty);
    await tester.tap(find.text('状态检测'));
    await tester.pump();
    await tester.pump();
    expect(addresses, [0x01EC]);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('水质正常'), findsOneWidget);
    await tester.pump(const Duration(seconds: 20));
    await tester.tap(find.text('状态检测').first);
    await tester.pump();
    expect(addresses, [0x01EC]);
    await tester.tap(find.text('语言设置'));
    await tester.pump();
    value = 10;
    await tester.tap(find.text('状态检测'));
    await tester.pump();
    await tester.pump();
    expect(addresses, [0x01EC, 0x01EC]);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('水质异常'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    Get.delete<AppHeaderClockController>(force: true);
  });

  for (final value in [0, 9, 10, 25]) {
    testWidgets('TDS $value uses the ten threshold', (tester) async {
      await tester.pumpWidget(
        app(StatusDetectionPanel(readRegister: (_) async => value)),
      );
      await tester.pump();
      expect(find.text('$value'), findsOneWidget);
      expect(find.text(value >= 10 ? '水质异常' : '水质正常'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('pending and failed reads never show zero or normal', (
    tester,
  ) async {
    final response = Completer<int>();
    await tester.pumpWidget(
      app(StatusDetectionPanel(readRegister: (_) => response.future)),
    );
    expect(find.text('正在读取水质…'), findsOneWidget);
    expect(find.text('0'), findsNothing);
    expect(find.text('水质正常'), findsNothing);
    response.completeError(StateError('disconnected'));
    await tester.pump();
    expect(find.text('水质状态暂不可用，请重新进入此页面检测。'), findsOneWidget);
    expect(find.text('0'), findsNothing);
    expect(find.text('水质正常'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('late response after leaving does not update disposed panel', (
    tester,
  ) async {
    final response = Completer<int>();
    await tester.pumpWidget(
      app(StatusDetectionPanel(readRegister: (_) => response.future)),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    response.complete(8);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
