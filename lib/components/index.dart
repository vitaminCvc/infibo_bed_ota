// 可复用UI组件
import 'package:flutter/material.dart';
import 'package:infibo_app/constants/assets.dart';

// 页面顶部公共表头
class AppTopHeader extends StatelessWidget {
  const AppTopHeader({
    super.key,
    required this.timeText,
    required this.dateText,
    this.onAddTap,
    this.onSettingTap,
    this.onUserTap,
  });

  // 当前时间文本
  final String timeText;

  // 当前日期文本
  final String dateText;

  // 点击添加按钮
  final VoidCallback? onAddTap;

  // 点击设置按钮
  final VoidCallback? onSettingTap;

  // 点击用户区域
  final VoidCallback? onUserTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildLogo(),
        const SizedBox(width: 80),
        _buildTimeBlock(),
        const Spacer(),
        _buildImageButton(
          asset: Assets.adminMainLogo,
          width: 108,
          height: 48,
          onTap: onUserTap,
        ),
        const SizedBox(width: 12),
        _buildImageButton(
          asset: Assets.addLogo,
          width: 48,
          height: 48,
          onTap: onAddTap,
        ),
        const SizedBox(width: 12),
        _buildImageButton(
          asset: Assets.settingLogo,
          width: 90,
          height: 48,
          onTap: onSettingTap,
        ),
      ],
    );
  }

  // 构建品牌logo
  Widget _buildLogo() {
    return Image.asset(
      Assets.mainLogo,
      width: 242,
      height: 44,
      fit: BoxFit.contain,
    );
  }

  // 构建时间日期
  Widget _buildTimeBlock() {
    return SizedBox(
      width: 76,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            timeText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              height: 1,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dateText,
            style: const TextStyle(
              color: Color(0xFF90939D),
              fontSize: 13,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  // 构建图片按钮
  Widget _buildImageButton({
    required String asset,
    required double width,
    required double height,
    VoidCallback? onTap,
  }) {
    final Widget image = Image.asset(
      asset,
      width: width,
      height: height,
      fit: BoxFit.contain,
    );

    if (onTap == null) {
      return image;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: image,
    );
  }
}
