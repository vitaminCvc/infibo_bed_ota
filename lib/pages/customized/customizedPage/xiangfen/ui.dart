// 香氛设置页。
//
// 这一页显示香薰机图片和五个香型选项。香型只能单选，默认是“轻柔”；
// 点击确认后把当前选中的香型 id 保存到 FragranceSettingController，
// 返回自定义方案页后再次进入仍会保持上次选择。
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/index.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/pages/customized/customizedPage/setting_page_helpers.dart';
import 'package:infibo_app/pages/customized/customizedPage/xiangfen/logic.dart';

class FragranceExpandResult {
  const FragranceExpandResult({required this.fragranceId});

  final String fragranceId;
}

class FragranceExpandPage extends StatefulWidget {
  const FragranceExpandPage({super.key, this.initialSetting});

  final FragranceExpandResult? initialSetting;

  @override
  State<FragranceExpandPage> createState() => _FragranceExpandPageState();
}

class _FragranceExpandPageState extends State<FragranceExpandPage> {
  static const double _designWidth = 800;
  static const double _designHeight = 1088;

  late final FragranceSettingController _controller;
  late String _selectedId;

  @override
  void initState() {
    super.initState();
    _controller = FragranceSettingController.instance;
    _selectedId =
        widget.initialSetting?.fragranceId ?? _controller.selectedFragranceId;
  }

  @override
  Widget build(BuildContext context) {
    final double scale = (MediaQuery.sizeOf(context).width / _designWidth)
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
                            onTap: () => popExpandPage(context),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 5,
                          child: Text(
                            'fragrance_setting'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 38,
                          top: 132,
                          child: Image.asset(
                            Assets.fragranceDiffuser,
                            width: 725,
                            height: 846,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned(left: 45, top: 785, child: _buildChoices()),
                        Positioned(
                          left: 45,
                          top: 1018,
                          child: AssetConfirmButton(
                            enabled: true,
                            enabledAsset: Assets.fragranceConfirmEnabled,
                            disabledAsset: Assets.fragranceConfirmDisabled,
                            width: 711,
                            onTap: () => _confirm(context),
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
          onTap: () => popExpandPage(context),
        ),
      ],
    );
  }

  Widget _buildChoices() {
    return SizedBox(
      width: 711,
      height: 194,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF272A32), Color(0xFF1C1E25)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8FA4C8).withValues(alpha: 0.16),
                    blurRadius: 34,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 28,
            right: 28,
            top: 83,
            child: Image.asset(
              Assets.fragranceChoiceLine,
              height: 2,
              fit: BoxFit.fill,
            ),
          ),
          for (int index = 0; index < _choices.length; index++)
            Positioned(
              left: 48 + index * 135,
              top: 48,
              child: _FragranceChoice(
                data: _choices[index],
                selected: _selectedId == _choices[index].id,
                onTap: () => _select(_choices[index].id),
              ),
            ),
        ],
      ),
    );
  }

  void _select(String id) {
    // 香氛是单选。再次点击当前已选项不取消，保证始终有一个香型被选中。
    if (_selectedId == id) return;
    setState(() => _selectedId = id);
  }

  void _confirm(BuildContext pageContext) {
    final FragranceExpandResult result = FragranceExpandResult(
      fragranceId: _selectedId,
    );

    // 只有确认时才写入 controller；返回按钮只是退出页面，不改变上次保存值。
    _controller.saveSelectedFragrance(result.fragranceId);
    popExpandPage(pageContext, result);
  }
}

class _FragranceChoice extends StatelessWidget {
  const _FragranceChoice({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final _FragranceChoiceData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 84,
        height: 120,
        child: Column(
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: Center(
                child: Image.asset(
                  selected ? data.selectedIcon : data.icon,
                  width: selected ? 70 : 60,
                  height: selected ? 70 : 60,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              data.title.tr,
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}

class _FragranceChoiceData {
  const _FragranceChoiceData({
    required this.id,
    required this.title,
    required this.icon,
    required this.selectedIcon,
  });

  final String id;
  final String title;
  final String icon;
  final String selectedIcon;
}

const List<_FragranceChoiceData> _choices = [
  _FragranceChoiceData(
    id: 'gentle',
    title: 'gentle',
    icon: Assets.fragranceSoftDefault,
    selectedIcon: Assets.fragranceSoftSelected,
  ),
  _FragranceChoiceData(
    id: 'intense',
    title: 'intense',
    icon: Assets.fragranceStrongDefault,
    selectedIcon: Assets.fragranceStrongSelected,
  ),
  _FragranceChoiceData(
    id: 'sleep',
    title: 'sleep',
    icon: Assets.fragranceSleepDefault,
    selectedIcon: Assets.fragranceSleepSelected,
  ),
  _FragranceChoiceData(
    id: 'flow',
    title: 'flow_state',
    icon: Assets.fragranceFlowDefault,
    selectedIcon: Assets.fragranceFlowSelected,
  ),
  _FragranceChoiceData(
    id: 'meditation',
    title: 'meditation',
    icon: Assets.fragranceMeditationDefault,
    selectedIcon: Assets.fragranceMeditationSelected,
  ),
];
