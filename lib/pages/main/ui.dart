import 'package:flutter/material.dart';
import 'package:infibo_app/components/index.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/constants/color.dart';
import 'package:infibo_app/pages/main/logic.dart';

// 主页面UI
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

// 主页面状态管理
class _MainPageState extends State<MainPage> {
  // 主页面逻辑控制器
  final MainLogic _logic = MainLogic();

  ///////////////////////////////////////////////模式卡片数据////////////////////////////////////////////////
  // 左侧模式卡片数据
  static const List<_ModeCardData> _leftModeCards = [
    // 深度放松
    _ModeCardData(
      title: '深度放松',
      color: Color(0xFF26D1EF),
      asset: Assets.deepRelaxLogo,
      left: 153,
      top: 262,
      width: 212,
      titleLeft: 41,
      titleTop: 19,
    ),
    // 能量提升
    _ModeCardData(
      title: '能量提升',
      color: Color(0xFFFB933E),
      asset: Assets.energyBoostLogo,
      left: 103,
      top: 411,
      width: 191,
      titleLeft: 41,
      titleTop: 19,
    ),
    // 疼痛缓解
    _ModeCardData(
      title: '疼痛缓解',
      color: Color(0xFFF9645C),
      asset: Assets.painReliefLogo,
      left: 53,
      top: 562,
      width: 217,
      titleLeft: 41,
      titleTop: 19,
    ),
    // 睡眠改善
    _ModeCardData(
      title: '睡眠改善',
      color: Color(0xFFA68DF5),
      asset: Assets.sleepEnhancementLogo,
      left: 103,
      top: 712,
      width: 190,
      titleLeft: 41,
      titleTop: 19,
    ),
    // 运动恢复
    _ModeCardData(
      title: '运动恢复',
      color: Color(0xFF56D785),
      asset: Assets.sportsRehabilitationLogo,
      left: 153,
      top: 861,
      width: 212,
      titleLeft: 41,
      titleTop: 16,
    ),
  ];

  // 右侧模式卡片数据
  static const List<_ModeCardData> _rightModeCards = [
    // 压力释放
    _ModeCardData(
      title: '压力释放',
      color: Color(0xFF45CD9F),
      asset: Assets.stressReliefLogo,
      left: 437,
      top: 262,
      width: 212,
      titleLeft: 88,
      titleTop: 18,
    ),
    // 免疫增强
    _ModeCardData(
      title: '免疫增强',
      color: Color(0xFF3DBAFA),
      asset: Assets.immuneBoostLogo,
      left: 500,
      top: 411,
      width: 191,
      titleLeft: 61,
      titleTop: 19,
    ),
    // 抗衰老
    _ModeCardData(
      title: '抗衰老',
      color: Color(0xFFF9645C),
      asset: Assets.antiAgingLogo,
      left: 525,
      top: 562,
      width: 217,
      titleLeft: 49,
      titleTop: 18,
    ),
    // 全面养护
    _ModeCardData(
      title: '全面养护',
      color: Color(0xFFE87CF3),
      asset: Assets.fullCareLogo,
      left: 500,
      top: 712,
      width: 190,
      titleLeft: 61,
      titleTop: 18,
    ),
    // 情绪疗愈
    _ModeCardData(
      title: '情绪疗愈',
      color: Color(0xFFFDBC2A),
      asset: Assets.mentalHealingLogo,
      left: 437,
      top: 861,
      width: 212,
      titleLeft: 88,
      titleTop: 17,
    ),
  ];

  @override
  // 初始化主页面状态
  void initState() {
    super.initState();
    _logic.startClock(_refreshClock);
  }

  @override
  // 页面销毁时释放资源
  void dispose() {
    _logic.disposeClock();
    super.dispose();
  }

  // 刷新时间显示
  void _refreshClock() {
    if (!mounted) return;
    setState(() {});
  }

  ///////////////////////////////////////////////主页面布局////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    final double scale = ((MediaQuery.sizeOf(context).width - 64) / 800)
        .clamp(0.72, 1.0)
        .toDouble();

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 800 * scale),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ///////////////////////////////////////////////主页面组件构建////////////////////////////////////////////////
  /// 构建主页画布
  Widget _buildMainCanvas() {
    return Stack(     
//超出内容也显示      
      clipBehavior: Clip.none,
      children: [
        // 占满整个布局
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(color: AppTheme.primaryColor),
          ),
        ),
        _buildHeader(),
        _buildTitle(),
        _buildBodyStage(),
        ..._leftModeCards.map(_buildModeCard),
        ..._rightModeCards.map(_buildModeCard),
        _buildBottomActions(),
      ],
    );
  }

  /// 构建公共顶部表头
  Widget _buildHeader() {
    return Positioned(
      left: 48,
      top: 34,
      right: 44,
      child: AppTopHeader(timeText: _logic.timeText, dateText: _logic.dateText),
    );
  }

  /// 构建标题区域
  Widget _buildTitle() {
    return Positioned(
      top: 145,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '预设理疗模式',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 14),
              _buildDeviceStatus(),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '10种专业配方方案',
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
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: Color(0xFF25E88A), size: 9),
          SizedBox(width: 5),
          Text(
            '设备就绪',
            style: TextStyle(color: Color(0xFF35E093), fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// 构建中间人体图片
  Widget _buildBodyStage() {
    return Positioned(
      left: 160,
      top: 242,
      child: Image.asset(
        Assets.mainBodyLogo,
        width: 479,
        height: 778,
        fit: BoxFit.contain,
      ),
    );
  }

  /// 构建模式卡片位置
  Widget _buildModeCard(_ModeCardData item) {
    return Positioned(
      left: item.left,
      top: item.top,
      child: _ModeCard(item: item, onTap: _logic.openModeDetail),
    );
  }

  /// 构建底部按钮区域
  Widget _buildBottomActions() {
    return Stack(
      children: [
        Positioned(
          left: 45,
          top: 1100,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.description_outlined, size: 22),
            label: const Text('自定义方案'),
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(192, 56),
              backgroundColor: const Color(0xFF1876F2),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              textStyle: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Positioned(
          left: 260,
          top: 1100,
          child: Image.asset(Assets.atmosphereLightLogo, width: 56, height: 56),
        ),
        Positioned(
          left: 568,
          top: 965,
          child: Image.asset(Assets.liftControlLogo, width: 187, height: 187),
        ),
      ],
    );
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
      onTap: () => widget.onTap(item.title),
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
                    item.title,
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
    required this.title,
    required this.color,
    required this.asset,
    required this.left,
    required this.top,
    required this.width,
    required this.titleLeft,
    required this.titleTop,
  });

  // 中文标题
  final String title;

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
