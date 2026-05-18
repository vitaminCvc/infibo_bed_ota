// 脉轮设置页。
//
// 这一页显示七个脉轮位置，用户点击某个脉轮后可输入强度。
// 点击确认时会把“脉轮 id -> 强度值”返回给自定义方案编辑页，
// 上级页面再负责把这些参数保存到方案数据里。
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/index.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/pages/customized/customizedPage/setting_page_helpers.dart';

/// 脉轮设置页返回给自定义方案编辑页的数据。
///
/// strengths 的 key 是脉轮 id，例如 crown / heart；
/// value 是用户在强度输入框中输入的数字文本。
class ChakraExpandResult {
  const ChakraExpandResult({required this.strengths, this.mode = 'rotation'});

  final Map<String, String> strengths;

  /// 脉轮模块模式：rotation=轮转，independent=独立，对应 0x0201。
  final String mode;
}

class ChakraExpandPage extends StatefulWidget {
  const ChakraExpandPage({
    super.key,
    this.initialStrengths = const {},
    this.initialMode = 'rotation',
  });

  /// 编辑已有方案时，上级页面会把之前保存过的脉轮强度传进来。
  final Map<String, String> initialStrengths;

  /// 编辑已有方案时恢复之前保存的模式；默认轮转。
  final String initialMode;

  @override
  State<ChakraExpandPage> createState() => _ChakraExpandPageState();
}

class _ChakraExpandPageState extends State<ChakraExpandPage> {
  // 以下尺寸按现有设计稿坐标系摆放，避免改动你当前截图里的位置。
  static const double _designWidth = 800;
  static const double _designHeight = 1088;

  /// 已经输入并提交到页面状态里的强度。
  ///
  /// key 使用列表下标，最终确认时再转换成业务 id。
  final Map<int, String> _committedStrengths = <int, String>{};

  /// 每个脉轮一个输入控制器，避免切换脉轮时输入内容丢失。
  late final List<TextEditingController> _strengthControllers;

  /// 当前展开强度输入框的脉轮下标。
  int? _selectedIndex;

  /// 当前选择的脉轮工作模式，默认轮转。
  late String _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialMode == 'independent'
        ? 'independent'
        : 'rotation';

    _strengthControllers = List.generate(_chakras.length, (int index) {
      final String text =
          widget.initialStrengths[_chakras[index].id]?.trim() ?? '';
      if (text.isNotEmpty) _committedStrengths[index] = text;
      return TextEditingController(text: text);
    });
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _strengthControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double scale =
        ((MediaQuery.sizeOf(context).width - 32) / _designWidth)
            .clamp(0.72, 1.0)
            .toDouble();

