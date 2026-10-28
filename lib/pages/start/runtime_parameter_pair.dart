import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Keep translated labels independent of the values and the units in the
/// existing panel artwork.
class RuntimeParameterPair extends StatelessWidget {
  const RuntimeParameterPair({
    super.key,
    required this.leftLabelKey,
    required this.rightLabelKey,
    required this.leftValue,
    required this.rightValue,
    this.valueTop = 36,
    this.leftValueFontSize = 20,
  });

  final String leftLabelKey;
  final String rightLabelKey;
  final String leftValue;
  final String rightValue;
  final double valueTop;
  final double leftValueFontSize;

  String _label(String key) =>
      Get.locale?.languageCode == 'pl' ? 'runtime_$key'.tr : key.tr;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: valueTop + 24,
      child: Stack(
        children: [
          _cell(0, 0, _label(leftLabelKey), label: true),
          _cell(120, 0, _label(rightLabelKey), label: true),
          _cell(0, valueTop, leftValue, fontSize: leftValueFontSize),
          _cell(120, valueTop, rightValue),
        ],
      ),
    );
  }

  Widget _cell(
    double left,
    double top,
    String text, {
    bool label = false,
    double fontSize = 20,
  }) => Positioned(
    left: left,
    top: top,
    width: 100,
    child: Text(
      text,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: label ? const Color(0xffb9bcc6) : Colors.white,
        fontSize: label ? 17 : fontSize,
        height: label ? 1.2 : 1,
      ),
    ),
  );
}
