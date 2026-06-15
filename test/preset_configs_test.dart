import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/preset/anti_aging/anti_aging.dart';
import 'package:infibo_app/preset/emo_healing/emo_healing.dart';
import 'package:infibo_app/preset/immune_boost/immune_boost.dart';
import 'package:infibo_app/preset/pain_relief/pain_relief.dart';
import 'package:infibo_app/preset/sleep_imp/sleep_imp.dart';
import 'package:infibo_app/preset/sports_rec/sports_rec.dart';
import 'package:infibo_app/preset/stress_relief/stress_relief.dart';
import 'package:infibo_app/preset/total_care/total_care.dart';

void main() {
  test(
    'preset identifiers and corrected parameters match the source table',
    () {
      expect(immuneBoostPreset.code, 'P07');
      expect(immuneBoostPreset.goalKey, 'preset_p07_goal');
      expect(immuneBoostPreset.phases[1].vat.frequencyHz, 15);
      expect(immuneBoostPreset.phases[4].pemf.waveform.deviceValue, 8);

      expect(antiAgingPreset.code, 'P08');
      expect(antiAgingPreset.goalKey, 'preset_p08_goal');
      expect(antiAgingPreset.phases[2].redLight.pulseFrequencyHz, 15);

      expect(painReliefPreset.phases[2].vat.frequencyHz, 12);
      expect(painReliefPreset.phases[2].vat.energyPercent, 50);
      expect(painReliefPreset.phases[2].vat.volumePercent, 40);
      expect(painReliefPreset.phases[4].pemf.frequencyHz, 10);
      expect(painReliefPreset.phases[4].pemf.intensityPercent, 30);

      expect(sportsRecPreset.phases[3].pemf.waveform.deviceValue, 6);

      expect(stressReliefPreset.phases[3].pemf.frequencyHz, 5);
      expect(stressReliefPreset.phases[3].vat.volumePercent, 20);

      expect(sleepImpPreset.titleKey, 'sleep_enhancement');
      expect(sportsRecPreset.titleKey, 'sports_recovery');
      expect(stressReliefPreset.titleKey, 'stress_release');
      expect(totalCarePreset.titleKey, 'full_care');
      expect(emoHealingPreset.titleKey, 'mental_healing');
    },
  );
}
