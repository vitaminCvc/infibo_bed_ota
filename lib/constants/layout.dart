import 'dart:ui' show Size;

enum LayoutProfile { ratio16x10, ratio16x9 }

final class AppLayoutMetrics {
  const AppLayoutMetrics._({
    required this.profile,
    required this.designHeight,
    required this.contentTopOffset,
  });

  final LayoutProfile profile;
  final double designHeight;
  final double contentTopOffset;

  Size get designSize => Size(AppLayout.designWidth, designHeight);
  bool get is16x9 => profile == LayoutProfile.ratio16x9;
  double get pageTopOffset => is16x9 ? 30 : 0;
  double get addedHeight => designHeight - AppLayout.legacyViewportHeight;

  double get standardContentHeight =>
      AppLayout.legacyStandardContentHeight + addedHeight;
  double get expandedContentHeight =>
      AppLayout.legacyExpandedContentHeight + addedHeight;
  double get mainContentHeight =>
      AppLayout.legacyMainContentHeight + addedHeight;

  double spreadY(double legacyY, double legacyHeight, double targetHeight) =>
      legacyY * targetHeight / legacyHeight;

  double standardY(double legacyY) => is16x9
      ? spreadY(
          legacyY,
          AppLayout.legacyStandardContentHeight,
          standardContentHeight,
        )
      : legacyY;

  double expandedY(double legacyY) => is16x9
      ? spreadY(
          legacyY,
          AppLayout.legacyExpandedContentHeight,
          expandedContentHeight,
        )
      : legacyY;

  double mainY(double legacyY) => is16x9
      ? spreadY(legacyY, AppLayout.legacyMainContentHeight, mainContentHeight)
      : legacyY;

  double viewportY(double legacyY) => is16x9
      ? spreadY(legacyY, AppLayout.legacyViewportHeight, designHeight)
      : legacyY;

  double standardContentY(double legacyY) =>
      is16x9 ? standardY(legacyY) + contentTopOffset : legacyY;

  double expandedContentY(double legacyY) =>
      is16x9 ? expandedY(legacyY) + contentTopOffset : legacyY;

  double mainContentY(double legacyY) =>
      is16x9 ? mainY(legacyY) + contentTopOffset : legacyY;

  double viewportContentY(double legacyY) =>
      is16x9 ? viewportY(legacyY) + contentTopOffset : legacyY;
}

class AppLayout {
  const AppLayout._();

  static const double designWidth = 800;
  static const double legacyViewportHeight = 1280;
  static const double ratio16x9Threshold = 1.69;

  static const AppLayoutMetrics ratio16x10 = AppLayoutMetrics._(
    profile: LayoutProfile.ratio16x10,
    designHeight: legacyViewportHeight,
    contentTopOffset: 0,
  );
  static const AppLayoutMetrics ratio16x9 = AppLayoutMetrics._(
    profile: LayoutProfile.ratio16x9,
    designHeight: designWidth * 16 / 9,
    contentTopOffset: 40,
  );

  static AppLayoutMetrics forHostSize(Size size) {
    if (!size.width.isFinite ||
        !size.height.isFinite ||
        size.width <= 0 ||
        size.height <= 0) {
      return ratio16x10;
    }

    final longSide = size.width >= size.height ? size.width : size.height;
    final shortSide = size.width < size.height ? size.width : size.height;
    return longSide / shortSide >= ratio16x9Threshold ? ratio16x9 : ratio16x10;
  }

  @Deprecated('Use profile metrics designHeight during profile migration.')
  static double get designHeight => ratio16x10.designHeight;
  @Deprecated('Use profile metrics addedHeight during profile migration.')
  static double get addedHeight => ratio16x10.addedHeight;
  static const double headerTop = 25;
  static const double horizontalPageInset = 44;
  @Deprecated('Use profile metrics contentTopOffset during profile migration.')
  static double get contentTopOffset => ratio16x10.contentTopOffset;
  static const double authBrandLogoTop = 280;
  static const double authBrandLogoWidth = 420;
  static const double authBrandLogoHeight = 159;

  static const double legacyStandardContentHeight = 1160;
  @Deprecated(
    'Use profile metrics standardContentHeight during profile migration.',
  )
  static double get standardContentHeight => ratio16x10.standardContentHeight;

  static const double legacyExpandedContentHeight = 1088;
  @Deprecated(
    'Use profile metrics expandedContentHeight during profile migration.',
  )
  static double get expandedContentHeight => ratio16x10.expandedContentHeight;

  static const double legacyMainContentHeight = 1230;
  @Deprecated('Use profile metrics mainContentHeight during profile migration.')
  static double get mainContentHeight => ratio16x10.mainContentHeight;

  @Deprecated('Use AppLayoutMetrics.spreadY during profile migration.')
  static double spreadY(
    double legacyY,
    double legacyHeight,
    double targetHeight,
  ) => ratio16x10.spreadY(legacyY, legacyHeight, targetHeight);

  @Deprecated('Use profile metrics standardY during profile migration.')
  static double standardY(double legacyY) => ratio16x10.standardY(legacyY);

  @Deprecated('Use profile metrics expandedY during profile migration.')
  static double expandedY(double legacyY) => ratio16x10.expandedY(legacyY);

  @Deprecated('Use profile metrics mainY during profile migration.')
  static double mainY(double legacyY) => ratio16x10.mainY(legacyY);

  @Deprecated('Use profile metrics viewportY during profile migration.')
  static double viewportY(double legacyY) => ratio16x10.viewportY(legacyY);

  @Deprecated('Use profile metrics standardContentY during profile migration.')
  static double standardContentY(double legacyY) =>
      ratio16x10.standardContentY(legacyY);

  @Deprecated('Use profile metrics expandedContentY during profile migration.')
  static double expandedContentY(double legacyY) =>
      ratio16x10.expandedContentY(legacyY);

  @Deprecated('Use profile metrics mainContentY during profile migration.')
  static double mainContentY(double legacyY) =>
      ratio16x10.mainContentY(legacyY);

  @Deprecated('Use profile metrics viewportContentY during profile migration.')
  static double viewportContentY(double legacyY) =>
      ratio16x10.viewportContentY(legacyY);
}
