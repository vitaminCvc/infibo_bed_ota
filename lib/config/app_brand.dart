import 'package:flutter/widgets.dart';

@immutable
class AppBrandConfig {
  const AppBrandConfig({
    required this.flavor,
    required this.defaultLocale,
    required this.loginLogoAsset,
    required this.headerLogoAsset,
  });

  final String flavor;
  final Locale defaultLocale;
  final String loginLogoAsset;
  final String headerLogoAsset;
}

abstract final class AppBrands {
  static const AppBrandConfig global = AppBrandConfig(
    flavor: 'global',
    defaultLocale: Locale('en', 'US'),
    loginLogoAsset: 'assets/branding/global/login_logo.png',
    headerLogoAsset: 'assets/branding/global/header_logo.png',
  );

  static const AppBrandConfig india = AppBrandConfig(
    flavor: 'india',
    defaultLocale: Locale('en', 'US'),
    loginLogoAsset: 'assets/branding/india/login_logo.png',
    headerLogoAsset: 'assets/branding/india/header_logo.png',
  );

  static const AppBrandConfig spain = AppBrandConfig(
    flavor: 'spain',
    defaultLocale: Locale('es', 'ES'),
    loginLogoAsset: 'assets/branding/spain/login_logo.png',
    headerLogoAsset: 'assets/branding/spain/header_logo.png',
  );

  static const AppBrandConfig turkey = AppBrandConfig(
    flavor: 'turkey',
    defaultLocale: Locale('tr', 'TR'),
    loginLogoAsset: 'assets/branding/turkey/login_logo.png',
    headerLogoAsset: 'assets/branding/turkey/header_logo.png',
  );

  static AppBrandConfig fromFlavor(String flavor) => switch (flavor) {
    'global' => global,
    'india' => india,
    'spain' => spain,
    'turkey' => turkey,
    _ => throw ArgumentError.value(flavor, 'flavor', 'Unsupported app flavor'),
  };
}

abstract final class AppBrand {
  static AppBrandConfig current = AppBrands.global;

  static void configure(AppBrandConfig config) {
    current = config;
  }
}
