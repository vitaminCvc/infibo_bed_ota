// 水位状态机弹窗。
//
// 一个弹窗承载 3 个状态，由外部 ValueNotifier<int> 驱动：
//   1 = 缺水提醒（闪烁动画 + 原图标）
//   2 = 注水中（静态）
//   3 = 注水完成（静态）
//
// 弹窗打开后，状态变化只切文案，不重新弹出、不关闭重开，避免闪动。
// 状态 2/3 的图标位预留给后续添加图片；当前版本只展示文字。
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/glass_card.dart';
import 'package:infibo_app/constants/assets.dart';

class WaterLevelStateDialog extends StatefulWidget {
  const WaterLevelStateDialog({super.key, required this.notifier});

  /// 水位状态：1=缺水, 2=注水中, 3=注水完成。
  final ValueNotifier<int> notifier;

  @override
  State<WaterLevelStateDialog> createState() => _WaterLevelStateDialogState();
}

class _WaterLevelStateDialogState extends State<WaterLevelStateDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  @override
  void initState() {
    super.initState();
    widget.notifier.addListener(_onStateChanged);
    // 初始状态为 1（缺水），启动闪烁动画。
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    final int state = widget.notifier.value;
    if (state == 1) {
      // 缺水状态：开启动画闪烁。
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
      // 非缺水状态：停止闪烁，重置到不透明。
      _controller.stop();
      _controller.reset();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final int state = widget.notifier.value;

    return FadeTransition(
      // 只在缺水状态 (1) 下闪烁，其他状态不透明。
      opacity: state == 1 ? _fade : const AlwaysStoppedAnimation(1.0),
      child: buildGlassCard(
        width: 322,
        height: 224,
        radius: 20,
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 30),
        gradientColors: [
          const Color(0xFF313844).withValues(alpha: 0.88),
          const Color(0xFF232936).withValues(alpha: 0.82),
          const Color(0xFF171C27).withValues(alpha: 0.78),
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
                fontWeight: FontWeight.w700,
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
                color: Color(0xFFB9BBC4),
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
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
