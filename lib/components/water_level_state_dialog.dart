// 水位状态机弹窗。
//
// 一个弹窗承载 3 个状态，由外部 ValueNotifier<int> 驱动：
//   1 = 独立缺水提醒界面（GIF 动画）
//   2 = 注水中（静态）
//   3 = 注水完成（静态）
//
// 弹窗打开后，状态变化只切文案，不重新弹出、不关闭重开，避免闪动。
// 状态 2/3 的图标位预留给后续添加图片；当前版本只展示文字。
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/glass_card.dart';
import 'package:infibo_app/components/water_shortage_dialog.dart';
import 'package:infibo_app/constants/assets.dart';

class WaterLevelStateDialog extends StatefulWidget {
  const WaterLevelStateDialog({
    super.key,
    required this.notifier,
    this.onShortageAnimationCompleted,
  });

  /// 水位状态：1=缺水, 2=注水中, 3=注水完成。
  final ValueNotifier<int> notifier;
  final VoidCallback? onShortageAnimationCompleted;

  @override
  State<WaterLevelStateDialog> createState() => _WaterLevelStateDialogState();
}

class _WaterLevelStateDialogState extends State<WaterLevelStateDialog> {
  static const Duration _shortageAnimationDuration = Duration(seconds: 4);

  Timer? _shortageAnimationTimer;

  @override
  void initState() {
    super.initState();
    widget.notifier.addListener(_onStateChanged);
    if (widget.notifier.value == 1) {
      _startShortageAnimation();
    }
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_onStateChanged);
    _shortageAnimationTimer?.cancel();
    super.dispose();
  }

  void _startShortageAnimation() {
    _shortageAnimationTimer?.cancel();
    _shortageAnimationTimer = Timer(
      _shortageAnimationDuration,
      _finishShortageAnimation,
    );
  }

  void _finishShortageAnimation() {
    if (!mounted || widget.notifier.value != 1) return;
    widget.onShortageAnimationCompleted?.call();
  }

  void _onStateChanged() {
    final int state = widget.notifier.value;
    if (state == 1) {
      if (_shortageAnimationTimer?.isActive != true) {
        _startShortageAnimation();
      }
    } else {
      _shortageAnimationTimer?.cancel();
      _shortageAnimationTimer = null;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final int state = widget.notifier.value;

    if (state == 1) return const WaterShortageDialog();

    return buildGlassCard(
      width: 362,
      height: 224,
      radius: 20,
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 30),
      gradientColors: const [
        Color(0xFF303236),
        Color(0xFF414448),
        Color(0xFF292B2F),
      ],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── 图标  ────────────────────────────────────────────
          _buildIcon(state),
          const SizedBox(height: 14),
          // ── 标题  ────────────────────────────────────────────
          Text(
            _titleKey(state).tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          // ── 描述文案  ────────────────────────────────────────
          Text(
            _messageKey(state).tr,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFBDBDBD),
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ── 图标 ─────────────────────────────────────────────────────
  // 状态 1 保留原图标不动；状态 2/3 为占位图标，后续替换为图片。
  Widget _buildIcon(int state) {
    switch (state) {
      case 1:
        // 缺水：原图标 error_outline，不改动。
        return const Icon(
          Icons.error_outline,
          color: Color(0xFFFF9B2F),
          size: 34,
        );
      case 2:
        // 注水中：占位图标（后续替换为图片）。
        return Image(image: AssetImage(Assets.waterLogo));
      case 3:
        // 注水完成：占位图标（后续替换为图片）。
        return Image(image: AssetImage(Assets.ok));
      default:
        return const Icon(
          Icons.error_outline,
          color: Color(0xFFFF9B2F),
          size: 34,
        );
    }
  }

  String _titleKey(int state) {
    switch (state) {
      case 1:
        return 'water_level_shortage_title';
      case 2:
        return 'water_level_filling_title';
      case 3:
        return 'water_level_complete_title';
      default:
        return 'water_level_shortage_title';
    }
  }

  String _messageKey(int state) {
    switch (state) {
      case 1:
        return 'water_level_shortage_message';
      case 2:
        return 'water_level_filling_message';
      case 3:
        return 'water_level_complete_message';
      default:
        return 'water_level_shortage_message';
    }
  }
}
