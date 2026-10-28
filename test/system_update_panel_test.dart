import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:infibo_app/ota/ota_controller.dart';
import 'package:infibo_app/pages/settingpage/system_update_panel.dart';
import 'package:infibo_app/translation/app_translations.dart';
import 'ota_controller_test.dart' show TestGateway, TestService;

void main() {
  testWidgets(
    'shows real versions and cancellation of confirmation never downloads',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final service = TestService(TestGateway());
      final controller = OtaController(
        service: service,
        readRegister: (address) async => address == 2 ? 0x0124 : 0,
      );
      await controller.refresh();
      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('zh', 'CN'),
          home: Scaffold(
            body: SizedBox(
              width: 463,
              height: 850,
              child: SystemUpdatePanel(controller: controller),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('上位机软件'), findsOneWidget);
      expect(find.text('主板固件'), findsOneWidget);
      expect(find.textContaining('1.0.0'), findsOneWidget);
      expect(find.textContaining('1.2.4'), findsOneWidget);
      expect(find.text('1.1.0'), findsOneWidget);
      expect(find.textContaining('Build'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('ota-app-update')));
      await tester.pumpAndSettle();
      expect(find.text('确认更新软件？'), findsOneWidget);
      expect(find.text('1.1.0'), findsNWidgets(2));
      expect(find.textContaining('Build'), findsNothing);
      await tester.tap(find.text('稍后'));
      await tester.pumpAndSettle();
      expect(service.downloads, 0);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
      Get.reset();
    },
  );
}
