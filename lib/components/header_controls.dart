import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/header_pill_background.dart';
import 'package:infibo_app/components/logic.dart';
import 'package:infibo_app/components/logout_menu.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/stores/user_store.dart';

/// Keep the clock independent of the width of the translated action buttons.
class AnchoredHeaderLayout extends StatelessWidget {
  const AnchoredHeaderLayout({
    super.key,
    required this.logo,
    required this.clock,
    required this.actions,
    required this.clockLeft,
    required this.logoTrailing,
    this.height = 48,
  });

  final Widget logo;
  final Widget clock;
  final Widget actions;
  final double clockLeft;
  final bool logoTrailing;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: height),
      child: Stack(
        alignment: Alignment.centerLeft,
        clipBehavior: Clip.none,
        children: [
          Row(
            textDirection: TextDirection.ltr,
            children: [
              SizedBox(width: clockLeft),
              clock,
            ],
          ),
          Positioned.fill(
            child: Align(
              alignment: logoTrailing
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: logo,
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: logoTrailing
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: actions,
            ),
          ),
        ],
      ),
    );
  }
}

class HeaderSettingsButton extends StatelessWidget {
  const HeaderSettingsButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap ?? AppComponentLogic.openSettingPage,
      child: _HeaderPill(
        variant: HeaderPillVariant.settings,
        minWidth: 100,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.ltr,
          children: [
            SvgPicture.asset(
              Assets.headerSettingsIcon,
              width: 15,
              height: 14,
              excludeFromSemantics: true,
            ),
            const SizedBox(width: 6),
            Text(
              'settings'.tr,
              softWrap: false,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HeaderUserButton extends StatelessWidget {
  const HeaderUserButton({super.key, this.enableLogout = false});

  final bool enableLogout;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = UserStore.instance;
      return LogoutMenu(
        enabled: enableLogout,
        onLogout: AppComponentLogic.logout,
        child: _HeaderPill(
          variant: HeaderPillVariant.user,
          minWidth: 108,
          padding: const EdgeInsets.fromLTRB(8, 6, 16, 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.ltr,
            children: [
              Container(
                width: 35,
                height: 35,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 41, 41, 41),
                ),
                child: Text(
                  user.avatarText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Text(
                user.roleText,
                softWrap: false,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({
    required this.variant,
    required this.minWidth,
    required this.padding,
    required this.child,
  });

  final HeaderPillVariant variant;
  final double minWidth;
  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth, minHeight: 48),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          // Figma's SVG foreignObject blur is implemented by Flutter instead.
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(child: HeaderPillBackground(variant: variant)),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    );
  }
}
