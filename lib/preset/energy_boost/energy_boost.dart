import '../a_cankao/preset_models.dart';

const PresetMode energyBoostPreset = PresetMode(
  code: 'P02',
  titleKey: 'energy_boost',
  goalKey: 'preset_p02_goal',
  durationMinutes: 20,
  phases: <PresetPhase>[
    //阶段1
    PresetPhase(
      startMinute: 0,
      endMinute: 5,
      pemf: PresetPemfConfig(
        frequencyHz: 20,
        intensityPercent: 40,
        waveform: pemfModels.pulse,
        burstFrequencyHz: 2,
      ),
      redLight: PresetRedLightConfig(
        power660Percent: 100,
        power850Percent: 50,
        mode: redModels.pulse,
        pulseFrequencyHz: 20,
        dutyCyclePercent: 70,
      ),
      vat: PresetVatConfig(
        frequencyHz: 20,
        energyPercent: 40,
        volumePercent: 50,
        trackId: 2,
      ),
      hydrogen: PresetHydrogenConfig(outputPercent: 50),
      descriptionKey: 'preset_p02_phase_1',
    ),
    PresetPhase(
      startMinute: 5,
      endMinute: 10,
      pemf: PresetPemfConfig(
        frequencyHz: 30,
        intensityPercent: 60,
        waveform: pemfModels.burstSquare,
        burstFrequencyHz: 3,
      ),
      redLight: PresetRedLightConfig(
        power660Percent: 100,
        power850Percent: 80,
        mode: redModels.pulse,
        pulseFrequencyHz: 30,
        dutyCyclePercent: 70,
      ),
      vat: PresetVatConfig(
        frequencyHz: 35,
        energyPercent: 60,
        volumePercent: 60,
        trackId: 2,
      ),
      hydrogen: PresetHydrogenConfig(outputPercent: 80),
      descriptionKey: 'preset_p02_phase_2',
    ),
    PresetPhase(
      startMinute: 10,
      endMinute: 15,
      pemf: PresetPemfConfig(
        frequencyHz: 50,
        intensityPercent: 80,
        waveform: pemfModels.burstSquare,
        burstFrequencyHz: 5,
      ),
      redLight: PresetRedLightConfig(
        power660Percent: 100,
        power850Percent: 100,
        mode: redModels.pulse,
        pulseFrequencyHz: 50,
        dutyCyclePercent: 80,
      ),
      vat: PresetVatConfig(
        frequencyHz: 50,
        energyPercent: 80,
        volumePercent: 70,
        trackId: 2,
      ),
      hydrogen: PresetHydrogenConfig(outputPercent: 100),
      descriptionKey: 'preset_p02_phase_3',
    ),
    PresetPhase(
      startMinute: 15,
      endMinute: 20,
      pemf: PresetPemfConfig(
        frequencyHz: 40,
        intensityPercent: 60,
        waveform: pemfModels.pulse,
        burstFrequencyHz: 2,
      ),
      redLight: PresetRedLightConfig(
        power660Percent: 80,
        power850Percent: 50,
        mode: redModels.continuous,
        pulseFrequencyHz: 0,
        dutyCyclePercent: 100,
      ),
      vat: PresetVatConfig(
        frequencyHz: 40,
        energyPercent: 60,
        volumePercent: 60,
        trackId: 2,
      ),
      hydrogen: PresetHydrogenConfig(outputPercent: 80),
      descriptionKey: 'preset_p02_phase_4',
    ),
  ],
);
