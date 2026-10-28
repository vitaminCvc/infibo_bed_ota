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

class _OfflineService extends TestService {
  _OfflineService(super.gateway);
  @override
  Future<UpdateCheck> check() async =>
      throw const OtaFailure('ota_network_error');
}

void main() {
  late OtaController controller;
  late TestGateway gateway;
  late TestService service;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    gateway = TestGateway();
    service = TestService(gateway);
    controller = OtaController(
      service: service,
      readRegister: (_) async => 0x0130,
    );
    await controller.refresh();
  });
  tearDown(() {
    controller.dispose();
    Get.reset();
  });

  Future<void> render(
    WidgetTester tester, {
    double width = 411,
    double scale = 1,
    Locale locale = const Locale('zh', 'CN'),
  }) async {
    service.publishedManifest = controller.manifest;
    gateway.code = controller.installed?.versionCode ?? 1;
    gateway.version = controller.installed?.version ?? '1.0.0';
    await tester.binding.setSurfaceSize(Size(width, 850));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: locale,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
            disableAnimations: true,
          ),
          child: child!,
        ),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              height: 850,
              child: SystemUpdatePanel(controller: controller),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final installedCode in [2, 3]) {
    testWidgets('APK Build $installedCode shows disabled up-to-date button', (
      tester,
    ) async {
      controller.installed = await (TestGateway()..code = installedCode)
          .installedApp();
      await render(tester);
      final action = find.byKey(const ValueKey('ota-app-update'));
      expect(tester.widget<FilledButton>(action).onPressed, isNull);
      expect(
        find.descendant(of: action, matching: find.text('已是最新版本')),
        findsOneWidget,
      );
      expect(find.text('无需更新'), findsOneWidget);
      expect(service.downloads, 0);
    });
  }

  for (final target in [0x0129, 0x0130, 0x0131]) {
    testWidgets('firmware target $target disables only the matching version', (
      tester,
    ) async {
      controller.manifest = OtaManifest(
        app: service.release,
        firmware: FirmwareRelease(
          version: target == 0x0130
              ? '1.3.0'
              : target == 0x0131
              ? '1.3.1'
              : '1.2.9',
          versionRegister: target,
          url: Uri.parse('https://example.test/firmware.bin'),
          size: 32,
          sha256: 'b' * 64,
          crc32: 1,
        ),
      );
      await render(tester);
      final finder = find.byKey(const ValueKey('ota-board-update'));
      await tester.ensureVisible(finder);
      final button = tester.widget<FilledButton>(finder);
      if (target == 0x0130) {
        expect(button.onPressed, isNull);
        expect(
          find.descendant(of: finder, matching: find.text('已是最新版本')),
          findsOneWidget,
        );
        expect(find.text('下载并重新安装'), findsNothing);
        expect(find.text('当前发布与主板版本相同，可以手动重新安装。'), findsNothing);
      } else {
        expect(button.onPressed, isNotNull);
      }
      expect(service.downloads, 0);
    });
  }

  testWidgets('software notes are shown only in its download confirmation', (
    tester,
  ) async {
    final notes = List.generate(15, (i) => '第${i + 1}项更新内容').join('\n');
    controller.manifest = OtaManifest(
      app: AppRelease(
        version: '1.1.0',
        url: service.release.url,
        size: 3,
        sha256: service.release.sha256,
        versionCode: 2,
        packageName: service.release.packageName,
        notes: notes,
      ),
    );
    await render(tester);
    final disclosure = find.byKey(const ValueKey('ota-app-notes'));
    expect(disclosure, findsNothing);
    expect(find.text(notes), findsNothing);
    final download = find.byKey(const ValueKey('ota-app-update'));
    await tester.ensureVisible(download);
    await tester.tap(download);
    await tester.pumpAndSettle();
    expect(find.text(notes), findsOneWidget);
    await tester.tap(find.text('稍后'));
    await tester.pumpAndSettle();
    expect(find.text(notes), findsNothing);
    expect(service.downloads, 0);
  });

  testWidgets('one network error message, and a missing board is explained', (
    tester,
  ) async {
    controller.dispose();
    service = _OfflineService(gateway);
    controller = OtaController(
      service: service,
      readRegister: (_) async => throw StateError('Board offline'),
    );
    await render(tester);
    expect(find.text('无法下载更新，请检查网络后重试。'), findsOneWidget);
    expect(find.text('未读取到主板版本，请检查供电和串口连接后重新检查。'), findsOneWidget);
    expect(find.byKey(const ValueKey('ota-board-update')), findsNothing);
  });

  testWidgets('empty firmware notes are hidden from the settings card', (
    tester,
  ) async {
    controller.manifest = OtaManifest(
      app: service.release,
      firmware: FirmwareRelease(
        version: '1.3.1',
        versionRegister: 0x0131,
        url: Uri.parse('https://example.test/firmware.bin'),
        size: 32,
        sha256: 'b' * 64,
        crc32: 1,
      ),
    );
    await render(tester);
    expect(find.byKey(const ValueKey('ota-board-notes-empty')), findsNothing);
    expect(find.text('更新说明'), findsNothing);
    expect(find.byKey(const ValueKey('ota-board-update')), findsOneWidget);
    expect(service.downloads, 0);
  });

  testWidgets(
    'firmware notes are available only in confirmation without starting installation',
    (tester) async {
      final notes = List.generate(10, (i) => '固件修复项目 ${i + 1}').join('\n');
      controller.manifest = OtaManifest(
        app: service.release,
        firmware: FirmwareRelease(
          version: '1.3.1',
          versionRegister: 0x0131,
          url: Uri.parse('https://example.test/firmware.bin'),
          size: 32,
          sha256: 'b' * 64,
          crc32: 1,
          notes: notes,
        ),
      );
      await render(tester);
      final disclosure = find.byKey(const ValueKey('ota-board-notes'));
      expect(disclosure, findsNothing);
      expect(find.text(notes), findsNothing);
      final update = find.byKey(const ValueKey('ota-board-update'));
      await tester.ensureVisible(update);
      await tester.tap(update);
      await tester.pumpAndSettle();
      expect(find.text(notes), findsOneWidget);
      await tester.tap(find.text('稍后'));
      await tester.pumpAndSettle();
      expect(service.downloads, 0);
    },
  );

  for (final firmware in [false, true]) {
    testWidgets(
      'confirmation reads selected Polish notes for ${firmware ? 'firmware' : 'app'}',
      (tester) async {
        const translated = 'Poprawiono połączenie i wyświetlanie.';
        controller.manifest = OtaManifest(
          app: AppRelease(
            version: service.release.version,
            versionCode: service.release.versionCode,
            packageName: service.release.packageName,
            url: service.release.url,
            size: service.release.size,
            sha256: service.release.sha256,
            notes: '修复连接与显示',
            notesI18n: const {
              'pl_PL': translated,
              'en_US': 'Connection and display fixes.',
            },
          ),
          firmware: FirmwareRelease(
            version: '1.3.1',
            versionRegister: 0x0131,
            url: Uri.parse('https://example.test/board_APP_OTA.bin'),
            size: 32,
            sha256: 'b' * 64,
            crc32: 1,
            notes: '修复连接与显示',
            notesI18n: const {
              'pl_PL': translated,
              'en_US': 'Connection and display fixes.',
            },
          ),
        );
        await render(tester, locale: const Locale('pl', 'PL'));
        final button = find.byKey(
          ValueKey(firmware ? 'ota-board-update' : 'ota-app-update'),
        );
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(find.text(translated), findsOneWidget);
        expect(find.text('修复连接与显示'), findsNothing);
        expect(tester.takeException(), isNull);
        expect(service.downloads, 0);
      },
    );
  }

  for (final width in [320.0, 375.0, 700.0]) {
    for (final locale in [const Locale('zh', 'CN'), const Locale('en', 'US')]) {
      testWidgets(
        'readable at $width, $locale, large text and reduced motion',
        (tester) async {
          await render(tester, width: width, scale: 2, locale: locale);
          expect(tester.takeException(), isNull);
          final update = find.byKey(const ValueKey('ota-app-update'));
          await tester.ensureVisible(update);
          await tester.pumpAndSettle();
          expect(tester.getSize(update).height, greaterThanOrEqualTo(48));
          await tester.tap(update);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.tap(
            find.text(locale.languageCode == 'zh' ? '稍后' : 'Later'),
          );
          await tester.pumpAndSettle();
          expect(service.downloads, 0);
        },
      );
    }
  }
}
