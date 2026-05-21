import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/logic.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/constants/color.dart';
import 'package:ntp/ntp.dart';

class AppHeaderClockController extends GetxController {
  final Rx<DateTime> _now = DateTime.now().obs;
  Duration _networkTimeOffset = Duration.zero;
  Timer? _clockTimer;
  bool _isStarted = false;

  static AppHeaderClockController get instance {
    if (Get.isRegistered<AppHeaderClockController>()) {
      return Get.find<AppHeaderClockController>();
    }
    return Get.put(AppHeaderClockController(), permanent: true);
  }

  String get timeText =>
      '${_twoDigits(_now.value.hour)}:${_twoDigits(_now.value.minute)}';

  String get dateText =>
      '${_now.value.year}.${_twoDigits(_now.value.month)}.${_twoDigits(_now.value.day)}';

  void startClock() {
    if (_isStarted) return;
    _isStarted = true;
    _syncNetworkTime();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _now.value = DateTime.now().add(_networkTimeOffset);
    });
  }

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

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  @override
  void onClose() {
    _clockTimer?.cancel();
    super.onClose();
  }
}

class AppHeaderPage extends StatelessWidget {
  const AppHeaderPage({
    super.key,
    this.children = const [],
    this.onSettingTap,
    this.onUserTap,
    this.enableLogoBack = true,
    this.resizeToAvoidBottomInset = true,
  });

  final List<Widget> children;
  final VoidCallback? onSettingTap;
  final VoidCallback? onUserTap;
  final bool enableLogoBack;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              ...children,
              Positioned(
                left: 48,
                top: 25,
                right: 44,
                child: AppTopHeader(
                  onLogoTap: enableLogoBack
                      ? AppComponentLogic.backToMainPage
                      : null,
                  onSettingTap: onSettingTap,
                  onUserTap: onUserTap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppTopHeader extends StatelessWidget {
  const AppTopHeader({
    super.key,
    this.onLogoTap,
    this.onSettingTap,
    this.onUserTap,
  });

  final VoidCallback? onLogoTap;
  final VoidCallback? onSettingTap;
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
          child: Positioned(
            left: 48,
            top: 13,
            child: Text(
              'administrator'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _buildImageButton(
          asset: Assets.settingLogo,
          width: 90,
          height: 48,
          onTap: AppComponentLogic.openSettingPage,
          child: Positioned(
            left: 38,
            top: 13,
            child: Text(
              'settings'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    final Widget logo = Image.asset(
      Assets.mainLogo,
      width: 242,
      height: 44,
      fit: BoxFit.contain,
    );
    if (onLogoTap == null) return logo;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onLogoTap,
      child: _withMinTapTarget(logo),
    );
  }

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

  Widget _buildImageButton({
    required String asset,
    required double width,
    required double height,
    VoidCallback? onTap,
    Widget? child,
  }) {
    final button = SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(asset, width: width, height: height, fit: BoxFit.contain),
          ?child,
        ],
      ),
    );
    if (onTap == null) return button;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: _withMinTapTarget(button),
    );
  }

  Widget _withMinTapTarget(Widget child) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      child: Center(child: child),
    );
  }
}
