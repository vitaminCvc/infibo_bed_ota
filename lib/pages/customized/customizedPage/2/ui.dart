import 'package:flutter/material.dart';
import 'package:infibo_app/pages/customized/customizedPage/1/ui.dart';

// 太赫兹拓展设置页面。
class TerahertzExpandPage extends StatelessWidget {
  const TerahertzExpandPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandSettingPage(title: '太赫兹', icon: Icons.sensors_outlined);
  }
}
