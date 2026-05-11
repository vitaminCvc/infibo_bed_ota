import 'dart:async';
import 'dart:math' as math;
import 'package:infibo_app/api/modbus_rtu_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/index.dart';
import 'package:infibo_app/constants/assets.dart';
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
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    _logic.configure(Get.arguments);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
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
        ? _logic.activeDevices(args.modeTitle)
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
            ..._buildFunctionPanelEffects(id, isActive),
            if (id == 'red') _buildRedLightPanelInfo(isActive),
            if (id != 'expand')
              Positioned(
                right: id == 'red' || id == 'pemf' ? 40 : 18,
                top: 15,
                child: Image.asset(isActive ? iconOn : iconOff, width: 43),
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

  // 构建功能框效果图
  List<Widget> _buildFunctionPanelEffects(String id, bool isActive) {
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
            left: 45,
            top: 18,
            child: _buildExpandStatusIcons(isActive),
          ),
        ];
      default:
        return const [];
    }
  }

  // 构建扩展功能状态图标
  Widget _buildExpandStatusIcons(bool isActive) {
    final List<String> iconAssets = [
      isActive ? Assets.startExpandIconOn : Assets.startExpandIconOff,
      isActive ? Assets.startTerahertzIconOn : Assets.startTerahertzIconOff,
      isActive ? Assets.startHifemIconOn : Assets.startHifemIconOff,
      isActive ? Assets.startFragranceIconOn : Assets.startFragranceIconOff,
    ];

    return Column(
      children: [
        for (final String asset in iconAssets) ...[
          Image.asset(asset, width: 24, height: 24),
          if (asset != iconAssets.last) const SizedBox(height: 14),
        ],
      ],
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
    final bool isActive = _logic.isRunning;

    return SizedBox(
      width: 167,
      height: 156,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isActive
            ? () async {
                try {
                  await modbusService.sendCommandQueue([
                    const ModbusWriteCommand(address: 0x0004, value: 2),
                    ...modbusService.buildStopRedLightCommands(),
                  ]);
                  if (!mounted) return;
                  setState(_logic.pause);
                  debugPrint('stop command sent successfully');
                } catch (e) {
                  debugPrint('stop command failed: $e');
                }
              }
            : null,
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
    final bool isActive =
        !_isStarting &&
        !_logic.isRunning &&
        _logic.elapsedSeconds < _logic.totalSeconds;

    return SizedBox(
      width: 167,
      height: 156,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isActive ? _handleStartPressed : null,
        child: Opacity(
          opacity: isActive ? 1 : 0.45,
          child: Center(
            child: Image.asset(
              isActive ? Assets.startPlayActiveButton : Assets.pausePlayButton,
              width: isActive ? 167 : 120,
              height: isActive ? 156 : 65,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleStartPressed() async {
    if (_isStarting || _logic.isRunning) return;

    setState(() => _isStarting = true);
    try {
      await modbusService.startWithCommands(_currentPhaseCommands());
      if (!mounted) return;
      setState(_logic.play);
      debugPrint('start command sent successfully');
    } catch (e) {
      debugPrint('start command failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('参数下发失败：$e')));
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  List<ModbusWriteCommand> _currentPhaseCommands() {
    if (!_logic.isCustomizedPlan) return const [];

    final _StartArguments args = _StartArguments.from(Get.arguments);
    final List<String> activeDevices = _logic.activeDevices(args.modeTitle);
    final RedLightPhaseSetting? redLightSetting = _logic.activeRedLightSetting;

    if (activeDevices.contains('red') && redLightSetting != null) {
      return modbusService.buildRedLightCommands(
        strength660: redLightSetting.strength660,
        strength850: redLightSetting.strength850,
        mode: redLightSetting.modbusMode,
      );
    }

    return const [];
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_logic.isRunning) return;
      setState(_logic.tick);
    });
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
  const _StartArguments({required this.modeTitle});

  final String modeTitle;

  factory _StartArguments.from(Object? args) {
    if (args is Map) {
      return _StartArguments(modeTitle: args['modeTitle'] as String? ?? '深度放松');
    }
    return const _StartArguments(modeTitle: '深度放松');
  }
}
