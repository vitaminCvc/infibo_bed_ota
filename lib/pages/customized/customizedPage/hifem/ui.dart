// HIFEM 设置页。
//
// 这一页负责显示人头图上的四个可点击区域，以及当前区域的射频 / HIFES
// 两条进度条。每个区域都有独立的百分比状态；点击确认后把本页设置保存到
// HifemSettingController，返回自定义方案页后再次进入仍能继续修改。
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/index.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/pages/customized/customizedPage/setting_page_helpers.dart';
import 'package:infibo_app/stores/hifem_setting_store.dart';
import 'package:infibo_app/utils/number_utils.dart';

class HifemExpandResult {
  const HifemExpandResult({
    required this.selectedRegion,
    required this.regionSettings,
  });

  final HifemRegion? selectedRegion;
  final Map<HifemRegion, HifemRegionSetting> regionSettings;
}

class HifemExpandPage extends StatefulWidget {
  const HifemExpandPage({super.key, this.initialSetting});

  final HifemExpandResult? initialSetting;

  @override
  State<HifemExpandPage> createState() => _HifemExpandPageState();
}

class _HifemExpandPageState extends State<HifemExpandPage> {
  static const double _designWidth = 800;
  static const double _designHeight = 1088;

  late HifemRegion? _selectedRegion;
  late Map<HifemRegion, HifemRegionSetting> _regionSettings;

  bool get _canConfirm => _selectedRegion != null;

  HifemRegionSetting get _currentSetting {
    final HifemRegion? region = _selectedRegion;
    if (region == null) return const HifemRegionSetting();
    return _settingFor(region);
  }

