import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infibo_app/pages/start/runtime_parameter_pair.dart';
import 'package:infibo_app/translation/app_translations.dart';

void main() {
  tearDown(() => Get.reset());

  testWidgets(
    'Polish runtime labels are short without changing other screens',
    (tester) async {
      Get.addTranslations(AppTranslations().keys);
      Get.locale = const Locale('pl', 'PL');
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RuntimeParameterPair(
              leftLabelKey: 'frequency',
              rightLabelKey: 'intensity',
              leftValue: '100',
              rightValue: '80',
            ),
          ),
        ),
      );
      expect(find.text('Częst.'), findsOneWidget);
      expect(find.text('Intens.'), findsOneWidget);
      expect('frequency'.tr, 'Częstotliwość');
      expect('intensity'.tr, 'Intensywność');
    },
  );

  testWidgets(
    'long translations cannot move values or the following waveform',
    (tester) async {
      Get.addTranslations(AppTranslations().keys);
      Offset? originalValue;
      Offset? originalNextRow;
      for (final language in ['en', 'pl', 'ru', 'fr', 'ar']) {
        Get.locale = Locale(
          language,
          {
            'en': 'US',
            'pl': 'PL',
            'ru': 'RU',
            'fr': 'FR',
            'ar': 'SA',
          }[language],
        );
        await tester.pumpWidget(
          MaterialApp(
            key: ValueKey(language),
            home: const Scaffold(
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RuntimeParameterPair(
                    leftLabelKey: 'frequency',
                    rightLabelKey: 'intensity',
                    leftValue: '100',
                    rightValue: '80',
                  ),
                  Text('waveform area'),
                ],
              ),
            ),
          ),
        );
        await tester.pump();
        expect(
          find.text(language == 'pl' ? 'runtime_frequency'.tr : 'frequency'.tr),
          findsOneWidget,
        );
        final value = tester.getTopLeft(find.text('100'));
        final nextRow = tester.getTopLeft(find.text('waveform area'));
        originalValue ??= value;
        originalNextRow ??= nextRow;
        expect(value, originalValue, reason: language);
        expect(nextRow, originalNextRow, reason: language);
        expect(tester.getTopLeft(find.text('80')).dy, value.dy);
        expect(tester.takeException(), isNull);
      }
    },
  );
}
