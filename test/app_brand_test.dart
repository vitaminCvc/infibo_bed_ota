import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/config/app_brand.dart';

void main() {
  group('AppBrands', () {
    test('provides the exact configuration for every flavor', () {
      final expectations =
          <
            ({
              AppBrandConfig brand,
              String flavor,
              Locale locale,
              String loginLogoAsset,
              String headerLogoAsset,
            })
          >[
            (
              brand: AppBrands.global,
              flavor: 'global',
              locale: const Locale('en', 'US'),
              loginLogoAsset: 'assets/branding/global/login_logo.png',
              headerLogoAsset: 'assets/branding/global/header_logo.png',
            ),
            (
              brand: AppBrands.india,
              flavor: 'india',
              locale: const Locale('en', 'US'),
              loginLogoAsset: 'assets/branding/india/login_logo.png',
              headerLogoAsset: 'assets/branding/india/header_logo.png',
            ),
            (
              brand: AppBrands.spain,
              flavor: 'spain',
              locale: const Locale('es', 'ES'),
              loginLogoAsset: 'assets/branding/spain/login_logo.png',
              headerLogoAsset: 'assets/branding/spain/header_logo.png',
            ),
            (
              brand: AppBrands.turkey,
              flavor: 'turkey',
              locale: const Locale('tr', 'TR'),
              loginLogoAsset: 'assets/branding/turkey/login_logo.png',
              headerLogoAsset: 'assets/branding/turkey/header_logo.png',
            ),
          ];

      for (final expectation in expectations) {
        expect(expectation.brand.flavor, expectation.flavor);
        expect(expectation.brand.defaultLocale, expectation.locale);
        expect(expectation.brand.loginLogoAsset, expectation.loginLogoAsset);
        expect(expectation.brand.headerLogoAsset, expectation.headerLogoAsset);
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
