// 自定义拓展设置页的公共小组件和导航工具。
//
// 这里放返回按钮、确认按钮、扩大点击区域、统一返回方法等复用逻辑。
// HIFEM、脉轮、太赫兹、香氛这些设置页都会引用它，避免每页重复写一套。
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/constants/assets.dart';

class ExpandBackButton extends StatelessWidget {
  const ExpandBackButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _debugExpandLog('[ExpandBackButton] tapped');
        onTap();
      },
      child: Container(
        width: 110,
        height: 45,
        decoration: BoxDecoration(
          color: const Color(0xFF202127),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(Assets.chakraReturnIcon, width: 20, height: 20),
            const SizedBox(width: 10),
            Text(
              'back'.tr,
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AssetConfirmButton extends StatelessWidget {
  const AssetConfirmButton({
    super.key,
    required this.enabled,
    required this.enabledAsset,
    required this.disabledAsset,
    required this.width,
    required this.onTap,
  });

  final bool enabled;
  final String enabledAsset;
  final String disabledAsset;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            enabled ? enabledAsset : disabledAsset,
            width: width,
            height: 56,
            fit: BoxFit.fill,
          ),
          Text(
            'confirm'.tr,
            style: TextStyle(
              color: enabled ? Colors.white : const Color(0xFF9EA2AB),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ExpandBackHitLayer extends StatelessWidget {
  const ExpandBackHitLayer({
    super.key,
    required this.designWidth,
    required this.designHeight,
    required this.scale,
    required this.onTap,
    this.fillTop = 70,
    this.designLeft = 44,
    this.designTop = 5,
    this.designWidthButton = 110,
    this.designHeightButton = 45,
  });

  final double designWidth;
  final double designHeight;
  final double scale;
  final double fillTop;
  final double designLeft;
  final double designTop;
  final double designWidthButton;
  final double designHeightButton;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    final EdgeInsets safePadding = MediaQuery.paddingOf(context);
    final double bodyHeight =
        screenSize.height - safePadding.top - safePadding.bottom;
    final double availableHeight = bodyHeight - fillTop;
    final double canvasHeight = designHeight * scale;
    final double canvasTop =
        fillTop +
        (availableHeight > canvasHeight
            ? (availableHeight - canvasHeight) / 2
            : 0);
    final double canvasLeft = (screenSize.width - designWidth * scale) / 2;
    const double hitPadding = 24;

    return Positioned(
      left: canvasLeft + designLeft * scale - hitPadding,
      top: canvasTop + designTop * scale - hitPadding,
      width: designWidthButton * scale + hitPadding * 2,
      height: designHeightButton * scale + hitPadding * 2,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _debugExpandLog('[ExpandBackHitLayer] tapped');
          onTap();
        },
      ),
    );
  }
}

void popExpandPage(BuildContext context, [Object? result]) {
  FocusManager.instance.primaryFocus?.unfocus();
  _debugExpandLog(
    '[ExpandPage] pop requested, route=${Get.currentRoute}, result=${result.runtimeType}',
  );

  // 优先使用当前页面上下文持有的 Navigator。Android 系统返回键使用同一路由栈，确保自定义按钮行为一致。
  final NavigatorState? rootNavigator = Navigator.maybeOf(
    context,
    rootNavigator: true,
  );
  if (rootNavigator != null && rootNavigator.canPop()) {
    rootNavigator.pop<Object?>(result);
    return;
  }

  final NavigatorState? nearestNavigator = Navigator.maybeOf(context);
  if (nearestNavigator != null && nearestNavigator.canPop()) {
    nearestNavigator.pop<Object?>(result);
    return;
  }

  if (Get.key.currentState?.canPop() == true) {
    Get.back<Object?>(result: result);
  }
}

void _debugExpandLog(String message) {
  assert(() {
    debugPrint(message);
    return true;
  }());
}

class SnapshotSettingPage extends StatefulWidget {
  const SnapshotSettingPage({
    super.key,
    required this.defaultAsset,
    required this.selectedAsset,
    this.initialSelected = false,
  });

  final String defaultAsset;
  final String selectedAsset;
  final bool initialSelected;

  @override
  State<SnapshotSettingPage> createState() => _SnapshotSettingPageState();
}

class _SnapshotSettingPageState extends State<SnapshotSettingPage> {
  static const double _designWidth = 800;
  static const double _designHeight = 1280;

  late bool _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelected;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(AssetImage(widget.defaultAsset), context);
    precacheImage(AssetImage(widget.selectedAsset), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double scale = (constraints.maxWidth / _designWidth)
                .clamp(0.72, 1.0)
                .toDouble();

            return Center(
              child: SizedBox(
                width: _designWidth * scale,
                height: _designHeight * scale,
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: _designWidth,
                    height: _designHeight,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            _selected
                                ? widget.selectedAsset
                                : widget.defaultAsset,
                            fit: BoxFit.fill,
                          ),
                        ),
                        Positioned(
                          left: 42,
                          top: 135,
                          width: 125,
                          height: 58,
                          child: _TapArea(onTap: () => popExpandPage(context)),
                        ),
                        Positioned(
                          left: 45,
                          top: 430,
                          width: 710,
                          height: 520,
                          child: _TapArea(onTap: _activate),
                        ),
                        Positioned(
                          left: 45,
                          top: 1134,
                          width: 710,
                          height: 80,
                          child: _TapArea(
                            onTap: _selected
                                ? () => popExpandPage(context, true)
                                : _activate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _activate() {
    if (_selected) return;
    setState(() => _selected = true);
  }
}

class _TapArea extends StatelessWidget {
  const _TapArea({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap);
  }
}
