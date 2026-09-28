// 分子氢模块 Modbus 数据构建器。
//
// 根据浓度生成批量写寄存器所需的数据。
import 'package:infibo_app/utils/number_utils.dart';

class HydrogenBatchPayload {
  const HydrogenBatchPayload({
    required this.startAddress,
    required this.values,
    required this.applyAddress,
    required this.commandAddress,
    required this.applyValue,
    required this.commandValue,
    required this.concentration,
  });

  final int startAddress;
  final List<int> values;
  final int applyAddress;
  final int commandAddress;
  final int applyValue;
  final int commandValue;
  final int concentration;

  int get quantity => values.length;
}

class HydrogenModbus {
  static const int startAddress = 0x01C0;
  static const int endAddress = 0x01C4;
  static const int quantity = 5;
  static const int applyAddress = 0x01D0;
  static const int commandAddress = 0x01D1;
  static const int flowReadAddress = 0x01E4;
  static const int waterLevelReadAddress = 0x01E5;

  /// 自动加水开关：写入 1 开始自动加水，水位仍由 0x01E5 轮询确认。
  static const int waterFillingSwitchAddress = 0x01EB;

  static HydrogenBatchPayload buildPayload({required int concentration}) {
    final int safeConcentration = clampPercentage(concentration);
    final int enable = safeConcentration > 0 ? 1 : 0;
    final List<int> values = <int>[
      enable, // 0x01C0
      0, // 0x01C1
      safeConcentration, // 0x01C2 电解功率=浓度
      0, // 0x01C3
      0, // 0x01C4
    ];
    if (values.length != quantity) {
      throw StateError(
        'Hydrogen payload length invalid: ${values.length}, expected $quantity',
      );
    }
    return HydrogenBatchPayload(
      startAddress: startAddress,
      values: values,
      applyAddress: applyAddress,
      commandAddress: commandAddress,
      applyValue: 1,
      commandValue: 1,
      concentration: safeConcentration,
    );
  }
}
