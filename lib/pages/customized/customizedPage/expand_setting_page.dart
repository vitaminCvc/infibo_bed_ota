// 通用拓展功能设置页占位模板。
//
// 这是早期用于展示“标题 + 参数面板 + 确认按钮”的简单页面。
// 当前脉轮、太赫兹、HIFEM、香氛已经有各自的专用页面；
// 如果后续新增一个很简单的拓展功能，可以先用这个模板承载。
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/index.dart';

class ExpandSettingPage extends StatelessWidget {
  const ExpandSettingPage({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppHeaderPage(
      children: [
        Positioned(left: 52, top: 145, right: 52, child: _buildContent()),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF1B8D64),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontFamily: 'Microsoft YaHei',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 42),
        _buildPanel(),
      ],
    );
  }

  Widget _buildPanel() {
    return Container(
      height: 420,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1D2425),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF526B62)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '参数设置',
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
          const SizedBox(height: 26),
          _buildInput('强度'),
          const SizedBox(height: 18),
          _buildInput('频率'),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 110,
              height: 42,
              child: ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F74E8),
                  foregroundColor: Colors.white,
                ),
                child: const Text('确认'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFFDCE4E0), fontSize: 17),
          ),
        ),
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
          ),
        ),
      ],
    );
  }
}
