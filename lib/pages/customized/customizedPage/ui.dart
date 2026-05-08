// 自定义方案编辑页。
//
// 这一页负责让用户按 5 分钟节点配置治疗模块：
// 红光、PEMF、VAT、分子氢以及拓展功能（脉轮、太赫兹、HIFEM、香氛）。
// 用户在这里选择每个节点启用哪些功能，点击“保存参数”固化当前节点，
// 最后点击“保存方案”把节点配置保存到本地方案数据里。
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/index.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/pages/customized/customizedPage/hifem/ui.dart'
    as hifem_page;
import 'package:infibo_app/pages/customized/customizedPage/mailun/ui.dart'
    as chakra_page;
import 'package:infibo_app/pages/customized/customizedPage/taihezi/ui.dart'
    as terahertz_page;
import 'package:infibo_app/pages/customized/customizedPage/xiangfen/ui.dart'
    as fragrance_page;
import 'package:infibo_app/pages/customized/customizedPage/logic.dart';
import 'package:infibo_app/pages/customized/logic.dart';
import 'package:infibo_app/pages/customized/plan_features.dart';

class CustomizedEditPage extends StatefulWidget {
  const CustomizedEditPage({super.key});

  @override
  State<CustomizedEditPage> createState() => _CustomizedEditPageState();
}

class _CustomizedEditPageState extends State<CustomizedEditPage> {
  // 设计稿尺寸。
  static const double _designWidth = 800;
  static const double _designHeight = 1160;
  // 最小缩放比例。
  static const double _minPageScale = 0.72;
  // 时间线高度。
  static const double _timelineHeight = 918;
  // 时间线节点顶部距离。
  static const double _timelineNodeTop = 48;
  // 时间线节点间距。
  static const double _timelineNodeGap = 75.2;
  // 时间线节点灯宽度。
  static const double _timelineNodeLightWidth = 30;
  // 时间线节点灯高度。
  static const double _timelineNodeLightHeight = 45;
  static const Color _timelineLightTopColor = Color(0x33B8DCFF);
  static const Color _timelineLightBottomColor = Color(0x6673A6FF);
  static const Color _timelineLightBorderColor = Color(0x3379BAFF);
  static const Color _timelineLightShadowColor = Color(0x8079BAFF);

  static const String _bodyAsset = Assets.customizedBody;
  static const String _timelineAsset = Assets.customizedTimeline;
  static const String _saveBgAsset = Assets.customizedSavePlanBox;

  final CustomizedEditLogic _logic = CustomizedEditLogic();
  final TextEditingController _nameController = TextEditingController();

  late final CustomizedPlanData? _editingPlan;
  late final List<Set<String>> _nodeFeatureIds;
  late final List<Set<String>> _nodeExpandIds;
  late final List<Map<String, String>> _nodeChakraStrengths;
  late final Set<int> _savedNodeIndexes;
  int? _activeNodeIndex;

