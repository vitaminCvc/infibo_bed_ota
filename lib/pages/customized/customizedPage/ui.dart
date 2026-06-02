// 自定义方案编辑页。
//
// 这一页负责让用户按 5 分钟节点配置治疗模块：
// 红光、PEMF、VAT、分子氢以及拓展功能（脉轮、太赫兹、HIFEM、香氛）。
// 用户在这里选择每个节点启用哪些功能，点击“保存参数”固化当前节点，
// 最后点击“保存方案”把节点配置保存到本地方案数据里。
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:infibo_app/pages/music/logic.dart';
import 'package:infibo_app/stores/hifem_setting_store.dart';

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
  // 时间线节点加号顶部距离。
  static const double _timelineNodeTop = 48;
  // 时间线节点间距。
  static const double _timelineNodeGap = 75.15;

  // 时间轴在 _buildCanvas 里的位置
  static const double _timelineTopInCanvas = 86;

  // timelight 图片大小

  static const double _timeLightHeight = 98;

  // timelight 在 _buildCanvas 里的 left 位置
  // 数值越小越靠左，越靠近人体；数值越大越靠右，越靠近时间轴
  static const double _timeLightLeft = 380;

  // // 时间线节点灯宽度。
  // static const double _timelineNodeLightWidth = 34;
  // // 时间线节点灯高度。
  // static const double _timelineNodeLightHeight = 45;
  // static const Color _timelineLightTopColor = Color.fromARGB(51, 245, 49, 4);
  // static const Color _timelineLightBottomColor = Color(0x6673A6FF);
  // static const Color _timelineLightBorderColor = Color(0x3379BAFF);
  // static const Color _timelineLightShadowColor = Color(0x8079BAFF);

  static const String _bodyAsset = Assets.customizedBody;
  static const String _timelineAsset = Assets.customizedTimeline;
  static const String _saveBgAsset = Assets.customizedSavePlanBox;
  static const String _pemfWaveDialogAsset = Assets.customizedPemfWaveDialog;

  final CustomizedEditLogic _logic = CustomizedEditLogic();
  final TextEditingController _nameController = TextEditingController();

  late final CustomizedPlanData? _editingPlan;
  late final List<Set<String>> _nodeFeatureIds;
  late final List<Set<String>> _nodeExpandIds;
  late final List<Map<String, String>> _nodeChakraStrengths;
  late final List<String> _nodeChakraModes;
  late final List<terahertz_page.TerahertzExpandResult?> _nodeTerahertzSettings;
  late final List<hifem_page.HifemExpandResult?> _nodeHifemSettings;
  late final List<fragrance_page.FragranceExpandResult?> _nodeFragranceSettings;
  late final List<TextEditingController> _redLight660Controllers;
  late final List<TextEditingController> _redLight850Controllers;
  late final List<TextEditingController> _pemfFrequencyControllers;
  late final List<TextEditingController> _pemfIntensityControllers;
  late final List<FocusNode> _redLight660FocusNodes;
  late final List<FocusNode> _redLight850FocusNodes;
  late final List<FocusNode> _pemfFrequencyFocusNodes;
  late final List<FocusNode> _pemfIntensityFocusNodes;
  late final List<TextEditingController> _vatFrequencyControllers;
  late final TextEditingController _vatIntensityController;
  late final List<FocusNode> _vatFrequencyFocusNodes;
  _VatMusicSetting _vatMusicSetting = const _VatMusicSetting();
  late final List<TextEditingController> _hydrogenConcentrationControllers;
  late final List<FocusNode> _hydrogenConcentrationFocusNodes;
  late final List<_RedLightMode> _nodeRedLightModes;
  late final List<_PemfWave?> _nodePemfWaves;
  late final Set<int> _savedNodeIndexes;
  int? _activeNodeIndex;
  int? _pemfWavePickerNodeIndex;
  bool _didPrecachePemfWaveDialog = false;

  // 治疗模块列表。
  late final List<_ModuleItem> _modules = [
    _ModuleItem(
      id: 'redlight',
      title: 'red_ther'.tr,
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
      title: 'module_hydrogen'.tr,
      iconOff: Assets.startHydrogenIconOff,
      iconOn: Assets.startHydrogenIconOn,
      addIcon: Assets.hydrogenAddIcon,
      rowBgAsset: Assets.addTreatmentHydrogen,
      color: Color(0xFF1F74E8),
      bgColors: [Color(0x55394D72), Color(0x33303D59)],
    ),
    _ModuleItem(
      id: 'expand',
      title: 'module_expand'.tr,
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
    _nodeChakraModes = List.generate(12, (_) => 'rotation');
    _nodeTerahertzSettings = List.generate(12, (_) => null);
    _nodeHifemSettings = List.generate(12, (_) => null);
    _nodeFragranceSettings = List.generate(12, (_) => null);
    _redLight660Controllers = List.generate(12, (_) => TextEditingController());
    _redLight850Controllers = List.generate(12, (_) => TextEditingController());
    _pemfFrequencyControllers = List.generate(
      12,
      (_) => TextEditingController(),
    );
    _pemfIntensityControllers = List.generate(
      12,
      (_) => TextEditingController(),
    );
    _redLight660FocusNodes = List.generate(12, (_) => FocusNode());
    _redLight850FocusNodes = List.generate(12, (_) => FocusNode());
    _pemfFrequencyFocusNodes = List.generate(12, (_) => FocusNode());
    _pemfIntensityFocusNodes = List.generate(12, (_) => FocusNode());
    _vatFrequencyControllers = List.generate(
      12,
      (_) => TextEditingController(),
    );
    _vatIntensityController = TextEditingController();
    _vatFrequencyFocusNodes = List.generate(12, (_) => FocusNode());
    _hydrogenConcentrationControllers = List.generate(
      12,
      (_) => TextEditingController(),
    );
    _hydrogenConcentrationFocusNodes = List.generate(12, (_) => FocusNode());
    _nodeRedLightModes = List.generate(12, (_) => _RedLightMode.continuous);
    _nodePemfWaves = List.generate(12, (_) => _defaultPemfWave);
    _savedNodeIndexes = <int>{};
    _restoreEditingPlan();
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final TextEditingController controller in _redLight660Controllers) {
      controller.dispose();
    }
    for (final TextEditingController controller in _redLight850Controllers) {
      controller.dispose();
    }
    for (final TextEditingController controller in _pemfFrequencyControllers) {
      controller.dispose();
    }
    for (final TextEditingController controller in _pemfIntensityControllers) {
      controller.dispose();
    }
    for (final FocusNode node in _redLight660FocusNodes) {
      node.dispose();
    }
    for (final FocusNode node in _redLight850FocusNodes) {
      node.dispose();
    }
    for (final FocusNode node in _pemfFrequencyFocusNodes) {
      node.dispose();
    }
    for (final FocusNode node in _pemfIntensityFocusNodes) {
      node.dispose();
    }
    for (final TextEditingController controller in _vatFrequencyControllers) {
      controller.dispose();
    }
    _vatIntensityController.dispose();
    for (final FocusNode node in _vatFrequencyFocusNodes) {
      node.dispose();
    }
    for (final TextEditingController controller
        in _hydrogenConcentrationControllers) {
      controller.dispose();
    }
    for (final FocusNode node in _hydrogenConcentrationFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecachePemfWaveDialog) return;

    _didPrecachePemfWaveDialog = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      precacheImage(
        const AssetImage(_pemfWaveDialogAsset),
        context,
        onError: (error, stackTrace) {
          debugPrint('Failed to precache PEMF wave dialog: $error');
        },
      );
    });
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
        Positioned(
          left: 186,
          top: 66,
          child: RepaintBoundary(child: _buildBody()),
        ),
        //添加时间轴底部灯光
        ..._buildTimelineLight(),

        Positioned(
          left: 366,
          top: 86,
          //给这一块 UI 套一个“独立绘制区域”。
          child: RepaintBoundary(child: _buildTimeline()),
        ),
        ..._buildSavedNodeFeatureDots(),
        if (showModulePanel)
          Positioned(left: 45, top: 102, child: _buildAddModulePanel()),
        if (showModulePanel && activeFeatures.contains('expand'))
          Positioned(left: 45, top: 650, child: _buildExpandPanel()),
        if (activeFeatures.contains('redlight'))
          Positioned(left: 485, top: 75, child: _buildRedLightPanel()),
        if (activeFeatures.contains('pemf'))
          Positioned(left: 485, top: 381, child: _buildPemfPanel()),
        if (activeFeatures.contains('vat'))
          Positioned(left: 485, top: 637, child: _buildVatPanel()),
        if (activeFeatures.contains('hydrogen'))
          Positioned(left: 485, top: 815, child: _buildHydrogenPanel()),
        if (showSaveParamsButton)
          Positioned(left: 660, top: 993, child: _buildSaveParamsButton()),
        Positioned(left: 175, bottom: 22, child: _buildSavePlanButton()),
        if (_pemfWavePickerNodeIndex != null) ..._buildPemfWavePickerOverlay(),
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

  //创建底部灯光条
  List<Widget> _buildTimelineLight() {
    return [
      //从 _lightedTimelineIndexes 这个列表里，一个一个取出时间节点的下标，每取出一个，就执行一次后面的代码。
      for (final int index in _lightedTimelineIndexes)
        Positioned(
          left: _timeLightLeft,
          //页面里时间轴的 top+ 时间轴里第一个节点的位置+ 当前是第几个节点 * 节点间距+ 微调偏移- 图片高度的一半
          top:
              (_timelineTopInCanvas +
                      _timelineNodeTop +
                      _timelineNodeGap * index +
                      12 -
                      _timeLightHeight / 2)
                  .clamp(
                    _timelineTopInCanvas,
                    _timelineTopInCanvas + _timelineHeight - _timeLightHeight,
                  )
                  .toDouble(),
          child: IgnorePointer(
            child: Image.asset(Assets.timelight, fit: BoxFit.fill),
          ),
        ),
    ];
  }

  Widget _buildTimeline() {
    // final List<int> lightedIndexes = _lightedTimelineIndexes;

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
          // for (final int index in lightedIndexes) _buildLightedTimeline(index),
          for (int index = 0; index < 12; index++)
            Positioned(
              right: -18,
              top: _timelineNodeTop + index * _timelineNodeGap - 16,
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

  // // 按当前节点裁剪蓝色时间轴，保留用户已经选择到哪一个 5 分钟节点的提示。
  // Widget _buildLightedTimeline(int index) {
  //   final double top =
  //       (index == 0
  //               ? 37
  //               : _timelineNodeTop +
  //                     index * _timelineNodeGap -
  //                     _timelineNodeLightHeight / 2 +
  //                     12)
  //           .clamp(0, _timelineHeight - _timelineNodeLightHeight)
  //           .toDouble();

  //   return Positioned(
  //     top: top,
  //     child: Container(
  //       width: _timelineNodeLightWidth,
  //       height: _timelineNodeLightHeight,
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(color: _timelineLightBorderColor, width: 1),
  //         gradient: const LinearGradient(
  //           begin: Alignment.topCenter,
  //           end: Alignment.bottomCenter,
  //           colors: [_timelineLightTopColor, _timelineLightBottomColor],
  //         ),
  //         boxShadow: const [
  //           BoxShadow(
  //             color: _timelineLightShadowColor,
  //             blurRadius: 20,
  //             spreadRadius: 5,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

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
      height: 530,
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
                Text(
                  'add_therapy_module'.tr,
                  style: const TextStyle(color: Colors.white, fontSize: 22),
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
                Expanded(
                  child: Text(
                    'expand_feature'.tr,
                    style: const TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ),
                Image.asset(Assets.expandIcon, width: 43, height: 43),
              ],
            ),
            const SizedBox(height: 15),
            _buildExpandLine(
              id: 'chakra',
              text: 'chakra'.tr,
              icon: Icons.bubble_chart_outlined,
            ),
            _buildExpandLine(
              id: 'terahertz',
              text: 'terahertz'.tr,
              icon: Icons.sensors_outlined,
            ),
            _buildExpandLine(
              id: 'hifem',
              text: 'HIFEM',
              icon: Icons.monitor_heart_outlined,
            ),
            _buildExpandLine(
              id: 'fragrance',
              text: 'fragrance'.tr,
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
    final int? index = _activeNodeIndex;
    if (index == null) return const SizedBox.shrink();

    return _NotchedPanel(
      //红光模块面板大小
      width: 270,
      height: 288,
      notchSide: _NotchSide.left,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xAA5A4936), Color(0x9940342E)],
      ),
      borderColor: const Color(0xFF7E6651),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 25, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PanelTitle(
                  title: 'red_light'.tr,
                  icon: _moduleById('redlight').iconOn,
                ),
                const SizedBox(height: 18),
                _buildTwoColumnLabels('wavelength'.tr, 'intensity'.tr),
                const SizedBox(height: 6),
                _buildWavelengthRow(
                  '660',
                  controller: _redLight660Controllers[index],
                  focusNode: _redLight660FocusNodes[index],
                ),
                const SizedBox(height: 16),
                _buildTwoColumnLabels('wavelength'.tr, 'intensity'.tr),
                const SizedBox(height: 6),
                _buildWavelengthRow(
                  '850',
                  controller: _redLight850Controllers[index],
                  focusNode: _redLight850FocusNodes[index],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    SizedBox(
                      width: 68,
                      height: 44,
                      child: Align(
                        alignment: const Alignment(-1, 0.45),
                        child: Text('mode_select'.tr, style: _smallLabelStyle),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildModeOption(
                              index,
                              _RedLightMode.continuous,
                              'continuous'.tr,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildModeOption(
                              index,
                              _RedLightMode.pulse,
                              'pulse'.tr,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildRedLightModeHitArea(
            left: 110,
            top: 219,
            width: 68,
            height: 54,
            onTap: () => _setRedLightMode(index, _RedLightMode.continuous),
          ),
          _buildRedLightModeHitArea(
            left: 179,
            top: 219,
            width: 68,
            height: 54,
            onTap: () => _setRedLightMode(index, _RedLightMode.pulse),
          ),
          _buildPanelInputHitArea(
            left: 132,
            top: 82,
            width: 104,
            height: 58,
            focusNode: _redLight660FocusNodes[index],
          ),
          _buildPanelInputHitArea(
            left: 132,
            top: 147,
            width: 104,
            height: 58,
            focusNode: _redLight850FocusNodes[index],
          ),
        ],
      ),
    );
  }

  Widget _buildRedLightModeHitArea({
    required double left,
    required double top,
    required double width,
    required double height,
    required VoidCallback onTap,
  }) {
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _buildPanelInputHitArea({
    required double left,
    required double top,
    required double width,
    required double height,
    required FocusNode focusNode,
  }) {
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // onTap: () => FocusScope.of(context).requestFocus(focusNode),
        //避免重复请求焦点，只在输入框当前没有焦点时，才让他获取焦点
        onTap: () {
          if (!focusNode.hasFocus) {
            FocusScope.of(context).requestFocus(focusNode);
          }
        },
        // onTap: () => FocusScope.of(context).requestFocus(focusNode),
        child: const SizedBox.expand(),
      ),
    );
  }

  void _setRedLightMode(int index, _RedLightMode mode) {
    setState(() {
      _nodeRedLightModes[index] = mode;
      _savedNodeIndexes.removeWhere((item) => item >= index);
    });
  }

  Widget _buildModeOption(int index, _RedLightMode mode, String text) {
    final bool active = _nodeRedLightModes[index] == mode;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _setRedLightMode(index, mode),
      child: SizedBox(
        height: 44,
        child: Align(
          alignment: const Alignment(0, 0.45),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: _smallLabelStyle,
                ),
              ),
              const SizedBox(width: 5),
              _RadioDot(active: active, color: const Color(0xFFF08A23)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPemfPanel() {
    final int? index = _activeNodeIndex;
    if (index == null) return const SizedBox.shrink();

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
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PanelTitle(title: 'PEMF', icon: _moduleById('pemf').iconOn),
                const SizedBox(height: 20),
                _buildTwoColumnLabels('frequency'.tr, 'intensity'.tr),
                const SizedBox(height: 7),
                Row(
                  children: [
                    _InputBox(
                      width: 88,
                      controller: _pemfFrequencyControllers[index],
                      focusNode: _pemfFrequencyFocusNodes[index],
                      keyboardType: TextInputType.number,
                      maxValue: 75,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                    ),
                    const SizedBox(width: 30),
                    _InputBox(
                      width: 88,
                      controller: _pemfIntensityControllers[index],
                      focusNode: _pemfIntensityFocusNodes[index],
                      keyboardType: TextInputType.number,
                      maxValue: 100,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('waveform'.tr, style: _smallLabelStyle),
                const SizedBox(height: 7),
                _PemfWaveSelector(
                  wave: _nodePemfWaves[index],
                  onTap: () => _openPemfWavePicker(index),
                ),
              ],
            ),
          ),
          _buildPanelInputHitArea(
            left: 16,
            top: 86,
            width: 104,
            height: 58,
            focusNode: _pemfFrequencyFocusNodes[index],
          ),
          _buildPanelInputHitArea(
            left: 134,
            top: 86,
            width: 104,
            height: 58,
            focusNode: _pemfIntensityFocusNodes[index],
          ),
          _buildPanelTapHitArea(
            left: 16,
            top: 152,
            width: 220,
            height: 66,
            onTap: () => _openPemfWavePicker(index),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelTapHitArea({
    required double left,
    required double top,
    required double width,
    required double height,
    required VoidCallback onTap,
  }) {
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _buildVatPanel() {
    final int? index = _activeNodeIndex;
    if (index == null) return const SizedBox.shrink();

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
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVatTitleRow(index),
                const SizedBox(height: 17),
                _buildTwoColumnLabels('frequency'.tr, 'intensity'.tr),
                const SizedBox(height: 7),
                Row(
                  children: [
                    _InputBox(
                      width: 88,
                      controller: _vatFrequencyControllers[index],
                      focusNode: _vatFrequencyFocusNodes[index],
                      keyboardType: TextInputType.number,
                      maxValue: 100,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                    ),
                    const SizedBox(width: 30),
                    _InputBox(
                      width: 88,
                      controller: _vatIntensityController,
                      enabled: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildPanelInputHitArea(
            left: 16,
            top: 80,
            width: 104,
            height: 58,
            focusNode: _vatFrequencyFocusNodes[index],
          ),
        ],
      ),
    );
  }

  Widget _buildVatTitleRow(int index) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'VAT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _openVatMusicPage(index),
          child: SizedBox(
            width: 67,
            height: 43,
            child: Center(
              child: Image.asset(
                _moduleById('vat').iconOn,
                width: 43,
                height: 43,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openVatMusicPage(int index) async {
    final Object? result = await Get.toNamed(
      '/music',
      arguments: {
        'fromPage': 'customized',
        'currentSelectedSongId': _vatMusicSetting.songId,
        'currentVatFrequency': _vatFrequencyControllers[index].text,
        'currentVatStrength': _vatIntensityController.text,
        'activeNodeIndex': index,
      },
    );

    if (!mounted) return;
    if (result is! VatMusicSelection) return;

    setState(() {
      _vatIntensityController.text = result.intensity;
      _vatMusicSetting = _VatMusicSetting(
        songId: result.songId,
        songName: result.songName,
      );
      _savedNodeIndexes.removeWhere((item) => item >= index);
    });
  }

  Widget _buildHydrogenPanel() {
    final int? index = _activeNodeIndex;
    if (index == null) return const SizedBox.shrink();

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
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PanelTitle(
                  title: 'module_hydrogen'.tr,
                  icon: _moduleById('hydrogen').iconOn,
                ),
                const SizedBox(height: 17),
                Text('hydrogen_concentration'.tr, style: _smallLabelStyle),
                const SizedBox(height: 7),
                Row(
                  children: [
                    _InputBox(
                      width: 206,
                      controller: _hydrogenConcentrationControllers[index],
                      focusNode: _hydrogenConcentrationFocusNodes[index],
                      keyboardType: TextInputType.number,
                      maxValue: 100,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildPanelInputHitArea(
            left: 16,
            top: 80,
            width: 220,
            height: 58,
            focusNode: _hydrogenConcentrationFocusNodes[index],
          ),
        ],
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

  Widget _buildWavelengthRow(
    String value, {
    required TextEditingController controller,
    required FocusNode focusNode,
  }) {
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
        _InputHitArea(
          focusNode: focusNode,
          child: _InputBox(
            width: 88,
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
          ),
        ),
      ],
    );
  }

  // 保存参数按钮
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
        child: Text('save_params'.tr),
      ),
    );
  }

  // 保存计划按钮
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
                  'save_plan'.tr,
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

  // 切换功能
  void _toggleFeature(String id) {
    final int? index = _activeNodeIndex;
    if (index == null) return;

    setState(() {
      if (_nodeFeatureIds[index].contains(id)) {
        _nodeFeatureIds[index].remove(id);
        if (id == 'expand') _nodeExpandIds[index].clear();
      } else {
        _nodeFeatureIds[index].add(id);
        if (id == 'pemf' && _nodePemfWaves[index] == null) {
          _nodePemfWaves[index] = _defaultPemfWave;
        }
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
      _showMessage('complete_previous_node'.tr);
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
        _nodeChakraModes[index] = result.mode;
        _savedNodeIndexes.removeWhere((item) => item >= index);
      });
      return;
    }

    if (id == 'terahertz') {
      if (result is! terahertz_page.TerahertzExpandResult) return;

      setState(() {
        _nodeFeatureIds[index].add('expand');
        _nodeExpandIds[index].add(id);
        _nodeTerahertzSettings[index] = result;
        _savedNodeIndexes.removeWhere((item) => item >= index);
      });
      return;
    }

    if (id == 'hifem') {
      if (result is! hifem_page.HifemExpandResult) return;

      setState(() {
        _nodeFeatureIds[index].add('expand');
        _nodeExpandIds[index].add(id);
        _nodeHifemSettings[index] = result;
        _savedNodeIndexes.removeWhere((item) => item >= index);
      });
      return;
    }

    if (id == 'fragrance') {
      if (result is! fragrance_page.FragranceExpandResult) return;

      setState(() {
        _nodeFeatureIds[index].add('expand');
        _nodeExpandIds[index].add(id);
        _nodeFragranceSettings[index] = result;
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
          initialMode: _nodeChakraModes[index],
        );
      case 'terahertz':
        return terahertz_page.TerahertzExpandPage(
          initialSetting: _nodeTerahertzSettings[index],
        );
      case 'hifem':
        return hifem_page.HifemExpandPage(
          initialSetting: _nodeHifemSettings[index],
        );
      case 'fragrance':
        return fragrance_page.FragranceExpandPage(
          initialSetting: _nodeFragranceSettings[index],
        );
      default:
        return chakra_page.ChakraExpandPage(
          initialStrengths: _nodeChakraStrengths[index],
          initialMode: _nodeChakraModes[index],
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

    if (_nodeFeatureIds[index].contains('redlight')) {
      final int red660 = _percentValue(_redLight660Controllers[index].text);
      final int red850 = _percentValue(_redLight850Controllers[index].text);
      if (red660 == 0 && red850 == 0) {
        _showMessage('红光660nm和850nm强度不能同时为0');
        return;
      }
    }
    if (_nodeFeatureIds[index].contains('pemf')) {
      final int pemfFrequency = _rangedValue(
        _pemfFrequencyControllers[index].text,
        75,
      );
      final int pemfIntensity = _rangedValue(
        _pemfIntensityControllers[index].text,
        100,
      );
      if (pemfFrequency == 0 || pemfIntensity == 0) {
        _showMessage('PEMF频率和强度都不能为0');
        return;
      }
      _nodePemfWaves[index] ??= _defaultPemfWave;
    }
    if (_nodeFeatureIds[index].contains('vat')) {
      final int vatFrequency = _rangedValue(
        _vatFrequencyControllers[index].text,
        100,
      );
      final int vatIntensity = _rangedValue(_vatIntensityController.text, 100);
      if (vatFrequency == 0 || vatIntensity == 0) {
        _showMessage('VAT频率和强度都不能为0');
        return;
      }
    }
    if (_nodeFeatureIds[index].contains('hydrogen')) {
      final int hydrogenConcentration = _rangedValue(
        _hydrogenConcentrationControllers[index].text,
        100,
      );
      if (hydrogenConcentration == 0) {
        _showMessage('分子氢浓度不能为0');
        return;
      }
    }

    if (_nodeFeatureIds[index].contains('redlight')) {
      _normalizeRedLightPercent(_redLight660Controllers[index]);
      _normalizeRedLightPercent(_redLight850Controllers[index]);
    }
    if (_nodeFeatureIds[index].contains('pemf')) {
      _normalizeRangedNumber(_pemfFrequencyControllers[index], 75);
      _normalizeRangedNumber(_pemfIntensityControllers[index], 100);
    }
    if (_nodeFeatureIds[index].contains('vat')) {
      _normalizeRangedNumber(_vatFrequencyControllers[index], 100);
      _normalizeRangedNumber(_vatIntensityController, 100);
    }
    if (_nodeFeatureIds[index].contains('hydrogen')) {
      _normalizeRangedNumber(_hydrogenConcentrationControllers[index], 100);
    }

    setState(() {
      _savedNodeIndexes.add(index);
      _activeNodeIndex = null;
    });
    _showMessage(
      '${'node_saved_prefix'.tr}${(index + 1) * 5}${'node_saved_suffix'.tr}',
    );
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

  void _openPemfWavePicker(int index) {
    FocusScope.of(context).unfocus();
    setState(() => _pemfWavePickerNodeIndex = index);
  }

  void _selectPemfWave(int index, _PemfWave wave) {
    setState(() {
      _nodePemfWaves[index] = wave;
      _pemfWavePickerNodeIndex = null;
      _savedNodeIndexes.removeWhere((item) => item >= index);
    });
  }

  List<Widget> _buildPemfWavePickerOverlay() {
    final int index = _pemfWavePickerNodeIndex!;

    return [
      Positioned.fill(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _pemfWavePickerNodeIndex = null),
          child: Container(color: Colors.black.withValues(alpha: 0.45)),
        ),
      ),
      Positioned(
        left: 260,
        top: 295,
        child: _PemfWavePopup(
          selected: _nodePemfWaves[index],
          dialogAsset: _pemfWaveDialogAsset,
          onCancel: () => setState(() => _pemfWavePickerNodeIndex = null),
          onConfirm: (wave) => _selectPemfWave(index, wave),
        ),
      ),
    ];
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
      _nodeChakraModes[index] = _parseChakraMode(parts[2]);
      _nodeFeatureIds[index].add('expand');
      _nodeExpandIds[index].add('chakra');
      _savedNodeIndexes.add(index);
      hasPhaseData = true;
    }

    for (final String text in featureIds) {
      if (!text.startsWith('terahertz:')) continue;

      final List<String> parts = text.split(':');
      if (parts.length < 3) continue;

      final int? index = int.tryParse(parts[1]);
      if (index == null ||
          index < 0 ||
          index >= _nodeTerahertzSettings.length) {
        continue;
      }

      final terahertz_page.TerahertzExpandResult? setting =
          _parseTerahertzSetting(parts[2]);
      if (setting == null) continue;

      _nodeTerahertzSettings[index] = setting;
      _nodeFeatureIds[index].add('expand');
      _nodeExpandIds[index].add('terahertz');
      _savedNodeIndexes.add(index);
      hasPhaseData = true;
    }

    for (final String text in featureIds) {
      if (!text.startsWith('hifem:')) continue;

      final List<String> parts = text.split(':');
      if (parts.length < 3) continue;

      final int? index = int.tryParse(parts[1]);
      if (index == null || index < 0 || index >= _nodeHifemSettings.length) {
        continue;
      }

      final hifem_page.HifemExpandResult? setting = _parseHifemSetting(
        parts[2],
      );
      if (setting == null) continue;

      _nodeHifemSettings[index] = setting;
      _nodeFeatureIds[index].add('expand');
      _nodeExpandIds[index].add('hifem');
      _savedNodeIndexes.add(index);
      hasPhaseData = true;
    }

    for (final String text in featureIds) {
      if (!text.startsWith('fragrance:')) continue;

      final List<String> parts = text.split(':');
      if (parts.length < 3) continue;

      final int? index = int.tryParse(parts[1]);
      if (index == null ||
          index < 0 ||
          index >= _nodeFragranceSettings.length) {
        continue;
      }

      final fragrance_page.FragranceExpandResult? setting =
          _parseFragranceSetting(parts[2]);
      if (setting == null) continue;

      _nodeFragranceSettings[index] = setting;
      _nodeFeatureIds[index].add('expand');
      _nodeExpandIds[index].add('fragrance');
      _savedNodeIndexes.add(index);
      hasPhaseData = true;
    }

    for (final String text in featureIds) {
      if (!text.startsWith('redlight:')) continue;

      final List<String> parts = text.split(':');
      if (parts.length < 3) continue;

      final int? index = int.tryParse(parts[1]);
      if (index == null || index < 0 || index >= _nodeFeatureIds.length) {
        continue;
      }

      final _RedLightSetting setting = _parseRedLightSetting(parts[2]);
      _redLight660Controllers[index].text = setting.strength660Text;
      _redLight850Controllers[index].text = setting.strength850Text;
      _nodeRedLightModes[index] = setting.mode;
      _nodeFeatureIds[index].add('redlight');
      _savedNodeIndexes.add(index);
      hasPhaseData = true;
    }

    for (final String text in featureIds) {
      if (!text.startsWith('pemf:')) continue;

      final List<String> parts = text.split(':');
      if (parts.length < 3) continue;

      final int? index = int.tryParse(parts[1]);
      if (index == null || index < 0 || index >= _nodeFeatureIds.length) {
        continue;
      }

      final _PemfSetting setting = _parsePemfSetting(parts[2]);
      _pemfFrequencyControllers[index].text = setting.frequencyText;
      _pemfIntensityControllers[index].text = setting.intensityText;
      _nodePemfWaves[index] = setting.wave;
      _nodeFeatureIds[index].add('pemf');
      _savedNodeIndexes.add(index);
      hasPhaseData = true;
    }

    for (final String text in featureIds) {
      if (!text.startsWith('vat:')) continue;

      final List<String> parts = text.split(':');
      if (parts.length < 3) continue;

      final int? index = int.tryParse(parts[1]);
      if (index == null || index < 0 || index >= _nodeFeatureIds.length) {
        continue;
      }

      final _VatSetting vatSetting = _parseVatSetting(parts[2]);
      _vatFrequencyControllers[index].text = vatSetting.frequencyText;
      _restoreVatModuleSetting(vatSetting);
      _nodeFeatureIds[index].add('vat');
      _savedNodeIndexes.add(index);
      hasPhaseData = true;
    }

    for (final String text in featureIds) {
      if (!text.startsWith('hydrogen:')) continue;

      final List<String> parts = text.split(':');
      if (parts.length < 3) continue;

      final int? index = int.tryParse(parts[1]);
      if (index == null || index < 0 || index >= _nodeFeatureIds.length) {
        continue;
      }

      final _HydrogenSetting hSetting = _parseHydrogenSetting(parts[2]);
      _hydrogenConcentrationControllers[index].text =
          hSetting.concentrationText;
      _nodeFeatureIds[index].add('hydrogen');
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
        phaseTexts.add('chakra:$index:${_formatChakraSetting(index)}');
      }
      final terahertz_page.TerahertzExpandResult? terahertzSetting =
          _nodeTerahertzSettings[index];
      if (terahertzSetting != null) {
        phaseTexts.add(
          'terahertz:$index:${_formatTerahertzSetting(terahertzSetting)}',
        );
      }
      final hifem_page.HifemExpandResult? hifemSetting =
          _nodeHifemSettings[index];
      if (hifemSetting != null) {
        phaseTexts.add('hifem:$index:${_formatHifemSetting(hifemSetting)}');
      }
      final fragrance_page.FragranceExpandResult? fragranceSetting =
          _nodeFragranceSettings[index];
      if (fragranceSetting != null) {
        phaseTexts.add(
          'fragrance:$index:${_formatFragranceSetting(fragranceSetting)}',
        );
      }
      if (_nodeFeatureIds[index].contains('redlight')) {
        phaseTexts.add('redlight:$index:${_formatRedLightSetting(index)}');
      }
      if (_nodeFeatureIds[index].contains('pemf')) {
        phaseTexts.add('pemf:$index:${_formatPemfSetting(index)}');
      }
      if (_nodeFeatureIds[index].contains('vat')) {
        phaseTexts.add('vat:$index:${_formatVatSetting(index)}');
      }
      if (_nodeFeatureIds[index].contains('hydrogen')) {
        phaseTexts.add('hydrogen:$index:${_formatHydrogenSetting(index)}');
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
      if (id.trim() == 'mode') continue;
      if (id.trim().isEmpty || value.trim().isEmpty) continue;

      result[id] = value;
    }

    return result;
  }

  String _parseChakraMode(String text) {
    for (final String pair in text.split('|')) {
      final int separator = pair.indexOf('=');
      if (separator <= 0 || separator == pair.length - 1) continue;

      final String key = pair.substring(0, separator).trim();
      final String value = pair.substring(separator + 1).trim();
      if (key == 'mode' && value == 'independent') return 'independent';
    }

    return 'rotation';
  }

  String _formatChakraSetting(int index) {
    final String strengths = _formatChakraStrengths(
      _nodeChakraStrengths[index],
    );
    return 'mode=${_nodeChakraModes[index]}|$strengths';
  }

  String _formatChakraStrengths(Map<String, String> strengths) {
    return strengths.entries
        .where((entry) => entry.value.trim().isNotEmpty)
        .map((entry) => '${entry.key}=${entry.value.trim()}')
        .join('|');
  }

  terahertz_page.TerahertzExpandResult? _parseTerahertzSetting(String text) {
    int frequency = 0;
    int power = 0;
    String? mode;
    String? wave;

    for (final String pair in text.split('|')) {
      final int separator = pair.indexOf('=');
      if (separator <= 0 || separator == pair.length - 1) continue;

      final String key = pair.substring(0, separator).trim();
      final String value = pair.substring(separator + 1).trim();
      switch (key) {
        case 'frequency':
          frequency = _rangedValue(value, 100);
          break;
        case 'power':
          power = _rangedValue(value, 100);
          break;
        case 'mode':
          mode = value;
          break;
        case 'wave':
          wave = value;
          break;
      }
    }

    if (mode == null || wave == null) return null;
    return terahertz_page.TerahertzExpandResult(
      frequency: frequency,
      power: power,
      mode: mode,
      wave: wave,
    );
  }

  String _formatTerahertzSetting(terahertz_page.TerahertzExpandResult setting) {
    return 'frequency=${setting.frequency}|power=${setting.power}|mode=${setting.mode}|wave=${setting.wave}';
  }

  hifem_page.HifemExpandResult? _parseHifemSetting(String text) {
    HifemRegion? selectedRegion;
    final Map<HifemRegion, HifemRegionSetting> regionSettings =
        <HifemRegion, HifemRegionSetting>{};

    for (final String pair in text.split('|')) {
      final int separator = pair.indexOf('=');
      if (separator <= 0 || separator == pair.length - 1) continue;

      final String key = pair.substring(0, separator).trim();
      final String value = pair.substring(separator + 1).trim();
      if (key == 'selected') {
        selectedRegion = _hifemRegionFromId(value);
        continue;
      }

      final List<String> keyParts = key.split('.');
      if (keyParts.length != 2) continue;

      final HifemRegion? region = _hifemRegionFromId(keyParts[0]);
      if (region == null) continue;

      final HifemRegionSetting current =
          regionSettings[region] ?? const HifemRegionSetting();
      switch (keyParts[1]) {
        case 'rf':
          regionSettings[region] = current.copyWith(
            rfPercent: _rangedValue(value, 100),
          );
          break;
        case 'hifes':
          regionSettings[region] = current.copyWith(
            hifesPercent: _rangedValue(value, 100),
          );
          break;
      }
    }

    if (selectedRegion == null && regionSettings.isEmpty) return null;
    return hifem_page.HifemExpandResult(
      selectedRegion: selectedRegion,
      regionSettings: regionSettings,
    );
  }

  String _formatHifemSetting(hifem_page.HifemExpandResult setting) {
    final List<String> pairs = <String>[];
    final HifemRegion? selectedRegion = setting.selectedRegion;
    if (selectedRegion != null) {
      pairs.add('selected=${_hifemRegionId(selectedRegion)}');
    }

    final HifemRegionSetting foreheadLeft =
        setting.regionSettings[HifemRegion.foreheadLeft] ??
        const HifemRegionSetting();
    final HifemRegionSetting foreheadRight =
        setting.regionSettings[HifemRegion.foreheadRight] ??
        const HifemRegionSetting();
    final int foreheadRf = foreheadLeft.rfPercent > foreheadRight.rfPercent
        ? foreheadLeft.rfPercent
        : foreheadRight.rfPercent;
    final int foreheadHifes =
        foreheadLeft.hifesPercent > foreheadRight.hifesPercent
        ? foreheadLeft.hifesPercent
        : foreheadRight.hifesPercent;
    if (foreheadRf > 0 || foreheadHifes > 0) {
      pairs.add('forehead.rf=$foreheadRf');
      pairs.add('forehead.hifes=$foreheadHifes');
    }

    for (final MapEntry<HifemRegion, HifemRegionSetting> entry
        in setting.regionSettings.entries) {
      if (entry.key == HifemRegion.foreheadLeft ||
          entry.key == HifemRegion.foreheadRight) {
        continue;
      }
      if (!entry.value.hasOutput) continue;
      final String id = _hifemRegionId(entry.key);
      pairs.add('$id.rf=${entry.value.rfPercent}');
      pairs.add('$id.hifes=${entry.value.hifesPercent}');
    }

    return pairs.join('|');
  }

  fragrance_page.FragranceExpandResult? _parseFragranceSetting(String text) {
    for (final String pair in text.split('|')) {
      final int separator = pair.indexOf('=');
      if (separator <= 0 || separator == pair.length - 1) continue;

      final String key = pair.substring(0, separator).trim();
      final String value = pair.substring(separator + 1).trim();
      if (key == 'type' && value.isNotEmpty) {
        return fragrance_page.FragranceExpandResult(fragranceId: value);
      }
    }

    return null;
  }

  String _formatFragranceSetting(fragrance_page.FragranceExpandResult setting) {
    return 'type=${setting.fragranceId}';
  }

  void _normalizeRedLightPercent(TextEditingController controller) {
    controller.text = _percentValue(controller.text).toString();
  }

  void _normalizeRangedNumber(TextEditingController controller, int maxValue) {
    controller.text = _rangedValue(controller.text, maxValue).toString();
  }

  int _percentValue(String text) {
    return _rangedValue(text, 100);
  }

  int _rangedValue(String text, int maxValue) {
    final int? value = int.tryParse(text.trim());
    if (value == null) return 0;
    return value.clamp(0, maxValue).toInt();
  }

  String _formatRedLightSetting(int index) {
    final int strength660 = _percentValue(_redLight660Controllers[index].text);
    final int strength850 = _percentValue(_redLight850Controllers[index].text);
    final String mode = _nodeRedLightModes[index].storageValue;

    return '660=$strength660|850=$strength850|mode=$mode';
  }

  _RedLightSetting _parseRedLightSetting(String text) {
    int strength660 = 0;
    int strength850 = 0;
    _RedLightMode mode = _RedLightMode.continuous;

    for (final String pair in text.split('|')) {
      final int separator = pair.indexOf('=');
      if (separator <= 0 || separator == pair.length - 1) continue;

      final String key = pair.substring(0, separator).trim();
      final String value = pair.substring(separator + 1).trim();
      switch (key) {
        case '660':
          strength660 = _percentValue(value);
          break;
        case '850':
          strength850 = _percentValue(value);
          break;
        case 'mode':
          mode = _redLightModeFromStorageValue(value);
          break;
      }
    }

    return _RedLightSetting(
      strength660: strength660,
      strength850: strength850,
      mode: mode,
    );
  }

  String _formatPemfSetting(int index) {
    final int frequency = _rangedValue(
      _pemfFrequencyControllers[index].text,
      75,
    );
    final int intensity = _rangedValue(
      _pemfIntensityControllers[index].text,
      100,
    );
    final String wave = (_nodePemfWaves[index] ?? _defaultPemfWave).id;

    return 'frequency=$frequency|intensity=$intensity|wave=$wave';
  }

  _PemfSetting _parsePemfSetting(String text) {
    int frequency = 0;
    int intensity = 0;
    _PemfWave? wave;

    for (final String pair in text.split('|')) {
      final int separator = pair.indexOf('=');
      if (separator <= 0 || separator == pair.length - 1) continue;

      final String key = pair.substring(0, separator).trim();
      final String value = pair.substring(separator + 1).trim();
      switch (key) {
        case 'frequency':
          frequency = _rangedValue(value, 75);
          break;
        case 'intensity':
          intensity = _rangedValue(value, 100);
          break;
        case 'wave':
          wave = _pemfWaveFromId(value);
          break;
      }
    }

    return _PemfSetting(
      frequency: frequency,
      intensity: intensity,
      wave: wave ?? _defaultPemfWave,
    );
  }

  String _formatVatSetting(int index) {
    final int frequency = _rangedValue(
      _vatFrequencyControllers[index].text,
      100,
    );
    final int intensity = _rangedValue(_vatIntensityController.text, 100);
    final _VatMusicSetting music = _vatMusicSetting;
    final String songId = music.songId.isNotEmpty
        ? music.songId
        : defaultSongId;
    final String songName = music.songName.isNotEmpty
        ? Uri.encodeComponent(music.songName)
        : '';
    final String seriesName = music.seriesName.isNotEmpty
        ? Uri.encodeComponent(music.seriesName)
        : '';

    return 'frequency=$frequency|intensity=$intensity|songId=$songId|songName=$songName|seriesName=$seriesName';
  }

  void _restoreVatModuleSetting(_VatSetting setting) {
    if (_vatIntensityController.text.isEmpty && setting.intensity > 0) {
      _vatIntensityController.text = setting.intensityText;
    }
    if (_vatMusicSetting.songId.isEmpty && setting.music.songId.isNotEmpty) {
      _vatMusicSetting = setting.music;
    }
  }

  _VatSetting _parseVatSetting(String text) {
    int frequency = 0;
    int intensity = 0;
    _VatMusicSetting music = const _VatMusicSetting();

    for (final String pair in text.split('|')) {
      final int separator = pair.indexOf('=');
      if (separator <= 0 || separator == pair.length - 1) continue;

      final String key = pair.substring(0, separator).trim();
      final String value = pair.substring(separator + 1).trim();
      switch (key) {
        case 'frequency':
          frequency = _rangedValue(value, 100);
          break;
        case 'intensity':
          intensity = _rangedValue(value, 100);
          break;
        case 'songId':
          music = _VatMusicSetting(
            songId: value,
            songName: music.songName,
            seriesName: music.seriesName,
          );
          break;
        case 'songName':
          music = _VatMusicSetting(
            songId: music.songId,
            songName: Uri.decodeComponent(value),
            seriesName: music.seriesName,
          );
          break;
        case 'seriesName':
          music = _VatMusicSetting(
            songId: music.songId,
            songName: music.songName,
            seriesName: Uri.decodeComponent(value),
          );
          break;
        // 向后兼容：旧格式使用 'music' 键
        case 'music':
          final Song? song = findSongById(value);
          music = _VatMusicSetting(songId: value, songName: song?.name ?? '');
          break;
      }
    }

    return _VatSetting(
      frequency: frequency,
      intensity: intensity,
      music: music,
    );
  }

  String _formatHydrogenSetting(int index) {
    final int concentration = _rangedValue(
      _hydrogenConcentrationControllers[index].text,
      100,
    );
    return 'concentration=$concentration';
  }

  _HydrogenSetting _parseHydrogenSetting(String text) {
    int concentration = 0;

    for (final String pair in text.split('|')) {
      final int separator = pair.indexOf('=');
      if (separator <= 0 || separator == pair.length - 1) continue;

      final String key = pair.substring(0, separator).trim();
      final String value = pair.substring(separator + 1).trim();
      switch (key) {
        case 'concentration':
          concentration = _rangedValue(value, 100);
          break;
      }
    }

    return _HydrogenSetting(concentration: concentration);
  }

  _ModuleItem _moduleById(String id) {
    return _modules.firstWhere((item) => item.id == id);
  }

  _PemfWave get _defaultPemfWave => _pemfWaves.first;
}

const TextStyle _smallLabelStyle = TextStyle(
  color: Color(0xFFE4E7EE),
  fontSize: 14,
  height: 1,
);

enum _RedLightMode { continuous, pulse }

extension _RedLightModeX on _RedLightMode {
  String get storageValue {
    switch (this) {
      case _RedLightMode.continuous:
        return 'continuous';
      case _RedLightMode.pulse:
        return 'pulse';
    }
  }
}

_RedLightMode _redLightModeFromStorageValue(String value) {
  return value == 'pulse' ? _RedLightMode.pulse : _RedLightMode.continuous;
}

class _RedLightSetting {
  const _RedLightSetting({
    required this.strength660,
    required this.strength850,
    required this.mode,
  });

  final int strength660;
  final int strength850;
  final _RedLightMode mode;

  String get strength660Text => strength660.toString();
  String get strength850Text => strength850.toString();
}

class _PemfSetting {
  const _PemfSetting({
    required this.frequency,
    required this.intensity,
    required this.wave,
  });

  final int frequency;
  final int intensity;
  final _PemfWave? wave;

  String get frequencyText => frequency.toString();
  String get intensityText => intensity.toString();
}

class _PemfWave {
  const _PemfWave({required this.id, required this.label, required this.asset});

  final String id;
  final String label;
  final String asset;
}

const List<_PemfWave> _pemfWaves = [
  _PemfWave(id: 'sine', label: 'sine', asset: Assets.customizedPemfWaveSine),
  _PemfWave(
    id: 'halfSine',
    label: 'halfSine',
    asset: Assets.customizedPemfWaveHalfSine,
  ),
  _PemfWave(
    id: 'trapezoid',
    label: 'trapezoid',
    asset: Assets.customizedPemfWaveTrapezoid,
  ),
  _PemfWave(
    id: 'standardSine',
    label: 'standardSine',
    asset: Assets.customizedPemfWaveStandardSine,
  ),
  _PemfWave(id: 'saw', label: 'saw', asset: Assets.customizedPemfWaveSaw),
  _PemfWave(
    id: 'triangle',
    label: 'triangle',
    asset: Assets.customizedPemfWaveTriangle,
  ),
  _PemfWave(id: 'pulse', label: 'pulse', asset: Assets.customizedPemfWavePulse),
  _PemfWave(
    id: 'fastRise',
    label: 'fastRise',
    asset: Assets.customizedPemfWaveFastRise,
  ),
  _PemfWave(
    id: 'dualFrequency',
    label: 'dualFrequency',
    asset: Assets.customizedPemfWaveDualFrequency,
  ),
  _PemfWave(id: 'cubic', label: 'cubic', asset: Assets.customizedPemfWaveCubic),
];

_PemfWave? _pemfWaveFromId(String id) {
  for (final _PemfWave wave in _pemfWaves) {
    if (wave.id == id) return wave;
  }
  return null;
}

String _hifemRegionId(HifemRegion region) {
  switch (region) {
    case HifemRegion.foreheadLeft:
      return 'forehead';
    case HifemRegion.foreheadRight:
      return 'forehead';
    case HifemRegion.cheekLeft:
      return 'cheek_left';
    case HifemRegion.cheekRight:
      return 'cheek_right';
  }
}

HifemRegion? _hifemRegionFromId(String id) {
  switch (id) {
    case 'forehead':
      return HifemRegion.foreheadLeft;
    case 'forehead_left':
      return HifemRegion.foreheadLeft;
    case 'forehead_right':
      return HifemRegion.foreheadLeft;
    case 'cheek_left':
      return HifemRegion.cheekLeft;
    case 'cheek_right':
      return HifemRegion.cheekRight;
    default:
      return null;
  }
}

class _PageTitle extends StatelessWidget {
  const _PageTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      'custom_plan_title'.tr,
      style: const TextStyle(
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
  const _InputBox({
    required this.width,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.inputFormatters,
    this.maxValue = 100,
    this.enabled = true,
  });

  final double width;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxValue;
  final bool enabled;

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
      child: _buildChild(),
    );
  }

  Widget? _buildChild() {
    final TextEditingController? textController = controller;
    if (textController != null) {
      return TextField(
        controller: textController,
        focusNode: focusNode,
        enabled: enabled,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1),
        cursorColor: Colors.white,
        decoration: const InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          final int? number = int.tryParse(value);
          if (number == null || number <= maxValue) return;

          textController
            ..text = maxValue.toString()
            ..selection = TextSelection.collapsed(
              offset: textController.text.length,
            );
        },
      );
    }

    return null;
  }
}

class _InputHitArea extends StatelessWidget {
  const _InputHitArea({required this.child, required this.focusNode});

  // 这里控制“看不见但能点中”的区域，后续只改这几个数即可微调。
  static const double _defaultLeft = -4;
  static const double _defaultTop = -33;
  static const double _defaultWidth = 98;
  static const double _defaultHeight = 62;

  final Widget child;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final double visualWidth = _InputBoxMetrics.visualWidth(child);

    return SizedBox(
      width: visualWidth,
      height: _InputBoxMetrics.visualHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          child,
          Positioned(
            left: _defaultLeft,
            top: _defaultTop,
            width: _defaultWidth,
            height: _defaultHeight,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              // onTap: () => FocusScope.of(context).requestFocus(focusNode),
              //避免重复请求焦点，只在输入框当前没有焦点时，才让他获取焦点
              onTap: () {
                if (!focusNode.hasFocus) {
                  FocusScope.of(context).requestFocus(focusNode);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InputBoxMetrics {
  const _InputBoxMetrics._();

  static const double visualHeight = 29;

  static double visualWidth(Widget child) {
    if (child is _InputBox) return child.width;
    return 88;
  }
}

class _PemfWaveSelector extends StatelessWidget {
  const _PemfWaveSelector({required this.wave, required this.onTap});

  final _PemfWave? wave;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 206,
        height: 37,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.20),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: wave == null
                  ? const SizedBox.shrink()
                  : Image.asset(wave!.asset, height: 24, fit: BoxFit.contain),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white.withValues(alpha: 0.65),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _PemfWavePopup extends StatefulWidget {
  const _PemfWavePopup({
    required this.selected,
    required this.dialogAsset,
    required this.onCancel,
    required this.onConfirm,
  });

  final _PemfWave? selected;
  final String dialogAsset;
  final VoidCallback onCancel;
  final ValueChanged<_PemfWave> onConfirm;

  @override
  State<_PemfWavePopup> createState() => _PemfWavePopupState();
}

class _PemfWavePopupState extends State<_PemfWavePopup> {
  static const double _width = 279;
  static const double _height = 658;
  static const double _listTop = 67;
  static const double _rowHeight = 44;
  static const double _rowGap = 8;
  static const double _cancelLeft = 64;
  static const double _confirmLeft = 144;
  static const double _buttonTop = 601;
  static const double _buttonWidth = 72;
  static const double _buttonHeight = 32;

  late _PemfWave? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (details) => _handleTap(details.localPosition),
      child: SizedBox(
        width: _width,
        height: _height,
        child: Image.asset(widget.dialogAsset, fit: BoxFit.fill),
      ),
    );
  }

  void _handleTap(Offset position) {
    if (_isInsideButton(position, _cancelLeft)) {
      widget.onCancel();
      return;
    }

    if (_isInsideButton(position, _confirmLeft)) {
      final _PemfWave? selected = _selected;
      if (selected != null) widget.onConfirm(selected);
      return;
    }

    final int rowIndex = ((position.dy - _listTop) / (_rowHeight + _rowGap))
        .floor();
    final double rowTop = _listTop + rowIndex * (_rowHeight + _rowGap);
    final bool inRow =
        rowIndex >= 0 &&
        rowIndex < _pemfWaves.length &&
        position.dy >= rowTop &&
        position.dy <= rowTop + _rowHeight;

    if (!inRow) return;

    final _PemfWave tappedWave = _pemfWaves[rowIndex];
    setState(() => _selected = tappedWave);
    widget.onConfirm(tappedWave);
  }

  bool _isInsideButton(Offset position, double left) {
    return position.dx >= left &&
        position.dx <= left + _buttonWidth &&
        position.dy >= _buttonTop &&
        position.dy <= _buttonTop + _buttonHeight;
  }
}

class _VatMusicSetting {
  const _VatMusicSetting({
    this.songId = '',
    this.songName = '',
    this.seriesName = '',
  });

  final String songId;
  final String songName;
  final String seriesName;
}

class _VatSetting {
  const _VatSetting({
    required this.frequency,
    required this.intensity,
    required this.music,
  });

  final int frequency;
  final int intensity;
  final _VatMusicSetting music;

  String get frequencyText => frequency.toString();
  String get intensityText => intensity.toString();
}

class _HydrogenSetting {
  const _HydrogenSetting({required this.concentration});

  final int concentration;

  String get concentrationText => concentration.toString();
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
      child: SizedBox(
        width: 56,
        height: 56,
        child: Center(child: _buildButton()),
      ),
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
      title: Text(
        'plan_naming'.tr,
        style: const TextStyle(color: Colors.white),
      ),
      content: TextField(
        controller: controller,
        autofocus: true,
        cursorColor: Colors.white,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'plan_search_hint'.tr,
          hintStyle: const TextStyle(color: Color(0xFF737782)),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF4A4D57)),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF1F74E8)),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('cancel'.tr),
        ),
        TextButton(
          onPressed: () {
            final String name = controller.text.trim();
            if (name.isEmpty) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('plan_name_empty'.tr)));
              return;
            }
            Navigator.of(context).pop(name);
          },
          child: Text('save'.tr),
        ),
      ],
    );
  }
}
