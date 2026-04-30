import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/index.dart';
import 'package:infibo_app/pages/customized/customizedPage/1/ui.dart';
import 'package:infibo_app/pages/customized/customizedPage/2/ui.dart';
import 'package:infibo_app/pages/customized/customizedPage/3/ui.dart';
import 'package:infibo_app/pages/customized/customizedPage/4/ui.dart';
import 'package:infibo_app/pages/customized/customizedPage/logic.dart';
import 'package:infibo_app/pages/customized/logic.dart';
import 'package:infibo_app/pages/customized/plan_features.dart';

class CustomizedEditPage extends StatefulWidget {
  const CustomizedEditPage({super.key});

  @override
  State<CustomizedEditPage> createState() => _CustomizedEditPageState();
}

class _CustomizedEditPageState extends State<CustomizedEditPage> {
  static const double _designWidth = 800;
  static const double _designHeight = 1160;
  static const double _minPageScale = 0.72;

  static const String _assetRoot = 'assets/customized';
  static const String _bodyAsset = '$_assetRoot/自定义页（人）.png';
  static const String _timelineAsset = '$_assetRoot/时间轴.png';
  static const String _saveBgAsset = '$_assetRoot/保存方案框.png';

  final CustomizedEditLogic _logic = CustomizedEditLogic();
  final TextEditingController _nameController = TextEditingController();

  late final CustomizedPlanData? _editingPlan;
  late final List<Set<String>> _nodeFeatureIds;
  late final List<Set<String>> _nodeExpandIds;
  late final Set<int> _savedNodeIndexes;
  int? _activeNodeIndex;

  // 治疗模块列表。
  final List<_ModuleItem> _modules = const [
    _ModuleItem(
      id: 'redlight',
      title: '红光',
      icon: '$_assetRoot/红光添加.png',
      color: Color(0xFFF08A23),
      bgColors: [Color(0x553F3327), Color(0x3342312D)],
    ),
    _ModuleItem(
      id: 'pemf',
      title: 'PEMF',
      icon: '$_assetRoot/PEMF添加.png',
      color: Color(0xFF2FAFC1),
      bgColors: [Color(0x55304F57), Color(0x3333444A)],
    ),
    _ModuleItem(
      id: 'vat',
      title: 'VAT',
      icon: '$_assetRoot/VAT添加.png',
      color: Color(0xFF8C45D5),
      bgColors: [Color(0x554A315E), Color(0x333A2E48)],
    ),
    _ModuleItem(
      id: 'hydrogen',
      title: '分子氢',
      icon: '$_assetRoot/分子氢添加.png',
      color: Color(0xFF1F74E8),
      bgColors: [Color(0x55394D72), Color(0x33303D59)],
    ),
    _ModuleItem(
      id: 'expand',
      title: '拓展功能',
      icon: '$_assetRoot/拓展.png',
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

    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Positioned(left: 52, top: 42, child: _PageTitle()),
        Positioned(left: 186, top: 66, child: _buildBody()),
        Positioned(left: 366, top: 70, child: _buildTimeline()),
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
        if (showModulePanel)
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
    return SizedBox(
      width: 68,
      height: 917,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Image.asset(_timelineAsset, width: 28, height: 917, fit: BoxFit.fill),
          for (int index = 0; index < 12; index++)
            Positioned(
              right: -2,
              top: 48 + index * 75,
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
                    _moduleById(id).icon,
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
    return _NotchedPanel(
      width: 270,
      height: 525,
      notchSide: _NotchSide.right,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF20212B), Color(0xFF171820)],
      ),
      borderColor: const Color(0xFF383A47),
      child: Padding(
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
    );
  }

  Widget _buildExpandPanel() {
    return _NotchedPanel(
      width: 270,
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
                Image.asset('$_assetRoot/拓展.png', width: 43, height: 43),
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
            _PanelTitle(title: '红光', icon: '$_assetRoot/红光添加.png'),
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
            _PanelTitle(title: 'PEMF', icon: '$_assetRoot/PEMF添加.png'),
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
            _PanelTitle(title: 'VAT', icon: '$_assetRoot/VAT添加.png'),
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
            _PanelTitle(title: '分子氢', icon: '$_assetRoot/分子氢添加.png'),
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
    final bool canSave = _activeFeatures.isNotEmpty;

    return SizedBox(
      width: 95,
      height: 40,
      child: ElevatedButton(
        onPressed: canSave ? _saveCurrentNodeParams : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          disabledBackgroundColor: const Color(0xFF34363E),
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

    final bool? result = await Get.to<bool>(() {
      switch (id) {
        case 'chakra':
          return const ChakraExpandPage();
        case 'terahertz':
          return const TerahertzExpandPage();
        case 'hifem':
          return const HifemExpandPage();
        case 'fragrance':
          return const FragranceExpandPage();
        default:
          return const ChakraExpandPage();
      }
    });

    if (result != true || !mounted) return;

    setState(() {
      _nodeFeatureIds[index].add('expand');
      _nodeExpandIds[index].add(id);
      _savedNodeIndexes.removeWhere((item) => item >= index);
    });
  }

  // 保存当前节点参数。
  void _saveCurrentNodeParams() {
    final int? index = _activeNodeIndex;
    if (index == null || _nodeFeatureIds[index].isEmpty) return;

    setState(() => _savedNodeIndexes.add(index));
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
    required this.icon,
    required this.color,
    required this.bgColors,
  });

  final String id;
  final String title;
  final String icon;
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
            Positioned(
              left: 12,
              child: Image.asset(item.icon, width: 43, height: 43),
            ),
            Positioned(
              left: 67,
              child: Text(
                item.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Positioned(
              right: 12,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: item.color.withValues(
                  alpha: isSelected ? 0.88 : 0.38,
                ),
                child: Icon(
                  isSelected ? Icons.check : Icons.add,
                  color: Colors.white,
                  size: 17,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建模块按钮背景。
  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
          width: 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: item.bgColors,
        ),
      ),
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
      child: Container(
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
      ),
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
