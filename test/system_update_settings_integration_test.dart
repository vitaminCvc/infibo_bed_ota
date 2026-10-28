import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:infibo_app/components/designCanvas/design.dart';
import 'package:infibo_app/config/app_brand.dart';
import 'package:infibo_app/ota/ota_busy_overlay.dart';
import 'package:infibo_app/ota/ota_controller.dart';
import 'package:infibo_app/ota/ota_manifest.dart';
import 'package:infibo_app/ota/android_update_gateway.dart';
import 'package:infibo_app/pages/settingpage/ui.dart';
import 'package:infibo_app/pages/settingpage/status_detection_panel.dart';
import 'package:infibo_app/pages/settingpage/system_update_panel.dart';
import 'package:infibo_app/stores/app_header_clock_store.dart';
import 'package:infibo_app/stores/user_store.dart';
import 'package:infibo_app/translation/app_translations.dart';
import 'ota_controller_test.dart' show TestGateway, TestService;

void main() {
  for (final brand in [AppBrands.global, AppBrands.uaeBiohackn]) {
    testWidgets(
      '${brand.flavor} updated panel works within the real 800x1280 settings screen',
      (tester) async {
        AppBrand.configure(brand);
        addTearDown(() => AppBrand.configure(AppBrands.global));
        final capture =
            const bool.fromEnvironment('OTA_UI_CAPTURE') &&
            brand.flavor == 'global';
        const output = String.fromEnvironment('OTA_UI_OUTPUT');
        SharedPreferences.setMockInitialValues({});
        Get.put(UserStore());
        await tester.binding.setSurfaceSize(const Size(800, 1280));
        addTearDown(() async {
          await tester.binding.setSurfaceSize(null);
          Get.reset();
        });
        if (capture) {
          for (final family in ['InfiboSettingsYaHei', 'Roboto']) {
            await (FontLoader(family)..addFont(
                  rootBundle.load('assets/fonts/MicrosoftYaHei-Regular.ttf'),
                ))
                .load();
          }
          await (FontLoader('MaterialIcons')
                ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
              .load();
        }
        final gateway = TestGateway()
          ..code = 22
          ..version = '1.0.22';
        final service = TestService(gateway);
        final controller = OtaController(
          service: service,
          readRegister: (_) async => 0x0130,
        );
        controller.installed = const InstalledApp(
          packageName: 'com.infibo.app.global',
          version: '1.0.22',
          versionCode: 22,
        );
        controller.boardVersion = 0x0130;
        controller.checkedAt = DateTime(2026, 10, 22, 15, 30);
        controller.manifest = OtaManifest(
          app: AppRelease(
            version: '1.0.23',
            versionCode: 23,
            packageName: 'com.infibo.app.global',
            url: Uri.parse('https://example.test/app.apk'),
            size: 3,
            sha256: 'a' * 64,
            notes: '优化系统更新界面，调整版本展示与安装提示。',
          ),
          firmware: FirmwareRelease(
            version: '1.3.1',
            versionRegister: 0x0131,
            url: Uri.parse('https://example.test/firmware.bin'),
            size: 32,
            sha256: 'b' * 64,
            crc32: 1,
            notes: '主板固件更新。安装期间请保持设备供电。',
          ),
        );
        final captureKey = GlobalKey();
        service.publishedManifest = controller.manifest;
        Future<void> save(String name) async {
          if (!capture) return;
          await tester.runAsync(() async {
            final boundary =
                captureKey.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final image = await boundary.toImage();
            final data = await image.toByteData(format: ui.ImageByteFormat.png);
            await File(
              '$output/$name.png',
            ).writeAsBytes(data!.buffer.asUint8List());
            image.dispose();
          });
        }

        await tester.pumpWidget(
          RepaintBoundary(
            key: captureKey,
            child: GetMaterialApp(
              translations: AppTranslations(),
              locale: const Locale('zh', 'CN'),
              theme: ThemeData.dark(),
              home: DesignCanvas(
                child: SettingWidget(
                  updateController: controller,
                  statusReadRegister: (_) async => 0,
                  openUpdates: true,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (capture) {
          await tester.runAsync(
            () => precacheImage(
              AssetImage(AppBrand.current.headerLogoAsset),
              captureKey.currentContext!,
            ),
          );
          await tester.runAsync(
            () => precacheImage(
              const AssetImage('assets/WifiBLE/bg.png'),
              captureKey.currentContext!,
            ),
          );
          await tester.pump();
        }
        expect(find.byKey(const ValueKey('ota-app-update')), findsOneWidget);
        expect(find.byKey(const ValueKey('ota-board-update')), findsOneWidget);
        expect(find.text('下载并尝试回退'), findsNothing);
        expect(tester.takeException(), isNull);
        await save('system-update');
        final updateTitle = find.descendant(
          of: find.byType(SystemUpdatePanel),
          matching: find.text('系统更新'),
        );
        final updateTitlePosition = tester.getTopLeft(updateTitle);
        final updateTitleStyle = tester.widget<Text>(updateTitle).style;
        final updateActionPosition = tester.getTopRight(
          find.byKey(const ValueKey('ota-check')),
        );
        await tester.tap(find.text('状态检测').first);
        await tester.pumpAndSettle();
        final statusTitle = find.descendant(
          of: find.byType(StatusDetectionPanel),
          matching: find.text('状态检测'),
        );
        expect(tester.getTopLeft(statusTitle), updateTitlePosition);
        expect(tester.widget<Text>(statusTitle).style, updateTitleStyle);
        expect(
          tester.getTopRight(
            find.byKey(const ValueKey('status_detection_refresh')),
          ),
          updateActionPosition,
        );
        await save('status-header-reference');
        await tester.tap(find.text('系统更新').first);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('ota-app-update')));
        await tester.pumpAndSettle();
        expect(find.text('确认更新软件？'), findsOneWidget);
        await save('app-confirmation');
        await tester.tap(find.text('稍后'));
        await tester.pumpAndSettle();
        final board = find.byKey(const ValueKey('ota-board-update'));
        await tester.ensureVisible(board);
        await tester.tap(board);
        await tester.pumpAndSettle();
        expect(find.text('确认升级主板？'), findsOneWidget);
        await save('firmware-confirmation');
        await tester.tap(find.text('稍后'));
        await tester.pumpAndSettle();
        // Render an older APK target through the same widget, without any download.
        gateway.code = 24;
        gateway.version = '1.0.24';
        controller.installed = const InstalledApp(
          packageName: 'com.infibo.app.global',
          version: '1.0.24',
          versionCode: 24,
        );
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(
          RepaintBoundary(
            key: captureKey,
            child: GetMaterialApp(
              translations: AppTranslations(),
              locale: const Locale('zh', 'CN'),
              theme: ThemeData.dark(),
              home: DesignCanvas(
                child: SettingWidget(
                  updateController: controller,
                  openUpdates: true,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<FilledButton>(
                find.byKey(const ValueKey('ota-app-update')),
              )
              .onPressed,
          isNull,
        );
        expect(find.text('已是最新版本'), findsOneWidget);
        await save('no-apk-rollback');
        await tester.pumpWidget(const SizedBox.shrink());
        if (capture) {
          controller.phase = OtaPhase.transferring;
          controller.progress = .5;
          await tester.pumpWidget(
            RepaintBoundary(
              key: captureKey,
              child: GetMaterialApp(
                translations: AppTranslations(),
                locale: const Locale('zh', 'CN'),
                theme: ThemeData.dark(),
                home: OtaBusyOverlay(
                  controller: controller,
                  child: const Scaffold(),
                ),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 300));
          await save('firmware-progress');
          await tester.pumpWidget(const SizedBox.shrink());
        }
        controller.dispose();
        Get.delete<AppHeaderClockController>(force: true);
      },
    );
  }
}
