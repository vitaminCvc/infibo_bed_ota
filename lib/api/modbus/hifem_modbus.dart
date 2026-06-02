// HIFEM 模块 Modbus 数据构建器。
//
// 根据额头和左右脸部的射频、磁场强度生成批量写寄存器所需的数据。
import 'package:infibo_app/utils/number_utils.dart';

class HifemModbus {
  const HifemModbus._();

  static const int startAddress = 0x02C0;
  static const int quantity = 8;
  static const int endAddress = startAddress + quantity - 1;

  static const int enableAddress = 0x02C0;
  static const int moduleModeAddress = 0x02C1;
  static const int foreheadRfAddress = 0x02C2;
  static const int foreheadMagneticAddress = 0x02C3;
  static const int leftFaceRfAddress = 0x02C4;
  static const int leftFaceMagneticAddress = 0x02C5;
  static const int rightFaceRfAddress = 0x02C6;
  static const int rightFaceMagneticAddress = 0x02C7;

  static const int applyAddress = 0x02D0;
  static const int commandAddress = 0x02D1;
  static const int faultResetAddress = 0x02D2;

  static HifemBatchPayload buildPayload({
    required int foreheadRf,
    required int foreheadMagnetic,
    required int leftFaceRf,
    required int leftFaceMagnetic,
    required int rightFaceRf,
    required int rightFaceMagnetic,
    int mode = 0,
  }) {
    final int safeForeheadRf = clampPercentage(foreheadRf);
    final int safeForeheadMagnetic = clampPercentage(foreheadMagnetic);
    final int safeLeftFaceRf = clampPercentage(leftFaceRf);
    final int safeLeftFaceMagnetic = clampPercentage(leftFaceMagnetic);
    final int safeRightFaceRf = clampPercentage(rightFaceRf);
    final int safeRightFaceMagnetic = clampPercentage(rightFaceMagnetic);
    final int safeMode = mode == 1 ? 1 : 0;
    final bool enabled =
        safeForeheadRf > 0 ||
        safeForeheadMagnetic > 0 ||
        safeLeftFaceRf > 0 ||
        safeLeftFaceMagnetic > 0 ||
        safeRightFaceRf > 0 ||
        safeRightFaceMagnetic > 0;

    final List<int> values = <int>[
      enabled ? 1 : 0, // 0x02C0
      safeMode, // 0x02C1
      safeForeheadRf, // 0x02C2
      safeForeheadMagnetic, // 0x02C3
      safeLeftFaceRf, // 0x02C4
      safeLeftFaceMagnetic, // 0x02C5
      safeRightFaceRf, // 0x02C6
      safeRightFaceMagnetic, // 0x02C7
    ];

    return HifemBatchPayload(
      startAddress: startAddress,
      values: values,
      applyAddress: applyAddress,
      commandAddress: commandAddress,
      applyValue: 1,
      commandValue: 1,
      mode: safeMode,
      foreheadRf: safeForeheadRf,
      foreheadMagnetic: safeForeheadMagnetic,
      leftFaceRf: safeLeftFaceRf,
      leftFaceMagnetic: safeLeftFaceMagnetic,
      rightFaceRf: safeRightFaceRf,
      rightFaceMagnetic: safeRightFaceMagnetic,
    );
  }
}

class HifemBatchPayload {
  const HifemBatchPayload({
    required this.startAddress,
    required this.values,
    required this.applyAddress,
    required this.commandAddress,
    required this.applyValue,
    required this.commandValue,
    required this.mode,
    required this.foreheadRf,
    required this.foreheadMagnetic,
    required this.leftFaceRf,
    required this.leftFaceMagnetic,
    required this.rightFaceRf,
    required this.rightFaceMagnetic,
  });

  final int startAddress;
  final List<int> values;
  final int applyAddress;
  final int commandAddress;
  final int applyValue;
  final int commandValue;
  final int mode;
  final int foreheadRf;
  final int foreheadMagnetic;
  final int leftFaceRf;
  final int leftFaceMagnetic;
  final int rightFaceRf;
  final int rightFaceMagnetic;
}
