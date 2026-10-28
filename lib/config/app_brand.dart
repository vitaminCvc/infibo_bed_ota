//app 配置

import 'package:flutter/widgets.dart';

enum HeaderLogoPosition { leading, trailing }

@immutable
class HeaderLayoutConfig {
  const HeaderLayoutConfig({
    required this.logoSize,
    required this.logoPosition,
    required this.indexLogoSlotWidth,
    required this.indexPageRightInset,
    required this.settingPageRightInset,
    required this.usersPageRightInset,
    required this.indexClockGap,
    required this.settingClockGap,
    required this.usersClockGap,
    required this.usersActionGap,
  });

  final Size logoSize;
  final HeaderLogoPosition logoPosition;
  final double indexLogoSlotWidth;
  final double indexPageRightInset;
  final double settingPageRightInset;
  final double usersPageRightInset;
  final double indexClockGap;
  final double settingClockGap;
  final double usersClockGap;
  final double usersActionGap;
}

@immutable
class AppBrandConfig {
  const AppBrandConfig({
    required this.flavor,
    required this.defaultLocale,
    required this.loginLogoAsset,
    required this.loginLogoSize,
    required this.headerLogoAsset,
    required this.headerLayout,
  });

  final String flavor;

  bool get supportsOtaUpdates => flavor == 'global' || flavor == 'uaeBiohackn';

  /// 自动加水开关仅对印度版生效，避免改变其他国家已交付版本的行为。
  /// 印度默认支持自动加水；仅“印度老版（无自动加水）”打包时传入
  /// --dart-define=INDIA_AUTO_WATER_FILLING=false，适配旧硬件。
  bool get supportsAutoWaterFilling =>
      flavor != 'india' ||
      const bool.fromEnvironment(
        'INDIA_AUTO_WATER_FILLING',
        defaultValue: true,
      );
  final Locale defaultLocale;
  final String loginLogoAsset;
  final Size loginLogoSize;
  final String headerLogoAsset;
  final HeaderLayoutConfig headerLayout;
}

abstract final class AppBrands {
  static const AppBrandConfig global = AppBrandConfig(
    flavor: 'global',
    defaultLocale: Locale('en', 'US'),
    loginLogoAsset: 'assets/branding/global/login_logo.png',
    loginLogoSize: Size(306, 166),
    headerLogoAsset: 'assets/branding/global/header_logo.png',
    headerLayout: HeaderLayoutConfig(
      logoSize: Size(242, 44),
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
  );

  static const AppBrandConfig india = AppBrandConfig(
    flavor: 'india',
    defaultLocale: Locale('en', 'US'),
    loginLogoAsset: 'assets/branding/india/login_logo.png',
    loginLogoSize: Size(217, 128),
    headerLogoAsset: 'assets/branding/india/header_logo.png',
    headerLayout: HeaderLayoutConfig(
      logoSize: Size(187, 33),
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
  );

  static const AppBrandConfig spain = AppBrandConfig(
    flavor: 'spain',
    defaultLocale: Locale('es', 'ES'),
    loginLogoAsset: 'assets/branding/spain/login_logo.png',
    loginLogoSize: Size(258, 52),
    headerLogoAsset: 'assets/branding/spain/header_logo.png',
    headerLayout: HeaderLayoutConfig(
      logoSize: Size(143, 29),
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
  );

  static const AppBrandConfig turkey = AppBrandConfig(
    flavor: 'turkey',
    defaultLocale: Locale('tr', 'TR'),
    loginLogoAsset: 'assets/branding/turkey/login_logo.png',
    loginLogoSize: Size(145, 145),
    headerLogoAsset: 'assets/branding/turkey/header_logo.png',
    headerLayout: HeaderLayoutConfig(
      logoSize: Size(242, 44),
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
  );

  static const AppBrandConfig america = AppBrandConfig(
    flavor: 'america',
    defaultLocale: Locale('en', 'US'),
    loginLogoAsset: 'assets/branding/america/login_logo.jpg',
    loginLogoSize: Size(423, 159),
    headerLogoAsset: 'assets/branding/america/header_logo.jpg',
    headerLayout: HeaderLayoutConfig(
      logoSize: Size(242, 44),
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
  );

  static const AppBrandConfig britain = AppBrandConfig(
    flavor: 'britain',
    defaultLocale: Locale('en', 'US'),
    loginLogoAsset: 'assets/branding/britain/login_logo.png',
    loginLogoSize: Size(423, 159),
    headerLogoAsset: 'assets/branding/britain/header_logo.png',
    headerLayout: HeaderLayoutConfig(
      logoSize: Size(242, 44),
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
  );

  static const AppBrandConfig australia = AppBrandConfig(
    flavor: 'australia',
    defaultLocale: Locale('en', 'US'),
    loginLogoAsset: 'assets/branding/australia/login_logo.png',
    loginLogoSize: Size(258, 110),
    headerLogoAsset: 'assets/branding/australia/header_logo.png',
    headerLayout: HeaderLayoutConfig(
      logoSize: Size(125, 53),
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
  );
  // 阿联酋Biohackn品牌
  static const AppBrandConfig uaeBiohackn = AppBrandConfig(
    flavor: 'uaeBiohackn',
    defaultLocale: Locale('en', 'US'),
    loginLogoAsset: 'assets/branding/uaeBiohackn/login_logo.svg',
    loginLogoSize: Size(380, 123),
    headerLogoAsset: 'assets/branding/uaeBiohackn/header_logo.svg',
    headerLayout: HeaderLayoutConfig(
      logoSize: Size(204, 56),
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
  );

  static AppBrandConfig fromFlavor(String flavor) => switch (flavor) {
    'global' => global,
    'india' => india,
    'spain' => spain,
    'turkey' => turkey,
    'america' => america,
    'britain' => britain,
    'australia' => australia,
    'uaeBiohackn' => uaeBiohackn,
    _ => throw ArgumentError.value(flavor, 'flavor', 'Unsupported app flavor'),
  };
}

abstract final class AppBrand {
  static AppBrandConfig _current = AppBrands.global;

  static AppBrandConfig get current => _current;

  static void configure(AppBrandConfig config) {
    _current = config;
  }
}
