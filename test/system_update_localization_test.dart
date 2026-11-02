import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:infibo_app/ota/ota_controller.dart';
import 'package:infibo_app/ota/ota_busy_overlay.dart';
import 'package:infibo_app/ota/ota_manifest.dart';
import 'package:infibo_app/pages/settingpage/system_update_panel.dart';
import 'package:infibo_app/translation/app_translations.dart';
import 'package:infibo_app/translation/ota_translations.dart';
import 'package:infibo_app/translation/ota_translations_western.dart';
import 'package:infibo_app/translation/ota_translations_eastern.dart';
import 'ota_controller_test.dart' show TestGateway, TestService;

const _locales = [
  Locale('zh', 'CN'),
  Locale('en', 'US'),
  Locale('pl', 'PL'),
  Locale('es', 'ES'),
  Locale('pt', 'PT'),
  Locale('ru', 'RU'),
  Locale('fr', 'FR'),
  Locale('ko', 'KR'),
  Locale('ar', 'SA'),
  Locale('de', 'DE'),
  Locale('tr', 'TR'),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader(
          'InfiboOtaKorean',
        )..addFont(rootBundle.load('assets/fonts/InfiboOtaKorean-Regular.ttf')))
        .load();
    await (FontLoader(
          'InfiboOtaArabic',
        )..addFont(rootBundle.load('assets/fonts/NotoSansArabic-Variable.ttf')))
        .load();
    await (FontLoader('InfiboSettingsYaHei')
          ..addFont(rootBundle.load('assets/fonts/MicrosoftYaHei-Regular.ttf')))
        .load();
    if (const bool.fromEnvironment('OTA_I18N_CAPTURE')) {
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    }
  });
  tearDown(() => Get.reset());

  test(
    'all added OTA locales use native translations with complete placeholder coverage',
    () {
      final english = withOtaTranslations({'en_US': {}})['en_US']!;
      final native = {...otaWesternTranslations, ...otaEasternTranslations};
      final localized = withOtaTranslations({
        for (final locale in native.keys) locale: {},
      });
      for (final entry in native.entries) {
        expect(
          entry.value.keys,
          unorderedEquals(english.keys),
          reason: entry.key,
        );
        for (final item in entry.value.entries) {
          final placeholders = RegExp(r'@[a-z_]+');
          expect(
            placeholders.allMatches(item.value).map((m) => m[0]).toSet(),
            placeholders
                .allMatches(english[item.key]!)
                .map((m) => m[0])
                .toSet(),
            reason: '${entry.key}/${item.key}',
          );
          expect(
            localized[entry.key]![item.key],
            item.value,
            reason: '${entry.key}/${item.key} must not fall back to English',
          );
        }
      }
    },
  );

  Future<(OtaController, TestService)> render(
    WidgetTester tester,
    Locale locale, {
    double width = 411,
    double scale = 1,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final service = TestService(TestGateway());
    service.publishedManifest = OtaManifest(
      app: service.release,
      firmware: FirmwareRelease(
        version: '1.3.1',
        versionRegister: 0x0131,
        url: Uri.parse('https://example.test/firmware.bin'),
        size: 32,
        sha256: 'b' * 64,
        crc32: 1,
        notes: 'Fallback notes',
        notesI18n: {locale.toString(): 'Localized notes ${locale.toString()}'},
      ),
    );
    final controller = OtaController(
      service: service,
      readRegister: (_) async => 0x0130,
    );
    await tester.binding.setSurfaceSize(Size(width, 1000));
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
      await tester.binding.setSurfaceSize(null);
    });
    await tester.pumpWidget(
      GetMaterialApp(
        locale: locale,
        translations: AppTranslations(),
        theme: ThemeData.dark().copyWith(
          textTheme: ThemeData.dark().textTheme.apply(
            fontFamily: 'InfiboSettingsYaHei',
          ),
        ),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: RepaintBoundary(
            key: const ValueKey('ota-localized-capture'),
            child: child!,
          ),
        ),
        home: Scaffold(
          body: SizedBox(
            width: width,
            child: SystemUpdatePanel(controller: controller),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return (controller, service);
  }

  for (final locale in _locales) {
    for (final phase in [
      OtaPhase.downloading,
      OtaPhase.transferring,
      OtaPhase.boardInstalling,
      OtaPhase.boardReconnecting,
    ]) {
      testWidgets(
        'progress $locale $phase fits large text and keeps safe cancellation rules',
        (tester) async {
          SharedPreferences.setMockInitialValues({});
          final controller = OtaController(
            service: TestService(TestGateway()),
            readRegister: (_) async => 0,
          );
          controller.phase = phase;
          controller.progress = .5;
          await tester.binding.setSurfaceSize(const Size(320, 400));
          addTearDown(() async {
            await tester.pumpWidget(const SizedBox.shrink());
            controller.dispose();
            await tester.binding.setSurfaceSize(null);
          });
          await tester.pumpWidget(
            GetMaterialApp(
              translations: AppTranslations(),
              locale: locale,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(2),
                  disableAnimations: true,
                ),
                child: child!,
              ),
              home: OtaBusyOverlay(
                controller: controller,
                child: const Scaffold(body: Text('background')),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 300));
          final words = AppTranslations().keys[locale.toString()]!;
          expect(find.text(words[controller.phaseKey]!), findsOneWidget);
          expect(
            find.byKey(const ValueKey('ota-progress-cancel')),
            controller.canCancel ? findsOneWidget : findsNothing,
          );
          expect(
            find.text(
              words[phase == OtaPhase.downloading
                  ? 'ota_download_hint'
                  : 'ota_power_hint']!,
            ),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
    for (final narrow in [false, true]) {
      testWidgets(
        'system update $locale at ${narrow ? '320px large text' : '411px'} fits and opens localized firmware confirmation',
        (tester) async {
          final (_, service) = await render(
            tester,
            locale,
            width: narrow ? 320 : 411,
            scale: narrow ? 2 : 1,
          );
          final words = AppTranslations().keys[locale.toString()]!;
          expect(find.text(words['ota_board']!), findsOneWidget);
          expect(find.text(words['ota_check']!), findsOneWidget);
          if (!narrow && locale.languageCode == 'en') {
            final title = find.text(words['ota_board']!);
            final status = find.text(words['ota_status_available']!).last;
            expect(
              tester.getCenter(title).dy,
              closeTo(tester.getCenter(status).dy, 1),
            );
            for (final finder in [title, status]) {
              final text = tester.widget<Text>(finder).data!;
              final paragraph = tester.renderObject<RenderParagraph>(finder);
              final lines = paragraph
                  .getBoxesForSelection(
                    TextSelection(baseOffset: 0, extentOffset: text.length),
                  )
                  .map((box) => box.top)
                  .toSet();
              expect(
                lines.length,
                1,
                reason: 'English $text must fit on one line',
              );
            }
          }
          if (locale.languageCode == 'ar') {
            expect(
              Directionality.of(tester.element(find.text(words['ota_board']!))),
              TextDirection.rtl,
            );
          }
          expect(tester.takeException(), isNull);
          final update = find.byKey(const ValueKey('ota-board-update'));
          await tester.ensureVisible(update);
          await tester.tap(update);
          await tester.pumpAndSettle();
          expect(find.text(words['ota_confirm_board']!), findsOneWidget);
          expect(
            find.text('Localized notes ${locale.toString()}'),
            findsOneWidget,
          );
          expect(find.text('Fallback notes'), findsNothing);
          expect(tester.takeException(), isNull);
          await tester.tap(find.text(words['ota_later']!));
          await tester.pumpAndSettle();
          expect(service.downloads, 0);
        },
      );
    }
  }

  if (const bool.fromEnvironment('OTA_I18N_CAPTURE')) {
    for (final locale in [
      const Locale('en', 'US'),
      const Locale('de', 'DE'),
      const Locale('ar', 'SA'),
      const Locale('ko', 'KR'),
    ]) {
      testWidgets('capture localized system update $locale', (tester) async {
        await render(tester, locale);
        Future<void> save(String suffix) async {
          await tester.runAsync(() async {
            const output = String.fromEnvironment('OTA_I18N_OUTPUT');
            await Directory(output).create(recursive: true);
            final boundary = tester.renderObject<RenderRepaintBoundary>(
              find.byKey(const ValueKey('ota-localized-capture')),
            );
            final image = await boundary.toImage(pixelRatio: 1);
            final data = await image.toByteData(format: ui.ImageByteFormat.png);
            await File(
              '$output/${locale.toString()}-$suffix.png',
            ).writeAsBytes(data!.buffer.asUint8List());
            image.dispose();
          });
        }

        await save('panel');
        final update = find.byKey(const ValueKey('ota-board-update'));
        await tester.ensureVisible(update);
        await tester.tap(update);
        await tester.pumpAndSettle();
        await save('confirmation');
        expect(tester.takeException(), isNull);
      });
    }
  }
}
