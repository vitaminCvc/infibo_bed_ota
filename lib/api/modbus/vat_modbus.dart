// VAT 模块 Modbus 数据构建器。
//
// 根据频率、强度和音乐索引生成批量写寄存器所需的数据。
import 'package:infibo_app/utils/number_utils.dart';

class VatBatchPayload {
  const VatBatchPayload({
    required this.startAddress,
    required this.values,
    required this.applyAddress,
    required this.commandAddress,
    required this.applyValue,
    required this.commandValue,
    required this.frequencyHz,
    required this.frequencyValue,
  });

  final int startAddress;
  final List<int> values;
  final int applyAddress;
  final int commandAddress;
  final int applyValue;
  final int commandValue;
  final double frequencyHz;
  final int frequencyValue;

  int get quantity => values.length;
}

class VatModbus {
  static const int startAddress = 0x0180;
  static const int endAddress = 0x018A;
  static const int quantity = 11;
  static const int applyAddress = 0x0190;
  static const int commandAddress = 0x0191;

  static VatBatchPayload buildPayload({
    required int frequencyHz,
    required int intensity,
    required int musicIndex,
  }) {
    final int safeIntensity = clampPercentage(intensity);
    final int enable = safeIntensity > 0 ? 1 : 0;
    final double hz = frequencyHz.toDouble();
    final int frequencyValue = (hz * 10).round().clamp(0, 65535).toInt();
    final int safeMusic = musicIndex.clamp(0, 65535).toInt();

    final List<int> values = <int>[
      enable, // 0x0180
      0, // 0x0181
      safeIntensity, // 0x0182
      0, // 0x0183
      0, // 0x0184
      frequencyValue, // 0x0185
      0, // 0x0186
      0, // 0x0187
      0, // 0x0188
      100, // 0x0189
      safeMusic, // 0x018A
    ];
    if (values.length != quantity) {
      throw StateError(
        'VAT payload length invalid: ${values.length}, expected $quantity',
      );
    }
    return VatBatchPayload(
      startAddress: startAddress,
      values: values,
      applyAddress: applyAddress,
      commandAddress: commandAddress,
      applyValue: 1,
      commandValue: 1,
      frequencyHz: hz,
      frequencyValue: frequencyValue,
    );
  }
}
