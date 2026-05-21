// 主页面。
//
// 展示预设理疗模式、顶部 Header 和氛围灯开关，并提供进入自定义方案页的入口。
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/api/modbus_rtu_service.dart';
import 'package:infibo_app/components/index.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/constants/color.dart';
import 'package:infibo_app/pages/joystick/ui.dart';
import 'package:infibo_app/pages/main/logic.dart';

// 主页面UI
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

// 主页面状态管理
class _MainPageState extends State<MainPage> {
  // 主页面底部氛围灯默认按钮
  bool _isLightOn = false;
  bool _isLightCommanding = false;
  bool _pendingLightState = false;
  bool _hasPendingLight = false;
  final ModbusRtuService _modbusService = const ModbusRtuService();
  // 主页面逻辑控制器
  final MainLogic _logic = MainLogic();

  @override
  void initState() {
    super.initState();
    _syncAmbientLightStateFromDevice();
  }

  Future<void> _syncAmbientLightStateFromDevice() async {
    try {
      final int state = await _modbusService.readHoldingRegister(0x0012);
      if (!mounted) return;
      setState(() => _isLightOn = state == 1);
      debugPrint('Ambient light sync RX 0x0012=$state');
    } catch (e) {
      debugPrint('Ambient light sync failed: $e');
    }
  }

  ///////////////////////////////////////////////模式卡片数据////////////////////////////////////////////////
  // 左侧模式卡片数据
  static const List<_ModeCardData> _leftModeCards = [
    // 深度放松
    _ModeCardData(
      titleKey: 'deep_relax',
      color: Color(0xFF26D1EF),
      asset: Assets.deepRelaxLogo,
      left: 153,
      top: 244,
      width: 212,
      titleLeft: 41,
      titleTop: 19,
    ),
    // 能量提升
    _ModeCardData(
      titleKey: 'energy_boost',
      color: Color(0xFFFB933E),
      asset: Assets.energyBoostLogo,
      left: 103,
      top: 393,
      width: 191,
      titleLeft: 41,
      titleTop: 19,
    ),
    // 疼痛缓解
    _ModeCardData(
      titleKey: 'pain_relief',
      color: Color(0xFFF9645C),
      asset: Assets.painReliefLogo,
      left: 53,
      top: 544,
      width: 217,
      titleLeft: 41,
      titleTop: 19,
    ),
    // 睡眠改善
    _ModeCardData(
      titleKey: 'sleep_enhancement',
      color: Color(0xFFA68DF5),
      asset: Assets.sleepEnhancementLogo,
      left: 103,
      top: 694,
      width: 190,
      titleLeft: 41,
      titleTop: 19,
    ),
    // 运动恢复
    _ModeCardData(
      titleKey: 'sports_recovery',
      color: Color(0xFF56D785),
      asset: Assets.sportsRehabilitationLogo,
      left: 153,
      top: 843,
      width: 212,
      titleLeft: 41,
      titleTop: 16,
    ),
  ];

  // 右侧模式卡片数据
  static const List<_ModeCardData> _rightModeCards = [
    // 压力释放
    _ModeCardData(
      titleKey: 'stress_release',
      color: Color(0xFF45CD9F),
      asset: Assets.stressReliefLogo,
      left: 437,
      top: 244,
      width: 212,
      titleLeft: 88,
      titleTop: 18,
    ),
    // 免疫增强
    _ModeCardData(
      titleKey: 'immune_boost',
      color: Color(0xFF3DBAFA),
      asset: Assets.immuneBoostLogo,
      left: 500,
      top: 393,
      width: 191,
      titleLeft: 61,
      titleTop: 19,
    ),
    // 抗衰老
    _ModeCardData(
      titleKey: 'anti_aging',
      color: Color(0xFFF9645C),
      asset: Assets.antiAgingLogo,
      left: 525,
      top: 544,
      width: 217,
      titleLeft: 49,
      titleTop: 18,
    ),
    // 全面养护
    _ModeCardData(
      titleKey: 'full_care',
      color: Color(0xFFE87CF3),
      asset: Assets.fullCareLogo,
      left: 500,
      top: 694,
      width: 190,
      titleLeft: 61,
      titleTop: 18,
    ),
    // 情绪疗愈
    _ModeCardData(
      titleKey: 'mental_healing',
      color: Color(0xFFFDBC2A),
      asset: Assets.mentalHealingLogo,
      left: 437,
      top: 843,
      width: 212,
      titleLeft: 88,
      titleTop: 17,
    ),
  ];

