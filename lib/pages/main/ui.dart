// 主页面。
//
// 展示预设理疗模式、顶部 Header 和氛围灯开关，并提供进入自定义方案页的入口。
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/api/modbus/hydrogen_modbus.dart';
import 'package:infibo_app/api/modbus/modbus_rtu_service.dart';
import 'package:infibo_app/components/designCanvas/design.dart';
import 'package:infibo_app/components/index.dart';
import 'package:infibo_app/components/water_level_state_dialog.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/config/app_brand.dart';
import 'package:infibo_app/constants/color.dart';
import 'package:infibo_app/constants/layout.dart';
import 'package:infibo_app/pages/joystick/ui.dart';
import 'package:infibo_app/pages/main/logic.dart';
import 'package:infibo_app/pages/start/audio_prompt_player.dart';
import 'package:infibo_app/pages/WifiBluetooth/connection_prompt_host.dart';
import 'package:infibo_app/routes/route_observer.dart';
import 'package:infibo_app/components/water_quality/water_quality_host.dart';

// 主页面UI
class MainPage extends StatefulWidget {
  const MainPage({super.key, this.modbusService = const ModbusRtuService()});

  final ModbusRtuService modbusService;

  @override
  State<MainPage> createState() => _MainPageState();
}

// 主页面状态管理
class _MainPageState extends State<MainPage> with RouteAware {
  // 主页面底部氛围灯默认按钮
  bool _isLightOn = false;
  bool _isLightCommanding = false;
  bool _pendingLightState = false;
  bool _hasPendingLight = false;
  bool _deviceFault = false; //true:设备故障(红色),false:设备正常(绿色)
  Timer? _deviceStatusTimer; //设备状态轮询定时器
  Timer? _waterLevelTimer; //水位状态轮询定时器
  bool _isDeviceStatusPolling = false;
  bool _isHomeDeviceStateReading = false;
  // 设备状态轮询（0x0012 → 0x0006）一轮结束的信号量。
  // 水位读取（0x01E5）会先等它完成，从而保证串口发送时序恒为 0x0012 → 0x0006 → 0x01E5。
  Completer<void>? _homeDeviceStateCycleCompleter;
  bool _isWaterLevelPolling = false;
  bool _isWaterLevelReading = false;
  bool _isWaterLevelDialogVisible = false;
  bool _isWaterLevelDialogDismissedForVisit = false;
  Timer? _waterLevelCompleteAutoDismissTimer;
  final ValueNotifier<int> _waterLevelStateNotifier = ValueNotifier<int>(1);

  // 旧硬件沿用原版 4 秒提醒展示时间，之后可手动关闭，不等待自动注水完成。
  final ValueNotifier<bool> _legacyWaterReminderCanDismiss = ValueNotifier(
    false,
  );
  Timer? _legacyWaterReminderTimer;
  bool get _supportsAutoWaterFilling =>
      AppBrand.current.supportsAutoWaterFilling;
  bool get _canDismissWaterDialog =>
      _waterLevelStateNotifier.value == 3 ||
      (!_supportsAutoWaterFilling && _legacyWaterReminderCanDismiss.value);

  /// 最近一次 0x01E5 读数：1=缺水, 2=正常, 3=高水位；关闭弹窗时用于判断是否仍在缺水。
  int? _lastWaterLevelRegisterState;
  bool _isRouteSubscribed = false;
  // final ValueNotifier<String> _liftCurrentText = ValueNotifier<String>('--');
  // 主页面逻辑控制器
  final MainLogic _logic = MainLogic();

  @override
  void initState() {
    super.initState();
    unawaited(AudioPromptPlayer.instance.preloadWaterSafely());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    if (!_isRouteSubscribed && route is PageRoute) {
      appRouteObserver.subscribe(this, route);
      _isRouteSubscribed = true;
    }
  }

  //加dispose释放定时器
  @override
  void dispose() {
    if (_isRouteSubscribed) {
      appRouteObserver.unsubscribe(this);
      _isRouteSubscribed = false;
    }
    _stopDeviceStatusPolling();
    _stopWaterLevelPolling();
    _cancelWaterLevelCompleteAutoDismissTimer();
    _waterLevelStateNotifier.dispose();
    _legacyWaterReminderTimer?.cancel();
    _legacyWaterReminderCanDismiss.dispose();
    // _liftCurrentText.dispose();
    super.dispose();
  }

