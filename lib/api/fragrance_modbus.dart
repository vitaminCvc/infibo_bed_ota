class FragranceBatchPayload {
  const FragranceBatchPayload({
    required this.startAddress,
    required this.values,
    required this.applyAddress,
    required this.commandAddress,
    required this.applyValue,
    required this.commandValue,
    required this.enabled,
    required this.fragranceMode,
  });

  final int startAddress;
  final List<int> values;
  final int applyAddress;
  final int commandAddress;
  final int applyValue;
  final int commandValue;
  final bool enabled;
  final int fragranceMode;

  int get quantity => values.length;
}

class FragranceModbus {
  static const int startAddress = 0x0280;
  static const int endAddress = 0x0282;
  static const int quantity = 3;
  static const int enableAddress = 0x0280;
  static const int moduleModeAddress = 0x0281;
  static const int fragranceModeAddress = 0x0282;
  static const int applyAddress = 0x0290;
  static const int commandAddress = 0x0291;
  static const int faultResetAddress = 0x0292;

  static FragranceBatchPayload buildPayload({
    required bool enabled,
    required int fragranceMode,
  }) {
    final int safeMode = fragranceMode.clamp(0, 4).toInt();
    final List<int> values = <int>[
      enabled ? 1 : 0, // 0x0280 enable
      0, // 0x0281 module mode default 0
      safeMode, // 0x0282 fragrance mode
    ];

    if (values.length != quantity) {
      throw StateError(
        'Fragrance payload length invalid: ${values.length}, expected $quantity',
      );
    }

    return FragranceBatchPayload(
      startAddress: startAddress,
      values: values,
      applyAddress: applyAddress,
      commandAddress: commandAddress,
      applyValue: 1,
      commandValue: enabled ? 1 : 2,
      enabled: enabled,
      fragranceMode: safeMode,
    );
  }
}