  // 治疗模块列表。
  final List<_ModuleItem> _modules = const [
    _ModuleItem(
      id: 'redlight',
      title: '红光',
      iconOff: Assets.startRedLightIconOff,
      iconOn: Assets.startRedLightIconOn,
      addIcon: Assets.redLightAddIcon,
      rowBgAsset: Assets.addTreatmentRedLight,
      color: Color(0xFFF08A23),
      bgColors: [Color(0x553F3327), Color(0x3342312D)],
    ),
    _ModuleItem(
      id: 'pemf',
      title: 'PEMF',
      iconOff: Assets.startPemfIconOff,
      iconOn: Assets.startPemfIconOn,
      addIcon: Assets.pemfAddIcon,
      rowBgAsset: Assets.addTreatmentPemf,
      color: Color(0xFF2FAFC1),
      bgColors: [Color(0x55304F57), Color(0x3333444A)],
    ),
    _ModuleItem(
      id: 'vat',
      title: 'VAT',
      iconOff: Assets.startVatIconOff,
      iconOn: Assets.startVatIconOn,
      addIcon: Assets.vatAddIcon,
      rowBgAsset: Assets.addTreatmentVat,
      color: Color(0xFF8C45D5),
      bgColors: [Color(0x554A315E), Color(0x333A2E48)],
    ),
    _ModuleItem(
      id: 'hydrogen',
      title: '分子氢',
      iconOff: Assets.startHydrogenIconOff,
      iconOn: Assets.startHydrogenIconOn,
      addIcon: Assets.hydrogenAddIcon,
      rowBgAsset: Assets.addTreatmentHydrogen,
      color: Color(0xFF1F74E8),
      bgColors: [Color(0x55394D72), Color(0x33303D59)],
    ),
    _ModuleItem(
      id: 'expand',
      title: '拓展功能',
      iconOff: Assets.expandIconOff,
      iconOn: Assets.expandIcon,
      addIcon: Assets.expandAddIcon,
      rowBgAsset: Assets.addTreatmentExpand,
      color: Color(0xFF11A36D),
      bgColors: [Color(0x55315B45), Color(0x332A4638)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _editingPlan = _logic.editingPlan;
    _nameController.text = _editingPlan?.name ?? '';
    _nodeFeatureIds = List.generate(12, (_) => <String>{});
    _nodeExpandIds = List.generate(12, (_) => <String>{});
    _nodeChakraStrengths = List.generate(12, (_) => <String, String>{});
    _savedNodeIndexes = <int>{};
    _restoreEditingPlan();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double scale =
        ((MediaQuery.sizeOf(context).width - 32) / _designWidth)
            .clamp(_minPageScale, 1.0)
            .toDouble();

    return AppHeaderPage(
      resizeToAvoidBottomInset: false,
      children: [
        Positioned.fill(
          top: 75,
          child: Center(
            child: SizedBox(
              width: _designWidth * scale,
              height: _designHeight * scale,
              child: FittedBox(
                fit: BoxFit.contain,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: _designWidth,
                  height: _designHeight,
                  child: _buildCanvas(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCanvas() {
    final bool showModulePanel = _activeNodeIndex != null;
    final Set<String> activeFeatures = _activeFeatures;
    final bool showSaveParamsButton =
        showModulePanel && activeFeatures.isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Positioned(left: 52, top: 42, child: _PageTitle()),
        Positioned(left: 186, top: 66, child: _buildBody()),
        Positioned(left: 366, top: 86, child: _buildTimeline()),
        ..._buildSavedNodeFeatureDots(),
        if (showModulePanel)
          Positioned(left: 45, top: 102, child: _buildAddModulePanel()),
        if (showModulePanel && activeFeatures.contains('expand'))
          Positioned(left: 45, top: 650, child: _buildExpandPanel()),
        if (activeFeatures.contains('redlight'))
          Positioned(left: 485, top: 75, child: _buildRedLightPanel()),
        if (activeFeatures.contains('pemf'))
          Positioned(left: 485, top: 330, child: _buildPemfPanel()),
        if (activeFeatures.contains('vat'))
          Positioned(left: 485, top: 590, child: _buildVatPanel()),
        if (activeFeatures.contains('hydrogen'))
          Positioned(left: 485, top: 755, child: _buildHydrogenPanel()),
        if (showSaveParamsButton)
          Positioned(left: 660, top: 936, child: _buildSaveParamsButton()),
        Positioned(left: 175, bottom: 22, child: _buildSavePlanButton()),
      ],
    );
  }

  Widget _buildBody() {
    return Image.asset(
      _bodyAsset,
      width: 428,
      height: 1024,
      fit: BoxFit.contain,
    );
  }

  Widget _buildTimeline() {
    final List<int> lightedIndexes = _lightedTimelineIndexes;

    return SizedBox(
      width: 68,
      height: _timelineHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Image.asset(
            _timelineAsset,
            width: 28,
            height: _timelineHeight,
            fit: BoxFit.fill,
          ),
          for (final int index in lightedIndexes) _buildLightedTimeline(index),
          for (int index = 0; index < 12; index++)
            Positioned(
              right: -2,
              top: _timelineNodeTop + index * _timelineNodeGap,
              child: _TimelineAddButton(
                isSaved: _savedNodeIndexes.contains(index),
                isActive: _activeNodeIndex == index,
                onTap: () => _selectNode(index),
              ),
            ),
        ],
      ),
    );
  }

  // 按当前节点裁剪蓝色时间轴，保留用户已经选择到哪一个 5 分钟节点的提示。
  Widget _buildLightedTimeline(int index) {
    final double top =
        (index == 0
                ? 37
                : _timelineNodeTop +
                      index * _timelineNodeGap -
                      _timelineNodeLightHeight / 2 +
                      12)
            .clamp(0, _timelineHeight - _timelineNodeLightHeight)
            .toDouble();

    return Positioned(
      top: top,
      child: Container(
        width: _timelineNodeLightWidth,
        height: _timelineNodeLightHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _timelineLightBorderColor, width: 1),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_timelineLightTopColor, _timelineLightBottomColor],
          ),
          boxShadow: const [
            BoxShadow(
              color: _timelineLightShadowColor,
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
      ),
    );
  }

  // 构建已保存节点左侧的大功能图标。
  List<Widget> _buildSavedNodeFeatureDots() {
    return [
      for (final int index in _savedNodeIndexes)
        Positioned(
          left: 245,
          top: 118 + index * 75,
          child: Row(
            children: [
              for (final String id in _orderedFeatureIds(
                _nodeFeatureIds[index],
              ))
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Image.asset(
                    _moduleById(id).iconOn,
                    width: 24,
                    height: 24,
                  ),
                ),
            ],
          ),
        ),
    ];
  }

  Widget _buildAddModulePanel() {
    return SizedBox(
      width: 270,
      height: 525,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(Assets.addTreatmentIcon, fit: BoxFit.fill),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '添加治疗模块',
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
                const SizedBox(height: 18),
                for (final _ModuleItem item in _modules) ...[
                  _ModuleRow(
                    item: item,
                    isSelected: _activeFeatures.contains(item.id),
                    onTap: () => _toggleFeature(item.id),
                  ),
                  if (item != _modules.last) const SizedBox(height: 18),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandPanel() {
    return _NotchedPanel(
      width: 250,
      height: 255,
      notchSide: _NotchSide.right,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x66365F4B), Color(0x5522352D)],
      ),
      borderColor: const Color(0xFF5A8E77),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 22, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '拓展功能',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ),
                Image.asset(Assets.expandIcon, width: 43, height: 43),
              ],
            ),
            const SizedBox(height: 15),
            _buildExpandLine(
              id: 'chakra',
              text: '脉轮',
              icon: Icons.bubble_chart_outlined,
            ),
            _buildExpandLine(
              id: 'terahertz',
              text: '太赫兹',
              icon: Icons.sensors_outlined,
            ),
            _buildExpandLine(
              id: 'hifem',
              text: 'HIFEM',
              icon: Icons.monitor_heart_outlined,
            ),
            _buildExpandLine(
              id: 'fragrance',
              text: '香氛',
              icon: Icons.waves_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandLine({
    required String id,
    required String text,
    required IconData icon,
  }) {
    final bool isSelected = _activeExpandFeatures.contains(id);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openExpandPage(id),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 11),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF38C78D)
                    : const Color(0xFF9EAEA6),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFFC8D4CD),
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            CircleAvatar(
              radius: 12,
              backgroundColor: isSelected
                  ? const Color(0xFF38C78D)
                  : const Color(0x334B6F61),
              child: const Icon(
                Icons.chevron_right,
                color: Color(0xFFB7C7BE),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRedLightPanel() {
    return _NotchedPanel(
      width: 270,
      height: 250,
      notchSide: _NotchSide.left,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xAA5A4936), Color(0x9940342E)],
      ),
      borderColor: const Color(0xFF7E6651),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PanelTitle(title: '红光', icon: _moduleById('redlight').iconOn),
            const SizedBox(height: 18),
            _buildTwoColumnLabels('波长', '强度'),
            const SizedBox(height: 6),
            _buildWavelengthRow('660'),
            const SizedBox(height: 16),
            _buildTwoColumnLabels('波长', '强度'),
            const SizedBox(height: 6),
            _buildWavelengthRow('660'),
            const Spacer(),
            Row(
              children: const [
                Text('模式选择', style: _smallLabelStyle),
                SizedBox(width: 25),
                Text('连续', style: _smallLabelStyle),
                SizedBox(width: 5),
                _RadioDot(active: false, color: Color(0xFFF08A23)),
                SizedBox(width: 12),
                Text('脉冲', style: _smallLabelStyle),
                SizedBox(width: 5),
                _RadioDot(active: true, color: Color(0xFFF08A23)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPemfPanel() {
    return _NotchedPanel(
      width: 270,
      height: 238,
      notchSide: _NotchSide.left,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x993B5E66), Color(0x77304952)],
      ),
      borderColor: const Color(0xFF63808A),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PanelTitle(title: 'PEMF', icon: _moduleById('pemf').iconOn),
            const SizedBox(height: 20),
            _buildTwoColumnLabels('频率', '强度'),
            const SizedBox(height: 7),
            Row(
              children: const [
                _InputBox(width: 88),
                SizedBox(width: 30),
                _InputBox(width: 88),
              ],
            ),
            const SizedBox(height: 16),
            const Text('波形', style: _smallLabelStyle),
            const SizedBox(height: 7),
            const _InputBox(width: 206, hasArrow: true),
          ],
        ),
      ),
    );
  }