  @override
  void didPush() {
    _isWaterLevelDialogDismissedForVisit = false;
    _startDeviceStatusPolling();
    _startWaterLevelPolling();
  }

  @override
  void didPopNext() {
    // 关闭水位弹窗也会触发 didPopNext；只有从其他页面返回才算重新进入首页。
    if (!_isWaterLevelDialogVisible) {
      _isWaterLevelDialogDismissedForVisit = false;
    }
    _startDeviceStatusPolling();
    _startWaterLevelPolling();
  }

  ///新增离开首页发送摇杆停止指令
  ///
  Future<void> _stopLiftOnLeave() async {
    try {
      await widget.modbusService.sendCommandQueue([
        const ModbusWriteCommand(address: 0x0010, value: 0),
      ]);

      ///发送失败
    } catch (e) {
      debugPrint('离开首页发送停止指令失败: $e');
    }
  }

  @override
  ///离开首页
  void didPushNext() {
    _stopDeviceStatusPolling();
    // Keep polling while the blocking water warning dialog is on top.
    if (!_isWaterLevelDialogVisible) {
      _stopWaterLevelPolling();
      //离开首页时，向下位机发送摇杆停止指令。
      unawaited(_stopLiftOnLeave());
    }
  }

  @override
  ///释放资源
  void didPop() {
    _stopDeviceStatusPolling();
    _stopWaterLevelPolling();
    unawaited(_stopLiftOnLeave());
  }

