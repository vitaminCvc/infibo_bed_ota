import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/config/app_brand.dart';
import 'package:infibo_app/constants/assets.dart';

void main() {
  group('AppBrands', () {
    const supportedBrands = <AppBrandConfig>[
      AppBrands.global,
      AppBrands.india,
      AppBrands.spain,
      AppBrands.turkey,
      AppBrands.america,
      AppBrands.australia,
    ];

    test('provides the exact configuration for every flavor', () {
      final expectations =
          <
            ({
              AppBrandConfig brand,
              String flavor,
              Locale locale,
              String loginLogoAsset,
              Size loginLogoSize,
              String headerLogoAsset,
            })
          >[
            (
              brand: AppBrands.global,
              flavor: 'global',
              locale: const Locale('en', 'US'),
              loginLogoAsset: 'assets/branding/global/login_logo.png',
              loginLogoSize: const Size(306, 166),
              headerLogoAsset: 'assets/branding/global/header_logo.png',
            ),
            (
              brand: AppBrands.india,
              flavor: 'india',
              locale: const Locale('en', 'US'),
              loginLogoAsset: 'assets/branding/india/login_logo.png',
              loginLogoSize: const Size(217, 128),
              headerLogoAsset: 'assets/branding/india/header_logo.png',
            ),
            (
              brand: AppBrands.spain,
              flavor: 'spain',
              locale: const Locale('es', 'ES'),
              loginLogoAsset: 'assets/branding/spain/login_logo.png',
              loginLogoSize: const Size(258, 52),
              headerLogoAsset: 'assets/branding/spain/header_logo.png',
            ),
            (
              brand: AppBrands.turkey,
              flavor: 'turkey',
              locale: const Locale('tr', 'TR'),
              loginLogoAsset: 'assets/branding/turkey/login_logo.png',
              loginLogoSize: const Size(145, 145),
              headerLogoAsset: 'assets/branding/turkey/header_logo.png',
            ),
            (
              brand: AppBrands.america,
              flavor: 'america',
              locale: const Locale('en', 'US'),
              loginLogoAsset: 'assets/branding/america/login_logo.jpg',
              loginLogoSize: const Size(145, 145),
              headerLogoAsset: 'assets/branding/america/header_logo.jpg',
            ),
          ];

      for (final expectation in expectations) {
        expect(expectation.brand.flavor, expectation.flavor);
        expect(expectation.brand.defaultLocale, expectation.locale);
        expect(expectation.brand.loginLogoAsset, expectation.loginLogoAsset);
        expect(expectation.brand.loginLogoSize, expectation.loginLogoSize);
        expect(expectation.brand.headerLogoAsset, expectation.headerLogoAsset);
      }
    });

    test('preserves each original country header layout', () {
      final expectations =
          <
            ({
              AppBrandConfig brand,
              Size logoSize,
              HeaderLogoPosition logoPosition,
              double indexLogoSlotWidth,
              double indexPageRightInset,
              double settingPageRightInset,
              double usersPageRightInset,
              double indexClockGap,
              double settingClockGap,
              double usersClockGap,
              double usersActionGap,
            })
          >[
            (
              brand: AppBrands.global,
              logoSize: const Size(242, 44),
              logoPosition: HeaderLogoPosition.leading,
              indexLogoSlotWidth: 242,
              indexPageRightInset: 44,
              settingPageRightInset: 44,
              usersPageRightInset: 44,
              indexClockGap: 80,
              settingClockGap: 80,
              usersClockGap: 80,
              usersActionGap: 12,
            ),
            (
              brand: AppBrands.india,
              logoSize: const Size(187, 33),
              logoPosition: HeaderLogoPosition.trailing,
              indexLogoSlotWidth: 242,
              indexPageRightInset: -11,
              settingPageRightInset: 44,
              usersPageRightInset: 44,
              indexClockGap: 109,
              settingClockGap: 217,
              usersClockGap: 53,
              usersActionGap: 8,
            ),
            (
              brand: AppBrands.spain,
              logoSize: const Size(143, 29),
              logoPosition: HeaderLogoPosition.leading,
              indexLogoSlotWidth: 242,
              indexPageRightInset: 44,
              settingPageRightInset: 44,
              usersPageRightInset: 44,
              indexClockGap: 80,
              settingClockGap: 179,
              usersClockGap: 179,
              usersActionGap: 12,
            ),
            (
              brand: AppBrands.turkey,
              logoSize: const Size(242, 44),
              logoPosition: HeaderLogoPosition.leading,
              indexLogoSlotWidth: 242,
              indexPageRightInset: 44,
              settingPageRightInset: 44,
              usersPageRightInset: 44,
              indexClockGap: 80,
              settingClockGap: 80,
              usersClockGap: 80,
              usersActionGap: 12,
            ),
            (
              brand: AppBrands.america,
              logoSize: const Size(242, 44),
              logoPosition: HeaderLogoPosition.leading,
              indexLogoSlotWidth: 242,
              indexPageRightInset: 44,
              settingPageRightInset: 44,
              usersPageRightInset: 44,
              indexClockGap: 80,
              settingClockGap: 80,
              usersClockGap: 80,
              usersActionGap: 12,
            ),
          ];

      for (final expectation in expectations) {
        final header = expectation.brand.headerLayout;

        expect(header.logoSize, expectation.logoSize);
        expect(header.logoPosition, expectation.logoPosition);
        expect(header.indexLogoSlotWidth, expectation.indexLogoSlotWidth);
        expect(header.indexPageRightInset, expectation.indexPageRightInset);
        expect(header.settingPageRightInset, expectation.settingPageRightInset);
        expect(header.usersPageRightInset, expectation.usersPageRightInset);
        expect(header.indexClockGap, expectation.indexClockGap);
        expect(header.settingClockGap, expectation.settingClockGap);
        expect(header.usersClockGap, expectation.usersClockGap);
        expect(header.usersActionGap, expectation.usersActionGap);
      }
    });

    test('resolves every supported flavor', () {
      expect(AppBrands.fromFlavor('global'), same(AppBrands.global));
      expect(AppBrands.fromFlavor('india'), same(AppBrands.india));
      expect(AppBrands.fromFlavor('spain'), same(AppBrands.spain));
      expect(AppBrands.fromFlavor('turkey'), same(AppBrands.turkey));
      expect(AppBrands.fromFlavor('america'), same(AppBrands.america));
      expect(AppBrands.fromFlavor('australia'), same(AppBrands.australia));
    });

    test('rejects an unknown flavor', () {
      expect(
        () => AppBrands.fromFlavor('unknown'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('provides existing login and header logo assets', () {
      for (final brand in supportedBrands) {
        expect(File(brand.loginLogoAsset).existsSync(), isTrue);
        expect(File(brand.headerLogoAsset).existsSync(), isTrue);
      }
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

    test('updates shared logo asset paths for every configuration', () {
      for (final brand in const <AppBrandConfig>[
        AppBrands.global,
        AppBrands.india,
        AppBrands.spain,
        AppBrands.turkey,
        AppBrands.america,
        AppBrands.australia,
      ]) {
        AppBrand.configure(brand);

        expect(Assets.logo, brand.loginLogoAsset);
        expect(Assets.mainLogo, brand.headerLogoAsset);
      }
    });
  });
}
