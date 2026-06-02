// HIFEM 设置页共享状态。
//
// 保存四个区域的射频和 HIFES 百分比，让页面返回后仍能恢复上次确认的设置。
import 'package:get/get.dart';
import 'package:infibo_app/utils/number_utils.dart';

enum HifemRegion { foreheadLeft, foreheadRight, cheekLeft, cheekRight }

class HifemRegionSetting {
  const HifemRegionSetting({this.rfPercent = 0, this.hifesPercent = 0});

  final int rfPercent;
  final int hifesPercent;

  bool get hasOutput => rfPercent > 0 || hifesPercent > 0;

  HifemRegionSetting copyWith({int? rfPercent, int? hifesPercent}) {
    return HifemRegionSetting(
      rfPercent: clampPercentage(rfPercent ?? this.rfPercent),
      hifesPercent: clampPercentage(hifesPercent ?? this.hifesPercent),
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