  void _startDeviceStatusPolling() {
    if (_isDeviceStatusPolling) return;
    _isDeviceStatusPolling = true;
    unawaited(_readHomeDeviceState());
    _deviceStatusTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => unawaited(_readHomeDeviceState()),
    );
  }

  void _stopDeviceStatusPolling() {
    _deviceStatusTimer?.cancel();
    _deviceStatusTimer = null;
    _isDeviceStatusPolling = false;
  }

  // 首页显示期间同时同步设备故障状态和氛围灯真实状态。
  // 发送时序固定为 0x0012 → 0x0006：两条都读完后才释放信号量，允许水位 0x01E5 读取。
  Future<void> _readHomeDeviceState() async {
    if (!_isDeviceStatusPolling || _isHomeDeviceStateReading) return;
    _isHomeDeviceStateReading = true;
    _homeDeviceStateCycleCompleter = Completer<void>();
    try {
      await _syncAmbientLightStateFromDevice(); // 第 1 帧：0x0012 氛围灯开关状态
      if (!mounted || !_isDeviceStatusPolling) return;
      await _readDeviceStatus0006(); // 第 2 帧：0x0006 系统运行状态
    } finally {
      _isHomeDeviceStateReading = false;
      // 本轮 0x0012 / 0x0006 已发送完毕，唤醒正在等待的水位读取（0x01E5）。
      _homeDeviceStateCycleCompleter?.complete();
      _homeDeviceStateCycleCompleter = null;
    }
  }

  /// 等待当前一轮 0x0012 / 0x0006 读取完成。
  ///
  /// 水位读取在发送 0x01E5 前调用本方法，确保 0x01E5 永远排在 0x0006 之后，
  /// 维持 0x0012 → 0x0006 → 0x01E5 的发送时序（旧版本 6月30日/7月9日 即为此顺序）。
  Future<void> _waitForHomeDeviceStateCycle() async {
    while (_isHomeDeviceStateReading) {
      final Completer<void>? completer = _homeDeviceStateCycleCompleter;
      if (completer == null) return;
      await completer.future;
    }
  }

  void _startWaterLevelPolling() {
    if (_isWaterLevelPolling) return;
    _isWaterLevelPolling = true;
    // 注释掉分子氢读取水位状态
    // 注意：这里不再直接抢发 0x01E5，首帧会等 0x0012 / 0x0006 读完后才发出，
    // 保证进入首页的发送时序为 0x0012 → 0x0006 → 0x01E5（3s 轮询周期保持不变）。
    _readWaterLevelStatus01E5();
    _waterLevelTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _readWaterLevelStatus01E5(),
    );
  }

  void _stopWaterLevelPolling() {
    _waterLevelTimer?.cancel();
    _waterLevelTimer = null;
    _isWaterLevelPolling = false;
  }

  // 从下位机读取0x0012寄存器状态，同步界面环境灯光开关状态。
  Future<void> _syncAmbientLightStateFromDevice() async {
    try {
      final int state = await widget.modbusService.readHoldingRegister(0x0012);
      if (!mounted) return;
      setState(() => _isLightOn = state == 1);
      debugPrint('Ambient light sync RX 0x0012=$state');
    } catch (e) {
      debugPrint('Ambient light sync failed: $e');
    }
  }

  // 5s读取一次0x0006寄存器状态，同步界面设备状态
  Future<void> _readDeviceStatus0006() async {
    try {
      final int state = await widget.modbusService.readHoldingRegister(
        0x0006,
      ); //读取0x0006寄存器状态，判断设备是否故障
      final bool fault = state == 3 || state == 5; //判断是否为设备故障状态
      // 0x0006寄存器状态为0时，设备正常(绿色)
      // 0x0006寄存器状态为1时，设备正常(绿色)
      // 0x0006寄存器状态为2时，设备正常(绿色)
      // 0x0006寄存器状态为3时，设备故障(红色)

      if (!mounted) return;
      //读取到设备故障状态后，如果新状态和旧状态不一样，就更新界面；如果读取失败，就打印错误日志。
      if (_deviceFault != fault) {
        setState(() => _deviceFault = fault);
      }
    } catch (e) {
      debugPrint('Device status sync failed: $e');
    }
  }

  // 0x01E5 水位：1=缺水，2=水位正常，3=高水位（注水完成），其余值忽略。
  Future<void> _readWaterLevelStatus01E5() async {
    if (_isWaterLevelReading) return;
    _isWaterLevelReading = true;
    try {
      // 先等 0x0012 / 0x0006 本轮读取完成，确保 0x01E5 排在 0x0006 之后发送。
      await _waitForHomeDeviceStateCycle();
      if (!mounted || !_isWaterLevelPolling) return;
      final int state = await widget.modbusService.readHoldingRegister(
        HydrogenModbus.waterLevelReadAddress,
      );
      if (!mounted) return;
      _lastWaterLevelRegisterState = state;

      if (state == 1) {
        if (!_isWaterLevelDialogVisible &&
            !_isWaterLevelDialogDismissedForVisit) {
          // 只要检测到缺水就弹出提醒，进入"缺水"状态。
          _waterLevelStateNotifier.value = 1;
          _cancelWaterLevelCompleteAutoDismissTimer();
          _showWaterLevelStateDialog();
        } else if (_isWaterLevelDialogVisible &&
            _waterLevelStateNotifier.value == 3) {
          // 完成提示还没关闭就再次缺水：回到缺水提醒，重新从 Ready? 开始。
          _cancelWaterLevelCompleteAutoDismissTimer();
          _waterLevelStateNotifier.value = 1;
        }
      } else if (state == 3) {
        // 高水位=注水完成：弹窗已打开时切到完成提示，等待点击关闭。
        _isWaterLevelDialogDismissedForVisit = false;
        if (_isWaterLevelDialogVisible && _waterLevelStateNotifier.value != 3) {
          _waterLevelStateNotifier.value = 3;
          _startWaterLevelCompleteAutoDismissTimer();
        }
      } else if (state == 2) {
        // 2=水位正常：新硬件继续等待加水操作/高水位 3，不提前提示完成。
        // 旧硬件仍显示提醒，但展示满 4 秒即可手动关闭，不要求进入自动注水流程。
        _isWaterLevelDialogDismissedForVisit = false;
      }
      // 其余值（如 0）忽略，不改变弹窗状态。

      debugPrint('Water level sync RX 0x01E5=$state');
    } catch (e) {
      debugPrint('Water level sync failed: $e');
    } finally {
      _isWaterLevelReading = false;
      // 原有水位读取完成后再检测 TDS，保留 0012 → 0006 → 01E5 顺序。
      if (mounted && _isWaterLevelPolling) {
        unawaited(
          WaterQualityScope.maybeOf(context)?.onHomeWaterPollComplete(),
        );
      }
    }
  }

  /// 点击 “Start Filling”：先切到注水中，再向下位机写入 0x01EB=1。
  Future<void> _startWaterFilling() async {
    // 旧硬件即使被意外调用，也不切换到“注水中”，不发送自动加水命令。
    if (!_supportsAutoWaterFilling) return;
    if (!mounted || !_isWaterLevelDialogVisible) return;
    if (_waterLevelStateNotifier.value != 1) return;
    _waterLevelStateNotifier.value = 2;
    try {
      await widget.modbusService.startWaterFilling();
    } catch (e) {
      debugPrint('Start water filling failed: $e');
      if (mounted &&
          _isWaterLevelDialogVisible &&
          _waterLevelStateNotifier.value == 2) {
        // 写入失败时退回缺水状态，允许重新点击按钮重试。
        _waterLevelStateNotifier.value = 1;
      }
    }
  }

  void _startWaterLevelCompleteAutoDismissTimer() {
    _cancelWaterLevelCompleteAutoDismissTimer();
    _waterLevelCompleteAutoDismissTimer = Timer(
      const Duration(milliseconds: 5000),
      () {
        if (!mounted ||
            !_isWaterLevelDialogVisible ||
            _waterLevelStateNotifier.value != 3) {
          return;
        }
        _dismissWaterLevelStateDialog();
      },
    );
  }

  void _cancelWaterLevelCompleteAutoDismissTimer() {
    _waterLevelCompleteAutoDismissTimer?.cancel();
    _waterLevelCompleteAutoDismissTimer = null;
  }

  void _dismissWaterLevelStateDialog() {
    if (!_isWaterLevelDialogVisible || !mounted) return;
    // 新硬件等待完成；旧硬件展示满 4 秒后允许关闭提醒。
    if (!_canDismissWaterDialog) return;
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _showWaterLevelStateDialog() {
    if (_isWaterLevelDialogVisible || !mounted) return;
    _isWaterLevelDialogVisible = true;
    _legacyWaterReminderCanDismiss.value = false;
    if (!_supportsAutoWaterFilling) {
      _legacyWaterReminderTimer?.cancel();
      _legacyWaterReminderTimer = Timer(const Duration(seconds: 4), () {
        if (mounted && _isWaterLevelDialogVisible) {
          _legacyWaterReminderCanDismiss.value = true;
        }
      });
    }
    unawaited(AudioPromptPlayer.instance.playWaterSafely());
    unawaited(
      showGeneralDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierLabel: 'water_level_dialog',
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (context, animation, secondaryAnimation) {
          return ListenableBuilder(
            listenable: Listenable.merge([
              _waterLevelStateNotifier,
              _legacyWaterReminderCanDismiss,
            ]),
            builder: (context, _) {
              // 关闭权限与硬件能力一起判断，避免隐藏按钮后旧设备无法退出。
              final bool canDismiss = _canDismissWaterDialog;
              return PopScope(
                canPop: canDismiss,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        key: const ValueKey<String>(
                          'water_level_dialog_barrier',
                        ),
                        behavior: HitTestBehavior.opaque,
                        onTap: canDismiss
                            ? _dismissWaterLevelStateDialog
                            : null,
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    Center(
                      child: Material(
                        color: Colors.transparent,
                        child: GestureDetector(
                          // 完成后点击弹窗内部任意位置也能关闭。
                          behavior: HitTestBehavior.opaque,
                          onTap: canDismiss
                              ? _dismissWaterLevelStateDialog
                              : null,
                          child: WaterLevelStateDialog(
                            supportsAutoWaterFilling: _supportsAutoWaterFilling,
                            notifier: _waterLevelStateNotifier,
                            onStartFilling: () {
                              unawaited(_startWaterFilling());
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ).whenComplete(() {
        _legacyWaterReminderTimer?.cancel();
        _legacyWaterReminderTimer = null;
        _cancelWaterLevelCompleteAutoDismissTimer();
        _isWaterLevelDialogVisible = false;
        // 关闭时若最近读数仍是缺水（竞态），本次停留不再重复弹出；
        // 水位回到正常/高水位后会重新允许提醒。
        _isWaterLevelDialogDismissedForVisit =
            _lastWaterLevelRegisterState == 1;
      }),
    );
  }

  ///////////////////////////////////////////////模式卡片数据////////////////////////////////////////////////
  // 左侧模式卡片数据
  static const List<_ModeCardData> _leftModeCards = [
    // 深度放松
    _ModeCardData(
      titleKey: 'deep_relax',
      color: Color(0xFF26D1EF),
      asset: Assets.deepRelaxLogo,
      iconAsset: Assets.deepRelaxationIcon,
      left: 150,
      top: 246,
      width: 220,
      headerLeft: 11,
      headerTop: 16,
    ),
    // 能量提升
    _ModeCardData(
      titleKey: 'energy_boost',
      color: Color(0xFFFB933E),
      asset: Assets.energyBoostLogo,
      iconAsset: Assets.energyBoostIcon,
      left: 103,
      top: 396,
      width: 191,
      headerLeft: 10,
      headerTop: 17,
    ),
    // 疼痛缓解
    _ModeCardData(
      titleKey: 'pain_relief',
      color: Color(0xFFF9645C),
      asset: Assets.painReliefLogo,
      iconAsset: Assets.painReliefIcon,
      left: 53,
      top: 546,
      width: 215,
      headerLeft: 13,
      headerTop: 19,
    ),
    // 睡眠改善
    _ModeCardData(
      titleKey: 'sleep_enhancement',
      color: Color(0xFFA68DF5),
      asset: Assets.sleepEnhancementLogo,
      iconAsset: Assets.sleepEnhancementIcon,
      left: 98,
      top: 696,
      width: 200,
      headerLeft: 12,
      headerTop: 17,
    ),
    // 运动恢复
    _ModeCardData(
      titleKey: 'sports_recovery',
      color: Color(0xFF56D785),
      asset: Assets.sportsRehabilitationLogo,
      iconAsset: Assets.sportsRehabilitationIcon,
      left: 148,
      top: 846,
      width: 218,
      headerLeft: 9,
      headerTop: 16,
    ),
  ];

  // 右侧模式卡片数据
  static const List<_ModeCardData> _rightModeCards = [
    // 压力释放
    _ModeCardData(
      titleKey: 'stress_release',
      color: Color(0xFF45CD9F),
      asset: Assets.stressReliefLogo,
      iconAsset: Assets.stressReliefIcon,
      left: 430,
      top: 246,
      width: 220,
      headerLeft: 50,
      headerTop: 19,
    ),
    // 日常活力
    _ModeCardData(
      titleKey: 'immune_boost',
      color: Color(0xFF3DBAFA),
      asset: Assets.immuneBoostLogo,
      iconAsset: Assets.immuneBoostIcon,
      left: 500,
      top: 395,
      width: 200,
      headerLeft: 25,
      headerTop: 18,
    ),
    // 焕采活力
    _ModeCardData(
      titleKey: 'anti_aging',
      color: Color(0xFFF9645C),
      asset: Assets.antiAgingLogo,
      iconAsset: Assets.antiAgingIcon,
      left: 525,
      top: 548,
      width: 217,
      headerLeft: 16,
      headerTop: 18,
    ),
    // 全身换新
    _ModeCardData(
      titleKey: 'full_care',
      color: Color(0xFFE87CF3),
      asset: Assets.fullCareLogo,
      iconAsset: Assets.fullCareIcon,
      left: 498,
      top: 697,
      width: 200,
      headerLeft: 29,
      headerTop: 20,
    ),
    // 情绪疗愈
    _ModeCardData(
      titleKey: 'mental_healing',
      color: Color(0xFFFDBC2A),
      asset: Assets.mentalHealingLogo,
      iconAsset: Assets.emotionalHealingIcon,
      left: 437,
      top: 845,
      width: 220,
      headerLeft: 59,
      headerTop: 17,
    ),
  ];

  ///////////////////////////////////////////////主页面布局////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    final AppLayoutMetrics layout = AppLayoutScope.of(context);
    final double scale = ((MediaQuery.sizeOf(context).width - 32) / 800)
        .clamp(0.72, 1.0)
        .toDouble();

    return AppHeaderPage(
      enableLogout: true,
      enableLogoBack: false,
      children: [
        Positioned.fill(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: SizedBox(
                // 主页面画布宽度
                width: 800 * scale,
                height: layout.mainContentHeight * scale,
                child: FittedBox(
                  // 主页面画布高度
                  fit: BoxFit.contain,
                  // 主页面画布居中对齐
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: 800,
                    height: layout.mainContentHeight,
                    child: _buildMainCanvas(layout),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  ///////////////////////////////////////////////主页面组件构建////////////////////////////////////////////////
  /// 构建主页画布
  Widget _buildMainCanvas(AppLayoutMetrics layout) {
    return Stack(
      //超出内容也显示
      clipBehavior: Clip.none,
      children: [
        _buildTitle(layout),
        _buildBodyStage(layout),
        ..._leftModeCards.map((card) => _buildModeCard(card, layout)),
        ..._rightModeCards.map((card) => _buildModeCard(card, layout)),
        _buildBottomActions(layout),
        Positioned(
          left: 590,
          top: layout.mainContentY(1010),
          child: JoystickControl(
            modbusService: widget.modbusService,
            /* 电流检测暂时停用。
            onLiftCurrentChanged: (value) {
              if (!mounted) return;
              _liftCurrentText.value = value?.toString() ?? '读取失败';
            },
            */
          ),
        ),
        /* 电流显示暂时停用，保留代码方便恢复。
        Positioned(
          left: 250,
          top: layout.mainContentY(190),
          width: 300,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xB3000000),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ValueListenableBuilder<String>(
                valueListenable: _liftCurrentText,
                builder: (context, value, child) => Text(
                  '电流 0x0017：$value',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ),
        */
      ],
    );
  }

  // 构建模式卡片
  Widget _buildModeCard(_ModeCardData item, AppLayoutMetrics layout) {
    return Positioned(
      left: item.left,
      top: layout.mainContentY(item.top),
      child: _ModeCard(item: item, onTap: _logic.openModeDetail),
    );
  }

  /// 构建标题区域
  Widget _buildTitle(AppLayoutMetrics layout) {
    return Positioned(
      top: layout.mainContentY(120),
      left: 0,
      right: 0,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'preset_mode'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 14),
              _buildDeviceStatus(),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'preset_mode_subtitle'.tr,
            style: TextStyle(color: Color(0xFFB9BBC4), fontSize: 16),
          ),
        ],
      ),
    );
  }

  /// 构建设备状态标签(改为动态颜色+文案)
  Widget _buildDeviceStatus() {
    final Color statusColor = _deviceFault
        ? Colors.red
        : Colors.green; //根据状态判断颜色
    final String statusText = _deviceFault
        ? 'device_fault'.tr
        : 'device_ready'.tr; //根据状态判断文案
    //构建设备状态标签底部框
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF37383c),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF37383c)),
      ),
      // 构建设备状态标签内容
      child: Row(
        mainAxisSize: MainAxisSize.min, //主轴方向上，组件只占自己内容需要的大小，不要撑满父组件
        children: [
          Icon(Icons.circle, color: statusColor, size: 9),
          const SizedBox(width: 5),
          Text(statusText, style: TextStyle(color: statusColor, fontSize: 12)),
        ],
      ),
    );
  }

  // Widget _buildDeviceStatus() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  //     decoration: BoxDecoration(
  //       color: const Color(0xFF37383c),
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(color: const Color(0xFF37383c)),
  //     ),
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         const Icon(Icons.circle, color: Color(0xFF35E093), size: 9),
  //         const SizedBox(width: 5),
  //         Text(
  //           'device_ready'.tr,
  //           style: const TextStyle(color: Color(0xFF35E093), fontSize: 12),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  /// 构建中间人体图片
  Widget _buildBodyStage(AppLayoutMetrics layout) {
    return Positioned(
      left: layout.is16x9 ? 98 : 160,
      top: layout.mainContentY(180),
      child: Image.asset(
        Assets.mainBodyLogo,
        width: layout.is16x9 ? 600 : 479,
        height: layout.is16x9 ? 900 : 800,
        fit: BoxFit.contain,
      ),
    );
  }

  /// 构建底部按钮区域
  Widget _buildBottomActions(AppLayoutMetrics layout) {
    return Stack(
      children: [
        Positioned(
          left: 45,
          top: layout.mainContentY(1092),
          child: SizedBox(
            width: 192,
            height: 72,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Material(
                  color: const Color(0xFF1876F2),
                  child: InkWell(
                    enableFeedback: false,
                    onTap: _logic.openCustomizedPage,
                    child: SizedBox(
                      width: 192,
                      height: 56,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'custom_plan'.tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 265,
          top: layout.mainContentY(1092),
          child:
              //检测用户手势操作
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleLight,
                child: SizedBox(
                  width: 64,
                  height: 80,
                  child: Center(
                    child: Image.asset(
                      _isLightOn ? Assets.lightOpenLogo : Assets.lightCloseLogo,
                      width: 56,
                      height: 56,
                    ),
                  ),
                ),
              ),
        ),
      ],
    );
  }

  // ── 氛围灯开关 ──────────────────────────────────────────────────

  void _toggleLight() {
    final bool newState = !_isLightOn;
    setState(() => _isLightOn = newState);

    if (_isLightCommanding) {
      _pendingLightState = newState;
      _hasPendingLight = true;
      return;
    }
    _sendLightCommand(newState);
  }

  Future<void> _sendLightCommand(bool state) async {
    _isLightCommanding = true;
    try {
      await widget.modbusService.sendCommandQueue([
        ModbusWriteCommand(address: 0x0012, value: state ? 1 : 0),
      ]);
      debugPrint(
        'Ambient light ${state ? "ON" : "OFF"} TX 0x0012=${state ? 1 : 0}',
      );
    } catch (e) {
      debugPrint('Ambient light command failed: $e');
    } finally {
      if (mounted) {
        _isLightCommanding = false;
        if (_hasPendingLight) {
          _hasPendingLight = false;
          _sendLightCommand(_pendingLightState);
        }
      }
    }
  }
}

// 模式卡片组件
class _ModeCard extends StatefulWidget {
  const _ModeCard({required this.item, required this.onTap});

  // 卡片数据
  final _ModeCardData item;

  // 点击卡片
  final ValueChanged<String> onTap;

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

// 模式卡片点击状态
class _ModeCardState extends State<_ModeCard> {
  static const Set<String> _raisedTitleLanguageCodes = <String>{
    'zh',
    'ru',
    'ko',
  };

  // 是否按下
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final _ModeCardData item = widget.item;
    final String? languageCode = Get.locale?.languageCode;
    final double titleBottomPadding =
        _raisedTitleLanguageCodes.contains(languageCode) ? 5 : 3;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: () => widget.onTap(item.titleKey),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.82 : 1,
          duration: const Duration(milliseconds: 110),
          child: SizedBox(
            width: item.width,
            height: 110,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(item.asset, fit: BoxFit.fill),
                ),
                Positioned(
                  left: item.headerLeft,
                  top: item.headerTop,
                  right: 12,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Image.asset(item.iconAsset),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: titleBottomPadding),
                          child: Text(
                            item.titleKey.tr,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: item.color,
                              fontSize: 16,
                              fontFamily: 'Microsoft YaHei',
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 模式详情占位页
class ModeDetailPage extends StatelessWidget {
  const ModeDetailPage({super.key, required this.title});

  // 模式标题
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(title),
      ),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// 模式卡片数据
class _ModeCardData {
  const _ModeCardData({
    required this.titleKey,
    required this.color,
    required this.asset,
    required this.iconAsset,
    required this.left,
    required this.top,
    required this.width,
    required this.headerLeft,
    required this.headerTop,
  });

  // 中文标题
  final String titleKey;

  // 中文标题颜色
  final Color color;

  // 卡片底图
  final String asset;

  // 卡片标题图标
  final String iconAsset;

  // 卡片在页面中的横向位置
  final double left;

  // 卡片在页面中的纵向位置
  final double top;

  // 卡片显示宽度
  final double width;

  // 图标与标题行在卡片内部的横向位置
  final double headerLeft;

  // 图标与标题行在卡片内部的纵向位置
  final double headerTop;
}
