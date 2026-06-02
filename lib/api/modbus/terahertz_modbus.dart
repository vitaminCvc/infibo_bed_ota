// 太赫兹模块 Modbus 数据构建器。
//
// 根据频率、功率、模式和波形生成批量写寄存器所需的数据。
import 'package:infibo_app/utils/number_utils.dart';

class TerahertzBatchPayload {
  const TerahertzBatchPayload({
    required this.startAddress,
    required this.values,
    required this.applyAddress,
    required this.commandAddress,
    required this.applyValue,
    required this.commandValue,
    required this.mode,
    required this.power,
    required this.frequency,
    required this.wave,
  });

  final int startAddress;
  final List<int> values;
  final int applyAddress;
  final int commandAddress;
  final int applyValue;
  final int commandValue;
  final int mode;
  final int power;
  final int frequency;
  final int wave;

  int get quantity => values.length;
}

class TerahertzModbus {
  static const int startAddress = 0x0240;
  static const int endAddress = 0x0244;
  static const int quantity = 5;
  static const int applyAddress = 0x0250;
  static const int commandAddress = 0x0251;
  static const int faultResetAddress = 0x0252;
  static const int enableAddress = 0x0240;
  static const int modeAddress = 0x0241;
  static const int powerAddress = 0x0242;
  static const int frequencyAddress = 0x0243;
  static const int waveAddress = 0x0244;

  static TerahertzBatchPayload buildPayload({
    required int frequency,
    required int power,
    required int mode,
    required int wave,
  }) {
    final int safePower = clampPercentage(power);
    final int safeMode = mode.clamp(0, 1).toInt();
    final int safeFrequency = frequency.clamp(1, 100).toInt();
    final int safeWave = wave.clamp(0, 2).toInt();
    final int enable = safePower > 0 ? 1 : 0;

    final List<int> values = <int>[
      enable, // 0x0240
      safeMode, // 0x0241
      safePower, // 0x0242
      safeFrequency, // 0x0243
      safeWave, // 0x0244
    ];

    if (values.length != quantity) {
      throw StateError(
        'Terahertz payload length invalid: ${values.length}, expected $quantity',
      );
    }

    return TerahertzBatchPayload(
      startAddress: startAddress,
      values: values,
      applyAddress: applyAddress,
      commandAddress: commandAddress,
      applyValue: 1,
      commandValue: enable == 1 ? 1 : 2,
      mode: safeMode,
      power: safePower,
      frequency: safeFrequency,
      wave: safeWave,
    );
  }
}
