import 'dart:async';
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

  test(
    'reset clears confirmed cache so the next session starts from zero',
    () async {
      final service = RecordingRuntimeService();
      final recorder = HydrogenRuntimeRecorder(service: service);
      await recorder.recordSession({'hydrogen': 600});
      await recorder.resetCumulativeRuntime();
      await HydrogenRuntimeRecorder(
        service: service,
      ).recordSession({'hydrogen': 60});
      expect(service.writes.map((write) => write.value), [110, 0, 1]);
      expect(service.writes.every((write) => write.address == 0x01E9), isTrue);
    },
  );

  test('failed reset keeps the last confirmed cumulative baseline', () async {
    final service = RecordingRuntimeService();
    final recorder = HydrogenRuntimeRecorder(service: service);
    await recorder.recordSession({'hydrogen': 600});
    service.failWrite = true;
    await expectLater(recorder.resetCumulativeRuntime(), throwsStateError);
    final next = RecordingRuntimeService(currentMinutes: 90);
    await HydrogenRuntimeRecorder(
      service: next,
    ).recordSession({'hydrogen': 60});
    expect(next.writes.single.value, 111);
  });

  test(
    'reset waits for an in-flight cumulative write and releases later sessions',
    () async {
      final service = RecordingRuntimeService()
        ..pendingWrite = Completer<void>();
      final recorder = HydrogenRuntimeRecorder(service: service);
      final recording = recorder.recordSession({'hydrogen': 360});
      await Future<void>.delayed(Duration.zero);
      final reset = HydrogenRuntimeRecorder(
        service: service,
      ).resetCumulativeRuntime();
      final next = HydrogenRuntimeRecorder(
        service: service,
      ).recordSession({'hydrogen': 60});
      await Future<void>.delayed(Duration.zero);
      expect(service.writes.map((write) => write.value), [106]);
      service.pendingWrite!.complete();
      await Future.wait([recording, reset, next]);
      expect(service.writes.map((write) => write.value), [106, 0, 1]);
    },
  );

  test(
    'duplicate reset requests share a pending write but later resets still work',
    () async {
      final service = RecordingRuntimeService()
        ..pendingWrite = Completer<void>();
      final recorder = HydrogenRuntimeRecorder(service: service);
      final first = recorder.resetCumulativeRuntime();
      final duplicate = recorder.resetCumulativeRuntime();
      await Future<void>.delayed(Duration.zero);
      expect(service.writes.map((write) => write.value), [0]);
      service.pendingWrite!.complete();
      await Future.wait([first, duplicate]);
      await recorder.resetCumulativeRuntime();
      expect(service.writes.map((write) => write.value), [0, 0]);
    },
  );

  testWidgets('reset timeout retries zero once after the bounded interval', (
    tester,
  ) async {
    final service = RecordingRuntimeService()
      ..writeFailures.add(TimeoutException('write timeout'));
    final reset = HydrogenRuntimeRecorder(
      service: service,
    ).resetCumulativeRuntime();
    await tester.pump();
    expect(service.writes.map((write) => write.value), [0]);
    await tester.pump(const Duration(milliseconds: 199));
    expect(service.writes, hasLength(1));
    await tester.pump(const Duration(milliseconds: 1));
    await reset;
    expect(service.writes.map((write) => write.value), [0, 0]);
    expect(service.currentMinutes, 0);
  });

  test('reset does not clear another board connection cache', () async {
    final other = RecordingRuntimeService(slaveId: 17);
    await HydrogenRuntimeRecorder(
      service: other,
    ).recordSession({'hydrogen': 600});
    await HydrogenRuntimeRecorder(
      service: RecordingRuntimeService(),
    ).resetCumulativeRuntime();
    other.currentMinutes = 90;
    await HydrogenRuntimeRecorder(
      service: other,
    ).recordSession({'hydrogen': 60});
    expect(other.writes.last.value, 111);
  });

  Future<void> mountPanel(
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
  }

  Future<void> tapRuntime(WidgetTester tester, [int count = 5]) async {
    for (var i = 0; i < count; i++) {
      await tester.tap(find.byKey(const ValueKey('status_hydrogen_runtime')));
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
  }

  String runtimeText(WidgetTester tester) => tester
      .widget<Text>(find.byKey(const ValueKey('status_hydrogen_runtime')))
      .textSpan!
      .toPlainText();

  testWidgets(
    'confirmation writes zero once and the next session excludes the old cache',
    (tester) async {
      final service = RecordingRuntimeService();
      await HydrogenRuntimeRecorder(
        service: service,
      ).recordSession({'hydrogen': 600});
      await mountPanel(tester, service);
      await tapRuntime(tester);
      expect(service.writes.map((write) => write.value), [110]);
      await tester.enterText(
        find.byKey(const ValueKey('status_hydrogen_reset_password')),
        'infibo',
      );
      await tester.tap(
        find.byKey(const ValueKey('status_hydrogen_reset_confirm')),
      );
      await tester.pumpAndSettle();
      expect(runtimeText(tester), '0 h 0 min');
      expect(find.text('分子氢累计运行时间已清零。'), findsOneWidget);
      expect(service.writes.map((write) => write.value), [110, 0]);
      await HydrogenRuntimeRecorder(
        service: service,
      ).recordSession({'hydrogen': 60});
      expect(service.writes.last.value, 1);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('taps outside the three-second window do not trigger a reset', (
    tester,
  ) async {
    final service = RecordingRuntimeService();
    await mountPanel(tester, service);
    await tapRuntime(tester, 4);
    await tester.pump(const Duration(seconds: 3));
    await tapRuntime(tester, 1);
    expect(find.byType(AlertDialog), findsNothing);
    expect(service.writes, isEmpty);
    await tapRuntime(tester, 4);
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey('status_hydrogen_reset_cancel')),
    );
    await tester.pumpAndSettle();
    expect(service.writes, isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'failed reset shows a failure and retains the displayed runtime',
    (tester) async {
      final service = RecordingRuntimeService()..failWrite = true;
      await mountPanel(tester, service);
      await tapRuntime(tester);
      await tester.enterText(
        find.byKey(const ValueKey('status_hydrogen_reset_password')),
        'infibo',
      );
      await tester.tap(
        find.byKey(const ValueKey('status_hydrogen_reset_confirm')),
      );
      await tester.pumpAndSettle();
      expect(runtimeText(tester), '1 h 40 min');
      expect(find.text('未能确认清零成功，请检查连接后重试。'), findsOneWidget);
      expect(service.writes.map((write) => write.value), [0]);
      expect(service.currentMinutes, 100);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'pending reset disables refresh and ignores repeated runtime taps',
    (tester) async {
      final service = RecordingRuntimeService();
      await mountPanel(tester, service);
      service.pendingWrite = Completer<void>();
      await tapRuntime(tester);
      await tester.enterText(
        find.byKey(const ValueKey('status_hydrogen_reset_password')),
        'infibo',
      );
      await tester.tap(
        find.byKey(const ValueKey('status_hydrogen_reset_confirm')),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ElevatedButton>(
              find.byKey(const ValueKey('status_detection_refresh')),
            )
            .onPressed,
        isNull,
      );
      await tapRuntime(tester);
      expect(find.byType(AlertDialog), findsNothing);
      expect(service.writes, hasLength(1));
      service.pendingWrite!.complete();
      await tester.pumpAndSettle();
      expect(runtimeText(tester), '0 h 0 min');
      await tester.tap(find.byKey(const ValueKey('status_detection_refresh')));
      await tester.pumpAndSettle();
      expect(runtimeText(tester), '0 h 0 min');
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'leaving the panel during reset still completes the confirmed cache update',
    (tester) async {
      final service = RecordingRuntimeService();
      await HydrogenRuntimeRecorder(
        service: service,
      ).recordSession({'hydrogen': 600});
      await mountPanel(tester, service);
      service.pendingWrite = Completer<void>();
      await tapRuntime(tester);
      await tester.enterText(
        find.byKey(const ValueKey('status_hydrogen_reset_password')),
        'infibo',
      );
      await tester.tap(
        find.byKey(const ValueKey('status_hydrogen_reset_confirm')),
      );
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      service.pendingWrite!.complete();
      await tester.pump();
      await HydrogenRuntimeRecorder(
        service: service,
      ).recordSession({'hydrogen': 60});
      expect(service.writes.map((write) => write.value), [110, 0, 1]);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('English confirmation and feedback are localized', (
    tester,
  ) async {
    final service = RecordingRuntimeService();
    await mountPanel(tester, service, locale: const Locale('en', 'US'));
    await tapRuntime(tester);
    expect(find.text('Reset hydrogen runtime'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('status_hydrogen_reset_password')),
      'infibo',
    );
    await tester.tap(
      find.byKey(const ValueKey('status_hydrogen_reset_confirm')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Total hydrogen runtime has been reset.'), findsOneWidget);
    expect(runtimeText(tester), '0 h 0 min');
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'four taps do nothing and the fifth opens a cancellable confirmation',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1280));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        GetMaterialApp(
          locale: const Locale('zh', 'CN'),
          translations: AppTranslations(),
          home: Scaffold(
            body: StatusDetectionPanel(readRegister: (_) async => 100),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final runtime = find.byKey(const ValueKey('status_hydrogen_runtime'));
      await tester.ensureVisible(runtime);
      for (var i = 0; i < 4; i++) {
        await tester.tap(runtime);
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.byType(AlertDialog), findsNothing);
      await tester.tap(runtime);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey('status_hydrogen_reset_cancel')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      final text = tester.widget<Text>(runtime);
      expect(text.textSpan!.toPlainText(), '1 h 40 min');
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
