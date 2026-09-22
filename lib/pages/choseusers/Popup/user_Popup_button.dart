// ignore_for_file: file_names

import 'package:flutter/material.dart';

/// 添加用户弹窗底部的取消和确认按钮组。
///
/// 组件只负责按钮样式和点击事件转发。
/// 关闭弹窗、表单校验、后端提交等逻辑由弹窗主体处理。
class PopupActionButtons extends StatelessWidget {
  const PopupActionButtons({
    super.key,
    required this.onCancel,
    required this.onConfirm,
    required this.cancelLabel,
    required this.confirmLabel,
    this.confirmBackgroundColor = const Color(0xFF1464DF),
  });

  /// 点击“取消”时执行。
  final VoidCallback onCancel;

  /// 点击“确认”时执行。
  final VoidCallback onConfirm;

  final String cancelLabel;
  final String confirmLabel;

  /// 确认按钮背景色；添加用户弹窗默认保持蓝色。
  final Color confirmBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildButton(
          text: cancelLabel,
          backgroundColor: const Color(0xFF3C4045),
          foregroundColor: const Color(0xFFA6A6A6),
          onPressed: onCancel,
        ),

        // 两个按钮的固定间距，对应参考图。
        const SizedBox(width: 16),

        _buildButton(
          text: confirmLabel,
          backgroundColor: confirmBackgroundColor,
          foregroundColor: Colors.white,
          onPressed: onConfirm,
        ),
      ],
    );
  }

  /// 构建尺寸随文字和内边距变化的胶囊按钮。
  Widget _buildButton({
    required String text,
    required Color backgroundColor,
    required Color foregroundColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
        elevation: 0,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        textStyle: const TextStyle(fontSize: 16),
        shape: const StadiumBorder(),
      ),
      child: Text(text),
    );
  }
}
