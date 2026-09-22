import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/glass_card.dart';
import 'package:infibo_app/constants/assets.dart';

/// 独立的缺水提示界面；水位监听和关闭时机由调用方管理。
class WaterShortageDialog extends StatelessWidget {
  const WaterShortageDialog({super.key});

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
                'water_level_shortage_message'.tr,
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
            ],
          ),
        ),
      ),
    );
  }
}
