import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:infibo_app/ota/ota_controller.dart';
import 'package:infibo_app/ota/ota_manifest.dart';
import 'package:infibo_app/ota/ota_service.dart';
import 'package:infibo_app/pages/settingpage/system_update_panel.dart';
import 'package:infibo_app/translation/app_translations.dart';
import 'ota_controller_test.dart' show TestGateway, TestService;

class _DelayedCheck extends TestService {
  _DelayedCheck(super.gateway);
  final result = Completer<OtaManifest>();
  @override
  Future<UpdateCheck> check() async {
    checks++;
    return UpdateCheck(await gateway.installedApp(), await result.future);
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(Get.reset);
  Future<void> enter(WidgetTester tester, OtaController controller) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('zh', 'CN'),
        home: AnimatedBuilder(
          animation: controller,
          builder: (context, _) =>
              Scaffold(body: SystemUpdatePanel(controller: controller)),
        ),
      ),
    );
  }

  testWidgets(
    'every entry refreshes cached release and board version without a click',
    (tester) async {
      final service = TestService(TestGateway());
      var board = 0x0130;
      var reads = 0;
      final controller = OtaController(
        service: service,
        readRegister: (address) async {
          expect(address, 2);
          reads++;
          return board;
        },
      );
      addTearDown(controller.dispose);
      await controller.refresh();
      AppRelease target(int code) => AppRelease(
        version: '1.2.$code',
        versionCode: code,
        packageName: service.release.packageName,
        url: service.release.url,
        size: 3,
        sha256: service.release.sha256,
      );
      service.publishedManifest = OtaManifest(app: target(3));
      board = 0x0131;
      await enter(tester, controller);
      await tester.pumpAndSettle();
      expect(service.checks, 2);
      expect(reads, 2);
      expect(controller.manifest!.app!.versionCode, 3);
      expect(find.text('1.3.1'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      service.publishedManifest = OtaManifest(app: target(4));
      board = 0x0132;
      await enter(tester, controller);
      await tester.pumpAndSettle();
      expect(service.checks, 3);
      expect(reads, 3);
      expect(controller.manifest!.app!.versionCode, 4);
      expect(find.text('1.3.2'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ota-check')));
      await tester.pumpAndSettle();
      expect(service.checks, 4);
      expect(reads, 4);
      expect(service.downloads, 0);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('reentry during a pending check does not overlap requests', (
    tester,
  ) async {
    final gateway = TestGateway();
    final service = _DelayedCheck(gateway);
    var reads = 0;
    final controller = OtaController(
      service: service,
      readRegister: (_) async {
        reads++;
        return 0x0130;
      },
    );
    addTearDown(controller.dispose);
    controller.installed = await gateway.installedApp();
    await enter(tester, controller);
    await tester.pump();
    expect(service.checks, 1);
    expect(controller.checking, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
    await enter(tester, controller);
    await tester.pump();
    expect(service.checks, 1);
    service.result.complete(OtaManifest(app: service.release));
    await tester.pumpAndSettle();
    expect(reads, 1);
    expect(controller.checking, isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'entry while transferring does not interrupt the active upgrade',
    (tester) async {
      final gateway = TestGateway();
      final service = TestService(gateway);
      var reads = 0;
      final controller = OtaController(
        service: service,
        readRegister: (_) async {
          reads++;
          return 0x0130;
        },
      );
      addTearDown(controller.dispose);
      controller.installed = await gateway.installedApp();
      controller.phase = OtaPhase.transferring;
      await enter(tester, controller);
      await tester.pumpAndSettle();
      expect(service.checks, 0);
      expect(reads, 0);
      expect(controller.phase, OtaPhase.transferring);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
