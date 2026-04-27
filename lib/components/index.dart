import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/logic.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/constants/color.dart';
import 'package:ntp/ntp.dart';

// 公共页头时间控制器，全局只保留一份时钟。
class AppHeaderClockController extends GetxController {
  final Rx<DateTime> _now = DateTime.now().obs;

  Duration _networkTimeOffset = Duration.zero;
  Timer? _clockTimer;
  bool _isStarted = false;

  // 获取全局页头时间控制器，没有注册时自动创建。
  static AppHeaderClockController get instance {
    if (Get.isRegistered<AppHeaderClockController>()) {
      return Get.find<AppHeaderClockController>();
    }
    return Get.put(AppHeaderClockController(), permanent: true);
  }

  // 当前时间文本。
  String get timeText =>
      '${_twoDigits(_now.value.hour)}:${_twoDigits(_now.value.minute)}';

  // 当前日期文本。
  String get dateText =>
      '${_now.value.year}.${_twoDigits(_now.value.month)}.${_twoDigits(_now.value.day)}';

  // 启动网络时间同步和本地刷新定时器。
  void startClock() {
    if (_isStarted) return;

    _isStarted = true;
    _syncNetworkTime();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _now.value = DateTime.now().add(_networkTimeOffset);
    });
  }

  // 同步网络时间，失败时使用本机时间。
  Future<void> _syncNetworkTime() async {
    try {
      final DateTime networkTime = await NTP.now();
      _networkTimeOffset = networkTime.difference(DateTime.now());
      _now.value = networkTime;
    } catch (_) {
      _networkTimeOffset = Duration.zero;
      _now.value = DateTime.now();
    }
  }

  // 数字补零。
  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  @override
  void onClose() {
    _clockTimer?.cancel();
    super.onClose();
  }
}

// 带公共页头的基础页面。
class AppHeaderPage extends StatelessWidget {
  const AppHeaderPage({
    super.key,
    this.children = const [],
    this.onAddTap,//用户弹窗
    this.onSettingTap,//设置按钮
    this.onUserTap,//用户区域
  });

  // 页面主体内容，通常传入 Positioned 组件。
  final List<Widget> children;

  // 点击顶部添加按钮。
  final VoidCallback? onAddTap;

  // 点击顶部设置按钮。
  final VoidCallback? onSettingTap;

  // 点击顶部用户区域。
  final VoidCallback? onUserTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Positioned(
                left: 48,
                top: 34,
                right: 44,
                child: AppTopHeader(
                  onLogoTap: AppComponentLogic.backToMainPage,
                  onAddTap: onAddTap,
                  onSettingTap: onSettingTap,
                  onUserTap: onUserTap,
                ),
              ),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

// 页面顶部公共表头
class AppTopHeader extends StatelessWidget {
  const AppTopHeader({
    super.key,
    this.onLogoTap,
    this.onAddTap,
    this.onSettingTap,
    this.onUserTap,
  });

  // 点击品牌logo。
  final VoidCallback? onLogoTap;

  // 点击添加按钮
  final VoidCallback? onAddTap;

  // 点击设置按钮
  final VoidCallback? onSettingTap;

  // 点击用户区域
  final VoidCallback? onUserTap;

  @override
  Widget build(BuildContext context) {
    final AppHeaderClockController clock = AppHeaderClockController.instance
      ..startClock();

    return Row(
      children: [
        _buildLogo(),
        const SizedBox(width: 80),
        Obx(() => _buildTimeBlock(clock.timeText, clock.dateText)),
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
    final Widget logo = Image.asset(
      Assets.mainLogo,
      width: 242,
      height: 44,
      fit: BoxFit.contain,
    );

    if (onLogoTap == null) {
      return logo;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onLogoTap,
      child: logo,
    );
  }

  // 构建时间日期
  Widget _buildTimeBlock(String timeText, String dateText) {
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
