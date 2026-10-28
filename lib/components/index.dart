// 公共页头组件。
//
// 提供常规页面使用的顶部 Header 和基础页面容器；共享时钟状态由 stores 统一维护。
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

class AppHeaderPage extends StatelessWidget {
  const AppHeaderPage({
    super.key,
    this.children = const [],
    this.onSettingTap,
    this.onUserTap,
    this.enableLogout = false,
    this.enableLogoBack = true,
    this.resizeToAvoidBottomInset = true,
  });

  final List<Widget> children;
  final VoidCallback? onSettingTap;
  final VoidCallback? onUserTap;
  final bool enableLogout;
  final bool enableLogoBack;
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
                  right: AppBrand.current.headerLayout.indexPageRightInset,
                  child: AppTopHeader(
                    clockCenterOffset:
                        (AppBrand.current.headerLayout.indexPageRightInset -
                            48) /
                        2,
                    onLogoTap: enableLogoBack
                        ? AppComponentLogic.backToMainPage
                        : null,
                    onSettingTap: onSettingTap,
                    onUserTap: onUserTap,
                    enableLogout: enableLogout,
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

class AppTopHeader extends StatelessWidget {
  const AppTopHeader({
    super.key,
    this.onLogoTap,
    this.onSettingTap,
    this.onUserTap,
    this.enableLogout = false,
    this.clockCenterOffset = 0,
  });

  final VoidCallback? onLogoTap;
  final VoidCallback? onSettingTap;
  final VoidCallback? onUserTap;
  final bool enableLogout;

  final double clockCenterOffset;

  @override
  Widget build(BuildContext context) {
    final AppHeaderClockController clock = AppHeaderClockController.instance
      ..startClock();
    final HeaderLayoutConfig layout = AppBrand.current.headerLayout;
    final Widget clockBlock = Obx(
      () => _buildTimeBlock(clock.timeText, clock.dateText),
    );
    final Widget userButton = HeaderUserButton(enableLogout: enableLogout);
    final Widget settingButton = HeaderSettingsButton(onTap: onSettingTap);

    final bool logoTrailing =
        layout.logoPosition == HeaderLogoPosition.trailing;
    return LayoutBuilder(
      builder: (context, constraints) => AnchoredHeaderLayout(
        height: _logoSlotHeight(layout),
        logo: _buildLogo(layout),
        clock: clockBlock,
        clockLeft: constraints.maxWidth / 2 - 38 + clockCenterOffset,
        logoTrailing: logoTrailing,
        actions: Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.ltr,
          children: [userButton, const SizedBox(width: 8), settingButton],
        ),
      ),
    );
  }

  double _logoSlotHeight(HeaderLayoutConfig layout) =>
      layout.logoSize.height > 48 ? layout.logoSize.height : 48;

  Widget _buildLogo(HeaderLayoutConfig layout) {
    final Widget logo = BrandLogo(
      Assets.mainLogo,
      width: layout.logoSize.width,
      height: layout.logoSize.height,
      fit: BoxFit.contain,
    );

    // Keep the same header height as settings for aligned clocks.
    final Widget logoBox = SizedBox(
      width: layout.indexLogoSlotWidth,
      height: _logoSlotHeight(layout),
      child: Align(alignment: Alignment.centerLeft, child: logo),
    );

    if (onLogoTap == null) {
      return logoBox;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onLogoTap,
      child: logoBox,
    );
  }

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
}