  Widget _buildVatPanel() {
    return _NotchedPanel(
      width: 270,
      height: 160,
      notchSide: _NotchSide.left,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x88543A69), Color(0x6638264B)],
      ),
      borderColor: const Color(0xFF80649A),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PanelTitle(title: 'VAT', icon: _moduleById('vat').iconOn),
            const SizedBox(height: 17),
            _buildTwoColumnLabels('频率', '强度'),
            const SizedBox(height: 7),
            Row(
              children: const [
                _InputBox(width: 88),
                SizedBox(width: 30),
                _InputBox(width: 88),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHydrogenPanel() {
    return _NotchedPanel(
      width: 270,
      height: 160,
      notchSide: _NotchSide.left,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x77405B80), Color(0x55334459)],
      ),
      borderColor: const Color(0xFF59739E),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PanelTitle(title: '分子氢', icon: _moduleById('hydrogen').iconOn),
            const SizedBox(height: 17),
            _buildTwoColumnLabels('氢气浓度', '流量'),
            const SizedBox(height: 7),
            Row(
              children: const [
                _InputBox(width: 88),
                SizedBox(width: 30),
                _InputBox(width: 88),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTwoColumnLabels(String left, String right) {
    return Row(
      children: [
        SizedBox(width: 88, child: Text(left, style: _smallLabelStyle)),
        const SizedBox(width: 30),
        SizedBox(width: 88, child: Text(right, style: _smallLabelStyle)),
      ],
    );
  }

  Widget _buildWavelengthRow(String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 88,
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                const TextSpan(
                  text: ' nm',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 30),
        const _InputBox(width: 88),
      ],
    );
  }

  Widget _buildSaveParamsButton() {
    return SizedBox(
      width: 95,
      height: 40,
      child: ElevatedButton(
        onPressed: _saveCurrentNodeParams,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF1F74E8),
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        child: const Text('保存参数'),
      ),
    );
  }

  Widget _buildSavePlanButton() {
    final bool canSave = _savedNodeIndexes.contains(0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: canSave ? _showSaveDialog : null,
      child: SizedBox(
        width: 451,
        height: 56,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: canSave
                  ? Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F74E8),
                        borderRadius: BorderRadius.circular(28),
                      ),
                    )
                  : Image.asset(_saveBgAsset, fit: BoxFit.fill),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.description_outlined,
                  color: canSave ? Colors.white : const Color(0xFFC4C7D0),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '保存方案',
                  style: TextStyle(
                    color: canSave ? Colors.white : const Color(0xFFC4C7D0),
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _toggleFeature(String id) {
    final int? index = _activeNodeIndex;
    if (index == null) return;

    setState(() {
      if (_nodeFeatureIds[index].contains(id)) {
        _nodeFeatureIds[index].remove(id);
        if (id == 'expand') _nodeExpandIds[index].clear();
      } else {
        _nodeFeatureIds[index].add(id);
      }
      _savedNodeIndexes.removeWhere((item) => item >= index);
    });
  }

  // 选择一个 5 分钟节点。
  void _selectNode(int index) {
    if (_activeNodeIndex == index) {
      setState(() => _activeNodeIndex = null);
      return;
    }

    if (index > 0 && !_savedNodeIndexes.contains(index - 1)) {
      _showMessage('请先完成上一个 5 分钟节点');
      return;
    }

    setState(() {
      _activeNodeIndex = index;
    });
  }

  // 打开拓展功能设置页。
  Future<void> _openExpandPage(String id) async {
    final int? index = _activeNodeIndex;
    if (index == null) return;

    // 打开具体拓展设置页前先预加载图片，减少页面切换时的闪烁。
    await _precacheExpandPageAssets(id);
    if (!mounted) return;

    final Object? result = await Get.to<Object?>(
      () => _buildExpandPage(id, index),
      preventDuplicates: false,
      transition: Transition.noTransition,
      duration: Duration.zero,
      curve: Curves.linear,
    );

    if (!mounted) return;

    if (id == 'chakra') {
      if (result is! chakra_page.ChakraExpandResult ||
          result.strengths.isEmpty) {
        return;
      }

      setState(() {
        _nodeFeatureIds[index].add('expand');
        _nodeExpandIds[index].add(id);
        _nodeChakraStrengths[index]
          ..clear()
          ..addAll(result.strengths);
        _savedNodeIndexes.removeWhere((item) => item >= index);
      });
      return;
    }

    if (result != true) return;

    setState(() {
      _nodeFeatureIds[index].add('expand');
      _nodeExpandIds[index].add(id);
      _savedNodeIndexes.removeWhere((item) => item >= index);
    });
  }

  Widget _buildExpandPage(String id, int index) {
    switch (id) {
      case 'chakra':
        return chakra_page.ChakraExpandPage(
          initialStrengths: _nodeChakraStrengths[index],
        );
      case 'terahertz':
        return const terahertz_page.TerahertzExpandPage();
      case 'hifem':
        return const hifem_page.HifemExpandPage();
      case 'fragrance':
        return const fragrance_page.FragranceExpandPage();
      default:
        return chakra_page.ChakraExpandPage(
          initialStrengths: _nodeChakraStrengths[index],
        );
    }
  }

  Future<void> _precacheExpandPageAssets(String id) async {
    final List<String> assetPaths = switch (id) {
      'chakra' => [
        Assets.chakraBody,
        Assets.chakraConfirmDisabled,
        Assets.chakraConfirmEnabled,
        Assets.chakraIntensityPanel,
        Assets.chakraCrown,
        Assets.chakraCrownSelected,
        Assets.chakraThirdEye,
        Assets.chakraThirdEyeSelected,
        Assets.chakraThroat,
        Assets.chakraThroatSelected,
        Assets.chakraHeart,
        Assets.chakraHeartSelected,
        Assets.chakraSolarPlexus,
        Assets.chakraSolarPlexusSelected,
        Assets.chakraSacral,
        Assets.chakraSacralSelected,
        Assets.chakraRoot,
        Assets.chakraRootSelected,
      ],
      'terahertz' => [
        Assets.terahertzBody,
        Assets.terahertzConfirmDisabled,
        Assets.terahertzConfirmEnabled,
        Assets.terahertzRadioDefault,
        Assets.terahertzRadioSelected,
        Assets.terahertzProgressDefaultBar,
        Assets.terahertzProgressDefaultThumb,
        Assets.terahertzFrequencyBar,
        Assets.terahertzFrequencyThumb,
        Assets.terahertzPowerBar,
        Assets.terahertzPowerThumb,
      ],
      'hifem' => [
        Assets.hifemConfirmButton,
        Assets.hifemHeadBase,
        Assets.hifemForeheadLeftDefault,
        Assets.hifemForeheadLeftSelected,
        Assets.hifemForeheadRightDefault,
        Assets.hifemForeheadRightSelected,
        Assets.hifemCheekLeftDefault,
        Assets.hifemCheekLeftSelected,
        Assets.hifemCheekRightDefault,
        Assets.hifemCheekRightSelected,
        Assets.hifemRfIcon,
        Assets.hifemRfDisabledIcon,
        Assets.hifemHifesIcon,
        Assets.hifemHifesDisabledIcon,
        Assets.hifemTimeIcon,
        Assets.hifemTimeDisabledIcon,
        Assets.hifemProgressDefaultBar,
        Assets.hifemProgressDefaultThumb,
        Assets.hifemRfBar,
        Assets.hifemRfThumb,
        Assets.hifemHifesBar,
        Assets.hifemHifesThumb,
        Assets.hifemTimeBar,
        Assets.hifemTimeThumb,
      ],
      'fragrance' => [
        Assets.fragranceDiffuser,
        Assets.fragranceChoicePanel,
        Assets.fragranceChoiceLine,
        Assets.fragranceConfirmDisabled,
        Assets.fragranceConfirmEnabled,
        Assets.fragranceSoftDefault,
        Assets.fragranceSoftSelected,
        Assets.fragranceStrongDefault,
        Assets.fragranceStrongSelected,
        Assets.fragranceSleepDefault,
        Assets.fragranceSleepSelected,
        Assets.fragranceFlowDefault,
        Assets.fragranceFlowSelected,
        Assets.fragranceMeditationDefault,
        Assets.fragranceMeditationSelected,
      ],
      _ => <String>[],
    };

    await Future.wait(
      assetPaths.map((String path) => precacheImage(AssetImage(path), context)),
    );
  }

  // 保存当前节点参数。
  void _saveCurrentNodeParams() {
    final int? index = _activeNodeIndex;
    if (index == null || _nodeFeatureIds[index].isEmpty) return;

    setState(() {
      _savedNodeIndexes.add(index);
      _activeNodeIndex = null;
    });
    _showMessage('第 ${(index + 1) * 5} 分钟节点参数已保存');
  }

  Future<void> _showSaveDialog() async {
    final String? name = await showDialog<String>(
      context: context,
      builder: (context) => _PlanNameDialog(controller: _nameController),
    );

    if (name == null) return;

    try {
      await _logic.savePlan(name: name, featureIds: _buildPlanFeatureIds());
    } on CustomizedPlanNameException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
      return;
    }
    Get.back(result: true);
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Set<String> get _activeFeatures {
    final int? index = _activeNodeIndex;
    if (index == null) return <String>{};
    return _nodeFeatureIds[index];
  }

  List<int> get _lightedTimelineIndexes {
    final Set<int> result = <int>{..._savedNodeIndexes};
    final int? activeIndex = _activeNodeIndex;
    if (activeIndex != null) result.add(activeIndex);

    return result.toList()..sort();
  }

  Set<String> get _activeExpandFeatures {
    final int? index = _activeNodeIndex;
    if (index == null) return <String>{};
    return _nodeExpandIds[index];
  }

  // 从已有方案恢复节点数据。
  void _restoreEditingPlan() {
    final List<String> featureIds = _editingPlan?.featureIds ?? const [];
    bool hasPhaseData = false;

    for (final String text in featureIds) {
      if (!text.startsWith('phase:')) continue;

      final List<String> parts = text.split(':');
      if (parts.length < 3) continue;

      final int? index = int.tryParse(parts[1]);
      if (index == null || index < 0 || index >= _nodeFeatureIds.length) {
        continue;
      }

      final Set<String> ids = parts[2]
          .split('|')
          .where((id) => _isKnownModuleId(id))
          .toSet();
      if (ids.isEmpty) continue;

      _nodeFeatureIds[index] = ids;
      _savedNodeIndexes.add(index);
      hasPhaseData = true;
    }

    for (final String text in featureIds) {
      if (!text.startsWith('expand:')) continue;

      final List<String> parts = text.split(':');
      if (parts.length < 3) continue;

      final int? index = int.tryParse(parts[1]);
      if (index == null || index < 0 || index >= _nodeExpandIds.length) {
        continue;
      }

      _nodeExpandIds[index] = parts[2]
          .split('|')
          .where((id) => id.trim().isNotEmpty)
          .toSet();
    }

    for (final String text in featureIds) {
      if (!text.startsWith('chakra:')) continue;

      final List<String> parts = text.split(':');
      if (parts.length < 3) continue;

      final int? index = int.tryParse(parts[1]);
      if (index == null || index < 0 || index >= _nodeChakraStrengths.length) {
        continue;
      }

      final Map<String, String> strengths = _parseChakraStrengths(parts[2]);
      if (strengths.isEmpty) continue;

      _nodeChakraStrengths[index]
        ..clear()
        ..addAll(strengths);
      _nodeFeatureIds[index].add('expand');
      _nodeExpandIds[index].add('chakra');
      _savedNodeIndexes.add(index);
      hasPhaseData = true;
    }

    if (!hasPhaseData && _editingPlan != null) {
      final Set<String> ids = knownFeatureIds(featureIds).toSet();
      if (ids.isNotEmpty) {
        _nodeFeatureIds[0] = ids;
        _savedNodeIndexes.add(0);
      }
    }
  }

  // 生成保存到数据库的功能数据。
  List<String> _buildPlanFeatureIds() {
    // 保存到数据库的是字符串列表：
    // - redlight/pemf/vat/hydrogen/expand 表示方案用到了哪些大模块；
    // - phase:index:a|b|c 表示某个 5 分钟节点启用哪些模块；
    // - expand:index:chakra|hifem 表示某个节点启用了哪些拓展功能；
    // - chakra:index:id=value|id=value 表示脉轮强度参数。
    final Set<String> allFeatureIds = <String>{};
    final List<String> phaseTexts = [];
    final List<int> indexes = _savedNodeIndexes.toList()..sort();

    for (final int index in indexes) {
      final List<String> ids = _orderedFeatureIds(_nodeFeatureIds[index]);
      if (ids.isEmpty) continue;

      allFeatureIds.addAll(ids);
      phaseTexts.add('phase:$index:${ids.join('|')}');
      if (_nodeExpandIds[index].isNotEmpty) {
        phaseTexts.add('expand:$index:${_nodeExpandIds[index].join('|')}');
      }
      if (_nodeChakraStrengths[index].isNotEmpty) {
        phaseTexts.add(
          'chakra:$index:${_formatChakraStrengths(_nodeChakraStrengths[index])}',
        );
      }
    }

    return [..._orderedFeatureIds(allFeatureIds), ...phaseTexts];
  }

  List<String> _orderedFeatureIds(Set<String> ids) {
    return [
      for (final _ModuleItem item in _modules)
        if (ids.contains(item.id)) item.id,
    ];
  }

  bool _isKnownModuleId(String id) {
    return _modules.any((item) => item.id == id);
  }

  Map<String, String> _parseChakraStrengths(String text) {
    final Map<String, String> result = <String, String>{};

    for (final String pair in text.split('|')) {
      final int separator = pair.indexOf('=');
      if (separator <= 0 || separator == pair.length - 1) continue;

      final String id = pair.substring(0, separator);
      final String value = pair.substring(separator + 1);
      if (id.trim().isEmpty || value.trim().isEmpty) continue;

      result[id] = value;
    }

    return result;
  }

  String _formatChakraStrengths(Map<String, String> strengths) {
    return strengths.entries
        .where((entry) => entry.value.trim().isNotEmpty)
        .map((entry) => '${entry.key}=${entry.value.trim()}')
        .join('|');
  }

  _ModuleItem _moduleById(String id) {
    return _modules.firstWhere((item) => item.id == id);
  }
}

