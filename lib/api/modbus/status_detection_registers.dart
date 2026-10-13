import 'package:infibo_app/api/modbus/hydrogen_modbus.dart';
import 'package:infibo_app/api/modbus/modbus_rtu_service.dart';

/// 状态检测表的实际地址。页面只读取，不下发配置或治疗命令。
abstract final class StatusDetectionRegisters {
  static const redState = 0x0080;
  static const redTemperature660 = 0x0089;
  static const redTemperature850 = 0x008E;
  static const pemfState = 0x00E0;
  static const pemfCurrent = 0x00E4;
  static const pemfVoltage = 0x00E5;
  static const pemfCoilTemperature = 0x00E6;
  static const vatState = 0x01A0;
  static const vatVolume = ModbusRtuService.vatVolumeAddress;
  static const vatAmplifierTemperature = 0x01A5;
  static const hydrogenState = 0x01E0;
  static const waterLevel = HydrogenModbus.waterLevelReadAddress;
  static const waterTemperature = 0x01E6;
  static const hydrogenRuntime = HydrogenModbus.cumulativeRuntimeAddress;
  static const waterTds = HydrogenModbus.waterQualityTestingAddress;

  static const addresses = <int>[
    redState,
    redTemperature660,
    redTemperature850,
    pemfState,
    pemfCurrent,
    pemfVoltage,
    pemfCoilTemperature,
    vatState,
    vatVolume,
    vatAmplifierTemperature,
    hydrogenState,
    waterLevel,
    waterTemperature,
    hydrogenRuntime,
    waterTds,
  ];
}
