// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';

///创建性别选择组件
///
///当前选中值由弹窗主体管理；用户点击后，通过【onChanged】回调通知弹窗主体更新选中值
///
class GenderSelector extends StatelessWidget {
  const GenderSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  ///当前选中的性别，值为['男']或['女']
  final String value;

  ///用户点击后，通过该回调通知弹窗主体更新选中值
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      width: 400,
      child: Row(
        children: [
          // 标题占用剩余空间；窄语言布局下可省略显示，避免挤压性别选项。
          Expanded(child: _buildLabel(context)),
          //性别选项框
          _GenderOption(
            label: 'male'.tr,
            isSelected: value == '男',
            onTap: () => onChanged('男'),
          ),

          // 根据参考图保留男女选项之间的固定距离。
          const SizedBox(width: 40),
          //性别选项框
          _GenderOption(
            label: 'female'.tr,
            isSelected: value == '女',
            onTap: () => onChanged('女'),
          ),
        ],
      ),
    );
  }

  ///////创建左侧“性别”标签
  Widget _buildLabel(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: 'user_gender_label'.tr,
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: Color(0xFFFF5D65)),
          ),
        ],
      ),
      style: const TextStyle(fontSize: 18, color: Colors.white),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

///单个性别选项
///
///它只是 [GenderSelector] 的内部实现，因此不用单独创建文件。
///
///
class _GenderOption extends StatelessWidget {
  const _GenderOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,

              // 选中时显示蓝色背景，未选中时保持透明。
              color: isSelected ? const Color(0xFF1464DF) : Colors.transparent,

              // 未选中状态显示灰色圆形边框。
              border: isSelected
                  ? null
                  : Border.all(color: const Color(0xFF8B909A), width: 1),
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 15),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
