import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/glass_card.dart';
import 'package:infibo_app/constants/assets.dart';
import 'water_quality_controller.dart';
import 'water_quality_orbit_spinner.dart';

class WaterQualityDialog extends StatelessWidget {
  const WaterQualityDialog({super.key, required this.controller});
  final WaterQualityController controller;
  @override
  Widget build(BuildContext context) {
    final success = controller.phase == WaterQualityPhase.success;
    final failed = controller.phase == WaterQualityPhase.failed;
    final treating = controller.phase == WaterQualityPhase.treating;
    final transitionDuration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 220);
    final color = success
        ? const Color(0xFF00C853)
        : failed
        ? const Color(0xFFFF4B40)
        : const Color(0xFFFF8D2A);
    final title = success
        ? 'water_quality_success_title'
        : failed
        ? 'water_quality_failed_title'
        : 'water_quality_title';
    final message = switch (controller.phase) {
      WaterQualityPhase.treating => 'water_quality_treating_message',
      WaterQualityPhase.failed => 'water_quality_failed_message',
      WaterQualityPhase.success => 'water_quality_success_message',
      WaterQualityPhase.unavailable => 'water_quality_tds_unavailable',
      _ => 'water_quality_waiting_message',
    };
    return Material(
      color: Colors.transparent,
      child: AnimatedSize(
        duration: transitionDuration,
        curve: Curves.easeOutCubic,
        alignment: Alignment.center,
        child: Stack(
          children: [
            buildGlassCard(
              width: 322,
              height: null,
              radius: 20,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
              gradientColors: const [
                Color(0xFF303236),
                Color(0xFF414448),
                Color(0xFF292B2F),
              ],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: transitionDuration,
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: _WaterQualityStatusIcon(
                      key: ValueKey(controller.phase),
                      color: color,
                      success: success,
                      failed: failed,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      title.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      message.tr,
                      textAlign: TextAlign.center,
                      textWidthBasis: TextWidthBasis.parent,
                      style: const TextStyle(
                        color: Color(0xFFD3D3D3),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                  if (treating) ...[
                    const SizedBox(height: 18),
                    SizedBox(
                      width: 35,
                      height: 35,
                      child: WaterQualityOrbitSpinner(
                        key: const ValueKey('water_quality_orbit_spinner'),
                        color: color,
                      ),
                    ),
                  ],
                  if (controller.readError != null &&
                      controller.phase != WaterQualityPhase.unavailable) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        (controller.readError == WaterQualityReadError.tds
                                ? 'water_quality_tds_unavailable'
                                : 'water_quality_treatment_unavailable')
                            .tr,
                        textAlign: TextAlign.center,
                        textWidthBasis: TextWidthBasis.parent,
                        style: const TextStyle(
                          color: Color(0xFFFFB56B),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                  if (success || failed) ...[
                    const SizedBox(height: 24),
                    FilledButton(
                      key: const ValueKey('water_quality_confirm'),
                      onPressed: controller.dismiss,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1876F2),
                        foregroundColor: Colors.white,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        (success ? 'confirm' : 'water_quality_got_it').tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!success && !failed)
              Positioned(
                top: 6,
                right: 6,
                child: Semantics(
                  label: MaterialLocalizations.of(context).closeButtonTooltip,
                  child: IconButton(
                    key: const ValueKey('water_quality_close'),
                    onPressed: controller.dismiss,
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                      color: Color(0xFFBDBDBD),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 各状态的提示图标；等待动画独立显示在正文下方。
class _WaterQualityStatusIcon extends StatelessWidget {
  const _WaterQualityStatusIcon({
    super.key,
    required this.color,
    required this.success,
    required this.failed,
  });
  final Color color;
  final bool success;
  final bool failed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 30,
    height: 30,
    child: success
        ? Image.asset(Assets.ok, width: 30, height: 30, fit: BoxFit.contain)
        : Icon(
            failed ? Icons.highlight_off : Icons.error_outline,
            color: color,
            size: 30,
          ),
  );
}