const TextStyle _smallLabelStyle = TextStyle(
  color: Color(0xFFE4E7EE),
  fontSize: 14,
  height: 1,
);

class _PageTitle extends StatelessWidget {
  const _PageTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      '自定义方案',
      style: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _ModuleItem {
  const _ModuleItem({
    required this.id,
    required this.title,
    required this.iconOff,
    required this.iconOn,
    required this.addIcon,
    required this.rowBgAsset,
    required this.color,
    required this.bgColors,
  });

  final String id;
  final String title;
  final String iconOff;
  final String iconOn;
  final String addIcon;
  final String rowBgAsset;
  final Color color;
  final List<Color> bgColors;
}

class _ModuleRow extends StatelessWidget {
  const _ModuleRow({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _ModuleItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 206,
        height: 72,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Positioned.fill(child: _buildBackground()),
            Positioned(left: 12, child: _buildIcon()),
            Positioned(
              left: 67,
              child: Text(
                item.title,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF9B9DA6),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Positioned(
              right: 12,
              child: isSelected
                  ? Image.asset(item.addIcon, width: 24, height: 24)
                  : const CircleAvatar(
                      radius: 12,
                      backgroundColor: Color(0xFF4A4D56),
                      child: Icon(
                        Icons.add,
                        color: Color(0xFFC4C7D0),
                        size: 17,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建模块图标，未选择时显示灰色图标，选择后显示彩色图标。
  Widget _buildIcon() {
    return Image.asset(
      isSelected ? item.iconOn : item.iconOff,
      width: 43,
      height: 43,
    );
  }

  Widget _buildBackground() {
    return Image.asset(
      isSelected ? item.rowBgAsset : Assets.addTreatmentRowDefault,
      fit: BoxFit.fill,
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({required this.title, required this.icon});

  final String title;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              height: 1,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Image.asset(icon, width: 43, height: 43),
      ],
    );
  }
}

class _InputBox extends StatelessWidget {
  const _InputBox({required this.width, this.hasArrow = false});

  final double width;
  final bool hasArrow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 29,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.20),
          width: 1,
        ),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 6),
      child: hasArrow
          ? Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white.withValues(alpha: 0.65),
              size: 18,
            )
          : null,
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.active, required this.color});

