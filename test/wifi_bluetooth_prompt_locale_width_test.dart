import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/translation/app_translations.dart';

void main() {
  test('every localized prompt fits the dialog without scaling', () {
    for (final MapEntry<String, Map<String, String>> locale
        in AppTranslations().keys.entries) {
      final String title = locale.value['connection_prompt_title']!;
      final String subtitle = locale.value['connection_prompt_subtitle']!;
      final TextDirection direction = locale.key.startsWith('ar_')
          ? TextDirection.rtl
          : TextDirection.ltr;
      final TextPainter titlePainter = TextPainter(
        text: TextSpan(
          text: title,
          style: const TextStyle(fontSize: 24, height: 1),
        ),
        textDirection: direction,
        maxLines: 1,
      )..layout();
      final TextPainter subtitlePainter = TextPainter(
        text: TextSpan(
          text: subtitle,
          style: const TextStyle(fontSize: 18, height: 1),
        ),
        textDirection: direction,
        maxLines: 1,
      )..layout();

      expect(
        titlePainter.width,
        lessThanOrEqualTo(448),
        reason: '${locale.key} title is too wide',
      );
      expect(
        subtitlePainter.width,
        lessThanOrEqualTo(448),
        reason: '${locale.key} subtitle is too wide',
      );
    }
  });
}
