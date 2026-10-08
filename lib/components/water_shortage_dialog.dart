import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/glass_card.dart';
import 'package:infibo_app/constants/assets.dart';

/// 独立的缺水提示界面；水位监听和关闭时机由调用方管理。
///
/// 底部按钮与光疗缺水弹窗一致：第一次点击只确认水源（Ready? → Start Filling），
/// 第二次点击才通过 [onButtonTap] 触发自动加水；按钮文案随当前语言翻译。
class WaterShortageDialog extends StatelessWidget {
  const WaterShortageDialog({
    super.key,
    required this.readyToFill,
    required this.onButtonTap,
    this.supportsAutoWaterFilling = true,
  });

  /// false：按钮显示 “Ready?”，仅确认水源已准备；
  /// true：按钮显示 “Start Filling”，点击后开始自动加水。
  final bool readyToFill;

  /// 按钮点击回调；切换文案或开始加水由调用方根据 [readyToFill] 决定。
  final VoidCallback onButtonTap;

  /// 旧硬件只显示人工加水提醒，隐藏自动加水入口及其占用的间距。
  final bool supportsAutoWaterFilling;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: buildGlassCard(
          width: 380,
          height: null, // 随多语言文案高度展开，避免挤压 GIF 或文字溢出。
          radius: 20,
          padding: const EdgeInsets.fromLTRB(27, 37, 27, 37),
          gradientColors: const [
            Color(0xFF303236),
            Color(0xFF414448),
            Color(0xFF292B2F),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Color(0xFFFF8800),
                size: 30,
              ),
              const SizedBox(height: 18),
              Text(
                'water_level_shortage_title'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                (supportsAutoWaterFilling
                        ? 'water_level_shortage_message'
                        : 'water_level_warning_message')
                    .tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFD3D3D3),
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 165, // GIF 宽度
                height: 202, // GIF 高度
                child: Image.asset(
                  Assets.water,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                  excludeFromSemantics: true,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'water_level_shortage_unavailable'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFA2A2A2),
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
              if (supportsAutoWaterFilling) ...[
                const SizedBox(height: 24),
                _buildActionButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Ready? → Start Filling：尺寸随文字和内边距自适应。
  Widget _buildActionButton() {
    return FilledButton(
      key: const ValueKey<String>('water_level_filling_button'),
      onPressed: onButtonTap,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF1876F2),
        foregroundColor: Colors.white,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.standard,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: const StadiumBorder(),
      ),
      child: Text(
        readyToFill
            ? 'water_level_start_filling_button'.tr
            : 'water_level_ready_button'.tr,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 19,
          height: 1.5,
          leadingDistribution: TextLeadingDistribution.even,
          letterSpacing: 0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
