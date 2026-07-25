import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/config/app_brand.dart';

void main() {
  group('AppBrands', () {
    test('provides the default locale for every flavor', () {
      expect(AppBrands.global.defaultLocale, const Locale('en', 'US'));
      expect(AppBrands.india.defaultLocale, const Locale('en', 'US'));
      expect(AppBrands.spain.defaultLocale, const Locale('es', 'ES'));
      expect(AppBrands.turkey.defaultLocale, const Locale('tr', 'TR'));
    });

    test('uses the Spain login logo', () {
      expect(AppBrands.spain.loginLogoAsset, contains('/spain/'));
    });

    test('uses the Turkey header logo', () {
      expect(AppBrands.turkey.headerLogoAsset, contains('/turkey/'));
    });

    test('provides exact logo asset paths for every flavor', () {
      for (final brand in <AppBrandConfig>[
        AppBrands.global,
        AppBrands.india,
        AppBrands.spain,
        AppBrands.turkey,
      ]) {
        expect(
          brand.loginLogoAsset,
          'assets/branding/${brand.flavor}/login_logo.png',
        );
        expect(
          brand.headerLogoAsset,
          'assets/branding/${brand.flavor}/header_logo.png',
        );
      }
    });

    test('resolves every supported flavor', () {
      expect(AppBrands.fromFlavor('global'), same(AppBrands.global));
      expect(AppBrands.fromFlavor('india'), same(AppBrands.india));
      expect(AppBrands.fromFlavor('spain'), same(AppBrands.spain));
      expect(AppBrands.fromFlavor('turkey'), same(AppBrands.turkey));
    });

    test('rejects an unknown flavor', () {
      expect(
        () => AppBrands.fromFlavor('unknown'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('AppBrand', () {
    tearDown(() => AppBrand.configure(AppBrands.global));

    test('starts with the global configuration', () {
      expect(AppBrand.current, same(AppBrands.global));
    });

    test('updates the current configuration', () {
      AppBrand.configure(AppBrands.spain);

      expect(AppBrand.current, same(AppBrands.spain));
    });
  });
}
