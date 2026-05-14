import 'dart:async';
import 'dart:math' as math;
import 'package:infibo_app/api/modbus_rtu_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/index.dart';
import 'package:infibo_app/components/logic.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/pages/joystick/ui.dart';
import 'package:infibo_app/pages/music/logic.dart';
import 'package:infibo_app/pages/start/logic.dart';

// 启动理疗页面
class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  // 这里使用 AndroidSerialPortService，默认路径为 /dev/ttyS0
  final ModbusRtuService modbusService = const ModbusRtuService();
  // 启动页按 800x1160 的设计稿坐标摆放，再根据屏幕宽度整体缩放
  static const double _designWidth = 800;
  static const double _designHeight = 1160;
  static const double _minPageScale = 0.72;

  // 倒计时素材尺寸，countdownPoint 允许超出外圈，所以 Stack 会关闭裁剪
  static const double _timerSize = 250; //倒计时圆的尺寸
  static const double _timerRingSize = 255; //中间的圆环尺寸
  static const double _timerDotSize = 29; //控制小圆点尺寸，位置也会自动按中心点对齐
  static const double _timerDotRadius = 121; //控制小圆点离圆心多远数字越大，点越往外；数字越小，点越往里

  // 页面逻辑控制器：倒计时、运行、暂停状态、当前工作设备都放在 logic.dart 中
  final StartLogic _logic = StartLogic();

  // 每秒推进一次倒计时
  Timer? _timer;
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
  Timer? _hydrogenFlowTimer;
  bool _isReadingHydrogenFlow = false;
  int? _hydrogenFlowValue;
  VatMusicSelection? _vatMusicSelection;

  @override
  void initState() {
    super.initState();
    _logic.configure(Get.arguments);
    _lastPhaseIndex = _logic.activePhaseIndex;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hydrogenFlowTimer?.cancel();
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
        Positioned(left: 278, top: 840, child: _buildTimer()),
        Positioned(left: 126, top: 970, child: _buildPauseButton()),
        Positioned(left: 508, top: 970, child: _buildPlayButton()),
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
            Positioned.fill(child: Image.asset(panelAsset, fit: BoxFit.fill)),
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

  Widget _buildRedLightPanelInfo(bool isActive) {
    final RedLightPhaseSetting? setting = _logic.activeRedLightSetting;

    final String strength660Text = setting == null
        ? ''
        : setting.strength660.toString();
    final String strength850Text = setting == null
        ? ''
        : setting.strength850.toString();

    final String modeText = setting?.mode == RedLightWorkMode.pulse
        ? '脉冲'
        : '连续';

    final String modeAsset = setting?.mode == RedLightWorkMode.pulse
        ? Assets.redLightPulseWave
        : Assets.startExpandContinuous;

    return Positioned(
      left: 18,
      top: 22,
      child: IgnorePointer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '红光',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),

            const SizedBox(height: 24),

            const Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    '波长',
                    style: TextStyle(color: Color(0xffb9bcc6), fontSize: 17),
                  ),
                ),
                SizedBox(width: 20),
                SizedBox(
                  width: 100,
                  child: Text(
                    '强度',
                    style: TextStyle(color: Color(0xffb9bcc6), fontSize: 17),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            _buildRedLightInfoRow('660', strength660Text),

            const SizedBox(height: 8),

            const Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    '波长',
                    style: TextStyle(color: Color(0xffb9bcc6), fontSize: 17),
                  ),
                ),
                SizedBox(width: 20),
                SizedBox(
                  width: 100,
                  child: Text(
                    '强度',
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
            const Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    '频率',
                    style: TextStyle(color: Color(0xffb9bcc6), fontSize: 17),
                  ),
                ),
                SizedBox(width: 20),
                SizedBox(
                  width: 100,
                  child: Text(
                    '强度',
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
              Image.asset(
                waveformAsset,
                width: 170,
                height: 24,
                fit: BoxFit.contain,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVatPanelInfo(bool isActive) {
    final VatPhaseSetting? setting = _logic.activeVatSetting;

    final String frequencyText = setting?.frequency.toString() ?? '';
    final String intensityText = setting?.intensity.toString() ?? '';

    return Positioned(
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
            const Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    '频率',
                    style: TextStyle(color: Color(0xffb9bcc6), fontSize: 17),
                  ),
                ),
                SizedBox(width: 20),
                SizedBox(
                  width: 100,
                  child: Text(
                    '强度',
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
    final String flowDisplay = _hydrogenFlowValue == null
        ? '--'
        : '$_hydrogenFlowValue';

    return Positioned(
      left: 40,
      top: 22,
      child: IgnorePointer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '分子氢',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 24),
            const Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    '氢气浓度',
                    style: TextStyle(color: Color(0xffb9bcc6), fontSize: 17),
                  ),
                ),
                SizedBox(width: 20),
                SizedBox(
                  width: 100,
                  child: Text(
                    '流量',
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
                Text(
                  flowDisplay,
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

  String _getWaveformAsset(String waveform) {
    switch (waveform) {
      case 'sine':
        return Assets.startPemfWaveSine;
      case 'standardSine':
        return Assets.startPemfWaveStandardSine;
      case 'halfSine':
        return Assets.startPemfWaveHalfSine;
      case 'pulse':
        return Assets.startPemfWavePulse;
      case 'square':
        return Assets.startPemfWaveSquare;
      case 'fastRise':
        return Assets.startPemfWaveFastRise;
      case 'saw':
      case 'sawtooth':
        return Assets.startPemfWaveSawtooth;
      case 'triangle':
        return Assets.startPemfWaveTriangle;
      case 'trapezoid':
        return Assets.startPemfWaveTrapezoid;
      case 'dualFrequency':
        return Assets.startPemfWaveDualFrequency;
      default:
        return '';
    }
  }

  // 构建功能框效果图
  List<Widget> _buildFunctionPanelEffects(
    String id,
    bool isActive,
    List<String> activeDevices,
  ) {
    switch (id) {
      case 'red':
        return [
          Positioned(
            left: 54,
            top: 255,
            child: Image.asset(
              Assets.startRedLightWave,
              width: 180,
              height: 130,
              fit: BoxFit.contain,
            ),
          ),
        ];
      case 'pemf':
        return [
          Positioned(
            left: -18,
            top: 140,
            child: Image.asset(
              Assets.startPemfWave,
              width: 300,
              height: 200,
              fit: BoxFit.contain,
            ),
          ),
        ];
      case 'vat':
        return [
          Positioned(
            left: 57,
            top: 151,
            child: Image.asset(
              Assets.startVatWave,
              width: 179,
              height: 56,
              fit: BoxFit.contain,
            ),
          ),
        ];
      case 'hydrogen':
        return [
          Positioned(
            left: 78,
            top: 145,
            child: Image.asset(
              Assets.startHydrogenMolecule,
              width: 120,
              height: 80,
              fit: BoxFit.contain,
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
        label: '脉轮',
        iconOn: Assets.startExpandIconOn,
        iconOff: Assets.startExpandIconOff,
      ),
      _ExpandStatusItem(
        id: 'terahertz',
        label: '太赫兹',
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
        label: '香氛',
        iconOn: Assets.startFragranceIconOn,
        iconOff: Assets.startFragranceIconOff,
      ),
    ];

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
                fontWeight: FontWeight.w500,
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
            running ? '正在运行' : '等待运行',
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
    final List<String> timeParts = _formatRemainingTime().split(':');
    final String minuteText = timeParts.isNotEmpty ? timeParts.first : '00';
    final String secondText = timeParts.length > 1 ? timeParts[1] : '00';
    final double elapsedProgress = _logic.progress;
    final Offset dotOffset = _countdownDotOffset(elapsedProgress);

    return SizedBox(
      width: _timerSize,
      height: _timerSize,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Image.asset(
            Assets.startTimerRing,
            width: _timerRingSize,
            height: _timerRingSize,
          ),
          ClipPath(
            clipper: _CountdownProgressClipper(
              elapsedProgress: elapsedProgress,
            ),
            child: Image.asset(
              Assets.startTimerProgress,
              width: _timerSize,
              height: _timerSize,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            left: dotOffset.dx,
            top: dotOffset.dy,
            child: Image.asset(
              Assets.startTimerDot,
              width: _timerDotSize,
              height: _timerDotSize,
              fit: BoxFit.contain,
            ),
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

  // 计算倒计时进度条上的点的偏移量
  Offset _countdownDotOffset(double progress) {
    const double size = _timerSize;
    const double dotSize = _timerDotSize;
    const double radius = _timerDotRadius;
    const Offset center = Offset(size / 2, size / 2);
    final double angle = -math.pi / 2 + math.pi * 2 * progress;

    return Offset(
      center.dx + math.cos(angle) * radius - dotSize / 2,
      center.dy + math.sin(angle) * radius - dotSize / 2,
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
              width: isActive ? 167 : 120,
              height: isActive ? 156 : 65,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    final bool isStopMode = _logic.isRunning;
    final bool isResumeMode = _logic.canResume;
    final bool isStartMode = _logic.canStart;
    final bool isActive =
        !_isCommanding && (isStopMode || isResumeMode || isStartMode);

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
                  ? Assets.pausePlayButton
                  : isActive
                  ? Assets.startPlayActiveButton
                  : Assets.pausePlayButton,
              width: isActive ? 167 : 120,
              height: isActive ? 156 : 65,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleStartPressed() async {
    if (_isCommanding || !_logic.canStart) return;

    setState(() => _isCommanding = true);
    try {
      final List<ModbusWriteCommand> commands = _buildPhaseCommands();
      await modbusService.startWithCommands(commands);
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
      });
      _syncHydrogenFlowPolling();
      debugPrint('start command sent successfully');
    } catch (e) {
      debugPrint('start command failed: $e');
      if (!mounted) return;
      _showError('参数下发失败：$e');
    } finally {
      if (mounted) setState(() => _isCommanding = false);
    }
  }

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
      debugPrint('pause command sent successfully');
    } catch (e) {
      debugPrint('pause command failed: $e');
      if (!mounted) return;
      _showError('暂停失败：$e');
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
      debugPrint('resume command sent successfully');
    } catch (e) {
      debugPrint('resume command failed: $e');
      if (!mounted) return;
      _showError('继续失败：$e');
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
      if (!mounted) return;
      setState(() {
        _logic.stop();
        _runningModules.clear();
        _runningModuleSignatures.clear();
        _runningModuleParamValues.clear();
        _stopHydrogenFlowPolling(clearValue: true);
      });
      await _showCompletionDialog(args);
    } catch (e) {
      debugPrint('stop command failed: $e');
      if (!mounted) return;
      _showError('停止失败：$e');
    } finally {
      if (mounted) setState(() => _isCommanding = false);
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
        debugPrint('PEMF TX address=0x00C7 value=1');
        debugPrint('PEMF TX address=0x00CE value=${setting.frequency}');
        debugPrint('PEMF TX address=0x00D0 value=${setting.intensity}');
        debugPrint('PEMF TX address=0x00D1 value=$waveformNum');
        debugPrint('PEMF TX address=0x00CA value=1');
        addModuleCommands('pemf', [
          const ModbusWriteCommand(
            address: ModbusRtuService.pemfTotalModeAddress,
            value: 1,
          ),
          ModbusWriteCommand(
            address: ModbusRtuService.pemfTotalFrequencyAddress,
            value: setting.frequency,
          ),
          ModbusWriteCommand(
            address: ModbusRtuService.pemfTotalIntensityAddress,
            value: setting.intensity,
          ),
          ModbusWriteCommand(
            address: ModbusRtuService.pemfTotalWaveformAddress,
            value: waveformNum,
          ),
          const ModbusWriteCommand(
            address: ModbusRtuService.pemfTotalCommandAddress,
            value: 1,
          ),
        ]);
      }
    }

    // 分子氢
    final bool hasHydrogen = activeDevices.contains('hydrogen');
    debugPrint('Hydrogen hasHydrogen=$hasHydrogen');
    if (hasHydrogen && shouldBuild('hydrogen')) {
      final HydrogenPhaseSetting? setting = _logic.activeHydrogenSetting;
      if (setting != null) {
        final List<ModbusWriteCommand> hydrogenCommands = modbusService
            .buildHydrogenParamCommands(concentration: setting.concentration);
        addModuleCommands('hydrogen', [
          ...hydrogenCommands,
          const ModbusWriteCommand(
            address: ModbusRtuService.hydrogenCommandAddress,
            value: 1,
          ),
        ]);
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
        final List<ModbusWriteCommand> vatCommands = modbusService
            .buildVatParamCommands(
              frequency: setting.frequency,
              intensity: setting.intensity,
              musicIndex: musicIndex,
            );
        addModuleCommands('vat', [
          ...vatCommands,
          const ModbusWriteCommand(
            address: ModbusRtuService.vatCommandAddress,
            value: 1,
          ),
        ]);
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
        return const <int>{ModbusRtuService.pemfTotalModeAddress};
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
    Set<String> modules,
  ) {
    // 对 modulesToKeep 中参数有变化的模块，按“地址值变化”做最小增量下发。
    final List<ModbusWriteCommand> commands = <ModbusWriteCommand>[];

    for (final String module in modules) {
      final Map<int, int> previousValues =
          _runningModuleParamValues[module] ?? const <int, int>{};
      final List<ModbusWriteCommand> currentCommands = _buildPhaseCommands(
        moduleFilter: <String>{module},
        includeStartCommands: false,
      );

      for (final ModbusWriteCommand command in currentCommands) {
        // 同地址值未变化则不重复下发。
        if (previousValues[command.address] == command.value) continue;
        commands.add(command);
      }
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
        return '${setting.frequency}|${setting.intensity}|${_resolveVatMusicIndex(setting)}';
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
    if (planSetting?.songId != null) {
      final int idx = allSongs.indexWhere((s) => s.id == planSetting!.songId);
      return idx >= 0 ? idx : 0;
    }
    return 0;
  }

  /// 获取当前阶段启用的模块列表。
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
        current?.songId ?? setting?.songId ?? defaultSongId;

    final Object? result = await Get.toNamed(
      '/music',
      arguments: {
        'fromPage': 'start',
        'currentSelectedSongId': currentSongId,
        'phaseIndex': _logic.activePhaseIndex,
      },
    );

    if (!mounted) return;
    if (result is! VatMusicSelection) return;

    setState(() => _vatMusicSelection = result);

    final bool isVatRunning =
        _logic.isRunning && _runningModules.contains('vat');
    if (isVatRunning) {
      final int idx = allSongs.indexWhere((s) => s.id == result.songId);
      final int musicIndex = idx >= 0 ? idx : 0;
      try {
        await modbusService.writeVatMusicIndex(musicIndex);
      } catch (e) {
        debugPrint('VAT runtime music change failed: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showCompletionDialog(_StartArguments args) async {
    final int actualSeconds = _logic.elapsedSeconds
        .clamp(0, _logic.totalSeconds)
        .toInt();
    final Map<String, int> moduleSeconds = _logic.actualWorkSecondsByDevice(
      args.modeTitle,
    );

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2129),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF535B6A)),
          ),
          title: const Text(
            '治疗完成',
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _completionRow('使用者', args.userName),
                _completionRow(
                  '本次使用',
                  StartLogic.formatDurationText(actualSeconds),
                ),
                const SizedBox(height: 12),
                const Text(
                  '模块时长',
                  style: TextStyle(color: Color(0xFFB9BCC6), fontSize: 15),
                ),
                const SizedBox(height: 8),
                ..._moduleDurationRows(moduleSeconds),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确认'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    AppComponentLogic.backToMainPage();
  }

  Widget _completionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFFB9BCC6), fontSize: 15),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _moduleDurationRows(Map<String, int> moduleSeconds) {
    final List<MapEntry<String, int>> entries = moduleSeconds.entries
        .where((entry) => entry.value > 0)
        .toList();
    if (entries.isEmpty) {
      return const [
        Text(
          '暂无模块运行记录',
          style: TextStyle(color: Color(0xFFB9BCC6), fontSize: 14),
        ),
      ];
    }

    return entries
        .map(
          (entry) => _completionRow(
            StartLogic.deviceName(entry.key),
            StartLogic.formatDurationText(entry.value),
          ),
        )
        .toList();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_logic.isRunning) return;
      setState(() {
        _logic.tick();
        _trySwitchPhase();
      });
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

    _isSwitchingPhase = true;

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

    // 1. Stop removed modules
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
              address: ModbusRtuService.pemfTotalModeAddress,
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

    // 2. Only start newly added modules; kept modules are left running.
    for (final String module in modulesToStart) {
      debugPrint('start new module: $module');
    }
    for (final String module in modulesToKeep.difference(modulesToUpdate)) {
      debugPrint('keep running module without command: $module');
    }
    for (final String module in modulesToUpdate) {
      debugPrint('update kept module params without restart: $module');
    }
    // Start: 发完整启动序列（使能/参数/启动）。
    commands.addAll(_buildPhaseCommands(moduleFilter: modulesToStart));
    // Keep+Update: 只发变化参数，不发启动/使能。
    commands.addAll(_buildChangedModuleParamCommands(modulesToUpdate));

    debugPrint('skip system restart because already running');

    if (commands.isNotEmpty) {
      modbusService
          .sendCommandQueue(commands)
          .then((_) {
            if (mounted) {
              setState(() {
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
              });
            }
            _syncHydrogenFlowPolling();
          })
          .catchError((Object e) {
            debugPrint('Phase switch command failed: $e');
            if (mounted) setState(() => _isSwitchingPhase = false);
          });
    } else {
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
      _syncHydrogenFlowPolling();
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
    _hydrogenFlowTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_logic.isRunning) return;
      _readHydrogenFlowOnce();
    });
  }

  void _stopHydrogenFlowPolling({required bool clearValue}) {
    _hydrogenFlowTimer?.cancel();
    _hydrogenFlowTimer = null;
    if (clearValue) {
      _hydrogenFlowValue = null;
    }
  }

  Future<void> _readHydrogenFlowOnce() async {
    if (_isReadingHydrogenFlow) return;
    if (!_logic.isRunning) return;
    final _StartArguments args = _StartArguments.from(Get.arguments);
    final List<String> activeDevices = _logic.activeDevices(args.modeTitle);
    if (!activeDevices.contains('hydrogen')) return;
    _isReadingHydrogenFlow = true;
    try {
      final int flow = await modbusService.readHydrogenFlow();
      if (mounted) {
        setState(() => _hydrogenFlowValue = flow);
      }
    } catch (e) {
      debugPrint('readHydrogenFlow failed: $e');
    } finally {
      if (mounted) {
        _isReadingHydrogenFlow = false;
      }
    }
  }

  String _formatRemainingTime() {
    return _logic.remainingTimeText;
  }
}

class _CountdownProgressClipper extends CustomClipper<Path> {
  const _CountdownProgressClipper({required this.elapsedProgress});

  final double elapsedProgress;

  @override
  Path getClip(Size size) {
    final double elapsed = elapsedProgress.clamp(0, 1).toDouble();
    if (elapsed >= 1) return Path();

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = math.sqrt(
      size.width * size.width + size.height * size.height,
    );
    final double startAngle = -math.pi / 2 + math.pi * 2 * elapsed;
    final double sweep = math.pi * 2 * (1 - elapsed);
    final int steps = math.max(2, (90 * (1 - elapsed)).ceil());
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
    return oldClipper.elapsedProgress != elapsedProgress;
  }
}

// 启动参数类，用于传递启动时的参数
class _StartArguments {
  const _StartArguments({required this.modeTitle, required this.userName});

  final String modeTitle;
  final String userName;

  factory _StartArguments.from(Object? args) {
    if (args is Map) {
      return _StartArguments(
        modeTitle: args['modeTitle'] as String? ?? '深度放松',
        userName: _readName(args['user']),
      );
    }
    return const _StartArguments(modeTitle: '深度放松', userName: '未选择用户');
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
      // Ignore unsupported user argument shapes.
    }

    return '未选择用户';
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
