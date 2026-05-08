// HIFEM 设置页的状态模型和控制器。
//
// UI 页只负责编辑临时值；点击确认时会把四个区域的射频 / HIFES 百分比
// 保存到这个 GetX controller。controller 设为 permanent，所以返回上级页面
// 后再次进入 HIFEM 页，之前确认过的设置还在。
import 'package:get/get.dart';

enum HifemRegion { foreheadLeft, foreheadRight, cheekLeft, cheekRight }

class HifemRegionSetting {
  const HifemRegionSetting({this.rfPercent = 0, this.hifesPercent = 0});

  final int rfPercent;
  final int hifesPercent;

  bool get hasOutput => rfPercent > 0 || hifesPercent > 0;

  HifemRegionSetting copyWith({int? rfPercent, int? hifesPercent}) {
    return HifemRegionSetting(
      rfPercent: (rfPercent ?? this.rfPercent).clamp(0, 100).toInt(),
      hifesPercent: (hifesPercent ?? this.hifesPercent).clamp(0, 100).toInt(),
    );
  }
}

class HifemSettingSnapshot {
  const HifemSettingSnapshot({
    required this.selectedRegion,
    required this.regionSettings,
  });

  final HifemRegion? selectedRegion;
  final Map<HifemRegion, HifemRegionSetting> regionSettings;
}

class HifemSettingController extends GetxController {
  HifemRegion? _selectedRegion;
  final Map<HifemRegion, HifemRegionSetting> _regionSettings =
      _emptyRegionSettings();

  HifemRegion? get selectedRegion => _selectedRegion;

  Map<HifemRegion, HifemRegionSetting> get regionSettings =>
      Map.unmodifiable(_regionSettings);

  static HifemSettingController get instance {
    if (Get.isRegistered<HifemSettingController>()) {
      return Get.find<HifemSettingController>();
    }
    return Get.put(HifemSettingController(), permanent: true);
  }

  HifemSettingSnapshot snapshot() {
    return HifemSettingSnapshot(
      selectedRegion: _selectedRegion,
      regionSettings: {
        for (final HifemRegion region in HifemRegion.values)
          region: _regionSettings[region] ?? const HifemRegionSetting(),
      },
    );
  }

  void save({
    required HifemRegion? selectedRegion,
    required Map<HifemRegion, HifemRegionSetting> regionSettings,
  }) {
    _selectedRegion = selectedRegion;
    _regionSettings
      ..clear()
      ..addAll({
        for (final HifemRegion region in HifemRegion.values)
          region: regionSettings[region] ?? const HifemRegionSetting(),
      });
    update();
  }

  static Map<HifemRegion, HifemRegionSetting> _emptyRegionSettings() {
    return {
      for (final HifemRegion region in HifemRegion.values)
        region: const HifemRegionSetting(),
    };
  }
}
