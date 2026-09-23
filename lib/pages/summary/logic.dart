// 理疗总结页逻辑。
//
// 负责读取总结数据、统计拓展模块时长，并在页面长时间无操作时返回主页。
import 'dart:async';
import 'dart:convert';
import 'package:infibo_app/api/dio/therapy_report/therapy_report_api.dart';
import 'package:infibo_app/api/dio/therapy_report/therapy_report_models.dart';
import 'package:infibo_app/stores/app_header_clock_store.dart';
import 'package:infibo_app/stores/user_store.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/logic.dart';

class SummaryLogic {
  // 页面无操作 2 秒后，走和点击确认一样的返回逻辑。
  static const Duration _idleDuration = Duration(milliseconds: 2000);

  final TextEditingController feelingController = TextEditingController();

  Timer? _idleTimer;

  // 键盘（输入法）是否正在显示。打字期间暂停自动返回计时，
  // 避免用户输入中途停顿超过 2 秒时总结页被销毁。
  bool _keyboardVisible = false;
  String userName = 'no_user_selected'.tr;
  Map<String, int> moduleSeconds = <String, int>{};

  int? clientId;
  int? planId;
  String planName = '';
  String planType = '';
  int durationSeconds = 0;
  bool reportSaved = false;
  bool _isOfflineMode = false;

  // 读取启动理疗页传过来的用户和模块运行时间。
  void configure(Object? args) {
    if (args is! Map) return;

    _isOfflineMode = args['isOfflineMode'] == true;

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

    // 从启动理疗页传过来的参数中读取客户端ID、计划ID、计划名称、计划类型、疗程时长。
    clientId = int.tryParse(args['clientId']?.toString() ?? '');
    planId = int.tryParse(args['planId']?.toString() ?? '');
    planName = args['planName']?.toString() ?? '';
    planType = args['planType']?.toString() ?? '';
    durationSeconds =
        int.tryParse(args['durationSeconds']?.toString() ?? '0') ??
        moduleSeconds.values.fold<int>(0, (sum, seconds) => sum + seconds);
  }

  // 点击、拖动、滚动、输入都算一次用户操作，会重新开始空闲计时。
  void recordUserAction() {
    startIdleTimer();
  }

  // 键盘弹出（正在打字）时暂停自动返回计时，键盘收起后再重新计时。
  // 这样用户在感受留言里输入时，无论写多久、停顿多久，页面都不会被自动关闭。
  void setKeyboardVisible(bool visible) {
    if (_keyboardVisible == visible) return;
    _keyboardVisible = visible;
    if (visible) {
      _idleTimer?.cancel();
      _idleTimer = null;
    } else {
      startIdleTimer();
    }
  }

  void startIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = null;
    // 打字期间不启动自动返回计时，等键盘收起后由 setKeyboardVisible 重新计时。
    if (_keyboardVisible) return;
    _idleTimer = Timer(_idleDuration, confirmBackToMain);
  }

  //新增保存报告方法
  Future<bool> saveReport() async {
    if (reportSaved) return true;
    final int? currentClientId = clientId;
    final int? ownerUserId = UserStore.instance.userId;
    if (currentClientId == null || ownerUserId == null) return false;

    final SaveTherapyReportRequestDto request = SaveTherapyReportRequestDto(
      clientId: currentClientId,
      planId: planId,
      planName: planName,
      planType: planType,
      reportTime: AppHeaderClockController.instance.currentTime,
      durationSeconds: durationSeconds,
      usedModulesJson: jsonEncode(moduleSeconds.keys.toList()),
      therapyFeedback: feelingController.text.trim(),
      modules: _buildModuleRequests(),
    );

    final response = await TherapyReportApi().save(
      ownerUserId: ownerUserId,
      request: request,
    );
    reportSaved = response.isSuccess;
    return response.isSuccess;
  }

  // 构建模块请求列表
  List<ReportModuleRequestDto> _buildModuleRequests() {
    return moduleSeconds.entries.where((entry) => entry.value > 0).map((entry) {
      return ReportModuleRequestDto(
        moduleCode: entry.key,
        moduleName: _moduleName(entry.key),
        runDurationMinutes: (entry.value / 60).ceil(),
        runStatus: 'completed',
      );
    }).toList();
  }

  String _moduleName(String code) {
    switch (code) {
      case 'red':
        return 'red_light'.tr;
      case 'pemf':
        return 'PEMF';
      case 'vat':
        return 'VAT';
      case 'hydrogen':
        return 'module_hydrogen'.tr;
      case 'expand':
        return 'module_expand'.tr;
      default:
        return code;
    }
  }

  // 确认按钮和无操作自动返回，都统一从这里回到首页。
  void confirmBackToMain() async {
    _idleTimer?.cancel();
    if (!_isOfflineMode) {
      await saveReport();
    }
    AppComponentLogic.backToMainPage();
  }

  String moduleDurationText(String id) {
    final int seconds = id == 'expand'
        ? expandSeconds
        : (moduleSeconds[id] ?? 0);
    if (seconds <= 0) return 'not_running'.tr;
    return '${'running_label'.tr}  ${formatDuration(seconds)}';
  }

  String formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainSeconds = seconds % 60;

    if (minutes <= 0) return '$remainSeconds${'seconds_unit'.tr}';
    if (remainSeconds <= 0) return '$minutes${'minutes_unit'.tr}';
    return '$minutes${'minutes_unit'.tr}$remainSeconds${'seconds_unit'.tr}';
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
