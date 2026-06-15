// 公共页头组件。
//
// 提供常规页面使用的顶部 Header 和基础页面容器；共享时钟状态由 stores 统一维护。
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/logic.dart';
import 'package:infibo_app/components/logout_menu.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/constants/color.dart';
import 'package:infibo_app/stores/index.dart';

class AppHeaderPage extends StatelessWidget {
  const AppHeaderPage({
    super.key,
    this.children = const [],
    this.onSettingTap,
    this.onUserTap,
    this.enableLogoBack = true,
    this.resizeToAvoidBottomInset = true,
  });

  final List<Widget> children;
  final VoidCallback? onSettingTap;
  final VoidCallback? onUserTap;
  final bool enableLogoBack;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              ...children,
              Positioned(
                left: 48,
                top: 25,
                right: 44,
                child: AppTopHeader(
                  onLogoTap: enableLogoBack
                      ? AppComponentLogic.backToMainPage
                      : null,
                  onSettingTap: onSettingTap,
                  onUserTap: onUserTap,
                ),
              ),
            ],
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
  });

  final VoidCallback? onLogoTap;
  final VoidCallback? onSettingTap;
  final VoidCallback? onUserTap;

  @override
  Widget build(BuildContext context) {
    final AppHeaderClockController clock = AppHeaderClockController.instance
      ..startClock();

    return Row(
      children: [
        _buildLogo(),
        const SizedBox(width: 80),
        Obx(() => _buildTimeBlock(clock.timeText, clock.dateText)),
        const Spacer(),
        //创建用户信息按钮
        _buildUserButton(),
        const SizedBox(width: 8),
        _buildImageButton(
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
        ),
      ],
    );
  }

  Widget _buildUserButton() {
    return Obx(() {
      final UserStore userStore = UserStore.instance;

      return LogoutMenu(
        onLogout: AppComponentLogic.logout,
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
  Widget _buildLogo() {
    final Widget logo = Image.asset(
      Assets.mainLogo,
      width: 242,
      height: 44,
      fit: BoxFit.contain,
    );
    if (onLogoTap == null) return logo;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onLogoTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 200, minHeight: 70),
        child: Align(alignment: Alignment.centerLeft, child: logo),
      ),
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