    return AppHeaderPage(
      resizeToAvoidBottomInset: false,
      children: [
        Positioned.fill(
          top: 70,
          child: Center(
            child: SizedBox(
              width: _designWidth * scale,
              height: _designHeight * scale,
              child: OverflowBox(
                alignment: Alignment.topCenter,
                minWidth: _designWidth,
                maxWidth: _designWidth,
                minHeight: _designHeight,
                maxHeight: _designHeight,
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: _designWidth,
                    height: _designHeight,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 44,
                          top: 5,
                          child: ExpandBackButton(
                            onTap: () => _handleBack(context),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 5,
                          child: Text(
                            'chakra_setting'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 30,
                          top: 52,
                          child: Image.asset(
                            Assets.chakraBody,
                            width: 720,
                            height: 913,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 930,
                          child: _buildModeSelector(),
                        ),
                        Positioned(
                          left: 133,
                          top: 1005,
                          child: _buildConfirm(context),
                        ),
                        for (int index = 0; index < _chakras.length; index++)
                          Positioned(
                            left: 370,
                            top: 128 + index * 113,
                            child: _ChakraLine(
                              data: _chakras[index],
                              controller: _strengthControllers[index],
                              isActive: _selectedIndex == index,
                              isConfigured: _committedStrengths.containsKey(
                                index,
                              ),
                              onTap: () => _toggleChakra(index),
                              onStrengthChanged: (String value) =>
                                  _saveStrength(index, value),
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
        ExpandBackHitLayer(
          designWidth: _designWidth,
          designHeight: _designHeight,
          scale: scale,
          onTap: () => _handleBack(context),
        ),
      ],
    );
  }

  Widget _buildConfirm(BuildContext pageContext) {
    final bool canConfirm = _committedStrengths.isNotEmpty;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: canConfirm ? () => _confirm(pageContext) : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            canConfirm
                ? Assets.chakraConfirmEnabled
                : Assets.chakraConfirmDisabled,
            width: 533,
            height: 56,
          ),
          Text(
            'confirm'.tr,
            style: TextStyle(
              color: canConfirm ? Colors.white : const Color(0xFF9EA2AB),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 点击脉轮图标或标题时，只展开对应的强度输入框。
  Widget _buildModeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'mode_select'.tr,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(width: 18),
        _buildModeOption(label: 'rotation'.tr, value: 'rotation'),
        const SizedBox(width: 22),
        _buildModeOption(label: 'independent'.tr, value: 'independent'),
      ],
    );
  }

  Widget _buildModeOption({required String label, required String value}) {
    final bool selected = _selectedMode == value;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _selectedMode = value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? const Color(0xFF1F7AFF) : Colors.white,
                width: 1.5,
              ),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1F7AFF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _toggleChakra(int index) {
    setState(() {
      _selectedIndex = _selectedIndex == index ? null : index;
    });
  }

  /// 用户直接在***强度框***里输入时同步页面状态。
  ///
  /// 输入为空表示取消该脉轮配置，确认按钮也会随之变成不可点击状态。
  void _saveStrength(int index, String value) {
    //表示输入框传进来的文字,把用户输入的内容去掉前后空格。
    final String text = value.trim();
    //刷新页面状态,如果输入框里没有内容了,就把这个脉轮的配置从已提交的强度里移除掉;如果有内容了,就更新这个脉轮的强度值。
    setState(() {
      //保存设置脉轮编号
      _selectedIndex = index;
      //保存设置的强度值,如果输入框里没有内容了,就把这个脉轮的配置从已提交的强度里移除掉;如果有内容了,就更新这个脉轮的强度值。
      if (text.isEmpty) {
        _committedStrengths.remove(index);
        return;
      }
      // 非数字输入直接忽略
      final int? parsed = int.tryParse(text);
      if (parsed == null) {
        return;
      }
      // 强度限制在 0~100
      final int normalized = parsed.clamp(0, 100);
      _committedStrengths[index] = normalized.toString();
      // 同步修正输入框文本，避免 UI 显示与实际值不一致
      if (controllerText(index) != normalized.toString()) {
        _strengthControllers[index].text = normalized.toString();
        _strengthControllers[index].selection = TextSelection.fromPosition(
          TextPosition(offset: _strengthControllers[index].text.length),
        );
      }
    });
  }

  String controllerText(int index) => _strengthControllers[index].text.trim();

  /// 确认时把页面状态转换成业务 id -> 强度值，然后返回给上级编辑页。
  void _confirm(BuildContext pageContext) {
    popExpandPage(
      pageContext,
      ChakraExpandResult(
        strengths: _buildResultStrengths(),
        mode: _selectedMode,
      ),
    );
  }

  /// 返回只关闭当前脉轮页，不修改上级页面里的拓展功能选择状态。
  void _handleBack(BuildContext pageContext) {
    popExpandPage(pageContext);
  }

  Map<String, String> _buildResultStrengths() {
    return {
      for (final MapEntry<int, String> entry in _committedStrengths.entries)
        if (entry.value.trim().isNotEmpty)
          _chakras[entry.key].id: entry.value.trim(),
    };
  }
}

class _ChakraLine extends StatelessWidget {
  const _ChakraLine({
    required this.data,
    required this.controller,
    required this.isActive,
    required this.isConfigured,
    required this.onTap,
    required this.onStrengthChanged,
  });

  final _ChakraData data;
  final TextEditingController controller;
  final bool isActive;
  final bool isConfigured;
  final VoidCallback onTap;
  final ValueChanged<String> onStrengthChanged;

  @override
  Widget build(BuildContext context) {
    final bool shouldHighlight = isActive || isConfigured;

    return SizedBox(
      width: 386,
      height: 90,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 6,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: Image.asset(
                shouldHighlight ? data.selectedIcon : data.icon,
                width: 56,
                height: 56,
              ),
            ),
          ),
          Positioned(
            left: 68,
            top: 9,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: _buildTitleBlock(),
            ),
          ),
          if (isActive)
            Positioned(left: 160, top: 0, child: _buildStrengthPanel()),
        ],
      ),
    );
  }

  Widget _buildTitleBlock() {
    return SizedBox(
      width: 105,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.title.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.subtitle.tr,
            style: const TextStyle(
              color: Color(0xFFB8BBC5),
              fontSize: 13,
              height: 1.05,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  /// 右侧强度面板。
  ///
  /// 这里直接放 TextField，用户点选脉轮后可以用系统键盘输入数字；
  /// 不再弹出 AlertDialog。
  Widget _buildStrengthPanel() {
    return SizedBox(
      width: 209,
      height: 80,
      child: Stack(
        children: [
          Positioned.fill(child: Image.asset(Assets.chakraIntensityPanel)),
          Positioned(
            left: 31,
            top: 28,
            child: Text(
              'intensity'.tr,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Positioned(
            left: 92,
            top: 17,
            child: SizedBox(
              width: 96,
              height: 45,
              child: TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                textAlign: TextAlign.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(color: Colors.white, fontSize: 18),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 12),
                ),
                onChanged: onStrengthChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChakraData {
  const _ChakraData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selectedIcon,
  });

  /// 保存到自定义方案数据里的稳定 id。
  final String id;

  /// 页面上显示的脉轮名称。
  final String title;

  /// 页面上显示的关联部位。
  final String subtitle;

  /// 未配置或未选中时的图标。
  final String icon;

  /// 当前选中或已经配置强度后的图标。
  final String selectedIcon;
}

const List<_ChakraData> _chakras = [
  _ChakraData(
    id: 'crown',
    title: 'crown_chakra',
    subtitle: 'crown_sub',
    icon: Assets.chakraCrown,
    selectedIcon: Assets.chakraCrownSelected,
  ),
  _ChakraData(
    id: 'third_eye',
    title: 'third_eye_chakra',
    subtitle: 'third_eye_sub',
    icon: Assets.chakraThirdEye,
    selectedIcon: Assets.chakraThirdEyeSelected,
  ),
  _ChakraData(
    id: 'throat',
    title: 'throat_chakra',
    subtitle: 'throat_sub',
    icon: Assets.chakraThroat,
    selectedIcon: Assets.chakraThroatSelected,
  ),
  _ChakraData(
    id: 'heart',
    title: 'heart_chakra',
    subtitle: 'heart_sub',
    icon: Assets.chakraHeart,
    selectedIcon: Assets.chakraHeartSelected,
  ),
  _ChakraData(
    id: 'solar_plexus',
    title: 'solar_plexus_chakra',
    subtitle: 'solar_plexus_sub',
    icon: Assets.chakraSolarPlexus,
    selectedIcon: Assets.chakraSolarPlexusSelected,
  ),
  _ChakraData(
    id: 'sacral',
    title: 'sacral_chakra',
    subtitle: 'sacral_sub',
    icon: Assets.chakraSacral,
    selectedIcon: Assets.chakraSacralSelected,
  ),
  _ChakraData(
    id: 'root',
    title: 'root_chakra',
    subtitle: 'root_sub',
    icon: Assets.chakraRoot,
    selectedIcon: Assets.chakraRootSelected,
  ),
];
