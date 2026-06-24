import 'dart:ui';

import 'package:flutter/material.dart';

Widget buildGlassCard({
  required Widget child,
  double width = 400,
  double height = 720,
  double radius = 18,
  EdgeInsets padding = const EdgeInsets.all(22),
  List<Color>? gradientColors,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.59, 0.99],
            colors: [
              const Color(0xFFF1F5FF).withValues(alpha: 0.12),
              const Color(0xFFDBE6FF).withValues(alpha: 0.28),
              const Color(0xFFF1F5FF).withValues(alpha: 0.12),
            ],
          ),
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius - 1),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.48, 1.0],
              colors:
                  gradientColors ??
                  [
                    const Color(0xFF202634).withValues(alpha: 0.78),
                    const Color(0xFF151A24).withValues(alpha: 0.74),
                    const Color(0xFF0B0E15).withValues(alpha: 0.70),
                  ],
            ),
          ),
          child: child,
        ),
      ),
    ),
  );
}
