import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:ntp/ntp.dart';

  // 主页面逻辑控制类
  class MainLogic extends GetxController {
  // 模式详情页路由
  static const String modeDetailRoute = '/modeDetail';

  // 页面当前显示时间
  DateTime _now = DateTime.now();

  // 网络时间与本机时间的偏移量
  Duration _networkTimeOffset = Duration.zero;

  // 时钟定时器
  Timer? _clockTimer;

  // 获取时间文本
  String get timeText => '${_twoDigits(_now.hour)}:${_twoDigits(_now.minute)}';

  // 获取日期文本
  String get dateText =>
      '${_now.year}.${_twoDigits(_now.month)}.${_twoDigits(_now.day)}';

  // 启动网络时间和本地刷新定时器
  void startClock(VoidCallback onChanged) {
    _syncNetworkTime(onChanged);
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _now = DateTime.now().add(_networkTimeOffset);
      onChanged();
    });
  }

  // 释放定时器
  void disposeClock() {
    _clockTimer?.cancel();
    _clockTimer = null;
  }

  // 跳转到模式详情页
  void openModeDetail(String title) {
    Get.toNamed('/choseusers');
  }

  // 同步网络时间，失败时使用本机时间
  Future<void> _syncNetworkTime(VoidCallback onChanged) async {
    try {
      final DateTime networkTime = await NTP.now();
      _networkTimeOffset = networkTime.difference(DateTime.now());
      _now = networkTime;
      onChanged();
    } catch (_) {
      _networkTimeOffset = Duration.zero;
      _now = DateTime.now();
      onChanged();
    }
  }

  // 数字补零
  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  @override
  void onClose() {
    disposeClock();
    super.onClose();
  }
}
