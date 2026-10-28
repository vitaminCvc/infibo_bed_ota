import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:infibo_app/ota/ota_controller.dart';
import 'package:infibo_app/pages/settingpage/system_update_panel.dart';
import 'package:infibo_app/translation/app_translations.dart';
import 'ota_controller_test.dart' show TestGateway, TestService;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late TestGateway gateway;
  late TestService service;
  late OtaController controller;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    gateway = TestGateway()..code = 5;
    service = TestService(gateway);
    controller = OtaController(service: service, readRegister: (_) async => 0);
  });
  tearDown(() {
    controller.dispose();
    Get.reset();
  });

  test(
    'older APK is unavailable and never starts download or installation',
    () async {
      await controller.refresh();
      expect(controller.appAvailable, isFalse);
      expect(controller.takePrompt(), isFalse);
      await controller.updateApp();
      expect(service.downloads, 0);
      expect(gateway.installs, 0);
    },
  );

  test(
    'returning without a downgrade must not report a higher installed code as success',
    () async {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setInt('ota_pending_app_code', 2);
      controller.phase = OtaPhase.installRequested;
      await controller.resume();
      expect(controller.phase, OtaPhase.idle);
      expect(controller.noticeKey, 'ota_install_not_completed');
      expect(preferences.getInt('ota_pending_app_code'), isNull);
    },
  );

  test(
    'an upgrade is confirmed only after the exact target code is installed',
    () async {
      gateway.code = 1;
      await controller.refresh();
      await controller.updateApp();
      gateway.code = 2;
      await controller.resume();
      expect(controller.phase, OtaPhase.success);
      expect(controller.noticeKey, 'ota_success');
      expect(controller.appAvailable, isFalse);
      expect(controller.takePrompt(), isFalse);
    },
  );

  test(
    'saved permission request for an older APK is discarded without downloading',
    () async {
      gateway.code = 1;
      gateway.permission = false;
      await controller.refresh();
      await controller.updateApp();
      gateway.code = 5;
      gateway.permission = true;
      await controller.resume();
      expect(service.downloads, 0);
      expect(gateway.installs, 0);
      expect(
        (await SharedPreferences.getInstance()).getString(
          'ota_permission_app_request',
        ),
        isNull,
      );
    },
  );

  testWidgets(
    'older published APK shows version names without internal build codes',
    (tester) async {
      await controller.refresh();
      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('zh', 'CN'),
          home: Scaffold(body: SystemUpdatePanel(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();
      final button = find.byKey(const ValueKey('ota-app-update'));
      expect(find.text(gateway.version), findsOneWidget);
      expect(find.text(service.release.version), findsOneWidget);
      expect(find.textContaining('Build'), findsNothing);
      expect(find.text('下载并尝试回退'), findsNothing);
      // 已安装版本更高时按钮仍显示，但被禁用并标注“已是最新版本”。
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
      expect(
        find.descendant(of: button, matching: find.text('已是最新版本')),
        findsOneWidget,
      );
      expect(find.textContaining('当前版本高于发布版本'), findsOneWidget);
      expect(service.downloads, 0);
      expect(gateway.installs, 0);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
