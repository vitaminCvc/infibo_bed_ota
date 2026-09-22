// 公共页头组件。
//
// 提供常规页面使用的顶部 Header 和基础页面容器；共享时钟状态由 stores 统一维护。
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/designCanvas/design.dart';
import 'package:infibo_app/components/logic.dart';
import 'package:infibo_app/components/logout_menu.dart';
import 'package:infibo_app/config/app_brand.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/constants/color.dart';
import 'package:infibo_app/stores/index.dart';

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
  });

  final VoidCallback? onLogoTap;
  final VoidCallback? onSettingTap;
  final VoidCallback? onUserTap;
  final bool enableLogout;

  @override
  Widget build(BuildContext context) {
    final AppHeaderClockController clock = AppHeaderClockController.instance
      ..startClock();
    final HeaderLayoutConfig layout = AppBrand.current.headerLayout;
    final Widget clockBlock = Obx(
      () => _buildTimeBlock(clock.timeText, clock.dateText),
    );
    final Widget userButton = _buildUserButton();
    final Widget settingButton = _buildSettingButton();

    if (layout.logoPosition == HeaderLogoPosition.trailing) {
      return Row(
        children: [
          userButton,
          const SizedBox(width: 8),
          settingButton,
          SizedBox(width: layout.indexClockGap),
          clockBlock,
          const Spacer(),
          _buildLogo(layout),
        ],
      );
    }

    return Row(
      children: [
        _buildLogo(layout),
        SizedBox(width: layout.indexClockGap),
        clockBlock,
        const Spacer(),
        //创建用户信息按钮
        userButton,
        const SizedBox(width: 8),
        settingButton,
      ],
    );
  }

  Widget _buildSettingButton() {
    return _buildImageButton(
      asset: Assets.settingLogo,
      width: 100,
      height: 48,
      onTap: AppComponentLogic.openSettingPage,
      child: Positioned(
        left: 18,
        top: 10,
        child: SizedBox(
          height: 28,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.settings_outlined, color: Colors.white, size: 18),
              const SizedBox(width: 4),
              Text(
                'settings'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserButton() {
    return Obx(() {
      final UserStore userStore = UserStore.instance;

      return LogoutMenu(
        onLogout: AppComponentLogic.logout,
        enabled: enableLogout,
        child: _buildImageButton(
          asset: Assets.adminMainLogo,
          width: 108,
          height: 48,
          child: SizedBox(
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
        ),
      );
    });
  }

  //创建角色头像组件
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

  //创建用户信息按钮
  Widget _buildLogo(HeaderLayoutConfig layout) {
    final Widget logo = Image.asset(
      Assets.mainLogo,
      width: layout.logoSize.width,
      height: layout.logoSize.height,
      fit: BoxFit.contain,
    );

    // 固定 Header 中 Logo 占用的高度，避免是否可点击导致上下位置变化
    final Widget logoBox = SizedBox(
      width: layout.indexLogoSlotWidth,
      height: 48,
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
    if (onTap == null) return button;
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
