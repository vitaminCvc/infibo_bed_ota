// 公共组件集合。
//
// 这里放多个页面都会用到的顶部 Header、返回主页按钮、阴影文字等通用 UI 组件。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/designCanvas/design.dart';
import 'package:infibo_app/components/logic.dart';
import 'package:infibo_app/components/logout_menu.dart';
import 'package:infibo_app/config/app_brand.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/constants/color.dart';
import 'package:infibo_app/stores/app_header_clock_store.dart';
import 'package:infibo_app/stores/user_store.dart';

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
  const AppTopHeader({super.key, this.onLogoTap, this.onUserTap});

  // 点击品牌logo。
  final VoidCallback? onLogoTap;

  // 点击用户区域
  final VoidCallback? onUserTap;

  @override
  Widget build(BuildContext context) {
    final AppHeaderClockController clock = AppHeaderClockController.instance
      ..startClock();
    final HeaderLayoutConfig layout = AppBrand.current.headerLayout;
    final Widget userButton = _buildUserButton();
    final Widget clockBlock = Obx(
      () => _buildTimeBlock(clock.timeText, clock.dateText),
    );

    if (layout.logoPosition == HeaderLogoPosition.trailing) {
      return Row(
        children: [
          userButton,
          SizedBox(width: layout.settingClockGap),
          clockBlock,
          const Spacer(),
          _buildLogo(layout),
        ],
      );
    }

    return Row(
      children: [
        _buildLogo(layout),
        SizedBox(width: layout.settingClockGap),
        clockBlock,
        const Spacer(),
        userButton,
        const SizedBox(width: 12),
      ],
    );
  }

  // 构建用户按钮
  Widget _buildUserButton() {
    return Obx(() {
      final UserStore userStore = UserStore.instance;

      return LogoutMenu(
        onLogout: AppComponentLogic.logout,
        enabled: false,
        child: _buildImageButton(
          asset: Assets.adminMainLogo,
          width: 108,
          height: 48,
          child: Stack(
            children: [
              Positioned(
                left: 8,
                top: 6,
                child: _buildRoleAvatar(userStore.avatarText),
              ),
              Positioned(
                left: 50,
                top: 13,
                right: 8,
                child: Text(
                  userStore.roleText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  //构建默认用户头像
  Widget _buildRoleAvatar(String text) {
    return Container(
      width: 35,
      height: 35,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromARGB(255, 41, 41, 41),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // 构建品牌logo
  Widget _buildLogo(HeaderLayoutConfig layout) {
    final Widget logo = Image.asset(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            timeText,
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

  // 构建图片按钮
  Widget _buildImageButton({
    required String asset,
    required double width,
    required double height,
    VoidCallback? onTap,
    Widget? child,
  }) {
    final button = SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(asset, width: width, height: height, fit: BoxFit.contain),
          ?child,
        ],
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: _withMinTapTarget(button),
    );
  }

  Widget _withMinTapTarget(Widget child) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      child: Center(child: child),
    );
  }
}
