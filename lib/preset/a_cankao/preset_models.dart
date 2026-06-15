// 十个预设模式共同使用的10个预设模型
enum pemfModels {
  sine(0), // 正弦波
  halfSine(1), // 半正弦
  trapezoid(2), // 梯形
  standardSine(3), // 标准正弦
  sawtooth(4), // 锯齿
  triangle(5), // 三角
  pulse(6), // 矩形脉冲
  fastRise(7), // 快速上升
  infibo(8), // 双频 / INFIBO
  burstSquare(9); // Burst矩形 / 标准方波

  const pemfModels(this.deviceValue);

  final int deviceValue;
}

enum redModels {
  continuous(0), // 连续
  pulse(1); // 脉冲

  const redModels(this.deviceValue);

  final int deviceValue;
}

class PresetMode {
  const PresetMode({
    required this.code,
    required this.titleKey,
    required this.goalKey,
    required this.durationMinutes,
    required this.phases,
  });

  //P01、P02、P03、P04、P05、P06、P07、P08、P09、P10
  // 预设模式代码
  final String code;
  // 预设模式标题
  final String titleKey;
  // 预设模式反右key
  final String goalKey;
  // 预设模式持续时间
  final int durationMinutes;
  // 预设模式周期
  final List<PresetPhase> phases;
}

class PresetPhase {
  const PresetPhase({
    required this.startMinute,
    required this.endMinute,
    required this.pemf,
    required this.redLight,
    required this.vat,
    required this.hydrogen,
    required this.descriptionKey,
  });

  final int startMinute;
  final int endMinute;

  final PresetPemfConfig pemf;
  final PresetRedLightConfig redLight;
  final PresetVatConfig vat;
  final PresetHydrogenConfig hydrogen;

  // 阶段说明的翻译 key。
  final String descriptionKey;

  int get durationMinutes => endMinute - startMinute;
}

class PresetPemfConfig {
  const PresetPemfConfig({
    required this.frequencyHz,
    required this.intensityPercent,
    required this.waveform,
    required this.burstFrequencyHz,
  });

  // 频率（Hz）
  final int frequencyHz;
  // 强度（%）
  final int intensityPercent;
  // 波形
  final pemfModels waveform;

  // 0 表示关闭 Burst。
  final int burstFrequencyHz;
}

class PresetRedLightConfig {
  const PresetRedLightConfig({
    required this.power660Percent,
    required this.power850Percent,
    required this.mode,
    required this.pulseFrequencyHz,
    required this.dutyCyclePercent,
  });

  //660 通道功率
  final int power660Percent;
  //850通道功率
  final int power850Percent;
  // 模式
  final redModels mode;

  // 连续模式填写 0。
  final int pulseFrequencyHz;

  // 连续模式填写 100。
  final int dutyCyclePercent;
}

class PresetVatConfig {
  const PresetVatConfig({
    required this.frequencyHz,
    required this.energyPercent,
    required this.volumePercent,
    required this.trackId,
  });

  final int frequencyHz;
  final int energyPercent;
  final int volumePercent;
  final int trackId;
}

class PresetHydrogenConfig {
  const PresetHydrogenConfig({required this.outputPercent});

  final int outputPercent;
}
