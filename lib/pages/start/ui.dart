// 启动理疗页面。
//
// 展示当前阶段、倒计时和设备状态，并协调理疗开始、暂停、恢复和停止动作。
import 'dart:async';
import 'dart:math' as math;
import 'package:infibo_app/api/modbus/modbus_rtu_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/index.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/pages/joystick/ui.dart';
import 'package:infibo_app/pages/music/logic.dart';
import 'package:infibo_app/pages/music/player.dart';
import 'package:infibo_app/pages/start/logic.dart';
import 'package:lottie/lottie.dart';

// 启动理疗页面
class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage>
        //加入一个动画节拍器
        with
        SingleTickerProviderStateMixin {
  //不要重复同步VAT音乐播放状态
  String? _lastVatMusicSongId;
  int? _lastVatMusicVolume;
  bool? _lastVatMusicSingleLoop;
  bool _isSyncingVatMusic = false;
  // 这里使用 AndroidSerialPortService，默认路径为 /dev/ttyS0
  final ModbusRtuService modbusService = const ModbusRtuService();
  static const Duration _phaseSwitchCommandDelay = Duration(milliseconds: 40);
  late final ModbusRtuService _phaseSwitchModbusService = ModbusRtuService(
    portName: modbusService.portName,
    baudRate: modbusService.baudRate,
    slaveId: modbusService.slaveId,
    timeout: modbusService.timeout,
    commandDelay: _phaseSwitchCommandDelay,
    maxRetries: 0,
  );
  // 启动页按 800x1160 的设计稿坐标摆放，再根据屏幕宽度整体缩放
  static const double _designWidth = 800;
  static const double _designHeight = 1160;
  static const double _minPageScale = 0.72;

  // 倒计时素材尺寸
  static const double _timerSize = 250; //倒计时圆的尺寸
  static const double _timerRingSize = 255; //中间的圆环尺寸
  static const double _timerProgressSize = 300; // 进度光圈尺寸
  // 页面逻辑控制器：倒计时、运行、暂停状态、当前工作设备都放在 logic.dart 中
  final StartLogic _logic = StartLogic();

  //用来表示“已经发送一键下降，但还没有收到 0x011 = 0
  bool _isWaitingLiftBottom = false;
  // 控制呼吸动画循环
  late final AnimationController _waitingLiftBreathController;
  // 控制呼吸动画从暗到亮、从亮到暗
  late final Animation<double> _waitingLiftBreathOpacity;

  // 每秒推进一次倒计时
  Timer? _timer;
  final ValueNotifier<int> _timerTick = ValueNotifier<int>(0);
  // 是否正在下发命令
  bool _isCommanding = false;
  int _lastPhaseIndex = 0;
  final Set<String> _runningModules = <String>{};
  // 记录每个模块在上一个已下发节点的“参数签名”，用于快速判断是否有参数变化。
  final Map<String, String> _runningModuleSignatures = <String, String>{};
  // 记录每个模块在上一个已下发节点的“寄存器地址 -> 值”，用于做按地址的增量下发。
  final Map<String, Map<int, int>> _runningModuleParamValues =
      <String, Map<int, int>>{};
  bool _isSwitchingPhase = false;
  bool _isCompletingSession = false;
  bool _isPreloadingPhaseParams = false;
  bool _hasPreloadedPhaseParams = false;
  Future<void>? _preloadPhaseParamsFuture;
  Timer? _hydrogenFlowTimer;
  bool _isReadingHydrogenFlow = false;
  final ValueNotifier<int?> _hydrogenFlowTick = ValueNotifier<int?>(null);
  VatMusicSelection? _vatMusicSelection;

  @override
  void initState() {
    super.initState();
    // 初始化时预加载阶段参数
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadPhaseParamsFuture = _preloadPhaseParamsIfNeeded();
    });
    _logic.configure(Get.arguments);
    _lastPhaseIndex = _logic.activePhaseIndex;
    _startTimer();
    // 初始化呼吸动画
    _waitingLiftBreathController = AnimationController(
      vsync: this,
      // 动画循环(一次由亮到暗的时间)
      duration: const Duration(milliseconds: 1000),
    );
    // 闪烁效果：透明度不会平滑变化，而是在暗和亮之间切换
    _waitingLiftBreathOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(0.15), // 暗
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.75), // 亮
        weight: 1,
      ),
    ]).animate(_waitingLiftBreathController);

    // 循环闪烁
    _waitingLiftBreathController.repeat();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hydrogenFlowTimer?.cancel();
    _timerTick.dispose();
    _hydrogenFlowTick.dispose();
    unawaited(VatMusicPlayer.instance.pause());
    _waitingLiftBreathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 从 Get.arguments 中获取启动参数
    final _StartArguments args = _StartArguments.from(Get.arguments);

    // 页面横向留 32px 安全边距，然后按设计稿宽度等比缩放
    final double scale =
        ((MediaQuery.sizeOf(context).width - 32) / _designWidth)
            .clamp(_minPageScale, 1.0)
            .toDouble();
    return AppHeaderPage(
      enableLogoBack: false,
      children: [
        Positioned.fill(
          top: 75,
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  width: _designWidth * scale,
                  height: _designHeight * scale,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: _designWidth,
                      height: _designHeight,
                      child: _buildCanvas(args),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建启动页主画布
  ///
  /// 这里的 Positioned 的 left/top 都是基于 800x1160 设计稿的固定坐标，
  /// 页面外层会统一缩放，所以调整 UI 位置时只需要改这里的设计稿坐标。
  Widget _buildCanvas(_StartArguments args) {
    // 暂停时所有设备都视为未运行；运行时根据当前 5 分钟阶段点亮对应 icon
    final List<String> activeDevices = _logic.isRunning
        ? _modulesForPhase().toList()
        : const [];

    return Stack(
      children: [
        // 当前理疗模式标题
        Positioned(left: 36, top: 30, child: _buildTitle(args)),

        // 中间人体图，它需要盖住左右功能框的手部边缘，所以放在功能框之前
        Positioned(
          left: 50,
          top: -10,
          child: Image.asset(
            Assets.startBodyLogo,
            width: 700,
            height: 1120,
            fit: BoxFit.contain,
          ),
        ),

        // 左侧红光功能框
        _buildFunctionPanel(
          id: 'red',
          left: 46,
          top: 96,
          width: 280,
          height: 407,
          panelAsset: Assets.startRedLightPanel,
          iconOff: Assets.startRedLightIconOff,
          iconOn: Assets.startRedLightIconOn,
          activeDevices: activeDevices,
        ),

        // 左侧 PEMF 功能框
        _buildFunctionPanel(
          id: 'pemf',
          left: 46,
          top: 525,
          width: 280,
          height: 317,
          panelAsset: Assets.startPemfPanel,
          iconOff: Assets.startPemfIconOff,
          iconOn: Assets.startPemfIconOn,
          activeDevices: activeDevices,
        ),

        // 右侧 VAT 功能框
        _buildFunctionPanel(
          id: 'vat',
          left: 486,
          top: 116,
          width: 269,
          height: 243,
          panelAsset: Assets.startVatPanel,
          iconOff: Assets.startVatIconOff,
          iconOn: Assets.startVatIconOn,
          activeDevices: activeDevices,
        ),

        // 右侧分子氢功能框
        _buildFunctionPanel(
          id: 'hydrogen',
          left: 486,
          top: 379,
          width: 269,
          height: 241,
          panelAsset: Assets.startHydrogenPanel,
          iconOff: Assets.startHydrogenIconOff,
          iconOn: Assets.startHydrogenIconOn,
          activeDevices: activeDevices,
        ),

        // 右侧扩展功能状态框，内部显示脉轮、太赫兹、HIFEM、香氛状态
        _buildFunctionPanel(
          id: 'expand',
          left: 486,
          top: 640,
          width: 269,
          height: 176,
          panelAsset: Assets.startExpandPanel,
          iconOff: Assets.startExpandIconOff,
          iconOn: Assets.startExpandIconOn,
          activeDevices: activeDevices,
        ),

        // 底部倒计时与暂停/启动按钮
        Positioned(
          left: 278,
          top: 850,
          child: ValueListenableBuilder<int>(
            valueListenable: _timerTick,
            builder: (context, _, child) => _buildTimer(),
          ),
        ),
        Positioned(left: 126, top: 995, child: _buildPauseButton()),
        Positioned(left: 508, top: 995, child: _buildPlayButton()),
        Positioned(
          left: 590,
          top: 830,
          child: JoystickControl(modbusService: modbusService),
        ),
      ],
    );
  }

  Widget _buildTitle(_StartArguments args) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          args.modeTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Microsoft YaHei',
          ),
        ),
      ],
    );
  }

  // 构建功能框
  Widget _buildFunctionPanel({
    required String id,
    required double left,
    required double top,
    required double width,
    required double height,
    required String panelAsset,
    required String iconOff,
    required String iconOn,
    required List<String> activeDevices,
  }) {
    final bool isActive = activeDevices.contains(id);

    return Positioned(
      left: left,
      top: top,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            Positioned.fill(child: _buildPanelAsset(panelAsset)),
            ..._buildFunctionPanelEffects(id, isActive, activeDevices),
            if (id == 'red') _buildRedLightPanelInfo(isActive),
            if (id == 'pemf') _buildPemfPanelInfo(isActive),
            if (id == 'vat') _buildVatPanelInfo(isActive),
            if (id == 'hydrogen') _buildHydrogenPanelInfo(isActive),
            if (id != 'expand')
              Positioned(
                right: id == 'red' || id == 'pemf' ? 40 : 18,
                top: 15,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: id == 'vat' ? _openStartVatMusicPage : null,
                  child: Image.asset(isActive ? iconOn : iconOff, width: 43),
                ),
              ),
          ],
        ),
      ),
    );
  }

  //用来加载功能框背景。现在背景如果是 PNG 就走 Image.asset，如果以后你真给某个完整面板换成 JSON，它也能自动走 Lottie.asset
  Widget _buildPanelAsset(String asset) {
    if (asset.toLowerCase().endsWith('.json')) {
      return Lottie.asset(
        asset,
        fit: BoxFit.fill,
        animate: false,
        repeat: false,
      );
    }
    return Image.asset(asset, fit: BoxFit.fill);
  }

  // 用来加载功能框内的效果图。它们有的可能是静态 PNG，有的可能是 Lottie 动画，甚至同一个功能框里两种都有，所以需要区分处理。
  Widget _buildEffectAsset(
    String asset, {
    BoxFit fit = BoxFit.contain,
    bool animate = false,
  }) {
    //增加一个参数，控制是否播放动画
    if (asset.toLowerCase().endsWith('.json')) {
      return RepaintBoundary(
        child: Lottie.asset(
          asset,
          fit: fit,
          animate: animate,
          repeat: animate,
          renderCache: RenderCache.drawingCommands,
        ),
      );
    }
    return Image.asset(asset, fit: fit);
  }

  Widget _buildRedLightPanelInfo(bool isActive) {
    final RedLightPhaseSetting? setting = _logic.activeRedLightSetting;

    final String strength660Text = setting == null
        ? ''
        : setting.strength660.toString();
    final String strength850Text = setting == null
        ? ''
        : setting.strength850.toString();

    final String modeText = setting?.mode == RedLightWorkMode.pulse
        ? 'pulse'.tr
        : 'continuous'.tr;

    final String modeAsset = setting?.mode == RedLightWorkMode.pulse
        ? Assets.maichong
        : Assets.startExpandContinuous;
    //背景板文字位置
    return Positioned(
      //调节红光功能框内文字整体位置
      left: 18,
      top: 22,
      child: IgnorePointer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'red_light'.tr,
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    'wavelength'.tr,
                    style: TextStyle(color: Color(0xffb9bcc6), fontSize: 17),
                  ),
                ),
                SizedBox(width: 20),
                SizedBox(
                  width: 100,
                  child: Text(
                    'intensity'.tr,
                    style: TextStyle(color: Color(0xffb9bcc6), fontSize: 17),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            _buildRedLightInfoRow('660', strength660Text),

            const SizedBox(height: 8),

            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    'wavelength'.tr,
                    style: TextStyle(color: Color(0xffb9bcc6), fontSize: 17),
                  ),
                ),
                SizedBox(width: 20),
                SizedBox(
                  width: 100,
                  child: Text(
                    'intensity'.tr,
                    style: TextStyle(color: Color(0xffb9bcc6), fontSize: 17),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            _buildRedLightInfoRow('850', strength850Text),

            const SizedBox(height: 22),

            if (setting != null)
              Row(
                children: [
                  Text(
                    modeText,
                    style: const TextStyle(
                      color: Color(0xFFE4E7EE),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Image.asset(
                    modeAsset,
                    width: 170,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRedLightInfoRow(String wavelength, String strengthText) {
    return SizedBox(
      width: 215,
      child: Row(
        children: [
          SizedBox(
            width: 105,
            child: Text(
              wavelength,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                height: 1,
              ),
            ),
          ),
          SizedBox(width: 17), // 波长和强度之间的间距(调节长度值)
          Text(
            strengthText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPemfPanelInfo(bool isActive) {
    final PemfPhaseSetting? setting = _logic.activePemfSetting;

    final String frequencyText = setting?.frequency.toString() ?? '';
    final String intensityText = setting?.intensity.toString() ?? '';
    final String waveformAsset = _getWaveformAsset(setting?.waveform ?? '');

    return Positioned(
      //调节 PEMF 功能框内文字整体位置
      left: 18,
      top: 22,
      child: IgnorePointer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PEMF',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    'frequency'.tr,
                    style: TextStyle(color: Color(0xffb9bcc6), fontSize: 17),
                  ),
                ),
                SizedBox(width: 20),
                SizedBox(
                  width: 100,
                  child: Text(
                    'intensity'.tr,
                    style: TextStyle(color: Color(0xffb9bcc6), fontSize: 17),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    frequencyText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 17),
                Text(
                  intensityText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    height: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (waveformAsset.isNotEmpty)
              Row(
                children: [
                  Text(
                    'waveform'.tr,
                    style: const TextStyle(
                      color: Color(0xFFE4E7EE),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 168,
                    child: Image.asset(waveformAsset, fit: BoxFit.contain),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVatPanelInfo(bool isActive) {
    final VatPhaseSetting? setting = _logic.activeVatSetting;

    final String frequencyText = setting?.frequency.toString() ?? '';
    final String intensityText = _currentVatIntensity(setting).toString();

    return Positioned(
      //调节 VAT 功能框内文字整体位置
      left: 40,
      top: 22,
      child: IgnorePointer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'VAT',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    'frequency'.tr,
                    style: TextStyle(color: Color(0xffb9bcc6), fontSize: 17),
                  ),
                ),
                SizedBox(width: 20),
                SizedBox(
                  width: 100,
                  child: Text(
                    'intensity'.tr,
                    style: TextStyle(color: Color(0xffb9bcc6), fontSize: 17),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    frequencyText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 17),
                Text(
                  intensityText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    height: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHydrogenPanelInfo(bool isActive) {
    final HydrogenPhaseSetting? setting = _logic.activeHydrogenSetting;

    final String concentrationText = setting?.concentration.toString() ?? '';
    return Positioned(
      //调节分子氢功能框内文字整体位置
      left: 40,
      top: 22,
      child: IgnorePointer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'hydrogen_molecule'.tr,
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    'hydrogen_concentration'.tr,
                    style: TextStyle(color: Color(0xffb9bcc6), fontSize: 17),
                  ),
                ),
                SizedBox(width: 20),
                SizedBox(
                  width: 100,
                  child: Text(
                    'flow'.tr,
                    style: TextStyle(color: Color(0xffb9bcc6), fontSize: 17),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    concentrationText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 17),
                ValueListenableBuilder<int?>(
                  valueListenable: _hydrogenFlowTick,
                  builder: (context, flowValue, child) {
                    return Text(
                      flowValue == null ? '--' : '$flowValue',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        height: 1,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getWaveformAsset(String waveform) {
    switch (waveform) {
      case 'square':
      case 'burstSquare':
      case 'cubic':
        return Assets.startPemfWaveSquare;
      case 'sine':
        return Assets.startPemfWaveSine;
      case 'triangle':
        return Assets.startPemfWaveTriangle;
      case 'trapezoid':
        return Assets.startPemfWaveTrapezoid;
      case 'saw':
      case 'sawtooth':
        return Assets.startPemfWaveSawtooth;
      case 'halfSine':
        return Assets.startPemfWaveHalfSine;
      case 'pulse':
        return Assets.startPemfWavePulse;
      case 'fastRise':
        return Assets.startPemfWaveFastRise;
      case 'decay':
      case 'standardSine':
      case 'decrease':
        return Assets.startPemfWaveDecay;
      case 'dualFrequency':
      case 'infibo':
        return Assets.startPemfWaveInfibo;
      default:
        return '';
    }
  }

  //***********************************************************************************/
  // 上面是构建功能框的主方法，下面这个方法根据功能框 id 和是否激活来决定要叠加哪些效果图，比如红光的光效、PEMF 的波形图、VAT 的音符图，以及扩展功能的状态列表等。
  // 构建功能框效果图
  List<Widget> _buildFunctionPanelEffects(
    String id,
    bool isActive,
    List<String> activeDevices,
  ) {
    final bool shouldAnimate =
        _logic.isRunning && isActive; //只有在理疗进行中才播放动画效果，暂停时显示静态图
    switch (id) {
      case 'red':
        return [
          Positioned(
            left: 23,
            top: 253,
            child: _buildEffectAsset(
              Assets.startRedLight,
              fit: BoxFit.contain,
              animate: shouldAnimate,
            ),
          ),
        ];
      case 'pemf':
        return [
          Positioned(
            left: 45,
            top: 195,
            child: _buildEffectAsset(
              Assets.startPemf,
              fit: BoxFit.contain,
              animate: shouldAnimate,
            ),
          ),
        ];
      case 'vat':
        return [
          Positioned(
            left: 57,
            top: 151,
            child: _buildEffectAsset(
              Assets.startVat,
              fit: BoxFit.contain,
              animate: shouldAnimate,
            ),
          ),
        ];
      case 'hydrogen':
        return [
          Positioned(
            left: 38,
            top: 140,
            child: _buildEffectAsset(
              Assets.startHydrogen,
              fit: BoxFit.contain,
              animate: shouldAnimate,
            ),
          ),
        ];
      case 'expand':
        return [
          Positioned(
            left: 35,
            top: 20,
            child: _buildExpandStatusList(activeDevices),
          ),
        ];
      default:
        return const [];
    }
  }

  // 构建扩展功能状态列表：未运行显示等待，运行时对应子模块点亮。
  Widget _buildExpandStatusList(List<String> activeDevices) {
    final Set<String> activeSet = activeDevices.toSet();
    final List<_ExpandStatusItem> items = [
      _ExpandStatusItem(
        id: 'chakra',
        label: 'chakra'.tr,
        iconOn: Assets.startExpandIconOn,
        iconOff: Assets.startExpandIconOff,
      ),
      _ExpandStatusItem(
        id: 'terahertz',
        label: 'terahertz'.tr,
        iconOn: Assets.startTerahertzIconOn,
        iconOff: Assets.startTerahertzIconOff,
      ),
      _ExpandStatusItem(
        id: 'hifem',
        label: 'HIFEM',
        iconOn: Assets.startHifemIconOn,
        iconOff: Assets.startHifemIconOff,
      ),
      _ExpandStatusItem(
        id: 'fragrance',
        label: 'fragrance'.tr,
        iconOn: Assets.startFragranceIconOn,
        iconOff: Assets.startFragranceIconOff,
      ),
    ];
    //等待运行
    return SizedBox(
      width: 220,
      child: Column(
        children: [
          for (final _ExpandStatusItem item in items)
            _buildExpandStatusRow(
              item: item,
              running: activeSet.contains(item.id),
            ),
        ],
      ),
    );
  }

  Widget _buildExpandStatusRow({
    required _ExpandStatusItem item,
    required bool running,
  }) {
    final Color textColor = running ? Colors.white : const Color(0xFFB7BBC5);
    final Color statusColor = running
        ? const Color(0xFF31E982)
        : const Color(0xFFC0C4CE);

    return SizedBox(
      height: 34,
      child: Row(
        children: [
          Image.asset(
            running ? item.iconOn : item.iconOff,
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 78,
            child: Text(
              item.label,
              style: TextStyle(
                color: textColor,
                fontSize: 17,
                fontWeight: FontWeight.w400,
                height: 1,
              ),
            ),
          ),
          const Spacer(),
          if (running) ...[
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF31E982),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            running ? 'running'.tr : 'waiting'.tr,
            style: TextStyle(
              color: statusColor,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  // 构建倒计时
  Widget _buildTimer() {
    final List<String> timeParts = _logic.remainingTimeText.split(':');
    final String minuteText = timeParts.isNotEmpty ? timeParts.first : '00';
    final String secondText = timeParts.length > 1 ? timeParts[1] : '00';
    final double elapsedProgress = _logic.progress;
    final double remainingProgress = (1 - elapsedProgress).clamp(0, 1);

    return SizedBox(
      width: _timerSize + 6,
      height: _timerSize + 6,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Image.asset(
            Assets.startTimerRing,
            width: _timerRingSize + 1,
            height: _timerRingSize + 1,
          ),
          OverflowBox(
            minWidth: _timerProgressSize,
            maxWidth: _timerProgressSize,
            minHeight: _timerProgressSize,
            maxHeight: _timerProgressSize,
            child: ClipPath(
              clipper: _CountdownProgressClipper(
                remainingProgress: remainingProgress,
              ),
              child: Image.asset(
                Assets.startTimerProgress,
                width: _timerProgressSize,
                height: _timerProgressSize,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Image.asset(
            Assets.startTimerCenter,
            width: 160,
            height: 160,
            fit: BoxFit.contain,
          ),
          Transform.translate(
            offset: const Offset(0, -8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 54,
                  child: Text(
                    minuteText,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      height: 1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 28),
                SizedBox(
                  width: 54,
                  child: Text(
                    secondText,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      height: 1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPauseButton() {
    final bool isActive = !_isCommanding && _logic.canPause;

    return SizedBox(
      width: 167,
      height: 156,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isActive ? _handlePausePressed : null,
        child: Opacity(
          opacity: isActive ? 1 : 0.45,
          child: Center(
            child: Image.asset(
              isActive
                  ? Assets.startPauseActiveButton
                  : Assets.startPauseButton,
              width: 167,
              height: 156,
            ),
          ),
        ),
      ),
    );
  }

  // 构建启动按钮
  Widget _buildPlayButton() {
    final bool isStopMode = _logic.isRunning;
    final bool isResumeMode = _logic.canResume;
    final bool isStartMode = _logic.canStart;
    final bool isActive =
        !_isCommanding && (isStopMode || isResumeMode || isStartMode);

    if (_isWaitingLiftBottom) {
      return _buildWaitingLiftBottomButton();
    }

    return SizedBox(
      width: 167,
      height: 156,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isActive
            ? isStopMode
                  ? _handleStopPressed
                  : isResumeMode
                  ? _handleResumePressed
                  : _handleStartPressed
            : null,
        child: Opacity(
          opacity: isActive ? 1 : 0.45,
          child: Center(
            child: Image.asset(
              isStopMode
                  ? Assets.waitingStopGlowButton
                  : isActive
                  ? Assets.startPlayActiveButton
                  : Assets.waitingStopGlowButton,
              width: 167,
              height: 156,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWaitingLiftBottomButton() {
    return SizedBox(
      width: 167,
      height: 156,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            FadeTransition(
              opacity: _waitingLiftBreathOpacity,
              child: Image.asset(
                Assets.waitingStopGlowButton,
                width: 167,
                height: 156,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 启动治疗
  // 启动治疗
  Future<void> _handleStartPressed() async {
    if (_isCommanding || !_logic.canStart) return;

    setState(() {
      _isCommanding = true;
      _isWaitingLiftBottom = true;
    });

    _waitingLiftBreathController.repeat(reverse: true);

    try {
      // 1. 先发送升降杆下降
      await _runStartButtonDeviceActions();

      // 2. 等待升降杆到底
      await _waitForLiftReachBottom();

      if (mounted) {
        setState(() => _isWaitingLiftBottom = false);
      }

      _waitingLiftBreathController.stop();
      _waitingLiftBreathController.reset();

      // 3. 关闭氛围灯
      await _turnoffAmbientLight();

      // 4. 构建当前 5 分钟节点的模块命令
      await _waitForPreloadBeforeStart();
      final List<ModbusWriteCommand> commands = _buildPhaseCommands();
      await _prepareVatMusicPlayback();

      // 预设模式不使用预加载。
      // 自定义方案如果已经预加载，则只发 APPLY / COMMAND + 系统启动。
      final bool usePreloadedParams = _hasPreloadedPhaseParams;

      if (usePreloadedParams) {
        final List<ModbusWriteCommand> startCommands = <ModbusWriteCommand>[
          ..._onlyApplyAndCommand(commands),
          const ModbusWriteCommand(
            address: ModbusRtuService.systemCommandAddress,
            value: 1,
          ),
        ];

        await modbusService.sendCommandQueue(startCommands);
      } else {
        // 预设模式走这里：完整下发参数 + APPLY + COMMAND + 0x0004
        throw StateError('Phase parameter preload is not complete.');
      }

      if (!mounted) return;

      setState(() {
        _logic.play();
        _runningModules.addAll(_modulesForPhase());
        _runningModuleSignatures
          ..clear()
          ..addAll(_currentModuleSignatures(_runningModules));
        _runningModuleParamValues
          ..clear()
          ..addAll(_currentModuleParamValues(_runningModules));

        // 启动命令已经发完，这里先恢复状态。
        _isCommanding = false;
      });

      // 5. 启动成功后，再开始氢气流量轮询和软件音乐播放
      _syncHydrogenFlowPolling();
      unawaited(_syncVatMusicPlayback());

      debugPrint('start command sent successfully');
    } catch (e) {
      debugPrint('start command failed: $e');
      if (!mounted) return;
      _showError('${'error_send_params_failed'.tr}$e');
    } finally {
      _waitingLiftBreathController.stop();
      _waitingLiftBreathController.reset();

      if (mounted) {
        setState(() {
          _isCommanding = false;
          _isWaitingLiftBottom = false;
        });
      }
    }
  }

  // 等待升降杆到达底部
  Future<void> _waitForLiftReachBottom() async {
    const Duration pollInterval = Duration(milliseconds: 500);
    while (mounted) {
      final int liftStatus = await modbusService.readHoldingRegister(0x0011);
      debugPrint('start button wait lift status RX 0x0011=$liftStatus');
      if (liftStatus == 0) {
        debugPrint('start button lift reached bottom, continue start flow');
        return;
      }
      await Future<void>.delayed(pollInterval);
    }
  }

  // 关闭氛围灯
  Future<void> _turnoffAmbientLight() async {
    try {
      // 读取氛围灯状态
      final int ambientLightState = await modbusService.readHoldingRegister(
        0x0012,
      );
      // 如果氛围灯是开启状态，才关闭
      if (ambientLightState == 1) {
        await modbusService.sendCommandQueue([
          const ModbusWriteCommand(address: 0x0012, value: 0),
        ]);
        debugPrint('start button auto-off ambient light TX 0x0012=0');
      }
    } catch (e) {
      debugPrint('start button read/close ambient light skipped: $e');
    }
  }

  Future<void> _runStartButtonDeviceActions() async {
    // 下发参数
    await modbusService.sendCommandQueue([
      const ModbusWriteCommand(address: 0x0010, value: 4),
    ]);
    JoystickCommandBus.instance.lockLeftBottom();
    // 关闭氛围灯
    // try {
    //   final int ambientLightState = await modbusService.readHoldingRegister(
    //     0x0012,
    //   );
    //   if (ambientLightState == 1) {
    //     await modbusService.sendCommandQueue([
    //       const ModbusWriteCommand(address: 0x0012, value: 0),
    //     ]);
    //     debugPrint('start button auto-off ambient light TX 0x0012=0');
    //   }
    // } catch (e) {
    //   debugPrint('start button read/close ambient light skipped: $e');
    // }
  }

  // 预加载参数
  Future<void> _preloadPhaseParamsIfNeeded({
    bool allowWhileCommanding = false,
  }) async {
    if (!_logic.isCustomizedPlan) return;

    //预设模式下，不预加载参数，点击启动按钮，完整下发参数
    if (_logic.isRunning) return;
    if ((!allowWhileCommanding && _isCommanding) || _isSwitchingPhase) return;
    if (_isPreloadingPhaseParams || _hasPreloadedPhaseParams) return;

    _isPreloadingPhaseParams = true;
    try {
      final List<ModbusWriteCommand> preloadCommands = _withoutApplyAndCommand(
        _buildPhaseCommands(),
      );
      if (preloadCommands.isNotEmpty) {
        debugPrint(
          'preload phase params without apply/command by 0x10: ${preloadCommands.length} commands',
        );
        await _sendPreloadCommandsByFunction10(preloadCommands);
      }
      _hasPreloadedPhaseParams = true;
      debugPrint('preload phase params complete');
    } catch (e) {
      _hasPreloadedPhaseParams = false;
      debugPrint('preload phase params failed: $e');
      if (mounted) {
        _showError('${'error_send_params_failed'.tr}$e');
      }
    } finally {
      _isPreloadingPhaseParams = false;
    }
  }

  Future<void> _waitForPreloadBeforeStart() async {
    if (!_logic.isCustomizedPlan) return;

    final Future<void>? pendingPreload = _preloadPhaseParamsFuture;
    if (pendingPreload != null) {
      await pendingPreload;
    }

    if (_hasPreloadedPhaseParams) return;

    _preloadPhaseParamsFuture = _preloadPhaseParamsIfNeeded(
      allowWhileCommanding: true,
    );
    await _preloadPhaseParamsFuture;
  }

  // 发送预加载命令
  Future<void> _sendPreloadCommandsByFunction10(
    List<ModbusWriteCommand> commands,
  ) async {
    final List<_PreloadCommandBatch> batches = _buildPreloadCommandBatches(
      commands,
    );
    for (final _PreloadCommandBatch batch in batches) {
      await modbusService.writeMultipleRegisters(
        startAddress: batch.startAddress,
        values: batch.values,
        logTag: 'StartPreload',
      );
    }
  }

  // 构建预加载命令批次
  List<_PreloadCommandBatch> _buildPreloadCommandBatches(
    List<ModbusWriteCommand> commands,
  ) {
    final List<_PreloadCommandBatch> batches = <_PreloadCommandBatch>[];
    final List<ModbusWriteCommand> current = <ModbusWriteCommand>[];

    void flushCurrent() {
      if (current.isEmpty) return;
      batches.add(
        _PreloadCommandBatch(
          startAddress: current.first.address,
          values: [
            for (final ModbusWriteCommand command in current) command.value,
          ],
        ),
      );
      current.clear();
    }

    for (final ModbusWriteCommand command in commands) {
      if (current.isEmpty) {
        current.add(command);
        continue;
      }

      if (command.address == current.last.address + 1) {
        current.add(command);
        continue;
      }

      flushCurrent();
      current.add(command);
    }

    flushCurrent();
    return batches;
  }

  // 暂停治疗
  Future<void> _handlePausePressed() async {
    if (_isCommanding || !_logic.canPause) return;

    setState(() => _isCommanding = true);
    try {
      await modbusService.pauseTherapy(
        pauseRed: _runningModules.contains('red'),
        pauseVat: _runningModules.contains('vat'),
        pausePemf: _runningModules.contains('pemf'),
        pauseHydrogen: _runningModules.contains('hydrogen'),
        pauseChakra: _runningModules.contains('chakra'),
        pauseTerahertz: _runningModules.contains('terahertz'),
        pauseHifem: _runningModules.contains('hifem'),
        pauseFragrance: _runningModules.contains('fragrance'),
      );
      if (!mounted) return;
      setState(() {
        _logic.pause();
        _stopHydrogenFlowPolling(clearValue: false);
      });
      unawaited(VatMusicPlayer.instance.pause());
      debugPrint('pause command sent successfully');
    } catch (e) {
      debugPrint('pause command failed: $e');
      if (!mounted) return;
      _showError('${'error_pause_failed'.tr}$e');
    } finally {
      if (mounted) setState(() => _isCommanding = false);
    }
  }

  Future<void> _handleResumePressed() async {
    if (_isCommanding || !_logic.canResume) return;

    setState(() => _isCommanding = true);
    try {
      await modbusService.resumeTherapy(
        resumeRed: _runningModules.contains('red'),
        resumeVat: _runningModules.contains('vat'),
        resumePemf: _runningModules.contains('pemf'),
        resumeHydrogen: _runningModules.contains('hydrogen'),
        resumeChakra: _runningModules.contains('chakra'),
        resumeTerahertz: _runningModules.contains('terahertz'),
        resumeHifem: _runningModules.contains('hifem'),
        resumeFragrance: _runningModules.contains('fragrance'),
      );
      if (!mounted) return;
      setState(() {
        _logic.play();
      });
      _syncHydrogenFlowPolling();
      unawaited(_syncVatMusicPlayback());
      debugPrint('resume command sent successfully');
    } catch (e) {
      debugPrint('resume command failed: $e');
      if (!mounted) return;
      _showError('${'error_resume_failed'.tr}$e');
    } finally {
      if (mounted) setState(() => _isCommanding = false);
    }
  }

  Future<void> _handleStopPressed() async {
    if (_isCommanding || !_logic.canStop) return;

    final _StartArguments args = _StartArguments.from(Get.arguments);
    setState(() => _isCommanding = true);
    try {
      await modbusService.stopTherapy(
        stopRed: _runningModules.contains('red'),
        stopVat: _runningModules.contains('vat'),
        stopPemf: _runningModules.contains('pemf'),
        stopHydrogen: _runningModules.contains('hydrogen'),
        stopChakra: _runningModules.contains('chakra'),
        stopTerahertz: _runningModules.contains('terahertz'),
        stopHifem: _runningModules.contains('hifem'),
        stopFragrance: _runningModules.contains('fragrance'),
      );
      await _runStopButtonDeviceActions();
      if (!mounted) return;
      setState(() {
        _logic.stop();
        _runningModules.clear();
        _runningModuleSignatures.clear();
        _runningModuleParamValues.clear();
        _stopHydrogenFlowPolling(clearValue: true);
      });
      unawaited(VatMusicPlayer.instance.stop());
      _openSummaryPage(args);
    } catch (e) {
      debugPrint('stop command failed: $e');
      if (!mounted) return;
      _showError('${'error_stop_failed'.tr}$e');
    } finally {
      if (mounted) setState(() => _isCommanding = false);
    }
  }

  Future<void> _runStopButtonDeviceActions() async {
    try {
      await modbusService.sendCommandQueue([
        const ModbusWriteCommand(address: 0x0010, value: 3),
      ]);
      JoystickCommandBus.instance.lockLeftTop();
    } catch (e) {
      debugPrint('stop button one-key-up failed: $e');
    }

    try {
      await modbusService.sendCommandQueue([
        const ModbusWriteCommand(address: 0x0012, value: 1),
      ]);
      debugPrint('stop button auto-on ambient light TX 0x0012=1');
    } catch (e) {
      debugPrint('stop button auto-on ambient light failed: $e');
    }
  }

  /// 构建当前阶段的所有模块参数命令列表，包含红光/PEMF/HYDROGEN/VAT。
  List<ModbusWriteCommand> _buildPhaseCommands({
    Set<String>? moduleFilter,
    bool includeStartCommands = true,
  }) {
    final _StartArguments args = _StartArguments.from(Get.arguments);
    final List<ModbusWriteCommand> commands = <ModbusWriteCommand>[];

    if (!_logic.isCustomizedPlan) return commands;

    final List<String> activeDevices = _logic.activeDevices(args.modeTitle);
    bool shouldBuild(String module) {
      return moduleFilter == null || moduleFilter.contains(module);
    }

    void addModuleCommands(
      String module,
      List<ModbusWriteCommand> moduleCommands,
    ) {
      commands.addAll(
        includeStartCommands
            ? moduleCommands
            : _withoutModuleStartCommand(module, moduleCommands),
      );
    }

    // 红光
    if (activeDevices.contains('red') && shouldBuild('red')) {
      final RedLightPhaseSetting? setting = _logic.activeRedLightSetting;
      if (setting != null) {
        addModuleCommands(
          'red',
          modbusService.buildRedLightCommands(
            strength660: setting.strength660,
            strength850: setting.strength850,
            mode: setting.modbusMode,
            pulseFrequencyHz: setting.pulseFrequencyHz,
            dutyCyclePercent: setting.dutyCyclePercent,
          ),
        );
      }
    }

    // PEMF
    debugPrint('active features = $activeDevices');
    debugPrint('PEMF hasPemf=${activeDevices.contains('pemf')}');
    if (activeDevices.contains('pemf') && shouldBuild('pemf')) {
      final PemfPhaseSetting? setting = _logic.activePemfSetting;
      if (setting != null) {
        final int waveformNum = setting.waveformNumber;
        debugPrint(
          'PEMF build V2.0: 0x00C0 + 0x10(0x00C3~0x00C9) + 0x00D0 + 0x00D1',
        );
        addModuleCommands(
          'pemf',
          modbusService.buildPemfCommands(
            frequencyHz: setting.frequency,
            intensity: setting.intensity,
            waveform: waveformNum,
            burstFrequencyHz: setting.burstFrequencyHz,
          ),
        );
      }
    }

    // 分子氢
    final bool hasHydrogen = activeDevices.contains('hydrogen');
    debugPrint('Hydrogen hasHydrogen=$hasHydrogen');
    if (hasHydrogen && shouldBuild('hydrogen')) {
      final HydrogenPhaseSetting? setting = _logic.activeHydrogenSetting;
      if (setting != null) {
        final List<ModbusWriteCommand> hydrogenCommands = modbusService
            .buildHydrogenCommands(concentration: setting.concentration);
        addModuleCommands('hydrogen', hydrogenCommands);
        debugPrint('Hydrogen flow polling start');
      }
    } else {
      debugPrint(
        'skip hydrogen commands and flow polling because current phase has no hydrogen',
      );
    }

    // VAT
    if (activeDevices.contains('vat') && shouldBuild('vat')) {
      final VatPhaseSetting? setting = _logic.activeVatSetting;
      if (setting != null) {
        final int musicIndex = _resolveVatMusicIndex(setting);
        final int runtimeIntensity = _currentVatIntensity(setting);
        final List<ModbusWriteCommand> vatCommands = modbusService
            .buildVatCommands(
              frequency: setting.frequency,
              intensity: _logic.isPresetPlan
                  ? setting.intensity
                  : runtimeIntensity,
              volume: _logic.isPresetPlan ? setting.volume : runtimeIntensity,
              musicIndex: musicIndex,
            );
        addModuleCommands('vat', vatCommands);
      }
    }

    // 脉轮（拓展功能子模块）
    final ChakraPhaseSetting? chakraSetting = _logic.activeChakraSetting;
    if (activeDevices.contains('expand') &&
        shouldBuild('chakra') &&
        chakraSetting != null &&
        chakraSetting.hasStrengths) {
      addModuleCommands(
        'chakra',
        modbusService.buildChakraCommands(
          strengths: chakraSetting.strengths,
          mode: chakraSetting.modbusMode,
        ),
      );
    }

    // 太赫兹（拓展功能子模块）
    final TerahertzPhaseSetting? terahertzSetting =
        _logic.activeTerahertzSetting;
    if (activeDevices.contains('expand') &&
        shouldBuild('terahertz') &&
        terahertzSetting != null) {
      addModuleCommands(
        'terahertz',
        modbusService.buildTerahertzCommands(
          frequency: terahertzSetting.frequency,
          power: terahertzSetting.power,
          mode: terahertzSetting.modbusMode,
          wave: terahertzSetting.modbusWave,
        ),
      );
    }

    // HIFEM（拓展功能子模块）
    final HifemPhaseSetting? hifemSetting = _logic.activeHifemSetting;
    if (activeDevices.contains('expand') &&
        shouldBuild('hifem') &&
        hifemSetting != null &&
        hifemSetting.hasOutput) {
      addModuleCommands(
        'hifem',
        modbusService.buildHifemCommands(
          foreheadRf: hifemSetting.foreheadRf,
          foreheadHifes: hifemSetting.foreheadHifes,
          leftCheekRf: hifemSetting.leftCheekRf,
          leftCheekHifes: hifemSetting.leftCheekHifes,
          rightCheekRf: hifemSetting.rightCheekRf,
          rightCheekHifes: hifemSetting.rightCheekHifes,
        ),
      );
    }

    // 香氛（拓展功能子模块）
    final FragrancePhaseSetting? fragranceSetting =
        _logic.activeFragranceSetting;
    if (activeDevices.contains('expand') &&
        shouldBuild('fragrance') &&
        fragranceSetting != null) {
      addModuleCommands(
        'fragrance',
        modbusService.buildFragranceCommands(type: fragranceSetting.modbusType),
      );
    }

    return commands;
  }

  List<ModbusWriteCommand> _withoutModuleStartCommand(
    String module,
    List<ModbusWriteCommand> commands,
  ) {
    // 模块处于 modulesToKeep 时，启动类/使能类指令应被过滤，只保留参数更新指令。
    final Set<int> excludedAddresses = _moduleKeepExcludedAddresses(module);
    if (excludedAddresses.isEmpty) return commands;

    return commands.where((command) {
      return !excludedAddresses.contains(command.address);
    }).toList();
  }

  Set<int> _moduleKeepExcludedAddresses(String module) {
    // keep 状态下要排除：启动 command + 该模块使能寄存器。
    if (module == 'red') {
      return const <int>{
        ModbusRtuService.redLightApplyAddress,
        ModbusRtuService.redLightTotalCommandAddress,
      };
    }
    if (module == 'chakra') {
      return const <int>{
        ModbusRtuService.chakraEnableAddress,
        ModbusRtuService.chakraApplyAddress,
        ModbusRtuService.chakraCommandAddress,
      };
    }
    if (module == 'terahertz') {
      return const <int>{
        ModbusRtuService.terahertzEnableAddress,
        ModbusRtuService.terahertzApplyAddress,
        ModbusRtuService.terahertzCommandAddress,
      };
    }
    if (module == 'fragrance') {
      return const <int>{
        ModbusRtuService.fragranceEnableAddress,
        ModbusRtuService.fragranceApplyAddress,
        ModbusRtuService.fragranceCommandAddress,
      };
    }
    if (module == 'hifem') {
      return const <int>{
        ModbusRtuService.hifemEnableAddress,
        ModbusRtuService.hifemApplyAddress,
        ModbusRtuService.hifemCommandAddress,
      };
    }
    final int? commandAddress = _moduleStartCommandAddress(module);
    return <int>{?commandAddress, ..._moduleEnableAddresses(module)};
  }

  Set<int> _moduleEnableAddresses(String module) {
    // 这些地址在模块保持运行时不应重复写 1。
    switch (module) {
      case 'red':
        return const <int>{
          ModbusRtuService.redLightTotalEnableAddress,
          ModbusRtuService.redLight660EnableAddress,
          ModbusRtuService.redLight850EnableAddress,
        };
      case 'pemf':
        return const <int>{ModbusRtuService.pemfTotalEnableAddress};
      case 'hydrogen':
        return const <int>{ModbusRtuService.hydrogenEnableAddress};
      case 'vat':
        return const <int>{ModbusRtuService.vatEnableAddress};
      case 'chakra':
        return const <int>{ModbusRtuService.chakraEnableAddress};
      case 'terahertz':
        return const <int>{ModbusRtuService.terahertzEnableAddress};
      case 'hifem':
        return const <int>{ModbusRtuService.hifemEnableAddress};
      case 'fragrance':
        return const <int>{ModbusRtuService.fragranceEnableAddress};
      default:
        return const <int>{};
    }
  }

  int? _moduleStartCommandAddress(String module) {
    switch (module) {
      case 'red':
        return ModbusRtuService.redLightTotalCommandAddress;
      case 'pemf':
        return ModbusRtuService.pemfTotalCommandAddress;
      case 'hydrogen':
        return ModbusRtuService.hydrogenCommandAddress;
      case 'vat':
        return ModbusRtuService.vatCommandAddress;
      case 'chakra':
        return ModbusRtuService.chakraCommandAddress;
      case 'terahertz':
        return ModbusRtuService.terahertzCommandAddress;
      case 'hifem':
        return ModbusRtuService.hifemCommandAddress;
      case 'fragrance':
        return ModbusRtuService.fragranceCommandAddress;
      default:
        return null;
    }
  }

  bool _isApplyOrCommandAddress(int address) {
    switch (address) {
      case ModbusRtuService.redLightApplyAddress:
      case ModbusRtuService.redLightTotalCommandAddress:
      case ModbusRtuService.pemfApplyAddress:
      case ModbusRtuService.pemfTotalCommandAddress:
      case ModbusRtuService.vatApplyAddress:
      case ModbusRtuService.vatCommandAddress:
      case ModbusRtuService.hydrogenApplyAddress:
      case ModbusRtuService.hydrogenCommandAddress:
      case ModbusRtuService.chakraApplyAddress:
      case ModbusRtuService.chakraCommandAddress:
      case ModbusRtuService.terahertzApplyAddress:
      case ModbusRtuService.terahertzCommandAddress:
      case ModbusRtuService.hifemApplyAddress:
      case ModbusRtuService.hifemCommandAddress:
      case ModbusRtuService.fragranceApplyAddress:
      case ModbusRtuService.fragranceCommandAddress:
        return true;
      default:
        return false;
    }
  }

  List<ModbusWriteCommand> _withoutApplyAndCommand(
    List<ModbusWriteCommand> commands,
  ) {
    return commands
        .where((command) => !_isApplyOrCommandAddress(command.address))
        .toList();
  }

  List<ModbusWriteCommand> _onlyApplyAndCommand(
    List<ModbusWriteCommand> commands,
  ) {
    return commands
        .where((command) => _isApplyOrCommandAddress(command.address))
        .toList();
  }

  Map<String, String> _currentModuleSignatures(Set<String> modules) {
    return <String, String>{
      for (final String module in modules)
        if (_moduleSignature(module) != null) module: _moduleSignature(module)!,
    };
  }

  Map<String, Map<int, int>> _currentModuleParamValues(Set<String> modules) {
    // 提取当前节点每个模块的“参数寄存器快照”（已去除启动/使能类指令）。
    return <String, Map<int, int>>{
      for (final String module in modules)
        module: {
          for (final ModbusWriteCommand command in _buildPhaseCommands(
            moduleFilter: <String>{module},
            includeStartCommands: false,
          ))
            command.address: command.value,
        },
    };
  }

  List<ModbusWriteCommand> _buildChangedModuleParamCommands(
    Set<String> modules, {
    required Map<String, Map<int, int>> currentParamValues,
  }) {
    final List<ModbusWriteCommand> commands = <ModbusWriteCommand>[];

    for (final String module in modules) {
      final Map<int, int> previousValues =
          _runningModuleParamValues[module] ?? const <int, int>{};
      final Map<int, int> currentValues =
          currentParamValues[module] ?? const <int, int>{};
      final List<int> sortedAddresses = currentValues.keys.toList()..sort();

      int changedCount = 0;
      for (final int address in sortedAddresses) {
        final int value = currentValues[address]!;
        if (previousValues[address] == value) continue;

        commands.add(ModbusWriteCommand(address: address, value: value));
        changedCount++;
      }
      debugPrint('phase switch diff $module: changed=$changedCount');
    }

    return commands;
  }

  String? _moduleSignature(String module) {
    switch (module) {
      case 'red':
        final RedLightPhaseSetting? setting = _logic.activeRedLightSetting;
        if (setting == null) return null;
        return '${setting.strength660}|${setting.strength850}|${setting.modbusMode}';
      case 'pemf':
        final PemfPhaseSetting? setting = _logic.activePemfSetting;
        if (setting == null) return null;
        return '${setting.frequency}|${setting.intensity}|${setting.waveformNumber}';
      case 'hydrogen':
        final HydrogenPhaseSetting? setting = _logic.activeHydrogenSetting;
        if (setting == null) return null;
        return '${setting.concentration}|${setting.flowRate}';
      case 'vat':
        final VatPhaseSetting? setting = _logic.activeVatSetting;
        if (setting == null) return null;
        return '${setting.frequency}|${_currentVatIntensity(setting)}|${_resolveVatMusicIndex(setting)}';
      case 'chakra':
        final ChakraPhaseSetting? setting = _logic.activeChakraSetting;
        if (setting == null) return null;
        final List<String> keys = setting.strengths.keys.toList()..sort();
        return [
          'mode=${setting.modbusMode}',
          ...keys.map((key) => '$key=${setting.strengths[key]}'),
        ].join('|');
      case 'terahertz':
        final TerahertzPhaseSetting? setting = _logic.activeTerahertzSetting;
        if (setting == null) return null;
        return '${setting.frequency}|${setting.power}|${setting.modbusMode}|${setting.modbusWave}';
      case 'hifem':
        final HifemPhaseSetting? setting = _logic.activeHifemSetting;
        if (setting == null) return null;
        return '${setting.foreheadRf}|${setting.foreheadHifes}|${setting.leftCheekRf}|${setting.leftCheekHifes}|${setting.rightCheekRf}|${setting.rightCheekHifes}';
      case 'fragrance':
        final FragrancePhaseSetting? setting = _logic.activeFragranceSetting;
        if (setting == null) return null;
        return '${setting.modbusType}';
      default:
        return null;
    }
  }

  int _resolveVatMusicIndex(VatPhaseSetting? planSetting) {
    final VatMusicSelection? runtimeSelection = _vatMusicSelection;
    if (runtimeSelection != null) {
      final int idx = allSongs.indexWhere(
        (s) => s.id == runtimeSelection.songId,
      );
      return idx >= 0 ? idx : 0;
    }
    final int? presetMusicIndex = planSetting?.musicIndex;
    if (presetMusicIndex != null) return presetMusicIndex;
    if (planSetting?.songId != null) {
      final int idx = allSongs.indexWhere((s) => s.id == planSetting!.songId);
      return idx >= 0 ? idx : 0;
    }
    return 0;
  }

  //获取当前播放的乐曲Id号
  String _currentVatMusicSongId(VatPhaseSetting? setting) {
    //如果当前有选中的歌曲，就返回选中歌曲的Id号
    final String? runtimeSongId = _vatMusicSelection?.songId;
    //如果当前没有选中的歌曲，就返回默认的歌曲Id号
    if (runtimeSongId != null && runtimeSongId.isNotEmpty) {
      return runtimeSongId;
    }
    //如果当前没有选中的歌曲，就返回默认的歌曲Id号
    final String? planSongId = setting?.songId;
    if (planSongId != null && planSongId.isNotEmpty) {
      final int? trackNumber = int.tryParse(planSongId);

      //因为预设的歌曲Id号是数字
      //软件音乐列表allSongs从0开始，所以需要减1
      if (trackNumber != null && allSongs.isNotEmpty) {
        final int index = (trackNumber - 1)
            .clamp(0, allSongs.length - 1)
            .toInt();
        return allSongs[index].id;
      }
      return planSongId;
    }
    return defaultSongId;
  }

  int _currentVatIntensity(VatPhaseSetting? setting) {
    final int? runtimeIntensity = int.tryParse(
      _vatMusicSelection?.intensity ?? '',
    );
    return runtimeIntensity ??
        setting?.intensity ??
        VatMusicPlayer.instance.volume;
  }

  /***歌曲没变 → 不重新播放
    *******音量没变 → 不重复设置
        *********循环模式没变 → 不重复设置**********/
  /// 同步 VAT 音乐播放。预设模式单曲循环
  Future<void> _syncVatMusicPlayback() async {
    //如果当前正在同步VAT音乐播放状态，就直接返回
    if (_isSyncingVatMusic) return;

    //如果当前没有启用VAT模块，就直接返回
    final Set<String> modules = _modulesForPhase();
    final VatPhaseSetting? setting = _logic.activeVatSetting;

    //如果当前没有选中的歌曲，就直接返回
    final bool shouldPlayVat =
        _logic.isRunning && modules.contains('vat') && setting != null;

    if (!shouldPlayVat) {
      _lastVatMusicSongId = null;
      _lastVatMusicVolume = null;
      _lastVatMusicSingleLoop = null;
      await VatMusicPlayer.instance.pause();
      return;
    }

    final String songId = _currentVatMusicSongId(setting);
    final int volume = _currentVatIntensity(setting).clamp(0, 100).toInt();
    final bool singleLoop = _logic.isPresetPlan;

    final bool songChanged = _lastVatMusicSongId != songId;
    final bool volumeChanged = _lastVatMusicVolume != volume;
    final bool loopChanged = _lastVatMusicSingleLoop != singleLoop;

    // 歌曲没变、循环模式没变、正在播放时，不要反复 applySelection。
    if (!songChanged && !loopChanged && VatMusicPlayer.instance.isPlaying) {
      if (volumeChanged) {
        _lastVatMusicVolume = volume;
        await VatMusicPlayer.instance.setVolume(volume);
      }
      return;
    }

    _isSyncingVatMusic = true;
    try {
      await VatMusicPlayer.instance.applySelection(
        songId,
        volume: volume,
        playNow: true,
        restart: songChanged,
        singleLoop: singleLoop,
      );

      _lastVatMusicSongId = songId;
      _lastVatMusicVolume = volume;
      _lastVatMusicSingleLoop = singleLoop;
    } finally {
      _isSyncingVatMusic = false;
    }
  }

  /// 获取当前阶段启用的模块列表。
  Future<void> _prepareVatMusicPlayback() async {
    final Set<String> modules = _modulesForPhase();
    final VatPhaseSetting? setting = _logic.activeVatSetting;
    if (!modules.contains('vat') || setting == null) return;

    final String songId = _currentVatMusicSongId(setting);
    final int volume = _currentVatIntensity(setting).clamp(0, 100).toInt();
    final bool singleLoop = _logic.isPresetPlan;

    try {
      await VatMusicPlayer.instance.prepareForVatPhase(
        songId,
        volume: volume,
        singleLoop: singleLoop,
      );
      _lastVatMusicSongId = songId;
      _lastVatMusicVolume = volume;
      _lastVatMusicSingleLoop = singleLoop;
    } catch (e) {
      debugPrint('VAT music preload failed: $e');
    }
  }

  Set<String> _modulesForPhase() {
    final _StartArguments args = _StartArguments.from(Get.arguments);
    final Set<String> modules = _logic.activeDevices(args.modeTitle).toSet();
    final ChakraPhaseSetting? chakraSetting = _logic.activeChakraSetting;
    if (modules.contains('expand') &&
        chakraSetting != null &&
        chakraSetting.hasStrengths) {
      modules.add('chakra');
    }
    final TerahertzPhaseSetting? terahertzSetting =
        _logic.activeTerahertzSetting;
    if (modules.contains('expand') && terahertzSetting != null) {
      modules.add('terahertz');
    }
    final HifemPhaseSetting? hifemSetting = _logic.activeHifemSetting;
    if (modules.contains('expand') &&
        hifemSetting != null &&
        hifemSetting.hasOutput) {
      modules.add('hifem');
    }
    final FragrancePhaseSetting? fragranceSetting =
        _logic.activeFragranceSetting;
    if (modules.contains('expand') && fragranceSetting != null) {
      modules.add('fragrance');
    }
    return modules;
  }

  /// 打开 VAT 音乐选择页面。
  Future<void> _openStartVatMusicPage() async {
    final VatPhaseSetting? setting = _logic.activeVatSetting;
    final VatMusicSelection? current = _vatMusicSelection;

    final String currentSongId =
        current?.songId ?? _currentVatMusicSongId(setting);

    final Object? result = await Get.toNamed(
      '/music',
      arguments: {
        'fromPage': 'start',
        'currentSelectedSongId': currentSongId,
        'currentVatFrequency': setting?.frequency.toString() ?? '',
        'currentVatStrength': _currentVatIntensity(setting).toString(),
        'phaseIndex': _logic.activePhaseIndex,
      },
    );

    if (!mounted) return;
    if (result is! VatMusicSelection) return;

    setState(() {
      _vatMusicSelection = result;
      if (!_logic.isRunning) {
        _hasPreloadedPhaseParams = false;
      }
    });

    final bool isVatRunning =
        _logic.isRunning && _runningModules.contains('vat');
    await VatMusicPlayer.instance.applySelection(
      result.songId,
      volume: int.tryParse(result.intensity) ?? VatMusicPlayer.instance.volume,
      playNow: isVatRunning,
      restart: true,
      singleLoop: _logic.isPresetPlan,
    );
    if (isVatRunning) {
      final Map<String, Map<int, int>> currentParamValues =
          _currentModuleParamValues(<String>{'vat'});
      final List<ModbusWriteCommand> commands =
          _buildChangedModuleParamCommands(<String>{
            'vat',
          }, currentParamValues: currentParamValues);
      try {
        if (commands.isNotEmpty) {
          await modbusService.sendCommandQueue(commands);
        }
        final Map<String, String> signatures = _currentModuleSignatures(
          <String>{'vat'},
        );
        setState(() {
          if (signatures['vat'] != null) {
            _runningModuleSignatures['vat'] = signatures['vat']!;
          }
          if (currentParamValues['vat'] != null) {
            _runningModuleParamValues['vat'] = currentParamValues['vat']!;
          }
        });
      } catch (e) {
        debugPrint('VAT runtime music or intensity change failed: $e');
      }
    } else {
      _preloadPhaseParamsFuture = _preloadPhaseParamsIfNeeded();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openSummaryPage(_StartArguments args) {
    final Map<String, int> moduleSeconds = _logic.actualWorkSecondsByDevice(
      args.modeTitle,
    );

    // 停止按钮或理疗自动结束后，不再弹总结框，直接进入总结页面。
    Get.offNamed(
      '/summary',
      arguments: {
        'clientId': args.clientId,
        'userName': args.userName,
        'moduleSeconds': moduleSeconds,
        'planName': args.modeTitle,
        'planType': 'preset',
        'durationSeconds': _logic.elapsedSeconds,
        'isOfflineMode': args.isOfflineMode,
      },
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_logic.isRunning) return;
      if (!mounted) return;
      _logic.tick();
      _timerTick.value++;
      _trySwitchPhase();
    });
  }

  /// 检测阶段切换，并下发新阶段参数。
  void _trySwitchPhase() {
    if (_isSwitchingPhase || _isCompletingSession) return;

    final int currentIndex = _logic.activePhaseIndex;
    if (currentIndex == _lastPhaseIndex && _logic.isRunning) return;

    if (_logic.elapsedSeconds >= _logic.totalSeconds) {
      _isCompletingSession = true;
      _handleStopPressed();
      return;
    }

    final List<String> prevDevices = _logic.isRunning
        ? _runningModules.toList()
        : <String>[];
    final List<String> currentDevices = _modulesForPhase().toList();
    final Set<String> prevSet = prevDevices.toSet();
    final Set<String> currSet = currentDevices.toSet();

    debugPrint('phase switch:');
    debugPrint('prev modules = $prevDevices');
    debugPrint('current modules = $currentDevices');

    if (mounted) {
      setState(() => _isSwitchingPhase = true);
    } else {
      _isSwitchingPhase = true;
    }
    _stopHydrogenFlowPolling(clearValue: false);

    final List<ModbusWriteCommand> commands = <ModbusWriteCommand>[];
    // 三类模块集合：
    // 1) Stop: 上一节点有、本节点无
    // 2) Start: 上一节点无、本节点有
    // 3) Keep: 上下节点都有
    final Set<String> modulesToStop = prevSet.difference(currSet);
    final Set<String> modulesToStart = currSet.difference(prevSet);
    final Set<String> modulesToKeep = prevSet.intersection(currSet);
    final Map<String, String> currentSignatures = _currentModuleSignatures(
      currSet,
    );
    final Map<String, Map<int, int>> currentParamValues =
        _currentModuleParamValues(currSet);
    // Keep 集合里再挑出“参数签名变化”的模块，才进入参数更新流程。
    final Set<String> modulesToUpdate = modulesToKeep.where((module) {
      return currentSignatures[module] != _runningModuleSignatures[module];
    }).toSet();

    // 1. 停止已移除的模块
    for (final String module in modulesToStop) {
      debugPrint('stop removed module: $module');
      switch (module) {
        case 'red':
          commands.addAll([
            const ModbusWriteCommand(
              address: ModbusRtuService.redLightTotalCommandAddress,
              value: 2,
            ),
            const ModbusWriteCommand(
              address: ModbusRtuService.redLight660EnableAddress,
              value: 0,
            ),
            const ModbusWriteCommand(
              address: ModbusRtuService.redLight660PowerAddress,
              value: 0,
            ),
            const ModbusWriteCommand(
              address: ModbusRtuService.redLight850EnableAddress,
              value: 0,
            ),
            const ModbusWriteCommand(
              address: ModbusRtuService.redLight850PowerAddress,
              value: 0,
            ),
            const ModbusWriteCommand(
              address: ModbusRtuService.redLightTotalEnableAddress,
              value: 0,
            ),
          ]);
          break;
        case 'pemf':
          commands.addAll([
            const ModbusWriteCommand(
              address: ModbusRtuService.pemfTotalCommandAddress,
              value: 2,
            ),
            const ModbusWriteCommand(
              address: ModbusRtuService.pemfTotalIntensityAddress,
              value: 0,
            ),
            const ModbusWriteCommand(
              address: ModbusRtuService.pemfTotalEnableAddress,
              value: 0,
            ),
          ]);
          break;
        case 'hydrogen':
          commands.addAll([
            const ModbusWriteCommand(
              address: ModbusRtuService.hydrogenCommandAddress,
              value: 2,
            ),
            const ModbusWriteCommand(
              address: ModbusRtuService.hydrogenConcentrationAddress,
              value: 0,
            ),
            const ModbusWriteCommand(
              address: ModbusRtuService.hydrogenEnableAddress,
              value: 0,
            ),
          ]);
          break;
        case 'vat':
          commands.addAll([
            const ModbusWriteCommand(
              address: ModbusRtuService.vatCommandAddress,
              value: 2,
            ),
            const ModbusWriteCommand(
              address: ModbusRtuService.vatIntensityAddress,
              value: 0,
            ),
            const ModbusWriteCommand(
              address: ModbusRtuService.vatEnableAddress,
              value: 0,
            ),
          ]);
          break;
        case 'chakra':
          commands.addAll([
            const ModbusWriteCommand(
              address: ModbusRtuService.chakraCommandAddress,
              value: 2,
            ),
            for (final int address
                in ModbusRtuService.chakraStrengthAddressMap.values)
              ModbusWriteCommand(address: address, value: 0),
            const ModbusWriteCommand(
              address: ModbusRtuService.chakraEnableAddress,
              value: 0,
            ),
          ]);
          break;
        case 'terahertz':
          commands.addAll([
            const ModbusWriteCommand(
              address: ModbusRtuService.terahertzCommandAddress,
              value: 2,
            ),
            const ModbusWriteCommand(
              address: ModbusRtuService.terahertzPowerAddress,
              value: 0,
            ),
            const ModbusWriteCommand(
              address: ModbusRtuService.terahertzEnableAddress,
              value: 0,
            ),
          ]);
          break;
        case 'hifem':
          commands.addAll([
            const ModbusWriteCommand(
              address: ModbusRtuService.hifemCommandAddress,
              value: 2,
            ),
            const ModbusWriteCommand(
              address: ModbusRtuService.hifemForeheadRfAddress,
              value: 0,
            ),
            const ModbusWriteCommand(
              address: ModbusRtuService.hifemForeheadHifesAddress,
              value: 0,
            ),
            const ModbusWriteCommand(
              address: ModbusRtuService.hifemLeftCheekRfAddress,
              value: 0,
            ),
            const ModbusWriteCommand(
              address: ModbusRtuService.hifemLeftCheekHifesAddress,
              value: 0,
            ),
            const ModbusWriteCommand(
              address: ModbusRtuService.hifemRightCheekRfAddress,
              value: 0,
            ),
            const ModbusWriteCommand(
              address: ModbusRtuService.hifemRightCheekHifesAddress,
              value: 0,
            ),
            const ModbusWriteCommand(
              address: ModbusRtuService.hifemEnableAddress,
              value: 0,
            ),
          ]);
          break;
        case 'fragrance':
          commands.addAll([
            const ModbusWriteCommand(
              address: ModbusRtuService.fragranceCommandAddress,
              value: 2,
            ),
            const ModbusWriteCommand(
              address: ModbusRtuService.fragranceEnableAddress,
              value: 0,
            ),
          ]);
          break;
      }
    }

    // 2. 仅启动新增模块；保留的模块继续运行。
    for (final String module in modulesToStart) {
      debugPrint('start new module: $module');
    }
    for (final String module in modulesToKeep.difference(modulesToUpdate)) {
      debugPrint('keep running module without command: $module');
    }
    for (final String module in modulesToUpdate) {
      debugPrint('update kept module params without restart: $module');
    }
    // 启动：发完整启动序列（使能/参数/启动）。
    commands.addAll(_buildPhaseCommands(moduleFilter: modulesToStart));
    // 保持+更新：只发变化参数，不发启动/使能。
    commands.addAll(
      _buildChangedModuleParamCommands(
        modulesToUpdate,
        currentParamValues: currentParamValues,
      ),
    );

    debugPrint('skip system restart because already running');

    void applyPhaseSwitchState() {
      _lastPhaseIndex = currentIndex;
      _runningModules
        ..clear()
        ..addAll(currentDevices);
      _runningModuleSignatures
        ..clear()
        ..addAll(currentSignatures);
      _runningModuleParamValues
        ..clear()
        ..addAll(currentParamValues);
      _isSwitchingPhase = false;
    }

    if (commands.isNotEmpty) {
      final Stopwatch phaseSwitchStopwatch = Stopwatch()..start();
      debugPrint('phase switch TX command count: ${commands.length}');
      _phaseSwitchModbusService
          .sendCommandQueue(commands)
          .then((_) {
            phaseSwitchStopwatch.stop();
            debugPrint(
              'phase switch TX complete: ${commands.length} commands, '
              '${phaseSwitchStopwatch.elapsedMilliseconds}ms',
            );
            if (mounted) {
              setState(applyPhaseSwitchState);
            }
            _syncHydrogenFlowPolling();
            unawaited(_syncVatMusicPlayback());
          })
          .catchError((Object e) {
            phaseSwitchStopwatch.stop();
            debugPrint('Phase switch command failed: $e');
            debugPrint(
              'phase switch TX failed after '
              '${phaseSwitchStopwatch.elapsedMilliseconds}ms',
            );
            if (mounted) {
              setState(() => _isSwitchingPhase = false);
              _syncHydrogenFlowPolling();
            }
          });
    } else {
      if (mounted) {
        setState(applyPhaseSwitchState);
      } else {
        applyPhaseSwitchState();
      }
      _syncHydrogenFlowPolling();
      unawaited(_syncVatMusicPlayback());
    }
  }

  /// 根据当前阶段是否包含分子氢，启动或停止流量轮询。
  void _syncHydrogenFlowPolling() {
    final _StartArguments args = _StartArguments.from(Get.arguments);
    final List<String> activeDevices = _logic.activeDevices(args.modeTitle);

    if (activeDevices.contains('hydrogen')) {
      _startHydrogenFlowPolling();
    } else {
      _stopHydrogenFlowPolling(clearValue: false);
    }
  }

  void _startHydrogenFlowPolling() {
    if (_hydrogenFlowTimer != null && _hydrogenFlowTimer!.isActive) return;
    _readHydrogenFlowOnce();
    //氢气流量轮询频率,8s轮询一次
    _hydrogenFlowTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!_logic.isRunning) return;
      _readHydrogenFlowOnce();
    });
  }

  void _stopHydrogenFlowPolling({required bool clearValue}) {
    _hydrogenFlowTimer?.cancel();
    _hydrogenFlowTimer = null;
    if (clearValue) {
      _hydrogenFlowTick.value = null;
    }
  }

  Future<void> _readHydrogenFlowOnce() async {
    if (_isReadingHydrogenFlow) return;
    if (!_logic.isRunning) return;
    if (_isSwitchingPhase) return;
    final _StartArguments args = _StartArguments.from(Get.arguments);
    final List<String> activeDevices = _logic.activeDevices(args.modeTitle);
    if (!activeDevices.contains('hydrogen')) return;
    _isReadingHydrogenFlow = true;
    try {
      final int flow = await modbusService.readHydrogenFlow();
      _hydrogenFlowTick.value = flow;
    } catch (e) {
      debugPrint('readHydrogenFlow failed: $e');
    } finally {
      if (mounted) {
        _isReadingHydrogenFlow = false;
      }
    }
  }
}

class _CountdownProgressClipper extends CustomClipper<Path> {
  const _CountdownProgressClipper({required this.remainingProgress});

  final double remainingProgress;

  @override
  Path getClip(Size size) {
    final double remaining = remainingProgress.clamp(0, 1).toDouble();
    if (remaining <= 0) return Path();
    if (remaining >= 1) return Path()..addRect(Offset.zero & size);

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = math.sqrt(
      size.width * size.width + size.height * size.height,
    );
    final double cutProgress = 1 - remaining;
    final double startAngle = -math.pi / 2 + math.pi * 2 * cutProgress;
    final double sweep = math.pi * 2 * remaining;
    final int steps = math.max(2, (90 * remaining).ceil());
    final Path path = Path()..moveTo(center.dx, center.dy);

    for (int i = 0; i <= steps; i++) {
      final double angle = startAngle + sweep * i / steps;
      path.lineTo(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
    }

    return path..close();
  }

  @override
  bool shouldReclip(covariant _CountdownProgressClipper oldClipper) {
    return oldClipper.remainingProgress != remainingProgress;
  }
}

// 启动参数类，用于传递启动时的参数
class _StartArguments {
  const _StartArguments({
    required this.modeTitle,
    required this.userName,
    required this.clientId,
    required this.isOfflineMode,
  });

  final String modeTitle;
  final String userName;
  final int? clientId;
  final bool isOfflineMode;

  factory _StartArguments.from(Object? args) {
    if (args is Map) {
      return _StartArguments(
        modeTitle: args['modeTitle'] as String? ?? 'default_mode_title'.tr,
        userName: _readName(args['user']),
        clientId: _readClientId(args['user']),
        isOfflineMode: args['isOfflineMode'] == true,
      );
    }
    //默认返回主页面
    return _StartArguments(
      modeTitle: 'default_mode_title'.tr,
      userName: 'no_user_selected'.tr,
      clientId: null,
      isOfflineMode: false,
    );
  }

  static String _readName(Object? user) {
    if (user is Map && user['name'] is String) {
      final String name = (user['name'] as String).trim();
      if (name.isNotEmpty) return name;
    }

    try {
      final dynamic dynamicUser = user;
      final Object? value = dynamicUser?.name;
      if (value is String && value.trim().isNotEmpty) return value.trim();
    } catch (_) {
      // 忽略不支持的用户参数格式。
    }

    return 'no_user_selected'.tr;
  }

  static int? _readClientId(Object? user) {
    if (user is Map) {
      return int.tryParse(user['id']?.toString() ?? '');
    }

    try {
      final dynamic dynamicUser = user;
      final Object? value = dynamicUser?.id;
      return int.tryParse(value?.toString() ?? '');
    } catch (_) {
      return null;
    }
  }
}

class _ExpandStatusItem {
  const _ExpandStatusItem({
    required this.id,
    required this.label,
    required this.iconOn,
    required this.iconOff,
  });

  final String id;
  final String label;
  final String iconOn;
  final String iconOff;
}

class _PreloadCommandBatch {
  const _PreloadCommandBatch({
    required this.startAddress,
    required this.values,
  });

  final int startAddress;
  final List<int> values;
}
