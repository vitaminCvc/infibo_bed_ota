// 理疗总结页逻辑。
//
// 负责读取总结数据、统计拓展模块时长，并在页面长时间无操作时返回主页。
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/logic.dart';

class SummaryLogic {
  // 页面无操作 1 分钟后，走和点击确认一样的返回逻辑。
  static const Duration _idleDuration = Duration(minutes: 100);

  final TextEditingController feelingController = TextEditingController();

  Timer? _idleTimer;
  String userName = 'no_user_selected'.tr;
  Map<String, int> moduleSeconds = <String, int>{};

  // 读取启动理疗页传过来的用户和模块运行时间。
  void configure(Object? args) {
    if (args is! Map) return;

    final Object? name = args['userName'];
    if (name is String && name.trim().isNotEmpty) {
      userName = name.trim();
    }

    final Object? seconds = args['moduleSeconds'];
    if (seconds is Map) {
      moduleSeconds = seconds.map((key, value) {
        final int safeValue = value is int ? value : 0;
        return MapEntry(key.toString(), safeValue);
      });
    }
  }

  // 点击、拖动、滚动、输入都算一次用户操作，会重新开始 2 分钟计时。
  void recordUserAction() {
    startIdleTimer();
  }

  void startIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(_idleDuration, confirmBackToMain);
  }

  // 确认按钮和无操作自动返回，都统一从这里回到首页。
  void confirmBackToMain() {
    _idleTimer?.cancel();
    AppComponentLogic.backToMainPage();
  }

  String moduleDurationText(String id) {
    final int seconds = id == 'expand'
        ? expandSeconds
        : (moduleSeconds[id] ?? 0);
    if (seconds <= 0) return '\u672a\u8fd0\u884c';
    return '\u8fd0\u884c  $seconds\u79d2';
  }

  int get expandSeconds {
    const Set<String> normalModules = <String>{
      'red',
      'pemf',
      'vat',
      'hydrogen',
    };
    int seconds = moduleSeconds['expand'] ?? 0;
    for (final MapEntry<String, int> entry in moduleSeconds.entries) {
      if (!normalModules.contains(entry.key)) {
        seconds += entry.value;
      }
    }
    return seconds;
  }

  void dispose() {
    _idleTimer?.cancel();
    feelingController.dispose();
  }
}
