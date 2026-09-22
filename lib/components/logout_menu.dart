//退出登录悬浮层组件（ui界面）
//
//只负责进行展示和点击事件，不负责业务逻辑

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/constants/assets.dart';

class LogoutMenu extends StatefulWidget {
  const LogoutMenu({
    super.key,
    required this.child,
    required this.onLogout,
    required this.enabled,
  });

  final Widget child;
  final Future<void> Function() onLogout;
  final bool enabled;
  //退出登录悬浮层组件（ui界面）
  //用CompositedTransformTarget 和 CompositedTransformFollower。它会自动把弹窗定位在用户按钮正下方
  @override
  State<LogoutMenu> createState() => _LogoutMenuState();
}

class _LogoutMenuState extends State<LogoutMenu> {
  // 是否正在显示退出登录菜单
  final LayerLink _layerLink = LayerLink();
  // 退出登录菜单的OverlayEntry
  OverlayEntry? _entry;
  @override
  void dispose() {
    _hideMenu();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LogoutMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled && !widget.enabled) {
      _hideMenu();
    }
  }

  @override
  // 构建退出登录菜单组件
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return AbsorbPointer(child: widget.child);
    }

    // 点击退出登录菜单时，切换显示状态
    return CompositedTransformTarget(
      // 退出登录菜单的OverlayEntry
      link: _layerLink,
      // 退出登录菜单的OverlayEntry
      child: GestureDetector(
        // 点击退出登录菜单时，切换显示状态
        behavior: HitTestBehavior.opaque,
        onTap: _toggleMenu,
        child: widget.child,
      ),
    );
  }

  // 切换退出登录菜单显示状态
  void _toggleMenu() {
    if (_entry == null) {
      _showMenu();
    } else {
      _hideMenu();
    }
  }

  // 显示退出登录菜单
  void _showMenu() {
    _entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _hideMenu,
              child: ColoredBox(color: Colors.black.withValues(alpha: 0.6)),
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomCenter,
            followerAnchor: Alignment.topCenter,
            //控制弹窗位置
            offset: const Offset(3, 0),
            child: GestureDetector(
              onTap: () async {
                _hideMenu();
                await widget.onLogout();
              },
              child: SizedBox(
                width: 135,
                height: 80,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(Assets.logoOutBackg, fit: BoxFit.fill),
                    ),
                    Positioned(
                      left: 20,
                      right: 0,
                      top: 2,
                      bottom: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.translate(
                            offset: const Offset(0, 1),
                            child: Icon(
                              Icons.logout,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 78,
                            height: 20,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'logout'.tr,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.clip,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_entry!);
  }

  // 隐藏退出登录菜单
  void _hideMenu() {
    _entry?.remove();
    _entry = null;
  }
}
