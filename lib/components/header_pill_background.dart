import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

enum HeaderPillVariant { settings, user }

/// The gradients come from header_settings_bg.svg and header_user.svg.
/// Only the gradient shader scales; the corner radius and border do not.
class HeaderPillBackground extends StatelessWidget {
  const HeaderPillBackground({super.key, required this.variant});

  final HeaderPillVariant variant;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _HeaderPillPainter(variant));
  }
}

class _HeaderPillPainter extends CustomPainter {
  const _HeaderPillPainter(this.variant);

  final HeaderPillVariant variant;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final outline = _roundedPath(size, 0.5);
    final fill = Paint();
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    if (variant == HeaderPillVariant.settings) {
      final gradientTransform = _gradientTransform(size, 90);
      fill.shader = ui.Gradient.linear(
        const Offset(-11.1366, -14.8333),
        const Offset(68.8382, 85.8451),
        [
          const Color(0xFFF1F5FF).withValues(alpha: 0.16 * 0.5),
          const Color(0xFFDBE6FF).withValues(alpha: 0.16),
          const Color(0xFFF1F5FF).withValues(alpha: 0.16 * 0.5),
        ],
        const [0, 0.589489, 0.985577],
        TileMode.clamp,
        gradientTransform,
      );
      border.shader = ui.Gradient.linear(
        const Offset(74.4512, -1.82423),
        const Offset(37.8482, 60.1169),
        const [Color(0x008690A8), Color(0xFF363B47), Color(0x008690A8)],
        const [0, 0.451923, 1],
        TileMode.clamp,
        gradientTransform,
      );
      canvas.drawPath(_roundedPath(size, 0), fill);
    } else {
      fill.shader = ui.Gradient.linear(
        const Offset(-14.7273, 23.3846),
        const Offset(118.014, 23.6751),
        [
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0.1),
        ],
        const [0, 1],
        TileMode.clamp,
        _gradientTransform(size, 108),
      );
      border.color = const Color(0xFF2D3038);
      canvas.drawPath(outline, fill);
    }
    canvas.drawPath(outline, border);
  }

  Float64List _gradientTransform(Size size, double sourceWidth) =>
      Float64List.fromList([
        size.width / sourceWidth,
        0,
        0,
        0,
        0,
        size.height / 48,
        0,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        0,
        1,
      ]);

  Path _roundedPath(Size size, double inset) {
    // Match the SVG's cubic quarter circles, including its 1px inset stroke.
    final radius = 24 - inset;
    final control = radius * 0.55228475;
    final left = inset;
    final top = inset;
    final right = size.width - inset;
    final bottom = size.height - inset;
    return Path()
      ..moveTo(left + radius, top)
      ..lineTo(right - radius, top)
      ..cubicTo(
        right - radius + control,
        top,
        right,
        top + radius - control,
        right,
        top + radius,
      )
      ..lineTo(right, bottom - radius)
      ..cubicTo(
        right,
        bottom - radius + control,
        right - radius + control,
        bottom,
        right - radius,
        bottom,
      )
      ..lineTo(left + radius, bottom)
      ..cubicTo(
        left + radius - control,
        bottom,
        left,
        bottom - radius + control,
        left,
        bottom - radius,
      )
      ..lineTo(left, top + radius)
      ..cubicTo(
        left,
        top + radius - control,
        left + radius - control,
        top,
        left + radius,
        top,
      )
      ..close();
  }

  @override
  bool shouldRepaint(_HeaderPillPainter oldDelegate) =>
      oldDelegate.variant != variant;
}
