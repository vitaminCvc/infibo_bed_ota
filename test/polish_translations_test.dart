import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/translation/app_translations.dart';

void main() {
  test('Polish covers every existing English and Chinese translation key', () {
    final translations = AppTranslations().keys;
    final polish = translations['pl_PL'] ?? <String, String>{};
    final referenceKeys = {
      ...translations['en_US']!.keys,
      ...translations['zh_CN']!.keys,
    };

    expect(polish.keys.toSet(), containsAll(referenceKeys));
    for (final key in referenceKeys) {
      expect(polish[key]?.trim(), isNotEmpty, reason: key);
    }
  });

  test(
    'Polish preserves substitution parameters in every translated message',
    () {
      final translations = AppTranslations().keys;
      final polish = translations['pl_PL'];
      expect(polish, isNotNull);
      final reference = {...translations['zh_CN']!, ...translations['en_US']!};
      final parameterPattern = RegExp(r'@[A-Za-z_][A-Za-z0-9_]*');
      for (final entry in reference.entries) {
        final expected =
            parameterPattern
                .allMatches(entry.value)
                .map((match) => match.group(0))
                .toList()
              ..sort();
        final actual =
            parameterPattern
                .allMatches(polish![entry.key] ?? '')
                .map((match) => match.group(0))
                .toList()
              ..sort();
        expect(actual, expected, reason: entry.key);
      }
    },
  );

  test('Polish messages are not replaced by the English fallback', () {
    final translations = AppTranslations().keys;
    final polish = translations['pl_PL']!;
    // International abbreviations, units and role names are shared labels.
    const sharedLabels = {
      'male',
      'connection_prompt_wifi',
      'connection_prompt_ble',
      'minutes_unit',
      'seconds_unit',
      'Admin',
      'Operator',
      'hydrogen_molecule',
      'module_hydrogen',
      'red_ther',
      'rf',
    };
    for (final entry in translations['en_US']!.entries) {
      if (!sharedLabels.contains(entry.key)) {
        expect(polish[entry.key], isNot(entry.value), reason: entry.key);
      }
    }
  });
}
