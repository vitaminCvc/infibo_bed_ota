import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/bootstrap.dart';

void main() {
  group('resolveInitialLocale', () {
    const fallback = Locale('es', 'ES');

    test('returns the brand fallback when no locale is saved', () {
      expect(resolveInitialLocale(fallback: fallback), fallback);
    });

    test('returns the fully saved locale', () {
      expect(
        resolveInitialLocale(
          languageCode: 'tr',
          countryCode: 'TR',
          fallback: fallback,
        ),
        const Locale('tr', 'TR'),
      );
    });

    test('returns the fallback when only the language is saved', () {
      expect(
        resolveInitialLocale(languageCode: 'tr', fallback: fallback),
        fallback,
      );
    });

    test('returns the fallback when only the country is saved', () {
      expect(
        resolveInitialLocale(countryCode: 'TR', fallback: fallback),
        fallback,
      );
    });
  });
}
