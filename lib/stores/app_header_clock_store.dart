// 公共页头时钟状态。
//
// 在多个页面之间共享当前时间，支持网络校时和用户手动设置时间。
import 'dart:async';

import 'package:get/get.dart';
import 'package:infibo_app/utils/date_time_utils.dart';
import 'package:ntp/ntp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppHeaderClockController extends GetxController {
  static const String _manualTimeEnabledKey = 'manual_time_enabled';
  static const String _manualTimeOffsetMillisKey = 'manual_time_offset_millis';

  final Rx<DateTime> _now = DateTime.now().obs;

  Duration _timeOffset = Duration.zero;
  Timer? _clockTimer;
  bool _isStarted = false;
  bool _useManualTime = false;

  static AppHeaderClockController get instance {
    if (Get.isRegistered<AppHeaderClockController>()) {
      return Get.find<AppHeaderClockController>();
    }
    return Get.put(AppHeaderClockController(), permanent: true);
  }

  DateTime get currentTime => _now.value;

  String get timeText => formatClockTime(_now.value);

  String get dateText => formatClockDate(_now.value);

  void startClock() {
    if (_isStarted) return;
    _isStarted = true;

    unawaited(_initTime());

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _now.value = DateTime.now().add(_timeOffset);
    });
  }

  Future<void> _initTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // 如果手动设置时间，就按照用户设置的时间显示。
    _useManualTime = prefs.getBool(_manualTimeEnabledKey) ?? false;

    if (_useManualTime) {
      final int offsetMillis = prefs.getInt(_manualTimeOffsetMillisKey) ?? 0;
      _timeOffset = Duration(milliseconds: offsetMillis);
      _now.value = DateTime.now().add(_timeOffset);
      return;
    }
    // 若用户没有设置时间，使用网络时间同步。
    await _syncNetworkTime();
  }

  Future<void> setManualTime(DateTime value) async {
    _useManualTime = true;
    _timeOffset = value.difference(DateTime.now());
    _now.value = value;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_manualTimeEnabledKey, true);
    await prefs.setInt(_manualTimeOffsetMillisKey, _timeOffset.inMilliseconds);
  }

  Future<void> resetToNetworkTime() async {
    _useManualTime = false;
    _timeOffset = Duration.zero;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_manualTimeEnabledKey, false);
    await prefs.remove(_manualTimeOffsetMillisKey);
    // 若用户没有设置时间，使用网络时间同步。
    await _syncNetworkTime();
  }

  Future<void> _syncNetworkTime() async {
    if (_useManualTime) return;

    try {
      final DateTime networkTime = await NTP.now();

      if (_useManualTime) return;

      _timeOffset = networkTime.difference(DateTime.now());
      _now.value = networkTime;
    } catch (_) {
      if (_useManualTime) return;

      _timeOffset = Duration.zero;
      _now.value = DateTime.now();
    }
  }

  @override
  void onClose() {
    _clockTimer?.cancel();
    super.onClose();
  }
}