  @override
  void initState() {
    super.initState();
    final HifemExpandResult? initialSetting = widget.initialSetting;
    if (initialSetting != null) {
      _selectedRegion = _normalizeSelectedRegion(initialSetting.selectedRegion);
      _regionSettings = Map<HifemRegion, HifemRegionSetting>.from(
        initialSetting.regionSettings,
      );
      _normalizeForeheadSettings();
      return;
    }

    // 新节点：从空白状态开始，不使用全局单例避免跨节点污染。
    _selectedRegion = null;
    _regionSettings = <HifemRegion, HifemRegionSetting>{};
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
                            'hifem_setting'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // 整个人头区域的位置。只想整体上下左右移动人头时，改这里。
                        Positioned(left: 142, top: 72, child: _buildHead()),
                        Positioned(left: 95, top: 800, child: _buildRows()),
                        Positioned(
                          left: 95,
                          top: 1018,
                          child: _HifemConfirmButton(
                            enabled: _canConfirm,
                            width: 610,
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

  Widget _buildHead() {
    // base.png 的原始尺寸就是 530x643，四个贴片坐标都按这张图内部坐标计算。
    // 如果改了这里的尺寸，底部 _regions 里的 left/top 也会跟着需要重新对。
    const double baseWidth = 530;
    const double baseHeight = 643;

    return SizedBox(
      width: baseWidth,
      height: baseHeight,
      child: Stack(
        children: [
          Positioned.fill(child: Image.asset(Assets.hifemHeadBase)),
          for (final _HifemRegionData data in _regions)
            Positioned(
              left: data.left,
              top: data.top,
              child: _HifemRegionPatch(
                data: data,
                selected: _isRegionSelected(data.region),
                configured: _isRegionConfigured(data.region),
                onTap: () => _selectRegion(data.region),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRows() {
    final HifemRegionSetting setting = _currentSetting;
    final bool hasRegion = _selectedRegion != null;

    return Column(
      children: [
        _HifemProgressRow(
          label: 'rf'.tr,
          value: setting.rfPercent,
          enabled: hasRegion,
          icon: Assets.hifemRfIcon,
          disabledIcon: Assets.hifemRfDisabledIcon,
          activeBar: Assets.hifemRfBar,
          activeThumb: Assets.hifemRfThumb,
          onChanged: (int value) => _updateCurrent(rfPercent: value),
        ),
        const SizedBox(height: 34),
        _HifemProgressRow(
          label: 'HIFES',
          value: setting.hifesPercent,
          enabled: hasRegion,
          icon: Assets.hifemHifesIcon,
          disabledIcon: Assets.hifemHifesDisabledIcon,
          activeBar: Assets.hifemHifesBar,
          activeThumb: Assets.hifemHifesThumb,
          onChanged: (int value) => _updateCurrent(hifesPercent: value),
        ),
      ],
    );
  }

  HifemRegionSetting _settingFor(HifemRegion region) {
    return _regionSettings[region] ?? const HifemRegionSetting();
  }

  HifemRegion? _normalizeSelectedRegion(HifemRegion? region) {
    if (region == HifemRegion.foreheadRight) return HifemRegion.foreheadLeft;
    return region;
  }

  bool _isForeheadRegion(HifemRegion region) {
    return region == HifemRegion.foreheadLeft ||
        region == HifemRegion.foreheadRight;
  }

  bool _isRegionSelected(HifemRegion region) {
    // 🔥 额头：左右都算同一个选中态
    if (_isForeheadRegion(region)) {
      return _selectedRegion == HifemRegion.foreheadLeft;
    }
    return _selectedRegion == region;
  }

  bool _isRegionConfigured(HifemRegion region) {
    if (_isForeheadRegion(region)) {
      final left = _settingFor(HifemRegion.foreheadLeft);
      final right = _settingFor(HifemRegion.foreheadRight);

      return left.rfPercent > 0 ||
          left.hifesPercent > 0 ||
          right.rfPercent > 0 ||
          right.hifesPercent > 0;
    }

    final setting = _settingFor(region);
    return setting.rfPercent > 0 || setting.hifesPercent > 0;
  }

  void _normalizeForeheadSettings() {
    final HifemRegionSetting left = _settingFor(HifemRegion.foreheadLeft);
    final HifemRegionSetting right = _settingFor(HifemRegion.foreheadRight);
    final int mergedRf = left.rfPercent > right.rfPercent
        ? left.rfPercent
        : right.rfPercent;
    final int mergedHifes = left.hifesPercent > right.hifesPercent
        ? left.hifesPercent
        : right.hifesPercent;
    final HifemRegionSetting merged = HifemRegionSetting(
      rfPercent: mergedRf,
      hifesPercent: mergedHifes,
    );
    _regionSettings[HifemRegion.foreheadLeft] = merged;
    _regionSettings[HifemRegion.foreheadRight] = merged;
  }

  void _selectRegion(HifemRegion region) {
    // 额头统一映射为 left（逻辑合并）
    final HifemRegion target = _isForeheadRegion(region)
        ? HifemRegion.foreheadLeft
        : region;

    setState(() {
      // ================================
      // 点击同一个区域 => 取消选中 + 清零
      // ================================
      if (_selectedRegion == target) {
        _selectedRegion = null;

        // 🔥 额头整体清零（左右同步）
        if (target == HifemRegion.foreheadLeft) {
          _regionSettings[HifemRegion.foreheadLeft] =
              const HifemRegionSetting();
          _regionSettings[HifemRegion.foreheadRight] =
              const HifemRegionSetting();
        } else {
          _regionSettings[target] = const HifemRegionSetting();
        }

        return;
      }

      // ================================
      // 选中新的区域
      // ================================
      _selectedRegion = target;
    });
  }

  void _updateCurrent({int? rfPercent, int? hifesPercent}) {
    final HifemRegion? region = _selectedRegion;
    if (region == null) return;

    setState(() {
      final HifemRegionSetting updated = _settingFor(
        region,
      ).copyWith(rfPercent: rfPercent, hifesPercent: hifesPercent);

      // ================================
      // 额头：左右同步更新
      // ================================
      if (_isForeheadRegion(region)) {
        _regionSettings[HifemRegion.foreheadLeft] = updated;
        _regionSettings[HifemRegion.foreheadRight] = updated;
      } else {
        _regionSettings[region] = updated;
      }
    });
  }

  void _confirm(BuildContext pageContext) {
    final HifemExpandResult result = HifemExpandResult(
      selectedRegion: _selectedRegion,
      regionSettings: Map<HifemRegion, HifemRegionSetting>.from(
        _regionSettings,
      ),
    );

    popExpandPage(pageContext, result);
  }
}

class _HifemRegionPatch extends StatelessWidget {
  const _HifemRegionPatch({
    required this.data,
    required this.selected,
    required this.configured,
    required this.onTap,
  });

  final _HifemRegionData data;
  final bool selected;
  final bool configured;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: data.width,
        height: data.height,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(data.defaultAsset, fit: BoxFit.fill),
            ),
            if (selected)
              Positioned.fill(
                child: Image.asset(data.selectedAsset, fit: BoxFit.fill),
              )
            else if (configured)
              Positioned.fill(
                child: Image.asset(data.selectedAsset, fit: BoxFit.fill),
              )
            else
              Positioned.fill(
                child: Image.asset(data.defaultAsset, fit: BoxFit.fill),
              ),
          ],
        ),
      ),
    );
  }
}

class _HifemProgressRow extends StatelessWidget {
  const _HifemProgressRow({
    required this.label,
    required this.value,
    required this.enabled,
    required this.icon,
    required this.disabledIcon,
    required this.activeBar,
    required this.activeThumb,
    required this.onChanged,
  });

  static const double _width = 610;
  static const double _trackWidth = 404;
  static const double _trackHeight = 10;
  static const double _thumbSize = 22;

  final String label;
  final int value;
  final bool enabled;
  final String icon;
  final String disabledIcon;
  final String activeBar;
  final String activeThumb;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final double progress = (value / 100).clamp(0.0, 1.0).toDouble();
    final bool active = enabled && value > 0;
    final double thumbLeft = (progress * _trackWidth - _thumbSize / 2).clamp(
      0.0,
      _trackWidth - _thumbSize,
    );

    return SizedBox(
      width: _width,
      height: 42,
      child: Row(
        children: [
          Image.asset(active ? icon : disabledIcon, width: 40, height: 40),
          const SizedBox(width: 8),
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFFE5E8EF), fontSize: 20),
            ),
          ),
          _buildTrack(active: active, progress: progress, thumbLeft: thumbLeft),
          const SizedBox(width: 22),
          SizedBox(
            width: 64,
            child: Text(
              _formatPercent(value),
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrack({
    required bool active,
    required double progress,
    required double thumbLeft,
  }) {
    // 这块是进度条可拖动区域：点击或横向拖动都会换算成 0-100 的百分比。
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled
          ? (TapDownDetails details) =>
                _changeByLocalDx(details.localPosition.dx)
          : null,
      onHorizontalDragStart: enabled
          ? (DragStartDetails details) =>
                _changeByLocalDx(details.localPosition.dx)
          : null,
      onHorizontalDragUpdate: enabled
          ? (DragUpdateDetails details) =>
                _changeByLocalDx(details.localPosition.dx)
          : null,
      child: SizedBox(
        width: _trackWidth,
        height: 34,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.centerLeft,
          children: [
            Image.asset(
              Assets.hifemProgressDefaultBar,
              width: _trackWidth,
              height: _trackHeight,
              fit: BoxFit.fill,
            ),
            if (active)
              ClipRect(
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Image.asset(
                    activeBar,
                    width: _trackWidth,
                    height: _trackHeight,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            Positioned(
              left: thumbLeft,
              child: Image.asset(
                active ? activeThumb : Assets.hifemProgressDefaultThumb,
                width: _thumbSize,
                height: _thumbSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changeByLocalDx(double dx) {
    final double progress = (dx / _trackWidth).clamp(0.0, 1.0).toDouble();
    onChanged((progress * 100).round().clamp(0, 100));
  }

  String _formatPercent(int percent) => formatPaddedPercentage(percent);
}

class _HifemConfirmButton extends StatelessWidget {
  const _HifemConfirmButton({
    required this.enabled,
    required this.width,
    required this.onTap,
  });

  final bool enabled;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (enabled)
            Image.asset(
              Assets.hifemConfirmButton,
              width: width,
              height: 56,
              fit: BoxFit.fill,
            )
          else
            Container(
              width: width,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF292C34), Color(0xFF1F222A)],
                ),
              ),
            ),
          Text(
            'confirm'.tr,
            style: TextStyle(
              color: enabled ? Colors.white : const Color(0xFF8F949E),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HifemRegionData {
  const _HifemRegionData({
    required this.region,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.defaultAsset,
    required this.selectedAsset,
  });

  final HifemRegion region;
  final double left;
  final double top;
  final double width;
  final double height;
  final String defaultAsset;
  final String selectedAsset;
}

const List<_HifemRegionData> _regions = [
  // 四个贴片的位置都在这里调。
  // left 越大越往右，top 越大越往下；width/height 是贴片图片显示尺寸。
  // 坐标是相对于 _buildHead() 里那张 530x643 人头图的内部坐标，不是屏幕坐标。
  _HifemRegionData(
    region: HifemRegion.foreheadLeft,
    left: 140,
    top: 202,
    width: 104,
    height: 75,
    defaultAsset: Assets.hifemForeheadLeftDefault,
    selectedAsset: Assets.hifemForeheadLeftSelected,
  ),
  _HifemRegionData(
    region: HifemRegion.foreheadRight,
    left: 240,
    top: 202,
    width: 104,
    height: 75,
    defaultAsset: Assets.hifemForeheadRightDefault,
    selectedAsset: Assets.hifemForeheadRightSelected,
  ),
  _HifemRegionData(
    region: HifemRegion.cheekLeft,
    left: 113,
    top: 285,
    width: 146,
    height: 180,
    defaultAsset: Assets.hifemCheekLeftDefault,
    selectedAsset: Assets.hifemCheekLeftSelected,
  ),
  _HifemRegionData(
    region: HifemRegion.cheekRight,
    left: 233,
    top: 285,
    width: 146,
    height: 180,
    defaultAsset: Assets.hifemCheekRightDefault,
    selectedAsset: Assets.hifemCheekRightSelected,
  ),
];
