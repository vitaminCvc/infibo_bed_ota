// 公共组件集合。
//
// 这里放多个页面都会用到的顶部 Header、返回主页按钮、阴影文字等通用 UI 组件。

import 'package:flutter/material.dart';
import 'package:infibo_app/components/brand_logo.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/designCanvas/design.dart';
import 'package:infibo_app/components/logic.dart';
import 'package:infibo_app/components/header_controls.dart';
import 'package:infibo_app/config/app_brand.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/constants/color.dart';
import 'package:infibo_app/stores/app_header_clock_store.dart';

// 带公共页头的基础页面。
class AppSettingHeaderPage extends StatelessWidget {
  const AppSettingHeaderPage({
    super.key,
    this.children = const [],
    this.onUserTap, //用户区域
    this.enableLogoBack = false,
    this.resizeToAvoidBottomInset = true,
  });

  // 页面主体内容，通常传入 Positioned 组件。
  final List<Widget> children;

  // 点击顶部用户区域。
  final VoidCallback? onUserTap;

  // 是否允许点击logo返回主页，主页本身不需要返回自己。
  final bool enableLogoBack;

  // 键盘弹出时是否压缩页面高度。
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final double pageTopOffset = AppLayoutScope.of(context).pageTopOffset;

    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Transform.translate(
            offset: Offset(0, pageTopOffset),
            child: Stack(
              children: [
                ...children,
                Positioned(
                  left: 48,
                  top: 25,
                  right: AppBrand.current.headerLayout.settingPageRightInset,
                  child: AppTopHeader(
                    clockCenterOffset:
                        (AppBrand.current.headerLayout.settingPageRightInset -
                            48) /
                        2,
                    onLogoTap: enableLogoBack
                        ? AppComponentLogic.backToMainPage
                        : null,
                    onUserTap: onUserTap,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 页面顶部公共表头
class AppTopHeader extends StatelessWidget {
  const AppTopHeader({
    super.key,
    this.onLogoTap,
    this.onUserTap,
    this.clockCenterOffset = 0,
  });

  // Compensate for asymmetric page insets so the clock centers on the page.
  final double clockCenterOffset;

  // 点击品牌logo。
  final VoidCallback? onLogoTap;

  // 点击用户区域
  final VoidCallback? onUserTap;

  @override
  Widget build(BuildContext context) {
    final AppHeaderClockController clock = AppHeaderClockController.instance
      ..startClock();
    final HeaderLayoutConfig layout = AppBrand.current.headerLayout;
    const Widget userButton = HeaderUserButton();
    final Widget clockBlock = Obx(
      () => _buildTimeBlock(clock.timeText, clock.dateText),
    );

    final bool logoTrailing =
        layout.logoPosition == HeaderLogoPosition.trailing;
    return LayoutBuilder(
      builder: (context, constraints) => AnchoredHeaderLayout(
        height: layout.logoSize.height > 48 ? layout.logoSize.height : 48,
        logo: _buildLogo(layout),
        clock: clockBlock,
        clockLeft: constraints.maxWidth / 2 - 38 + clockCenterOffset,
        logoTrailing: logoTrailing,
        actions: Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.ltr,
          children: [userButton, if (!logoTrailing) const SizedBox(width: 12)],
        ),
      ),
    );
  }

  // 构建品牌logo
  Widget _buildLogo(HeaderLayoutConfig layout) {
    final Widget logo = BrandLogo(
      Assets.mainLogo,
      width: layout.logoSize.width,
      height: layout.logoSize.height,
      fit: BoxFit.contain,
    );

    if (onLogoTap == null) {
      return logo;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onLogoTap,
      child: _withMinTapTarget(logo),
    );
  }

  // 构建时间日期
  Widget _buildTimeBlock(String timeText, String dateText) {
    return SizedBox(
      width: 76,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            timeText,
            textAlign: TextAlign.center,
            maxLines: 1,
            softWrap: false,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              height: 1,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dateText,
            textAlign: TextAlign.center,
            maxLines: 1,
            softWrap: false,
            style: const TextStyle(
              color: Color(0xFF90939D),
              fontSize: 13,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _withMinTapTarget(Widget child) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      child: Center(widthFactor: 1, heightFactor: 1, child: child),
    );
  }
}
