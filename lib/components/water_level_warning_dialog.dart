import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/glass_card.dart';

class WaterLevelWarningDialog extends StatefulWidget {
  const WaterLevelWarningDialog({super.key});

  @override
  State<WaterLevelWarningDialog> createState() =>
      _WaterLevelWarningDialogState();
}

class _WaterLevelWarningDialogState extends State<WaterLevelWarningDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat(reverse: true);

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
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
            const Icon(Icons.error_outline, color: Color(0xFFFF9B2F), size: 34),
            const SizedBox(height: 14),
            Text(
              'water_level_warning_title'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'water_level_warning_message'.tr,
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
}
