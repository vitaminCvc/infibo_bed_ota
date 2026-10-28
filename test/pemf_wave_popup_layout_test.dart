import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infibo_app/config/app_brand.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/pages/customized/customizedPage/ui.dart';
import 'package:infibo_app/stores/app_header_clock_store.dart';
import 'package:infibo_app/stores/user_store.dart';
import 'package:infibo_app/translation/app_translations.dart';

Finder _asset(String name) => find.byWidgetPredicate(
  (widget) =>
      widget is Image &&
      widget.image is AssetImage &&
      (widget.image as AssetImage).assetName == name,
);

Finder _action(String text) => find
    .ancestor(of: find.text(text), matching: find.byType(GestureDetector))
    .first;

Future<void> _openPicker(WidgetTester tester) async {
  // The selector has a transparent input layer above its painted contents.
  await tester.tapAt(tester.getCenter(find.byIcon(Icons.keyboard_arrow_down)));
  await tester.pumpAndSettle();
}

Future<void> _openEditor(WidgetTester tester, Locale locale) async {
  await tester.binding.setSurfaceSize(const Size(800, 1280));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  Get.testMode = true;
  AppBrand.configure(AppBrands.global);
  Get.put(UserStore());
  Get.put<AppHeaderClockController>(_Clock());
  addTearDown(() => Get.reset());
  await tester.runAsync(() async {
    final font = FontLoader('WavePopupTest');
    font.addFont(rootBundle.load('assets/fonts/MicrosoftYaHei-Regular.ttf'));
    await font.load();
  });
  await tester.pumpWidget(
    GetMaterialApp(
      translations: AppTranslations(),
      locale: locale,
      theme: ThemeData(fontFamily: 'WavePopupTest'),
      home: const CustomizedEditPage(),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.add).first);
  await tester.pumpAndSettle();
  await tester.tapAt(tester.getCenter(find.text('PEMF')));
  await tester.pumpAndSettle();
  await _openPicker(tester);
}

void main() {
  for (final locale in [const Locale('pl', 'PL'), const Locale('ru', 'RU')]) {
    testWidgets('wave actions fit and preserve selection in $locale', (
      tester,
    ) async {
      await _openEditor(tester, locale);
      final cancel = 'cancel'.tr;
      final confirm = 'confirm'.tr;
      final popup = tester.getRect(_asset(Assets.customizedPemfWaveDialog));
      final scale = popup.width / 279;
      final cancelRect = tester.getRect(_action(cancel));
      final confirmRect = tester.getRect(_action(confirm));
      expect(cancelRect.overlaps(confirmRect), isFalse);
      expect(
        (cancelRect.left + confirmRect.right) / 2,
        closeTo(popup.center.dx, 0.01),
      );
      for (final label in [cancel, confirm]) {
        final text = tester.widget<Text>(find.text(label));
        final painter = TextPainter(
          text: TextSpan(
            text: label,
            style: text.style!.copyWith(fontFamily: 'WavePopupTest'),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        expect(
          tester.getSize(_action(label)).width,
          greaterThanOrEqualTo((painter.width + 24) * scale),
        );
        painter.dispose();
      }
      // Pick the second waveform and confirm at the button's outer edge.
      await tester.tapAt(popup.topLeft + Offset(139, 67 + 52 + 22) * scale);
      await tester.pumpAndSettle();
      expect(_asset(Assets.customizedPemfWaveSineSelected), findsOneWidget);
      await tester.tapAt(confirmRect.centerRight - Offset(2 * scale, 0));
      await tester.pumpAndSettle();
      expect(_asset(Assets.customizedPemfWaveDialog), findsNothing);
      await _openPicker(tester);
      expect(_asset(Assets.customizedPemfWaveSineSelected), findsOneWidget);
      // Cancel a different choice; reopening must retain the confirmed sine.
      await tester.tapAt(popup.topLeft + Offset(139, 67 + 22) * scale);
      await tester.pumpAndSettle();
      await tester.tapAt(
        tester.getRect(_action(cancel)).centerLeft + Offset(2 * scale, 0),
      );
      await tester.pumpAndSettle();
      expect(_asset(Assets.customizedPemfWaveDialog), findsNothing);
      await _openPicker(tester);
      expect(_asset(Assets.customizedPemfWaveSineSelected), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('long wave actions wrap below the unchanged waveform list', (
    tester,
  ) async {
    await _openEditor(tester, const Locale('pl', 'PL'));
    await tester.tapAt(tester.getCenter(_action('cancel'.tr)));
    await tester.pumpAndSettle();
    Get.addTranslations({
      'pl_PL': {
        ...AppTranslations().keys['pl_PL']!,
        'cancel': 'Anuluj wybór przebiegu',
        'confirm': 'Potwierdź wybrany przebieg',
      },
    });
    await _openPicker(tester);
    final popup = tester.getRect(_asset(Assets.customizedPemfWaveDialog));
    final scale = popup.width / 279;
    final cancelRect = tester.getRect(_action('cancel'.tr));
    final confirmRect = tester.getRect(_action('confirm'.tr));
    expect(popup.height, greaterThan(658 * scale));
    expect(confirmRect.top, greaterThanOrEqualTo(cancelRect.bottom));
    expect(
      cancelRect.top,
      greaterThanOrEqualTo(popup.top + 601 * scale - 0.01),
    );
    expect(
      popup.contains(confirmRect.bottomRight - const Offset(1, 1)),
      isTrue,
    );
    await tester.tapAt(confirmRect.centerRight - Offset(2 * scale, 0));
    await tester.pumpAndSettle();
    expect(_asset(Assets.customizedPemfWaveDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

class _Clock extends AppHeaderClockController {
  final _time = '11:03'.obs;
  final _date = '2026.10.23'.obs;
  @override
  String get timeText => _time.value;
  @override
  String get dateText => _date.value;
  @override
  void startClock() {}
}
