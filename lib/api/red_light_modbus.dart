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

  static RedLightBatchPayload buildPayload({
    required int strength660,
    required int strength850,
    required int mode,
  }) {
    final int safe660 = _clampPercent(strength660);
    final int safe850 = _clampPercent(strength850);
    final int safeMode = mode == 0 ? 0 : 1;
    final bool enabled = safe660 > 0 || safe850 > 0;

    final List<int> values = <int>[
      0, // 0x0063 红光目标站号（固定）
      enabled ? 1 : 0, // 0x0064 总使能
      safeMode, // 0x0065 红光总模式
      0, // 0x0066 共用脉冲频率（默认）
      100, // 0x0067 共用占空比（默认）
      safe660 > 0 ? 1 : 0, // 0x0068 660nm 使能
      0, // 0x0069 预留
      safeMode, // 0x006A 660nm 模式
      0, // 0x006B 预留
      100, // 0x006C 预留默认占空比
      safe660, // 0x006D 660nm 强度
      safe850 > 0 ? 1 : 0, // 0x006E 850nm 使能
      safeMode, // 0x006F 850nm 模式
      0, // 0x0070 预留
      safe850, // 0x0071 850nm 强度
    ];

    if (values.length != quantity) {
      throw StateError(
        'Red light payload length invalid: ${values.length}, expected $quantity',
      );
    }

    return RedLightBatchPayload(
      startAddress: startAddress,
      values: values,
      applyAddress: applyAddress,
      commandAddress: commandAddress,
      applyValue: 1,
      commandValue: enabled ? 1 : 2,
    );
  }

  static int _clampPercent(int value) => value.clamp(0, 100).toInt();
}
