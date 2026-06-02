// 红光模块 Modbus 数据构建器。
//
// 根据红光强度和模式生成批量写寄存器所需的数据。
import 'package:infibo_app/utils/number_utils.dart';

class RedLightBatchPayload {
  const RedLightBatchPayload({
    required this.startAddress,
    required this.values,
    required this.applyAddress,
    required this.commandAddress,
    required this.applyValue,
    required this.commandValue,
  });

  final int startAddress;
  final List<int> values;
  final int applyAddress;
  final int commandAddress;
  final int applyValue;
  final int commandValue;

  int get quantity => values.length;
}

class RedLightModbus {
  static const int startAddress = 0x0063;
  static const int endAddress = 0x0071;
  static const int quantity = 15;
  static const int applyAddress = 0x0072;
  static const int commandAddress = 0x0073;

  static List<int> buildValues({
    required int strength660,
    required int strength850,
    required int mode,
  }) {
    final int safe660 = clampPercentage(strength660);
    final int safe850 = clampPercentage(strength850);
    final int safeMode = mode == 0 ? 0 : 1;
    final bool enabled = safe660 > 0 || safe850 > 0;

    final List<int> values = <int>[
      0, // 0x0063 red light target station
      enabled ? 1 : 0, // 0x0064 total enable
      safeMode, // 0x0065 total mode
      0, // 0x0066 common pulse frequency
      100, // 0x0067 common duty cycle
      safe660 > 0 ? 1 : 0, // 0x0068 660nm enable
      safe660, // 0x0069 660nm intensity
      safeMode, // 0x006A 660nm mode
      0, // 0x006B use common pulse frequency
      0, // 0x006C use common duty cycle
      safe850 > 0 ? 1 : 0, // 0x006D 850nm enable
      safe850, // 0x006E 850nm intensity
      safeMode, // 0x006F 850nm mode
      0, // 0x0070 use common pulse frequency
      0, // 0x0071 use common duty cycle
    ];

    if (values.length != quantity) {
      throw StateError(
        'Red light payload length invalid: ${values.length}, expected $quantity',
      );
    }

    return values;
  }

  static RedLightBatchPayload buildPayload({
    required int strength660,
    required int strength850,
    required int mode,
  }) {
    final List<int> values = buildValues(
      strength660: strength660,
      strength850: strength850,
      mode: mode,
    );
    final bool enabled =
        clampPercentage(strength660) > 0 || clampPercentage(strength850) > 0;

    return RedLightBatchPayload(
      startAddress: startAddress,
      values: values,
      applyAddress: applyAddress,
      commandAddress: commandAddress,
      applyValue: 1,
      commandValue: enabled ? 1 : 2,
    );
  }
}