  final bool active;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: active ? color : Colors.white24, width: 1.5),
      ),
      alignment: Alignment.center,
      child: active
          ? Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            )
          : null,
    );
  }
}

class _TimelineAddButton extends StatelessWidget {
  const _TimelineAddButton({
    required this.isSaved,
    required this.isActive,
    required this.onTap,
  });

  final bool isSaved;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: _buildButton(),
    );
  }

  Widget _buildButton() {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSaved || isActive
              ? const [Color(0xFF75B6FF), Color(0xFF1F6EF2)]
              : const [Color(0xFF4D83E8), Color(0xFF244EBC)],
        ),
        boxShadow: [
          BoxShadow(
            color: isSaved || isActive
                ? const Color(0xDD3B8DFF)
                : const Color(0x883B73E8),
            blurRadius: isSaved || isActive ? 16 : 9,
            spreadRadius: isSaved || isActive ? 3 : 1,
          ),
        ],
      ),
      child: const Icon(Icons.add, color: Colors.white, size: 16),
    );
  }
}

enum _NotchSide { left, right }

class _NotchedPanel extends StatelessWidget {
  const _NotchedPanel({
    required this.width,
    required this.height,
    required this.notchSide,
    required this.gradient,
    required this.borderColor,
    required this.child,
  });

  final double width;
  final double height;
  final _NotchSide notchSide;
  final Gradient gradient;
  final Color borderColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _NotchedPanelPainter(
        notchSide: notchSide,
        gradient: gradient,
        borderColor: borderColor,
      ),
      child: SizedBox(width: width, height: height, child: child),
    );
  }
}

