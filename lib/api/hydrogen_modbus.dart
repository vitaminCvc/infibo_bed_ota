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

  static HydrogenBatchPayload buildPayload({required int concentration}) {
    final int safeConcentration = concentration.clamp(0, 100).toInt();
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
