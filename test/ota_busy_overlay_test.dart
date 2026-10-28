import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:infibo_app/ota/ota_busy_overlay.dart';
import 'package:infibo_app/ota/ota_controller.dart';
import 'package:infibo_app/translation/app_translations.dart';
import 'ota_controller_test.dart' show TestGateway, TestService;

void main() {
  for (final phase in [
    OtaPhase.downloading,
    OtaPhase.transferring,
    OtaPhase.boardInstalling,
    OtaPhase.boardReconnecting,
  ]) {
    testWidgets('$phase keeps cancellation restricted to safe stages', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      await tester.binding.setSurfaceSize(const Size(320, 400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final controller = OtaController(
        service: TestService(TestGateway()),
        readRegister: (_) async => 0,
      );
      controller.phase = phase;
      controller.progress = .5;
      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('zh', 'CN'),
          home: MediaQuery(
            data: const MediaQueryData(
              textScaler: TextScaler.linear(2),
              disableAnimations: true,
            ),
            child: SizedBox(
              width: 320,
              height: 400,
              child: OtaBusyOverlay(
                controller: controller,
                child: const Scaffold(body: Text('background')),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      final cancel = find.byKey(const ValueKey('ota-progress-cancel'));
      expect(cancel, controller.canCancel ? findsOneWidget : findsNothing);
      if (phase == OtaPhase.transferring) {
        expect(find.text('取消传输'), findsOneWidget);
      }
      expect(
        find.text('更新期间请保持设备供电。'),
        phase == OtaPhase.downloading ? findsNothing : findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
      Get.reset();
    });
  }
}