class _NotchedPanelPainter extends CustomPainter {
  const _NotchedPanelPainter({
    required this.notchSide,
    required this.gradient,
    required this.borderColor,
  });

  final _NotchSide notchSide;
  final Gradient gradient;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = _buildPath(size);
    final Rect rect = Offset.zero & size;

    canvas.drawShadow(path, const Color(0x77233D55), 18, true);
    canvas.drawPath(
      path,
      Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  Path _buildPath(Size size) {
    const double radius = 18;
    const double notchWidth = 28;
    const double notchHeight = 30;
    final double notchTop = size.height * 0.21;
    final double notchMid = notchTop + notchHeight / 2;

    final Path path = Path();
    if (notchSide == _NotchSide.right) {
      path
        ..moveTo(radius, 0)
        ..lineTo(size.width - radius, 0)
        ..quadraticBezierTo(size.width, 0, size.width, radius)
        ..lineTo(size.width, notchTop)
        ..lineTo(size.width + notchWidth, notchMid)
        ..lineTo(size.width, notchTop + notchHeight)
        ..lineTo(size.width, size.height - radius)
        ..quadraticBezierTo(
          size.width,
          size.height,
          size.width - radius,
          size.height,
        )
        ..lineTo(radius, size.height)
        ..quadraticBezierTo(0, size.height, 0, size.height - radius)
        ..lineTo(0, radius)
        ..quadraticBezierTo(0, 0, radius, 0);
    } else {
      path
        ..moveTo(radius, 0)
        ..lineTo(size.width - radius, 0)
        ..quadraticBezierTo(size.width, 0, size.width, radius)
        ..lineTo(size.width, size.height - radius)
        ..quadraticBezierTo(
          size.width,
          size.height,
          size.width - radius,
          size.height,
        )
        ..lineTo(radius, size.height)
        ..quadraticBezierTo(0, size.height, 0, size.height - radius)
        ..lineTo(0, notchTop + notchHeight)
        ..lineTo(-notchWidth, notchMid)
        ..lineTo(0, notchTop)
        ..lineTo(0, radius)
        ..quadraticBezierTo(0, 0, radius, 0);
    }

    return path..close();
  }

  @override
  bool shouldRepaint(covariant _NotchedPanelPainter oldDelegate) {
    return oldDelegate.notchSide != notchSide ||
        oldDelegate.gradient != gradient ||
        oldDelegate.borderColor != borderColor;
  }
}

class _PlanNameDialog extends StatelessWidget {
  const _PlanNameDialog({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF202127),
      title: const Text('方案命名', style: TextStyle(color: Colors.white)),
      content: TextField(
        controller: controller,
        autofocus: true,
        cursorColor: Colors.white,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: '输入方案名称',
          hintStyle: TextStyle(color: Color(0xFF737782)),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF4A4D57)),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF1F74E8)),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            final String name = controller.text.trim();
            if (name.isEmpty) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('方案名称不能为空')));
              return;
            }
            Navigator.of(context).pop(name);
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
