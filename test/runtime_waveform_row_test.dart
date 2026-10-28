import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/pages/start/runtime_waveform_row.dart';
import 'package:infibo_app/translation/app_translations.dart';

Future<void> _loadFont(WidgetTester tester) async {
  await tester.runAsync(() async {
    final font = FontLoader('WaveformTest');
    font.addFont(rootBundle.load('assets/fonts/MicrosoftYaHei-Regular.ttf'));
    await font.load();
  });
}

Future<void> _pumpRow(
  WidgetTester tester,
  Locale locale,
  String labelKey, {
  bool red = true,
}) async {
  Get.locale = locale;
  final asset = red ? Assets.startExpandContinuous : Assets.startPemfWaveSine;
  await tester.pumpWidget(
    MaterialApp(
      key: ValueKey('$locale-$labelKey'),
      theme: ThemeData(fontFamily: 'WaveformTest'),
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: RuntimeWaveformRow(
            labelKey: labelKey,
            asset: asset,
            waveformWidth: red ? 170 : 168,
            waveformHeight: red ? 24 : null,
          ),
        ),
      ),
    ),
  );
  await tester.runAsync(
    () => precacheImage(
      AssetImage(asset),
      tester.element(find.byType(RuntimeWaveformRow)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => Get.addTranslations(AppTranslations().keys));
  tearDown(() => Get.reset());

  testWidgets('runtime abbreviations retain full labels on other screens', (
    tester,
  ) async {
    await _loadFont(tester);
    await _pumpRow(tester, const Locale('pl', 'PL'), 'pulse');
    expect(find.text('Imp.'), findsOneWidget);
    expect('pulse'.tr, 'Impulsowy');
    await _pumpRow(tester, const Locale('pl', 'PL'), 'waveform', red: false);
    expect(find.text('Przeb.'), findsOneWidget);
    expect('waveform'.tr, 'Przebieg');
  });

  testWidgets('every locale keeps waveform size and right margin unchanged', (
    tester,
  ) async {
    await _loadFont(tester);
    final locales = AppTranslations().keys.keys.toList();
    Offset? redPosition;
    Offset? pemfPosition;
    for (final localeKey in locales) {
      final parts = localeKey.split('_');
      final locale = Locale(parts[0], parts[1]);
      for (final labelKey in ['continuous', 'pulse', 'waveform']) {
        final red = labelKey != 'waveform';
        await _pumpRow(tester, locale, labelKey, red: red);
        final row = tester.getRect(find.byType(RuntimeWaveformRow));
        final image = tester.getRect(find.byType(Image));
        expect(image.width, red ? 170 : 168, reason: '$localeKey $labelKey');
        expect(image.right, row.right, reason: '$localeKey $labelKey');
        if (red) {
          redPosition ??= image.topLeft;
          expect(image.topLeft, redPosition);
          expect(image.height, 24);
        } else {
          pemfPosition ??= image.topLeft;
          expect(image.topLeft, pemfPosition);
        }
        expect(tester.widget<Text>(find.byType(Text)).maxLines, 1);
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('an extra long name is ellipsized without scaling the waveform', (
    tester,
  ) async {
    await _loadFont(tester);
    Get.addTranslations({
      'pl_PL': {
        ...AppTranslations().keys['pl_PL']!,
        'continuous': 'Bardzo długa nazwa trybu światła czerwonego',
      },
    });
    await _pumpRow(tester, const Locale('pl', 'PL'), 'continuous');
    final paragraph = tester.renderObject<RenderParagraph>(
      find.byType(RichText),
    );
    expect(paragraph.didExceedMaxLines, isTrue);
    expect(tester.getSize(find.byType(Image)), const Size(170, 24));
    final row = tester.getRect(find.byType(RuntimeWaveformRow));
    expect(tester.getRect(find.byType(Image)).right, row.right);
    expect(tester.takeException(), isNull);
  });
}
