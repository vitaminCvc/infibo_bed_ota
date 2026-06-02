// PEMF 模块 Modbus 数据构建器。
//
// 根据频率、强度和波形等参数生成批量写寄存器所需的数据。
import 'package:infibo_app/utils/number_utils.dart';

class PemfBatchPayload {
  const PemfBatchPayload({
    required this.enableAddress,
    required this.enableValue,
    required this.startAddress,
    required this.values,
    required this.applyAddress,
    required this.commandAddress,
    required this.applyValue,
    required this.commandValue,
  });

  final int enableAddress;
  final int enableValue;
  final int startAddress;
  final List<int> values;
  final int applyAddress;
  final int commandAddress;
  final int applyValue;
  final int commandValue;

  int get quantity => values.length;
}

class PemfModbus {
  static const int enableAddress = 0x00C0;
  static const int startAddress = 0x00C3;
  static const int endAddress = 0x00C9;
  static const int quantity = 7;
  static const int applyAddress = 0x00D0;
  static const int commandAddress = 0x00D1;

  static PemfBatchPayload buildPayload({
    required int frequencyHz,
    required int intensity,
    required int waveform,
    int dutyCycle = 100,
    int polarityMode = 0,
    int riseTime = 0,
    int fallTime = 0,
  }) {
    final int safeIntensity = clampPercentage(intensity);
    final int enableValue = safeIntensity > 0 ? 1 : 0;
    final int burstFrequency = (frequencyHz.clamp(0, 6553) * 10).toInt();
    final List<int> values = <int>[
      burstFrequency, // 0x00C3
      clampPercentage(dutyCycle), // 0x00C4
      safeIntensity, // 0x00C5
      waveform.clamp(0, 65535).toInt(), // 0x00C6
      polarityMode.clamp(0, 65535).toInt(), // 0x00C7
      riseTime.clamp(0, 65535).toInt(), // 0x00C8
      fallTime.clamp(0, 65535).toInt(), // 0x00C9
    ];
    if (values.length != quantity) {
      throw StateError(
        'PEMF payload length invalid: ${values.length}, expected $quantity',
      );
    }
    return PemfBatchPayload(
      enableAddress: enableAddress,
      enableValue: enableValue,
      startAddress: startAddress,
      values: values,
      applyAddress: applyAddress,
      commandAddress: commandAddress,
      applyValue: 1,
      commandValue: 1,
    );
  }
}
