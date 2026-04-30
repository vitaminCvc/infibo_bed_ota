import 'package:flutter/material.dart';
import 'package:infibo_app/pages/customized/customizedPage/1/ui.dart';

// HIFEM 拓展设置页面。
class HifemExpandPage extends StatelessWidget {
  const HifemExpandPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpandSettingPage(
      title: 'HIFEM',
      icon: Icons.monitor_heart_outlined,
    );
  }
}
