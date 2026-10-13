import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infibo_app/api/modbus/hydrogen_runtime_recorder.dart';
import 'package:infibo_app/pages/settingpage/status_detection_panel.dart';
import 'package:infibo_app/translation/app_translations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'hydrogen_runtime_recorder_test.dart' show RecordingRuntimeService;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(Get.reset);

  Future<void> openReset(
    WidgetTester tester,
    RecordingRuntimeService service, {
    Locale locale = const Locale('zh', 'CN'),
  }) async {
    await tester.binding.setSurfaceSize(const Size(800, 1280));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      GetMaterialApp(
        locale: locale,
        translations: AppTranslations(),
        home: Scaffold(body: StatusDetectionPanel(runtimeService: service)),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('status_hydrogen_runtime')),
    );
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.byKey(const ValueKey('status_hydrogen_runtime')));
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
  }

  testWidgets(
    'confirming with an empty password keeps runtime and cache unchanged',
    (tester) async {
      final service = RecordingRuntimeService();
      await HydrogenRuntimeRecorder(
        service: service,
      ).recordSession({'hydrogen': 600});
      await openReset(tester, service);
      await tester.tap(
        find.byKey(const ValueKey('status_hydrogen_reset_confirm')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(service.writes.map((write) => write.value), [110]);
      expect(service.currentMinutes, 110);
      await tester.tap(
        find.byKey(const ValueKey('status_hydrogen_reset_cancel')),
      );
      await tester.pumpAndSettle();
      service.currentMinutes = 90;
      await HydrogenRuntimeRecorder(
        service: service,
      ).recordSession({'hydrogen': 60});
      expect(service.writes.last.value, 111);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final wrongPassword in [
    'wrong',
    'Infibo',
    'INFIBO',
    ' infibo',
    'infibo ',
  ]) {
    testWidgets('incorrect password "$wrongPassword" cannot clear runtime', (
      tester,
    ) async {
      final service = RecordingRuntimeService();
      await openReset(tester, service);
      await tester.enterText(
        find.byKey(const ValueKey('status_hydrogen_reset_password')),
        wrongPassword,
      );
      await tester.tap(
        find.byKey(const ValueKey('status_hydrogen_reset_confirm')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('密码错误，请重新输入。'), findsOneWidget);
      expect(service.writes, isEmpty);
      expect(service.currentMinutes, 100);
      await tester.tap(
        find.byKey(const ValueKey('status_hydrogen_reset_cancel')),
      );
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets(
    'correcting a wrong password allows exactly one confirmed reset',
    (tester) async {
      final service = RecordingRuntimeService();
      await openReset(tester, service);
      final password = find.byKey(
        const ValueKey('status_hydrogen_reset_password'),
      );
      expect(tester.widget<TextField>(password).obscureText, isTrue);
      await tester.enterText(password, 'wrong');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('密码错误，请重新输入。'), findsOneWidget);
      expect(service.writes, isEmpty);
      await tester.enterText(password, 'infibo');
      await tester.pump();
      expect(find.text('密码错误，请重新输入。'), findsNothing);
      expect(service.writes, isEmpty);
      await tester.tap(
        find.byKey(const ValueKey('status_hydrogen_reset_confirm')),
      );
      await tester.pumpAndSettle();
      expect(service.writes.map((write) => write.value), [0]);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('分子氢累计运行时间已清零。'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'cancelling a correct password does not authorize the next popup',
    (tester) async {
      final service = RecordingRuntimeService();
      await openReset(tester, service);
      final password = find.byKey(
        const ValueKey('status_hydrogen_reset_password'),
      );
      await tester.enterText(password, 'infibo');
      await tester.tap(
        find.byKey(const ValueKey('status_hydrogen_reset_cancel')),
      );
      await tester.pumpAndSettle();
      expect(service.writes, isEmpty);
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.byKey(const ValueKey('status_hydrogen_runtime')));
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(password).controller!.text, isEmpty);
      await tester.tap(
        find.byKey(const ValueKey('status_hydrogen_reset_confirm')),
      );
      await tester.pumpAndSettle();
      expect(service.writes, isEmpty);
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey('status_hydrogen_reset_cancel')),
      );
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('English password prompt and invalid feedback are localized', (
    tester,
  ) async {
    final service = RecordingRuntimeService();
    await openReset(tester, service, locale: const Locale('en', 'US'));
    expect(find.text('Password'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey('status_hydrogen_reset_confirm')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Incorrect password. Please try again.'), findsOneWidget);
    expect(service.writes, isEmpty);
    await tester.tap(
      find.byKey(const ValueKey('status_hydrogen_reset_cancel')),
    );
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
