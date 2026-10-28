import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Reserve space for the original waveform size; translations only affect
/// the bounded label at its side.
class RuntimeWaveformRow extends StatelessWidget {
  const RuntimeWaveformRow({
    super.key,
    required this.labelKey,
    required this.asset,
    required this.waveformWidth,
    this.waveformHeight,
  }) : assert(waveformWidth > 0 && waveformWidth < 212);

  final String labelKey;
  final String asset;
  final double waveformWidth;
  final double? waveformHeight;

  @override
  Widget build(BuildContext context) {
    final shortKey = 'runtime_$labelKey';
    final shortLabel = shortKey.tr;
    final label = shortLabel == shortKey ? labelKey.tr.trim() : shortLabel;
    return SizedBox(
      width: 220,
      child: Row(
        children: [
          SizedBox(
            width: 220 - 8 - waveformWidth,
            child: Text(
              label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFFE4E7EE), fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Image.asset(
            asset,
            width: waveformWidth,
            height: waveformHeight,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
