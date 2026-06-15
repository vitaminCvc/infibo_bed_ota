import 'preset_models.dart';
import '../anti_aging/anti_aging.dart';
import '../deep_relax/deep_relax.dart';
import '../emo_healing/emo_healing.dart';
import '../energy_boost/energy_boost.dart';
import '../immune_boost/immune_boost.dart';
import '../pain_relief/pain_relief.dart';
import '../sleep_imp/sleep_imp.dart';
import '../sports_rec/sports_rec.dart';
import '../stress_relief/stress_relief.dart';
import '../total_care/total_care.dart';

const List<PresetMode> allPresetModes = <PresetMode>[
  deepRelaxPreset,
  energyBoostPreset,
  painReliefPreset,
  sleepImpPreset,
  sportsRecPreset,
  stressReliefPreset,
  immuneBoostPreset,
  antiAgingPreset,
  totalCarePreset,
  emoHealingPreset,
];

PresetMode? presetByCode(String code) {
  for (final PresetMode preset in allPresetModes) {
    if (preset.code == code) return preset;
  }
  return null;
}

PresetMode? presetByTitleKey(String titleKey) {
  for (final PresetMode preset in allPresetModes) {
    if (preset.titleKey == titleKey) return preset;
  }
  return null;
}
