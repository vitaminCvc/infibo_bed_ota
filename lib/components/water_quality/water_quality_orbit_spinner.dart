import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 五个圆点错峰绕圈，在环顶缓慢聚拢、经过下方时加速散开。
/// 只表达等待，不表示实际处理百分比。
class WaterQualityOrbitSpinner extends StatefulWidget {
  const WaterQualityOrbitSpinner({super.key, required this.color});
  final Color color;

  @override
  State<WaterQualityOrbitSpinner> createState() =>
      _WaterQualityOrbitSpinnerState();
}

class _WaterQualityOrbitSpinnerState extends State<WaterQualityOrbitSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _rotation.stop();
    } else if (!_rotation.isAnimating) {
      _rotation.repeat();
    }
  }

  @override
  void dispose() {
    _rotation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _OrbitDotsPainter(rotation: _rotation, color: widget.color),
    child: const SizedBox.expand(),
  );
}

class _OrbitDotsPainter extends CustomPainter {
  _OrbitDotsPainter({required this.rotation, required this.color})
    : super(repaint: rotation);
  final Animation<double> rotation;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const dotCount = 6;
    const dotRadius = 2.2;
    final radius = math.max(0.0, size.shortestSide / 2 - dotRadius);
    final center = size.center(Offset.zero);
    final paint = Paint();
    for (var dot = 0; dot < dotCount; dot++) {
      // 领头圆点保留原色，尾随圆点逐个变浅，形成绕圈的渐变尾迹。
      paint.color = Color.lerp(
        color,
        Color.fromARGB(255, 245, 229, 131),
        dot / dotCount * 0.65,
      )!;
      final progress = (rotation.value - dot * 0.09 + 1) % 1;
      // 单调、连续的速度曲线；首尾回到同一点，没有跳帧或突然复位。
      final orbit =
          progress - 0.8 * math.sin(2 * math.pi * progress) / (2 * math.pi);
      final angle = 2 * math.pi * orbit - math.pi / 2;
      final position =
          center + Offset(math.cos(angle), math.sin(angle)) * radius;
      canvas.drawCircle(position, dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(_OrbitDotsPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.rotation != rotation;
}
