class ChakraBatchPayload {
  const ChakraBatchPayload({
    required this.startAddress,
    required this.values,
    required this.applyAddress,
    required this.commandAddress,
    required this.applyValue,
    required this.commandValue,
    required this.crown,
    required this.thirdEye,
    required this.throat,
    required this.heart,
    required this.solarPlexus,
    required this.sacral,
    required this.root,
  });

  final int startAddress;
  final List<int> values;
  final int applyAddress;
  final int commandAddress;
  final int applyValue;
  final int commandValue;

  final int crown;
  final int thirdEye;
  final int throat;
  final int heart;
  final int solarPlexus;
  final int sacral;
  final int root;

  int get quantity => values.length;
}

class ChakraModbus {
  static const int startAddress = 0x0200;
  static const int endAddress = 0x0208;
  static const int quantity = 9;
  static const int applyAddress = 0x0210;
  static const int commandAddress = 0x0211;
  static const int enableAddress = 0x0200;
  static const int modeAddress = 0x0201;

  static const Map<String, int> strengthAddressMap = <String, int>{
    'crown': 0x0202,
    'third_eye': 0x0203,
    'throat': 0x0204,
    'heart': 0x0205,
    'solar_plexus': 0x0206,
    'sacral': 0x0207,
    'root': 0x0208,
  };

  static ChakraBatchPayload buildPayload({
    required Map<String, int> strengths,
    int mode = 0,
  }) {
    final int crown = _clampPercent(strengths['crown'] ?? 0);
    final int thirdEye = _clampPercent(strengths['third_eye'] ?? 0);
    final int throat = _clampPercent(strengths['throat'] ?? 0);
    final int heart = _clampPercent(strengths['heart'] ?? 0);
    final int solarPlexus = _clampPercent(strengths['solar_plexus'] ?? 0);
    final int sacral = _clampPercent(strengths['sacral'] ?? 0);
    final int root = _clampPercent(strengths['root'] ?? 0);
    final int safeMode = mode.clamp(0, 1).toInt();
    final bool enabled =
        crown > 0 ||
        thirdEye > 0 ||
        throat > 0 ||
        heart > 0 ||
        solarPlexus > 0 ||
        sacral > 0 ||
        root > 0;

    final List<int> values = <int>[
      enabled ? 1 : 0, // 0x0200 module enable
      safeMode, // 0x0201 module mode: 0=rotation, 1=independent
      crown, // 0x0202
      thirdEye, // 0x0203
      throat, // 0x0204
      heart, // 0x0205
      solarPlexus, // 0x0206
      sacral, // 0x0207
      root, // 0x0208
    ];

    if (values.length != quantity) {
      throw StateError(
        'Chakra payload length invalid: ${values.length}, expected $quantity',
      );
    }

    return ChakraBatchPayload(
      startAddress: startAddress,
      values: values,
      applyAddress: applyAddress,
      commandAddress: commandAddress,
      applyValue: 1,
      commandValue: enabled ? 1 : 2,
      crown: crown,
      thirdEye: thirdEye,
      throat: throat,
      heart: heart,
      solarPlexus: solarPlexus,
      sacral: sacral,
      root: root,
    );
  }

  static int _clampPercent(int value) => value.clamp(0, 100).toInt();
}