  ///////////////////////////////////////////////主页面布局////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    final double scale = ((MediaQuery.sizeOf(context).width - 32) / 800)
        .clamp(0.72, 1.0)
        .toDouble();

    return AppHeaderPage(
      enableLogoBack: false,
      children: [
        Positioned.fill(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: SizedBox(
                // 主页面画布宽度
                width: 800 * scale,
                height: 1230 * scale,
                child: FittedBox(
                  // 主页面画布高度
                  fit: BoxFit.contain,
                  // 主页面画布居中对齐
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: 800,
                    height: 1230,
                    child: _buildMainCanvas(),
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
  Widget _buildMainCanvas() {
    return Stack(
      //超出内容也显示
      clipBehavior: Clip.none,
      children: [
        _buildTitle(),
        _buildBodyStage(),
        ..._leftModeCards.map((card) => _buildModeCard(card)),
        ..._rightModeCards.map((card) => _buildModeCard(card)),
        _buildBottomActions(),
        const Positioned(left: 590, top: 1010, child: JoystickControl()),
      ],
    );
  }

  // 构建模式卡片
  Widget _buildModeCard(_ModeCardData item) {
    return Positioned(
      left: item.left,
      top: item.top,
      child: _ModeCard(item: item, onTap: _logic.openModeDetail),
    );
  }

  /// 构建标题区域
  Widget _buildTitle() {
    return Positioned(
      top: 120,
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

  /// 构建设备状态标签
  Widget _buildDeviceStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1D3A31),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF295E4D)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, color: Color(0xFF25E88A), size: 9),
          const SizedBox(width: 5),
          Text(
            'device_ready'.tr,
            style: const TextStyle(color: Color(0xFF35E093), fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// 构建中间人体图片
  Widget _buildBodyStage() {
    return Positioned(
      left: 160,
      top: 180,
      child: Image.asset(
        Assets.mainBodyLogo,
        width: 479,
        height: 800,
        fit: BoxFit.contain,
      ),
    );
  }

  /// 构建底部按钮区域
  Widget _buildBottomActions() {
    return Stack(
      children: [
        Positioned(
          left: 45,
          top: 1092,
          child: SizedBox(
            width: 192,
            height: 72,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Material(
                  color: const Color(0xFF1876F2),
                  child: InkWell(
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
          left: 260,
          top: 1100,
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
      await _modbusService.sendCommandQueue([
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
  // 是否按下
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final _ModeCardData item = widget.item;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: () => widget.onTap(item.titleKey.tr),
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
                  left: item.titleLeft,
                  top: item.titleTop,
                  right: 12,
                  child: Text(
                    item.titleKey.tr,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: item.color,
                      fontSize: 16,
                      fontFamily: 'Microsoft YaHei',
                      height: 1,
                      fontWeight: FontWeight.w600,
                    ),
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
    required this.left,
    required this.top,
    required this.width,
    required this.titleLeft,
    required this.titleTop,
  });

  // 中文标题
  final String titleKey;

  // 中文标题颜色
  final Color color;

  // 卡片底图
  final String asset;

  // 卡片在页面中的横向位置
  final double left;

  // 卡片在页面中的纵向位置
  final double top;

  // 卡片显示宽度
  final double width;

  // 中文标题在卡片内部的横向位置
  final double titleLeft;

  // 中文标题在卡片内部的纵向位置
  final double titleTop;
}
