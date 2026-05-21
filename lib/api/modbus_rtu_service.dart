// Modbus RTU 写寄存器服务。
//
// 目前主要用于向下位机主控板发送“写单寄存器 0x06”命令。
// Android 真机走 AndroidSerialPortService + /dev/ttyS0；
// Windows 调试时仍保留 flutter_libserialport 分支，便于桌面串口测试。
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:infibo_app/api/chakra_modbus.dart';
import 'package:infibo_app/api/fragrance_modbus.dart';
import 'package:infibo_app/api/hifem_modbus.dart';
import 'package:infibo_app/api/hydrogen_modbus.dart';
import 'package:infibo_app/api/pemf_modbus.dart';
import 'package:infibo_app/api/red_light_modbus.dart';
import 'package:infibo_app/api/terahertz_modbus.dart';
import 'package:infibo_app/api/vat_modbus.dart';
import 'package:infibo_app/services/android_serial_port_service.dart';

class ModbusRtuService {
  static const Duration modbusCommandInterval = Duration(milliseconds: 40);

  /// 系统控制命令寄存器地址。
  static const int systemCommandAddress = 0x0004;

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////红光模块相关寄存器地址//////////////////

  /// 红光总命令地址。
  static const int redLightTotalEnableAddress = 0x0064;

  /// 红光总模式地址。
  static const int redLightTotalModeAddress = 0x0065;

  /// 红光总命令地址。
  static const int redLightTotalCommandAddress = 0x0073;
  static const int redLightApplyAddress = 0x0072;

  /// 红光660nm 启用地址。
  static const int redLight660EnableAddress = 0x0068;

  /// 红光660nm 模式地址。
  static const int redLight660ModeAddress = 0x006A;

  /// 红光660nm 功率地址。
  static const int redLight660PowerAddress = 0x0069;

  /// 红光850nm 启用地址。
  static const int redLight850EnableAddress = 0x006D;

  /// 红光850nm 模式地址。
  static const int redLight850ModeAddress = 0x006F;

  /// 红光850nm 功率地址。
  static const int redLight850PowerAddress = 0x006E;

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////PEMF模块相关寄存器地址//////////////////

  /// PEMF总命令地址。
  static const int pemfTotalCommandAddress = PemfModbus.commandAddress;

  /// PEMF总启用地址。
  static const int pemfTotalEnableAddress = PemfModbus.enableAddress;

  /// PEMF总模式地址。
  static const int pemfTotalModeAddress = 0x00C7;

  ///PEMF总频率地址。
  static const int pemfTotalFrequencyAddress = 0x00C3;

  /// PEMF输出强度地址。
  static const int pemfTotalIntensityAddress = 0x00C5;

  /// PEMF输出波形地址。
  static const int pemfTotalWaveformAddress = 0x00C6;
  static const int pemfDutyCycleAddress = 0x00C4;
  static const int pemfPolarityAddress = 0x00C7;
  static const int pemfRiseTimeAddress = 0x00C8;
  static const int pemfFallTimeAddress = 0x00C9;
  static const int pemfApplyAddress = PemfModbus.applyAddress;

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////VAT模块相关寄存器地址//////////////////

  /// VAT总启用地址。
  static const int vatEnableAddress = 0x0180;

  /// VAT模式地址。
  static const int vatModeAddress = 0x0181;

  /// VAT命令地址。
  static const int vatCommandAddress = VatModbus.commandAddress;

  /// VAT频率地址。
  static const int vatFrequencyAddress = 0x0185;

  /// VAT强度地址。
  static const int vatIntensityAddress = 0x0182;

  /// VAT音乐索引地址。
  static const int vatMusicIndexAddress = 0x018A;
  static const int vatApplyAddress = VatModbus.applyAddress;
  static const int vatLeftChannelIntensityAddress = 0x0183;
  static const int vatRightChannelIntensityAddress = 0x0184;
  static const int vatSweepStartAddress = 0x0186;
  static const int vatSweepEndAddress = 0x0187;
  static const int vatSweepCycleAddress = 0x0188;
  static const int vatVolumeAddress = 0x0189;

  /// 分子氢使能地址。
  static const int hydrogenEnableAddress = 0x01C0;

  /// 分子氢模式地址。
  static const int hydrogenModeAddress = 0x01C1;

  /// 分子氢命令地址。
  static const int hydrogenCommandAddress = HydrogenModbus.commandAddress;

  /// 分子氢浓度地址。
  static const int hydrogenConcentrationAddress = 0x01C2;

  /// 分子氢流量地址（只读）。
  static const int hydrogenFlowAddress = HydrogenModbus.flowReadAddress;
  static const int hydrogenTargetFlowAddress = 0x01C3;
  static const int hydrogenAutoCleanAddress = 0x01C4;
  static const int hydrogenApplyAddress = HydrogenModbus.applyAddress;
  static const int chakraEnableAddress = ChakraModbus.enableAddress;
  static const int chakraModeAddress = ChakraModbus.modeAddress;
  static const int chakraCommandAddress = ChakraModbus.commandAddress;
  static const int chakraApplyAddress = ChakraModbus.applyAddress;
  static const Map<String, int> chakraStrengthAddressMap = <String, int>{
    'crown': 0x0202,
    'third_eye': 0x0203,
    'throat': 0x0204,
    'heart': 0x0205,
    'solar_plexus': 0x0206,
    'sacral': 0x0207,
    'root': 0x0208,
  };
  static const int terahertzEnableAddress = TerahertzModbus.enableAddress;
  static const int terahertzModeAddress = TerahertzModbus.modeAddress;
  static const int terahertzCommandAddress = TerahertzModbus.commandAddress;
  static const int terahertzPowerAddress = TerahertzModbus.powerAddress;
  static const int terahertzFrequencyAddress = TerahertzModbus.frequencyAddress;
  static const int terahertzWaveAddress = TerahertzModbus.waveAddress;
  static const int terahertzApplyAddress = TerahertzModbus.applyAddress;
  static const int terahertzFaultResetAddress =
      TerahertzModbus.faultResetAddress;
  static const int fragranceEnableAddress = FragranceModbus.enableAddress;
  static const int fragranceModeAddress = FragranceModbus.moduleModeAddress;
  static const int fragranceTypeAddress = FragranceModbus.fragranceModeAddress;
  static const int fragranceApplyAddress = FragranceModbus.applyAddress;
  static const int fragranceCommandAddress = FragranceModbus.commandAddress;
  static const int fragranceFaultResetAddress =
      FragranceModbus.faultResetAddress;
  static const int hifemEnableAddress = HifemModbus.enableAddress;
  static const int hifemModeAddress = HifemModbus.moduleModeAddress;
  static const int hifemForeheadRfAddress = HifemModbus.foreheadRfAddress;
  static const int hifemForeheadHifesAddress =
      HifemModbus.foreheadMagneticAddress;
  static const int hifemLeftCheekRfAddress = HifemModbus.leftFaceRfAddress;
  static const int hifemLeftCheekHifesAddress =
      HifemModbus.leftFaceMagneticAddress;
  static const int hifemRightCheekRfAddress = HifemModbus.rightFaceRfAddress;
  static const int hifemRightCheekHifesAddress =
      HifemModbus.rightFaceMagneticAddress;
  static const int hifemApplyAddress = HifemModbus.applyAddress;
  static const int hifemCommandAddress = HifemModbus.commandAddress;
  static const int hifemFaultResetAddress = HifemModbus.faultResetAddress;

  final String portName; // Android 上通常是 /dev/ttyS0。
  final int baudRate; // 115200。
  final int slaveId; // 16。
  final Duration timeout; // 1 秒。
  final Duration commandDelay; // 命令间延迟。
  final int maxRetries; // 最大重试次数，默认 2 次。

  // 其他参数如数据位、停止位、校验等 Modbus RTU 标准配置固定为 8N1，无需暴露。
  const ModbusRtuService({
    this.portName = AndroidSerialPortService.defaultPath,
    this.baudRate = AndroidSerialPortService.defaultBaudRate,
    this.slaveId = 16,
    this.timeout = const Duration(seconds: 1),
    this.commandDelay = modbusCommandInterval,
    this.maxRetries = 2,
  });

  /// 启动，发送 0x0004 = 1 命令。
  Future<void> start() async {
    await sendCommandQueue([
      const ModbusWriteCommand(address: systemCommandAddress, value: 1),
    ]);
  }

  /// 停止，发送 0x0004 = 2 命令。
  Future<void> pause() async {
    await sendCommandQueue([
      const ModbusWriteCommand(address: systemCommandAddress, value: 2),
    ]);
  }

  //暂停按钮
  Future<void> pauseTherapy({
    bool pauseRed = false,
    bool pauseVat = false,
    bool pausePemf = false,
    bool pauseHydrogen = false,
    bool pauseChakra = false,
    bool pauseTerahertz = false,
    bool pauseHifem = false,
    bool pauseFragrance = false,
  }) {
    return sendCommandQueue([
      ...buildModulePauseCommands(
        pauseRed: pauseRed,
        pauseVat: pauseVat,
        pausePemf: pausePemf,
        pauseHydrogen: pauseHydrogen,
        pauseChakra: pauseChakra,
        pauseTerahertz: pauseTerahertz,
        pauseHifem: pauseHifem,
        pauseFragrance: pauseFragrance,
      ),
      const ModbusWriteCommand(address: systemCommandAddress, value: 3),
    ]);
  }

  // 继续总命令。
  Future<void> resumeTherapy({
    bool resumeRed = false,
    bool resumeVat = false,
    bool resumePemf = false,
    bool resumeHydrogen = false,
    bool resumeChakra = false,
    bool resumeTerahertz = false,
    bool resumeHifem = false,
    bool resumeFragrance = false,
  }) {
    return sendCommandQueue([
      ...buildModuleResumeCommands(
        resumeRed: resumeRed,
        resumeVat: resumeVat,
        resumePemf: resumePemf,
        resumeHydrogen: resumeHydrogen,
        resumeChakra: resumeChakra,
        resumeTerahertz: resumeTerahertz,
        resumeHifem: resumeHifem,
        resumeFragrance: resumeFragrance,
      ),
      const ModbusWriteCommand(address: systemCommandAddress, value: 4),
    ]);
  }

  // 停止总命令。
  Future<void> stopTherapy({
    bool stopRed = false,
    bool stopVat = false,
    bool stopPemf = false,
    bool stopHydrogen = false,
    bool stopChakra = false,
    bool stopTerahertz = false,
    bool stopHifem = false,
    bool stopFragrance = false,
  }) async {
    if (!stopChakra && !stopFragrance && !stopHifem) {
      await sendCommandQueue(
        buildStopTherapyCommands(
          stopRed: stopRed,
          stopVat: stopVat,
          stopPemf: stopPemf,
          stopHydrogen: stopHydrogen,
          stopChakra: stopChakra,
          stopTerahertz: stopTerahertz,
          stopHifem: stopHifem,
          stopFragrance: stopFragrance,
          includeSystemStop: true,
        ),
      );
      return;
    }

    await _stopTherapyWithBatchClear(
      stopRed: stopRed,
      stopVat: stopVat,
      stopPemf: stopPemf,
      stopHydrogen: stopHydrogen,
      stopChakra: stopChakra,
      stopTerahertz: stopTerahertz,
      stopHifem: stopHifem,
      stopFragrance: stopFragrance,
    );
  }

  /// 按自定义方案的当前 5 分钟节点配置红光模块。
  ///
  /// mode: 0=连续，1=脉冲；strength660/strength850 均为 0-100%。
  /// 写完参数后，如果至少一个波长强度大于 0，会向红光总命令写 1 启动红光模块。
  Future<void> applyRedLightSetting({
    required int strength660,
    required int strength850,
    required int mode,
  }) async {
    final RedLightBatchPayload payload = RedLightModbus.buildPayload(
      strength660: strength660,
      strength850: strength850,
      mode: mode,
    );
    await _applyRedLightPayload(payload);
  }

  /// 当前阶段不需要红光时，停止红光模块并关闭两个波长输出。
  Future<void> stopRedLight() async {
    await sendCommandQueue(buildStopRedLightCommands());
  }

  /// 下发当前 5 分钟节点参数，全部成功后最后发送系统启动命令。
  Future<void> startWithCommands(List<ModbusWriteCommand> parameterCommands) {
    return _startWithModuleBatches(parameterCommands);
  }

  Future<void> _startWithModuleBatches(
    List<ModbusWriteCommand> parameterCommands,
  ) async {
    final _RedLightBatchParseResult redParsed = _extractRedLightPayload(
      parameterCommands,
    );
    final _PemfBatchParseResult pemfParsed = _extractPemfPayload(
      redParsed.remainingCommands,
    );
    final _VatBatchParseResult vatParsed = _extractVatPayload(
      pemfParsed.remainingCommands,
    );
    final _HydrogenBatchParseResult hydrogenParsed = _extractHydrogenPayload(
      vatParsed.remainingCommands,
    );
    final _ChakraBatchParseResult chakraParsed = _extractChakraPayload(
      hydrogenParsed.remainingCommands,
    );
    final _TerahertzBatchParseResult terahertzParsed = _extractTerahertzPayload(
      chakraParsed.remainingCommands,
    );
    final _FragranceBatchParseResult fragranceParsed = _extractFragrancePayload(
      terahertzParsed.remainingCommands,
    );
    final _HifemBatchParseResult hifemParsed = _extractHifemPayload(
      fragranceParsed.remainingCommands,
    );
    await sendCommandQueue(hifemParsed.remainingCommands);
    if (redParsed.payload != null) {
      await _applyRedLightPayload(redParsed.payload!);
    }
    if (pemfParsed.payload != null) {
      await _applyPemfPayload(pemfParsed.payload!);
    }
    if (vatParsed.payload != null) {
      await _applyVatPayload(vatParsed.payload!);
    }
    if (hydrogenParsed.payload != null) {
      await _applyHydrogenPayload(hydrogenParsed.payload!);
    }
    if (chakraParsed.payload != null) {
      await _applyChakraPayload(chakraParsed.payload!);
    }
    if (terahertzParsed.payload != null) {
      await _applyTerahertzPayload(terahertzParsed.payload!);
    }
    if (fragranceParsed.payload != null) {
      await _applyFragrancePayload(fragranceParsed.payload!);
    }
    if (hifemParsed.payload != null) {
      await _applyHifemPayload(hifemParsed.payload!);
    }
    debugPrint('System start command will be sent last: 0x0004 = 1');
    await sendCommandQueue([
      const ModbusWriteCommand(address: systemCommandAddress, value: 1),
    ]);
  }

  // 构建红光模块相关寄存器的写命令列表。
  List<ModbusWriteCommand> buildRedLightCommands({
    required int strength660,
    required int strength850,
    required int mode,
  }) {
    final RedLightBatchPayload payload = RedLightModbus.buildPayload(
      strength660: strength660,
      strength850: strength850,
      mode: mode,
    );
    return [
      for (int i = 0; i < payload.values.length; i++)
        ModbusWriteCommand(
          address: payload.startAddress + i,
          value: payload.values[i],
        ),
      ModbusWriteCommand(
        address: payload.applyAddress,
        value: payload.applyValue,
      ),
      ModbusWriteCommand(
        address: payload.commandAddress,
        value: payload.commandValue,
      ),
    ];
  }

  List<ModbusWriteCommand> buildPemfCommands({
    required int frequencyHz,
    required int intensity,
    required int waveform,
    int dutyCycle = 100,
    int polarityMode = 0,
    int riseTime = 0,
    int fallTime = 0,
  }) {
    final PemfBatchPayload payload = PemfModbus.buildPayload(
      frequencyHz: frequencyHz,
      intensity: intensity,
      waveform: waveform,
      dutyCycle: dutyCycle,
      polarityMode: polarityMode,
      riseTime: riseTime,
      fallTime: fallTime,
    );
    return [
      ModbusWriteCommand(
        address: payload.enableAddress,
        value: payload.enableValue,
      ),
      for (int i = 0; i < payload.values.length; i++)
        ModbusWriteCommand(
          address: payload.startAddress + i,
          value: payload.values[i],
        ),
      ModbusWriteCommand(
        address: payload.applyAddress,
        value: payload.applyValue,
      ),
      ModbusWriteCommand(
        address: payload.commandAddress,
        value: payload.commandValue,
      ),
    ];
  }

  // 构建红光模块相关寄存器的写命令列表。
  List<ModbusWriteCommand> buildStopRedLightCommands() {
    return const [
      ModbusWriteCommand(address: redLightTotalCommandAddress, value: 2),
      ModbusWriteCommand(address: redLight660EnableAddress, value: 0),
      ModbusWriteCommand(address: redLight660PowerAddress, value: 0),
      ModbusWriteCommand(address: redLight850EnableAddress, value: 0),
      ModbusWriteCommand(address: redLight850PowerAddress, value: 0),
      ModbusWriteCommand(address: redLightTotalEnableAddress, value: 0),
    ];
  }

  // 构建停止治疗的命令列表，系统命令必须最后发送。
  List<ModbusWriteCommand> buildStopTherapyCommands({
    bool stopRed = false,
    bool stopVat = false,
    bool stopPemf = false,
    bool stopHydrogen = false,
    bool stopChakra = false,
    bool stopTerahertz = false,
    bool stopHifem = false,
    bool stopFragrance = false,
    bool includeSystemStop = true,
  }) {
    return [
      if (stopRed) ...buildStopRedLightCommands(),
      if (stopPemf) ...[
        const ModbusWriteCommand(address: pemfTotalCommandAddress, value: 2),
        const ModbusWriteCommand(address: pemfTotalIntensityAddress, value: 0),
        const ModbusWriteCommand(address: pemfTotalEnableAddress, value: 0),
      ],
      if (stopHydrogen) ...[
        const ModbusWriteCommand(address: hydrogenCommandAddress, value: 2),
        const ModbusWriteCommand(
          address: hydrogenConcentrationAddress,
          value: 0,
        ),
        const ModbusWriteCommand(address: hydrogenEnableAddress, value: 0),
      ],
      if (stopVat) ...[
        const ModbusWriteCommand(address: vatCommandAddress, value: 2),
        const ModbusWriteCommand(address: vatIntensityAddress, value: 0),
        const ModbusWriteCommand(address: vatEnableAddress, value: 0),
      ],
      if (stopChakra) ...[
        const ModbusWriteCommand(address: chakraCommandAddress, value: 2),
        ...chakraStrengthAddressMap.values.map(
          (address) => ModbusWriteCommand(address: address, value: 0),
        ),
        const ModbusWriteCommand(address: chakraEnableAddress, value: 0),
      ],
      if (stopTerahertz) ...[
        const ModbusWriteCommand(address: terahertzCommandAddress, value: 2),
        const ModbusWriteCommand(address: terahertzPowerAddress, value: 0),
        const ModbusWriteCommand(address: terahertzEnableAddress, value: 0),
      ],
      if (stopHifem)
        const ModbusWriteCommand(address: hifemCommandAddress, value: 2),
      if (stopFragrance) ...[
        const ModbusWriteCommand(address: fragranceCommandAddress, value: 2),
        const ModbusWriteCommand(address: fragranceEnableAddress, value: 0),
      ],
      if (includeSystemStop)
        const ModbusWriteCommand(address: systemCommandAddress, value: 2),
    ];
  }

  Future<void> _stopTherapyWithBatchClear({
    required bool stopRed,
    required bool stopVat,
    required bool stopPemf,
    required bool stopHydrogen,
    required bool stopChakra,
    required bool stopTerahertz,
    required bool stopHifem,
    required bool stopFragrance,
  }) async {
    final List<ModbusWriteCommand> otherModuleStops = buildStopTherapyCommands(
      stopRed: stopRed,
      stopVat: stopVat,
      stopPemf: stopPemf,
      stopHydrogen: stopHydrogen,
      stopChakra: false,
      stopTerahertz: stopTerahertz,
      stopHifem: false,
      stopFragrance: false,
      includeSystemStop: false,
    );
    if (otherModuleStops.isNotEmpty) {
      await sendCommandQueue(otherModuleStops);
    }

    if (stopChakra) {
      await sendCommandQueue([
        const ModbusWriteCommand(address: chakraCommandAddress, value: 2),
      ]);
      if (commandDelay > Duration.zero) {
        await Future<void>.delayed(commandDelay);
      }

      final List<int> chakraClearValues = <int>[
        0, // 0x0200 chakra enable
        0, // 0x0201 chakra mode
        0, // 0x0202 crown
        0, // 0x0203 third eye
        0, // 0x0204 throat
        0, // 0x0205 heart
        0, // 0x0206 solar plexus
        0, // 0x0207 sacral
        0, // 0x0208 root
      ];
      debugPrint('Chakra stop clear startAddress = 0x0200');
      debugPrint('Chakra stop clear quantity = 9');
      debugPrint('Chakra stop clear values = $chakraClearValues');
      for (int i = 0; i < chakraClearValues.length; i++) {
        final int address = ChakraModbus.startAddress + i;
        debugPrint(
          'Chakra stop clear map 0x${address.toRadixString(16).toUpperCase().padLeft(4, '0')} -> ${chakraClearValues[i]}',
        );
      }
      await writeMultipleRegisters(
        startAddress: ChakraModbus.startAddress,
        values: chakraClearValues,
        logTag: 'ChakraStopClear',
      );
      if (commandDelay > Duration.zero) {
        await Future<void>.delayed(commandDelay);
      }
    }

    if (stopFragrance) {
      await sendCommandQueue([
        const ModbusWriteCommand(address: fragranceCommandAddress, value: 2),
      ]);
      if (commandDelay > Duration.zero) {
        await Future<void>.delayed(commandDelay);
      }
      final List<int> fragranceClearValues = <int>[
        0, // 0x0280 enable
        0, // 0x0281 module mode
        0, // 0x0282 fragrance mode
      ];
      debugPrint('Fragrance stop clear startAddress = 0x0280');
      debugPrint('Fragrance stop clear quantity = 3');
      debugPrint('Fragrance stop clear values = $fragranceClearValues');
      for (int i = 0; i < fragranceClearValues.length; i++) {
        final int address = FragranceModbus.startAddress + i;
        debugPrint(
          'Fragrance stop clear map 0x${address.toRadixString(16).toUpperCase().padLeft(4, '0')} -> ${fragranceClearValues[i]}',
        );
      }
      await writeMultipleRegisters(
        startAddress: FragranceModbus.startAddress,
        values: fragranceClearValues,
        logTag: 'FragranceStopClear',
      );
      if (commandDelay > Duration.zero) {
        await Future<void>.delayed(commandDelay);
      }
    }

    if (stopHifem) {
      await sendCommandQueue([
        const ModbusWriteCommand(address: hifemCommandAddress, value: 2),
      ]);
      if (commandDelay > Duration.zero) {
        await Future<void>.delayed(commandDelay);
      }
      final List<int> hifemClearValues = <int>[
        0, // 0x02C0 enable
        0, // 0x02C1 mode
        0, // 0x02C2 forehead rf
        0, // 0x02C3 forehead magnetic
        0, // 0x02C4 left rf
        0, // 0x02C5 left magnetic
        0, // 0x02C6 right rf
        0, // 0x02C7 right magnetic
      ];
      debugPrint('HIFEM stop clear startAddress = 0x02C0');
      debugPrint('HIFEM stop clear quantity = 8');
      debugPrint('HIFEM stop clear values = $hifemClearValues');
      for (int i = 0; i < hifemClearValues.length; i++) {
        final int address = HifemModbus.startAddress + i;
        debugPrint(
          'HIFEM stop clear map 0x${address.toRadixString(16).toUpperCase().padLeft(4, '0')} -> ${hifemClearValues[i]}',
        );
      }
      await writeMultipleRegisters(
        startAddress: HifemModbus.startAddress,
        values: hifemClearValues,
        logTag: 'HIFEMStopClear',
      );
      if (commandDelay > Duration.zero) {
        await Future<void>.delayed(commandDelay);
      }
    }

    debugPrint('System stop command will be sent last: 0x0004 = 2');
    await sendCommandQueue([
      const ModbusWriteCommand(address: systemCommandAddress, value: 2),
    ]);
  }

  /// 构建模块暂停命令列表（不含系统命令）。
  List<ModbusWriteCommand> buildModulePauseCommands({
    bool pauseRed = false,
    bool pauseVat = false,
    bool pausePemf = false,
    bool pauseHydrogen = false,
    bool pauseChakra = false,
    bool pauseTerahertz = false,
    bool pauseHifem = false,
    bool pauseFragrance = false,
  }) {
    return [
      if (pauseHydrogen)
        const ModbusWriteCommand(address: hydrogenCommandAddress, value: 3),
      if (pausePemf)
        const ModbusWriteCommand(address: pemfTotalCommandAddress, value: 3),
      if (pauseVat)
        const ModbusWriteCommand(address: vatCommandAddress, value: 3),
      if (pauseChakra)
        const ModbusWriteCommand(address: chakraCommandAddress, value: 3),
      if (pauseTerahertz)
        const ModbusWriteCommand(address: terahertzCommandAddress, value: 3),
      if (pauseHifem)
        const ModbusWriteCommand(address: hifemCommandAddress, value: 3),
      if (pauseFragrance)
        const ModbusWriteCommand(address: fragranceCommandAddress, value: 3),
      if (pauseRed)
        const ModbusWriteCommand(
          address: redLightTotalCommandAddress,
          value: 3,
        ),
    ];
  }

  /// 构建模块恢复命令列表（不含系统命令）。
  List<ModbusWriteCommand> buildModuleResumeCommands({
    bool resumeRed = false,
    bool resumeVat = false,
    bool resumePemf = false,
    bool resumeHydrogen = false,
    bool resumeChakra = false,
    bool resumeTerahertz = false,
    bool resumeHifem = false,
    bool resumeFragrance = false,
  }) {
    return [
      if (resumeHydrogen)
        const ModbusWriteCommand(address: hydrogenCommandAddress, value: 4),
      if (resumePemf)
        const ModbusWriteCommand(address: pemfTotalCommandAddress, value: 4),
      if (resumeVat)
        const ModbusWriteCommand(address: vatCommandAddress, value: 4),
      if (resumeChakra)
        const ModbusWriteCommand(address: chakraCommandAddress, value: 4),
      if (resumeTerahertz)
        const ModbusWriteCommand(address: terahertzCommandAddress, value: 4),
      if (resumeHifem)
        const ModbusWriteCommand(address: hifemCommandAddress, value: 4),
      if (resumeFragrance)
        const ModbusWriteCommand(address: fragranceCommandAddress, value: 4),
      if (resumeRed)
        const ModbusWriteCommand(
          address: redLightTotalCommandAddress,
          value: 4,
        ),
    ];
  }

  /// 构建脉轮模块参数与启动命令
  List<ModbusWriteCommand> buildChakraCommands({
    required Map<String, int> strengths,
    int mode = 0,
  }) {
    final ChakraBatchPayload payload = ChakraModbus.buildPayload(
      strengths: strengths,
      mode: mode,
    );
    debugPrint('Chakra startAddress = 0x0200');
    debugPrint('Chakra quantity = 9');
    debugPrint('Chakra values = ${payload.values}');
    debugPrint(
      'Chakra strengths crown=${payload.crown}, thirdEye=${payload.thirdEye}, throat=${payload.throat}, heart=${payload.heart}, solarPlexus=${payload.solarPlexus}, sacral=${payload.sacral}, root=${payload.root}',
    );
    return <ModbusWriteCommand>[
      for (int i = 0; i < payload.values.length; i++)
        ModbusWriteCommand(
          address: payload.startAddress + i,
          value: payload.values[i],
        ),
      ModbusWriteCommand(
        address: payload.applyAddress,
        value: payload.applyValue,
      ),
      ModbusWriteCommand(
        address: payload.commandAddress,
        value: payload.commandValue,
      ),
    ];
  }

  /// 构建太赫兹模块参数与启动命令
  List<ModbusWriteCommand> buildTerahertzCommands({
    required int frequency,
    required int power,
    required int mode,
    required int wave,
  }) {
    final TerahertzBatchPayload payload = TerahertzModbus.buildPayload(
      frequency: frequency,
      power: power,
      mode: mode,
      wave: wave,
    );
    debugPrint('Terahertz startAddress = 0x0240');
    debugPrint('Terahertz quantity = 5');
    debugPrint('Terahertz values = ${payload.values}');
    debugPrint(
      'Terahertz mode=${payload.mode}(0=continuous,1=pulse), power=${payload.power}, frequency=${payload.frequency}, wave=${payload.wave}',
    );
    return <ModbusWriteCommand>[
      for (int i = 0; i < payload.values.length; i++)
        ModbusWriteCommand(
          address: payload.startAddress + i,
          value: payload.values[i],
        ),
      ModbusWriteCommand(
        address: payload.applyAddress,
        value: payload.applyValue,
      ),
      ModbusWriteCommand(
        address: payload.commandAddress,
        value: payload.commandValue,
      ),
    ];
  }

  /// 构建 HIFEM 模块参数与启动命令。
  List<ModbusWriteCommand> buildHifemCommands({
    required int foreheadRf,
    required int foreheadHifes,
    required int leftCheekRf,
    required int leftCheekHifes,
    required int rightCheekRf,
    required int rightCheekHifes,
  }) {
    final HifemBatchPayload payload = HifemModbus.buildPayload(
      foreheadRf: foreheadRf,
      foreheadMagnetic: foreheadHifes,
      leftFaceRf: leftCheekRf,
      leftFaceMagnetic: leftCheekHifes,
      rightFaceRf: rightCheekRf,
      rightFaceMagnetic: rightCheekHifes,
      mode: 0,
    );
    debugPrint('HIFEM startAddress = 0x02C0');
    debugPrint('HIFEM quantity = 8');
    debugPrint('HIFEM values = ${payload.values}');
    debugPrint(
      'HIFEM foreheadRf=${payload.foreheadRf} / foreheadMagnetic=${payload.foreheadMagnetic}',
    );
    debugPrint(
      'HIFEM leftFaceRf=${payload.leftFaceRf} / leftFaceMagnetic=${payload.leftFaceMagnetic}',
    );
    debugPrint(
      'HIFEM rightFaceRf=${payload.rightFaceRf} / rightFaceMagnetic=${payload.rightFaceMagnetic}',
    );
    return <ModbusWriteCommand>[
      for (int i = 0; i < payload.values.length; i++)
        ModbusWriteCommand(
          address: payload.startAddress + i,
          value: payload.values[i],
        ),
      ModbusWriteCommand(
        address: payload.applyAddress,
        value: payload.applyValue,
      ),
      ModbusWriteCommand(
        address: payload.commandAddress,
        value: payload.commandValue,
      ),
    ];
  }

  /// 构建香氛模块参数与启动命令。
  List<ModbusWriteCommand> buildFragranceCommands({
    required int type,
    bool enabled = true,
  }) {
    final FragranceBatchPayload payload = FragranceModbus.buildPayload(
      enabled: enabled,
      fragranceMode: type,
    );
    debugPrint('Fragrance startAddress = 0x0280');
    debugPrint('Fragrance quantity = 3');
    debugPrint('Fragrance values = ${payload.values}');
    debugPrint('Fragrance module mode(0x0281) default = ${payload.values[1]}');
    debugPrint('Fragrance mode(0x0282) = ${payload.fragranceMode}');

    return <ModbusWriteCommand>[
      for (int i = 0; i < payload.values.length; i++)
        ModbusWriteCommand(
          address: payload.startAddress + i,
          value: payload.values[i],
        ),
      ModbusWriteCommand(
        address: payload.applyAddress,
        value: payload.applyValue,
      ),
      ModbusWriteCommand(
        address: payload.commandAddress,
        value: payload.commandValue,
      ),
    ];
  }

  /// 构建 VAT V2.0 参数命令列表。
  List<ModbusWriteCommand> buildVatCommands({
    required int frequency,
    required int intensity,
    required int musicIndex,
  }) {
    final VatBatchPayload payload = VatModbus.buildPayload(
      frequencyHz: frequency,
      intensity: intensity,
      musicIndex: musicIndex,
    );
    debugPrint(
      'VAT V2.0 build: frequencyHz=${payload.frequencyHz} frequencyValue=${payload.frequencyValue} intensity=$intensity musicIndex=$musicIndex',
    );
    return <ModbusWriteCommand>[
      for (int i = 0; i < payload.values.length; i++)
        ModbusWriteCommand(
          address: payload.startAddress + i,
          value: payload.values[i],
        ),
      ModbusWriteCommand(
        address: payload.applyAddress,
        value: payload.applyValue,
      ),
      ModbusWriteCommand(
        address: payload.commandAddress,
        value: payload.commandValue,
      ),
    ];
  }

  /// 写入 VAT 音乐索引到硬件。
  Future<void> writeVatMusicIndex(int musicIndex) async {
    final int safeIndex = musicIndex.clamp(0, 65535);
    await sendCommandQueue([
      ModbusWriteCommand(address: vatMusicIndexAddress, value: safeIndex),
    ]);
    debugPrint('VAT music index written: $safeIndex');
  }

  List<ModbusWriteCommand> buildHydrogenCommands({required int concentration}) {
    final HydrogenBatchPayload payload = HydrogenModbus.buildPayload(
      concentration: concentration,
    );
    debugPrint('Hydrogen concentration=${payload.concentration}');
    debugPrint('Hydrogen power(0x01C2)=${payload.values[2]}');
    return <ModbusWriteCommand>[
      for (int i = 0; i < payload.values.length; i++)
        ModbusWriteCommand(
          address: payload.startAddress + i,
          value: payload.values[i],
        ),
      ModbusWriteCommand(
        address: payload.applyAddress,
        value: payload.applyValue,
      ),
      ModbusWriteCommand(
        address: payload.commandAddress,
        value: payload.commandValue,
      ),
    ];
  }

  /// 读取氢气流量（0x03 读保持寄存器）。
  Future<int> readHydrogenFlow() async {
    try {
      final int value = await readHoldingRegister(hydrogenFlowAddress);
      debugPrint('Hydrogen flow RX address=0x01E4 value=$value');
      debugPrint('Hydrogen flow parsed value=$value');
      return value;
    } catch (error) {
      debugPrint('Hydrogen modbus failed: $error');
      rethrow;
    }
  }

  Future<int> readHoldingRegister(int address) async {
    final Uint8List frame = _buildReadHoldingRegistersFrame(
      slaveId: slaveId,
      address: address,
      quantity: 1,
    );

    if (Platform.isAndroid) {
      try {
        debugPrint('Hydrogen TX: ${_formatBytes(frame)}');
        final Uint8List response = await AndroidSerialPortService.instance
            .transceiveBytes(
              bytes: frame,
              path: portName,
              baudRate: baudRate,
              timeout: timeout,
            );
        debugPrint('Hydrogen RX: ${_formatBytes(response)}');
        return _parseReadSingleRegisterResponse(response: response);
      } on PlatformException catch (error) {
        throw ModbusRtuException(_normalizeNativeError(error.message));
      }
    }

    if (!Platform.isWindows) {
      throw UnsupportedError(
        'Modbus RTU serial test requires Android or Windows desktop.',
      );
    }

    final SerialPort port = SerialPort(portName);
    SerialPortConfig? config;
    try {
      if (!port.openReadWrite()) {
        throw Exception(
          'Open serial port failed: $portName, ${SerialPort.lastError}',
        );
      }

      config = SerialPortConfig()
        ..baudRate = baudRate
        ..bits = 8
        ..parity = SerialPortParity.none
        ..stopBits = 1
        ..setFlowControl(SerialPortFlowControl.none);
      port.config = config;
      config = null;
      port.flush();

      debugPrint('Hydrogen TX: ${_formatBytes(frame)}');
      final int written = port.write(frame, timeout: timeout.inMilliseconds);
      if (written != frame.length) {
        throw TimeoutException(
          'Serial write timeout: $written/${frame.length} bytes',
        );
      }
      final Uint8List response = port.read(7, timeout: timeout.inMilliseconds);
      debugPrint('Hydrogen RX: ${_formatBytes(response)}');
      return _parseReadSingleRegisterResponse(response: response);
    } finally {
      if (port.isOpen) port.close();
      config?.dispose();
      port.dispose();
    }
  }

  // 其他模块如 PEMF 的命令构建方法可以类似添加。
  Future<void> sendCommandQueue(List<ModbusWriteCommand> commands) async {
    if (commands.isEmpty) return;

    final List<Uint8List> frames = [
      for (final ModbusWriteCommand command in commands)
        _buildWriteSingleRegisterFrame(
          slaveId: slaveId,
          address: command.address,
          value: command.value,
        ),
    ];
    final Stopwatch queueStopwatch = Stopwatch()..start();

    if (Platform.isAndroid) {
      try {
        final List<Uint8List> responses = await AndroidSerialPortService
            .instance
            .writeModbusQueue(
              frames: frames,
              path: portName,
              baudRate: baudRate,
              timeout: timeout,
              commandDelay: commandDelay,
              maxRetries: maxRetries,
            );
        for (int index = 0; index < responses.length; index++) {
          final ModbusWriteCommand command = commands[index];
          final Uint8List response = responses[index];
          debugPrint('Dart RX: ${_formatBytes(response)}');
          _validateWriteSingleRegisterResponse(
            response: response,
            address: command.address,
            value: command.value,
          );
          debugPrint('Dart response validate success: ${command.addressText}');
          debugPrint(
            'Dart queue completer frame complete: ${command.addressText}',
          );
        }
        queueStopwatch.stop();
        debugPrint(
          'Dart queue complete: ${responses.length} responses total=${queueStopwatch.elapsedMilliseconds}ms',
        );
      } on PlatformException catch (error) {
        throw ModbusRtuException(_normalizeNativeError(error.message));
      }
      return;
    }

    if (!Platform.isWindows) {
      throw UnsupportedError(
        'Modbus RTU serial test requires Android or Windows desktop.',
      );
    }

    await _sendCommandQueueWindows(commands, frames);
  }

  Future<void> sendCommandQueueNoResponse(
    List<ModbusWriteCommand> commands,
  ) async {
    if (commands.isEmpty) return;

    final List<_ModbusFrameBatch> batches = _buildNoResponseFrameBatches(
      commands,
    );
    final List<Uint8List> frames = [
      for (final _ModbusFrameBatch batch in batches) batch.frame,
    ];
    final Stopwatch queueStopwatch = Stopwatch()..start();

    if (Platform.isAndroid) {
      try {
        for (int index = 0; index < batches.length; index++) {
          debugPrint(
            'Dart fast queue frame[${index + 1}/${batches.length}]: ${batches[index].description}',
          );
        }
        final int writtenCount = await AndroidSerialPortService.instance
            .writeModbusQueueNoResponse(
              frames: frames,
              path: portName,
              baudRate: baudRate,
              commandDelay: commandDelay,
            );
        queueStopwatch.stop();
        debugPrint(
          'Dart fast queue complete: $writtenCount/${frames.length} frames '
          'from ${commands.length} commands total=${queueStopwatch.elapsedMilliseconds}ms',
        );
      } on PlatformException catch (error) {
        throw ModbusRtuException(_normalizeNativeError(error.message));
      }
      return;
    }

    if (!Platform.isWindows) {
      throw UnsupportedError(
        'Modbus RTU serial test requires Android or Windows desktop.',
      );
    }

    await _sendCommandQueueNoResponseWindows(batches);
  }

  List<_ModbusFrameBatch> _buildNoResponseFrameBatches(
    List<ModbusWriteCommand> commands,
  ) {
    final List<_ModbusFrameBatch> batches = <_ModbusFrameBatch>[];
    final List<ModbusWriteCommand> current = <ModbusWriteCommand>[];

    void flushCurrent() {
      if (current.isEmpty) return;

      if (current.length == 1) {
        final ModbusWriteCommand command = current.single;
        batches.add(
          _ModbusFrameBatch(
            frame: _buildWriteSingleRegisterFrame(
              slaveId: slaveId,
              address: command.address,
              value: command.value,
            ),
            description: '0x06 ${command.addressText}=${command.value}',
          ),
        );
        current.clear();
        return;
      }

      final int startAddress = current.first.address;
      final List<int> values = [
        for (final ModbusWriteCommand command in current) command.value,
      ];
      final int endAddress = current.last.address;
      batches.add(
        _ModbusFrameBatch(
          frame: _buildWriteMultipleRegistersFrame(
            slaveId: slaveId,
            startAddress: startAddress,
            values: values,
          ),
          description:
              '0x10 0x${startAddress.toRadixString(16).toUpperCase().padLeft(4, '0')}'
              '~0x${endAddress.toRadixString(16).toUpperCase().padLeft(4, '0')} '
              'quantity=${values.length} values=$values',
        ),
      );
      current.clear();
    }

    for (final ModbusWriteCommand command in commands) {
      if (current.isEmpty) {
        current.add(command);
        continue;
      }

      final int expectedNextAddress = current.last.address + 1;
      if (command.address == expectedNextAddress) {
        current.add(command);
        continue;
      }

      flushCurrent();
      current.add(command);
    }

    flushCurrent();
    return batches;
  }

  Future<void> _applyRedLightPayload(RedLightBatchPayload payload) async {
    if (payload.values.length != RedLightModbus.quantity) {
      throw StateError(
        'Red light values length invalid: ${payload.values.length}, expected ${RedLightModbus.quantity}',
      );
    }
    debugPrint('RedLight full values:');
    for (int i = 0; i < payload.values.length; i++) {
      final int address = payload.startAddress + i;
      debugPrint(
        '0x${address.toRadixString(16).toUpperCase().padLeft(4, '0')} = ${payload.values[i]}',
      );
    }
    await writeMultipleRegisters(
      startAddress: payload.startAddress,
      values: payload.values,
      logTag: 'RedLight',
    );
    if (commandDelay > Duration.zero) await Future<void>.delayed(commandDelay);
    debugPrint(
      'RedLight apply address=0x${payload.applyAddress.toRadixString(16).toUpperCase()} value=${payload.applyValue}',
    );
    await sendCommandQueue([
      ModbusWriteCommand(
        address: payload.applyAddress,
        value: payload.applyValue,
      ),
    ]);
    if (commandDelay > Duration.zero) await Future<void>.delayed(commandDelay);
    debugPrint(
      'RedLight command address=0x${payload.commandAddress.toRadixString(16).toUpperCase()} value=${payload.commandValue}',
    );
    await sendCommandQueue([
      ModbusWriteCommand(
        address: payload.commandAddress,
        value: payload.commandValue,
      ),
    ]);
  }

  Future<void> _applyPemfPayload(PemfBatchPayload payload) async {
    if (payload.values.length != PemfModbus.quantity) {
      throw StateError(
        'PEMF values length invalid: ${payload.values.length}, expected ${PemfModbus.quantity}',
      );
    }
    debugPrint(
      'PEMF single write 0x${payload.enableAddress.toRadixString(16).toUpperCase()} value=${payload.enableValue}',
    );
    await sendCommandQueue([
      ModbusWriteCommand(
        address: payload.enableAddress,
        value: payload.enableValue,
      ),
    ]);
    await writeMultipleRegisters(
      startAddress: payload.startAddress,
      values: payload.values,
      logTag: 'PEMF',
    );
    if (commandDelay > Duration.zero) await Future<void>.delayed(commandDelay);
    debugPrint(
      'PEMF apply address=0x${payload.applyAddress.toRadixString(16).toUpperCase()} value=${payload.applyValue}',
    );
    await sendCommandQueue([
      ModbusWriteCommand(
        address: payload.applyAddress,
        value: payload.applyValue,
      ),
    ]);
    if (commandDelay > Duration.zero) await Future<void>.delayed(commandDelay);
    debugPrint(
      'PEMF command address=0x${payload.commandAddress.toRadixString(16).toUpperCase()} value=${payload.commandValue}',
    );
    await sendCommandQueue([
      ModbusWriteCommand(
        address: payload.commandAddress,
        value: payload.commandValue,
      ),
    ]);
  }

  Future<void> _applyVatPayload(VatBatchPayload payload) async {
    if (payload.values.length != VatModbus.quantity) {
      throw StateError(
        'VAT values length invalid: ${payload.values.length}, expected ${VatModbus.quantity}',
      );
    }
    debugPrint(
      'VAT frequency conversion: frequencyHz=${payload.frequencyHz} frequencyValue=${payload.frequencyValue}',
    );
    await writeMultipleRegisters(
      startAddress: payload.startAddress,
      values: payload.values,
      logTag: 'VAT',
    );
    if (commandDelay > Duration.zero) await Future<void>.delayed(commandDelay);
    debugPrint(
      'VAT apply address=0x${payload.applyAddress.toRadixString(16).toUpperCase()} value=${payload.applyValue}',
    );
    await sendCommandQueue([
      ModbusWriteCommand(
        address: payload.applyAddress,
        value: payload.applyValue,
      ),
    ]);
    if (commandDelay > Duration.zero) await Future<void>.delayed(commandDelay);
    debugPrint(
      'VAT command address=0x${payload.commandAddress.toRadixString(16).toUpperCase()} value=${payload.commandValue}',
    );
    await sendCommandQueue([
      ModbusWriteCommand(
        address: payload.commandAddress,
        value: payload.commandValue,
      ),
    ]);
  }

  Future<void> _applyHydrogenPayload(HydrogenBatchPayload payload) async {
    if (payload.values.length != HydrogenModbus.quantity) {
      throw StateError(
        'Hydrogen values length invalid: ${payload.values.length}, expected ${HydrogenModbus.quantity}',
      );
    }
    debugPrint('Hydrogen startAddress = 0x01C0');
    debugPrint('Hydrogen quantity = 5');
    debugPrint('Hydrogen concentration = ${payload.concentration}');
    debugPrint('Hydrogen power(0x01C2) = ${payload.values[2]}');
    debugPrint('Hydrogen flow read address = 0x01E4');
    await writeMultipleRegisters(
      startAddress: payload.startAddress,
      values: payload.values,
      logTag: 'Hydrogen',
    );
    if (commandDelay > Duration.zero) await Future<void>.delayed(commandDelay);
    debugPrint(
      'Hydrogen apply address=0x${payload.applyAddress.toRadixString(16).toUpperCase()} value=${payload.applyValue}',
    );
    await sendCommandQueue([
      ModbusWriteCommand(
        address: payload.applyAddress,
        value: payload.applyValue,
      ),
    ]);
    if (commandDelay > Duration.zero) await Future<void>.delayed(commandDelay);
    debugPrint(
      'Hydrogen command address=0x${payload.commandAddress.toRadixString(16).toUpperCase()} value=${payload.commandValue}',
    );
    await sendCommandQueue([
      ModbusWriteCommand(
        address: payload.commandAddress,
        value: payload.commandValue,
      ),
    ]);
  }

  Future<void> _applyChakraPayload(ChakraBatchPayload payload) async {
    if (payload.values.length != ChakraModbus.quantity) {
      throw StateError(
        'Chakra values length invalid: ${payload.values.length}, expected ${ChakraModbus.quantity}',
      );
    }
    debugPrint('Chakra startAddress = 0x0200');
    debugPrint('Chakra quantity = 9');
    debugPrint('Chakra values = ${payload.values}');
    debugPrint('Chakra full values:');
    for (int i = 0; i < payload.values.length; i++) {
      final int address = payload.startAddress + i;
      debugPrint(
        '0x${address.toRadixString(16).toUpperCase().padLeft(4, '0')} = ${payload.values[i]}',
      );
    }
    debugPrint(
      'Chakra strengths crown=${payload.crown}, thirdEye=${payload.thirdEye}, throat=${payload.throat}, heart=${payload.heart}, solarPlexus=${payload.solarPlexus}, sacral=${payload.sacral}, root=${payload.root}',
    );
    await writeMultipleRegisters(
      startAddress: payload.startAddress,
      values: payload.values,
      logTag: 'Chakra',
    );
    if (commandDelay > Duration.zero) await Future<void>.delayed(commandDelay);
    debugPrint(
      'Chakra apply address=0x${payload.applyAddress.toRadixString(16).toUpperCase()} value=${payload.applyValue}',
    );
    await sendCommandQueue([
      ModbusWriteCommand(
        address: payload.applyAddress,
        value: payload.applyValue,
      ),
    ]);
    if (commandDelay > Duration.zero) await Future<void>.delayed(commandDelay);
    debugPrint(
      'Chakra command address=0x${payload.commandAddress.toRadixString(16).toUpperCase()} value=${payload.commandValue}',
    );
    await sendCommandQueue([
      ModbusWriteCommand(
        address: payload.commandAddress,
        value: payload.commandValue,
      ),
    ]);
  }

  Future<void> _applyTerahertzPayload(TerahertzBatchPayload payload) async {
    if (payload.values.length != TerahertzModbus.quantity) {
      throw StateError(
        'Terahertz values length invalid: ${payload.values.length}, expected ${TerahertzModbus.quantity}',
      );
    }
    debugPrint('Terahertz startAddress = 0x0240');
    debugPrint('Terahertz quantity = 5');
    debugPrint('Terahertz values = ${payload.values}');
    debugPrint(
      'Terahertz mode=${payload.mode}(0=continuous,1=pulse), power=${payload.power}, frequency=${payload.frequency}, wave=${payload.wave}',
    );
    await writeMultipleRegisters(
      startAddress: payload.startAddress,
      values: payload.values,
      logTag: 'Terahertz',
    );
    if (commandDelay > Duration.zero) await Future<void>.delayed(commandDelay);
    debugPrint(
      'Terahertz apply address=0x${payload.applyAddress.toRadixString(16).toUpperCase()} value=${payload.applyValue}',
    );
    await sendCommandQueue([
      ModbusWriteCommand(
        address: payload.applyAddress,
        value: payload.applyValue,
      ),
    ]);
    if (commandDelay > Duration.zero) await Future<void>.delayed(commandDelay);
    debugPrint(
      'Terahertz command address=0x${payload.commandAddress.toRadixString(16).toUpperCase()} value=${payload.commandValue}',
    );
    await sendCommandQueue([
      ModbusWriteCommand(
        address: payload.commandAddress,
        value: payload.commandValue,
      ),
    ]);
  }

  Future<void> _applyFragrancePayload(FragranceBatchPayload payload) async {
    if (payload.values.length != FragranceModbus.quantity) {
      throw StateError(
        'Fragrance values length invalid: ${payload.values.length}, expected ${FragranceModbus.quantity}',
      );
    }
    debugPrint('Fragrance startAddress = 0x0280');
    debugPrint('Fragrance quantity = 3');
    debugPrint('Fragrance values = ${payload.values}');
    debugPrint('Fragrance module mode(0x0281) default = ${payload.values[1]}');
    debugPrint('Fragrance mode(0x0282) = ${payload.fragranceMode}');
    await writeMultipleRegisters(
      startAddress: payload.startAddress,
      values: payload.values,
      logTag: 'Fragrance',
    );
    if (commandDelay > Duration.zero) await Future<void>.delayed(commandDelay);
    debugPrint(
      'Fragrance apply address=0x${payload.applyAddress.toRadixString(16).toUpperCase()} value=${payload.applyValue}',
    );
    await sendCommandQueue([
      ModbusWriteCommand(
        address: payload.applyAddress,
        value: payload.applyValue,
      ),
    ]);
    if (commandDelay > Duration.zero) await Future<void>.delayed(commandDelay);
    debugPrint(
      'Fragrance command address=0x${payload.commandAddress.toRadixString(16).toUpperCase()} value=${payload.commandValue}',
    );
    await sendCommandQueue([
      ModbusWriteCommand(
        address: payload.commandAddress,
        value: payload.commandValue,
      ),
    ]);
  }

  Future<void> _applyHifemPayload(HifemBatchPayload payload) async {
    if (payload.values.length != HifemModbus.quantity) {
      throw StateError(
        'HIFEM values length invalid: ${payload.values.length}, expected ${HifemModbus.quantity}',
      );
    }
    debugPrint('HIFEM startAddress = 0x02C0');
    debugPrint('HIFEM quantity = 8');
    debugPrint('HIFEM values = ${payload.values}');
    for (int i = 0; i < payload.values.length; i++) {
      final int address = payload.startAddress + i;
      debugPrint(
        '0x${address.toRadixString(16).toUpperCase().padLeft(4, '0')} = ${payload.values[i]}',
      );
    }
    debugPrint(
      'HIFEM foreheadRf=${payload.foreheadRf}, foreheadMagnetic=${payload.foreheadMagnetic}',
    );
    debugPrint(
      'HIFEM leftFaceRf=${payload.leftFaceRf}, leftFaceMagnetic=${payload.leftFaceMagnetic}',
    );
    debugPrint(
      'HIFEM rightFaceRf=${payload.rightFaceRf}, rightFaceMagnetic=${payload.rightFaceMagnetic}',
    );
    await writeMultipleRegisters(
      startAddress: payload.startAddress,
      values: payload.values,
      logTag: 'HIFEM',
    );
    if (commandDelay > Duration.zero) await Future<void>.delayed(commandDelay);
    debugPrint(
      'HIFEM apply address=0x${payload.applyAddress.toRadixString(16).toUpperCase()} value=${payload.applyValue}',
    );
    await sendCommandQueue([
      ModbusWriteCommand(
        address: payload.applyAddress,
        value: payload.applyValue,
      ),
    ]);
    if (commandDelay > Duration.zero) await Future<void>.delayed(commandDelay);
    debugPrint(
      'HIFEM command address=0x${payload.commandAddress.toRadixString(16).toUpperCase()} value=${payload.commandValue}',
    );
    await sendCommandQueue([
      ModbusWriteCommand(
        address: payload.commandAddress,
        value: payload.commandValue,
      ),
    ]);
  }

  _RedLightBatchParseResult _extractRedLightPayload(
    List<ModbusWriteCommand> commands,
  ) {
    final Map<int, int> redMap = <int, int>{};
    final List<ModbusWriteCommand> remaining = <ModbusWriteCommand>[];
    final Set<int> redAddresses = <int>{
      for (
        int address = RedLightModbus.startAddress;
        address <= RedLightModbus.endAddress;
        address++
      )
        address,
      redLightApplyAddress,
      redLightTotalCommandAddress,
    };
    for (final ModbusWriteCommand command in commands) {
      if (redAddresses.contains(command.address)) {
        redMap[command.address] = command.value;
      } else {
        remaining.add(command);
      }
    }
    if (redMap.isEmpty) {
      return _RedLightBatchParseResult(remainingCommands: commands);
    }
    final List<int> values = <int>[
      for (
        int address = RedLightModbus.startAddress;
        address <= RedLightModbus.endAddress;
        address++
      )
        redMap[address] ?? 0,
    ];
    final RedLightBatchPayload payload = RedLightBatchPayload(
      startAddress: RedLightModbus.startAddress,
      values: values,
      applyAddress: redLightApplyAddress,
      commandAddress: redLightTotalCommandAddress,
      applyValue: redMap[redLightApplyAddress] ?? 1,
      commandValue: redMap[redLightTotalCommandAddress] ?? 1,
    );
    return _RedLightBatchParseResult(
      remainingCommands: remaining,
      payload: payload,
    );
  }

  _PemfBatchParseResult _extractPemfPayload(List<ModbusWriteCommand> commands) {
    final Map<int, int> pemfMap = <int, int>{};
    final List<ModbusWriteCommand> remaining = <ModbusWriteCommand>[];
    final Set<int> pemfAddresses = <int>{
      PemfModbus.enableAddress,
      for (
        int address = PemfModbus.startAddress;
        address <= PemfModbus.endAddress;
        address++
      )
        address,
      PemfModbus.applyAddress,
      PemfModbus.commandAddress,
    };
    for (final ModbusWriteCommand command in commands) {
      if (pemfAddresses.contains(command.address)) {
        pemfMap[command.address] = command.value;
      } else {
        remaining.add(command);
      }
    }
    if (pemfMap.isEmpty) {
      return _PemfBatchParseResult(remainingCommands: commands);
    }
    final List<int> values = <int>[
      for (
        int address = PemfModbus.startAddress;
        address <= PemfModbus.endAddress;
        address++
      )
        pemfMap[address] ?? 0,
    ];
    final PemfBatchPayload payload = PemfBatchPayload(
      enableAddress: PemfModbus.enableAddress,
      enableValue: pemfMap[PemfModbus.enableAddress] ?? 0,
      startAddress: PemfModbus.startAddress,
      values: values,
      applyAddress: PemfModbus.applyAddress,
      commandAddress: PemfModbus.commandAddress,
      applyValue: pemfMap[PemfModbus.applyAddress] ?? 1,
      commandValue: pemfMap[PemfModbus.commandAddress] ?? 1,
    );
    return _PemfBatchParseResult(
      remainingCommands: remaining,
      payload: payload,
    );
  }

  _VatBatchParseResult _extractVatPayload(List<ModbusWriteCommand> commands) {
    final Map<int, int> vatMap = <int, int>{};
    final List<ModbusWriteCommand> remaining = <ModbusWriteCommand>[];
    final Set<int> vatAddresses = <int>{
      for (
        int address = VatModbus.startAddress;
        address <= VatModbus.endAddress;
        address++
      )
        address,
      VatModbus.applyAddress,
      VatModbus.commandAddress,
    };
    for (final ModbusWriteCommand command in commands) {
      if (vatAddresses.contains(command.address)) {
        vatMap[command.address] = command.value;
      } else {
        remaining.add(command);
      }
    }
    if (vatMap.isEmpty) {
      return _VatBatchParseResult(remainingCommands: commands);
    }
    final List<int> values = <int>[
      for (
        int address = VatModbus.startAddress;
        address <= VatModbus.endAddress;
        address++
      )
        vatMap[address] ?? 0,
    ];
    final VatBatchPayload payload = VatBatchPayload(
      startAddress: VatModbus.startAddress,
      values: values,
      applyAddress: VatModbus.applyAddress,
      commandAddress: VatModbus.commandAddress,
      applyValue: vatMap[VatModbus.applyAddress] ?? 1,
      commandValue: vatMap[VatModbus.commandAddress] ?? 1,
      frequencyHz: ((vatMap[vatFrequencyAddress] ?? 0) / 10.0),
      frequencyValue: vatMap[vatFrequencyAddress] ?? 0,
    );
    return _VatBatchParseResult(remainingCommands: remaining, payload: payload);
  }

  _HydrogenBatchParseResult _extractHydrogenPayload(
    List<ModbusWriteCommand> commands,
  ) {
    final Map<int, int> hydrogenMap = <int, int>{};
    final List<ModbusWriteCommand> remaining = <ModbusWriteCommand>[];
    final Set<int> hydrogenAddresses = <int>{
      for (
        int address = HydrogenModbus.startAddress;
        address <= HydrogenModbus.endAddress;
        address++
      )
        address,
      HydrogenModbus.applyAddress,
      HydrogenModbus.commandAddress,
    };
    for (final ModbusWriteCommand command in commands) {
      if (hydrogenAddresses.contains(command.address)) {
        hydrogenMap[command.address] = command.value;
      } else {
        remaining.add(command);
      }
    }
    if (hydrogenMap.isEmpty) {
      return _HydrogenBatchParseResult(remainingCommands: commands);
    }
    final List<int> values = <int>[
      for (
        int address = HydrogenModbus.startAddress;
        address <= HydrogenModbus.endAddress;
        address++
      )
        hydrogenMap[address] ?? 0,
    ];
    final HydrogenBatchPayload payload = HydrogenBatchPayload(
      startAddress: HydrogenModbus.startAddress,
      values: values,
      applyAddress: HydrogenModbus.applyAddress,
      commandAddress: HydrogenModbus.commandAddress,
      applyValue: hydrogenMap[HydrogenModbus.applyAddress] ?? 1,
      commandValue: hydrogenMap[HydrogenModbus.commandAddress] ?? 1,
      concentration: (hydrogenMap[hydrogenConcentrationAddress] ?? 0).clamp(
        0,
        100,
      ),
    );
    return _HydrogenBatchParseResult(
      remainingCommands: remaining,
      payload: payload,
    );
  }

  _ChakraBatchParseResult _extractChakraPayload(
    List<ModbusWriteCommand> commands,
  ) {
    final Map<int, int> chakraMap = <int, int>{};
    final List<ModbusWriteCommand> remaining = <ModbusWriteCommand>[];
    final Set<int> chakraAddresses = <int>{
      for (
        int address = ChakraModbus.startAddress;
        address <= ChakraModbus.endAddress;
        address++
      )
        address,
      ChakraModbus.applyAddress,
      ChakraModbus.commandAddress,
    };
    for (final ModbusWriteCommand command in commands) {
      if (chakraAddresses.contains(command.address)) {
        chakraMap[command.address] = command.value;
      } else {
        remaining.add(command);
      }
    }
    if (chakraMap.isEmpty) {
      return _ChakraBatchParseResult(remainingCommands: commands);
    }
    final Map<String, int> strengths = <String, int>{
      'crown': chakraMap[chakraStrengthAddressMap['crown']!] ?? 0,
      'third_eye': chakraMap[chakraStrengthAddressMap['third_eye']!] ?? 0,
      'throat': chakraMap[chakraStrengthAddressMap['throat']!] ?? 0,
      'heart': chakraMap[chakraStrengthAddressMap['heart']!] ?? 0,
      'solar_plexus': chakraMap[chakraStrengthAddressMap['solar_plexus']!] ?? 0,
      'sacral': chakraMap[chakraStrengthAddressMap['sacral']!] ?? 0,
      'root': chakraMap[chakraStrengthAddressMap['root']!] ?? 0,
    };
    final ChakraBatchPayload payload = ChakraModbus.buildPayload(
      strengths: strengths,
      mode: chakraMap[chakraModeAddress] ?? 0,
    );
    final ChakraBatchPayload normalizedPayload = ChakraBatchPayload(
      startAddress: payload.startAddress,
      values: <int>[
        for (
          int address = ChakraModbus.startAddress;
          address <= ChakraModbus.endAddress;
          address++
        )
          chakraMap[address] ??
              payload.values[address - ChakraModbus.startAddress],
      ],
      applyAddress: payload.applyAddress,
      commandAddress: payload.commandAddress,
      applyValue: chakraMap[ChakraModbus.applyAddress] ?? 1,
      commandValue: chakraMap[ChakraModbus.commandAddress] ?? 1,
      crown: payload.crown,
      thirdEye: payload.thirdEye,
      throat: payload.throat,
      heart: payload.heart,
      solarPlexus: payload.solarPlexus,
      sacral: payload.sacral,
      root: payload.root,
    );
    return _ChakraBatchParseResult(
      remainingCommands: remaining,
      payload: normalizedPayload,
    );
  }

  _TerahertzBatchParseResult _extractTerahertzPayload(
    List<ModbusWriteCommand> commands,
  ) {
    final Map<int, int> terahertzMap = <int, int>{};
    final List<ModbusWriteCommand> remaining = <ModbusWriteCommand>[];
    final Set<int> terahertzAddresses = <int>{
      for (
        int address = TerahertzModbus.startAddress;
        address <= TerahertzModbus.endAddress;
        address++
      )
        address,
      TerahertzModbus.applyAddress,
      TerahertzModbus.commandAddress,
    };
    for (final ModbusWriteCommand command in commands) {
      if (terahertzAddresses.contains(command.address)) {
        terahertzMap[command.address] = command.value;
      } else {
        remaining.add(command);
      }
    }
    if (terahertzMap.isEmpty) {
      return _TerahertzBatchParseResult(remainingCommands: commands);
    }
    final TerahertzBatchPayload payload = TerahertzModbus.buildPayload(
      frequency: terahertzMap[terahertzFrequencyAddress] ?? 1,
      power: terahertzMap[terahertzPowerAddress] ?? 0,
      mode: terahertzMap[terahertzModeAddress] ?? 0,
      wave: terahertzMap[terahertzWaveAddress] ?? 0,
    );
    final TerahertzBatchPayload normalizedPayload = TerahertzBatchPayload(
      startAddress: payload.startAddress,
      values: <int>[
        for (
          int address = TerahertzModbus.startAddress;
          address <= TerahertzModbus.endAddress;
          address++
        )
          terahertzMap[address] ??
              payload.values[address - TerahertzModbus.startAddress],
      ],
      applyAddress: payload.applyAddress,
      commandAddress: payload.commandAddress,
      applyValue: terahertzMap[TerahertzModbus.applyAddress] ?? 1,
      commandValue: terahertzMap[TerahertzModbus.commandAddress] ?? 1,
      mode: payload.mode,
      power: payload.power,
      frequency: payload.frequency,
      wave: payload.wave,
    );
    return _TerahertzBatchParseResult(
      remainingCommands: remaining,
      payload: normalizedPayload,
    );
  }

  _FragranceBatchParseResult _extractFragrancePayload(
    List<ModbusWriteCommand> commands,
  ) {
    final Map<int, int> fragranceMap = <int, int>{};
    final List<ModbusWriteCommand> remaining = <ModbusWriteCommand>[];
    final Set<int> fragranceAddresses = <int>{
      for (
        int address = FragranceModbus.startAddress;
        address <= FragranceModbus.endAddress;
        address++
      )
        address,
      FragranceModbus.applyAddress,
      FragranceModbus.commandAddress,
    };
    for (final ModbusWriteCommand command in commands) {
      if (fragranceAddresses.contains(command.address)) {
        fragranceMap[command.address] = command.value;
      } else {
        remaining.add(command);
      }
    }
    if (fragranceMap.isEmpty) {
      return _FragranceBatchParseResult(remainingCommands: commands);
    }
    final FragranceBatchPayload payload = FragranceModbus.buildPayload(
      enabled: (fragranceMap[fragranceEnableAddress] ?? 0) == 1,
      fragranceMode: fragranceMap[fragranceTypeAddress] ?? 0,
    );
    final FragranceBatchPayload normalizedPayload = FragranceBatchPayload(
      startAddress: payload.startAddress,
      values: <int>[
        for (
          int address = FragranceModbus.startAddress;
          address <= FragranceModbus.endAddress;
          address++
        )
          fragranceMap[address] ??
              payload.values[address - FragranceModbus.startAddress],
      ],
      applyAddress: payload.applyAddress,
      commandAddress: payload.commandAddress,
      applyValue: fragranceMap[FragranceModbus.applyAddress] ?? 1,
      commandValue: fragranceMap[FragranceModbus.commandAddress] ?? 1,
      enabled: payload.enabled,
      fragranceMode: payload.fragranceMode,
    );
    return _FragranceBatchParseResult(
      remainingCommands: remaining,
      payload: normalizedPayload,
    );
  }

  _HifemBatchParseResult _extractHifemPayload(
    List<ModbusWriteCommand> commands,
  ) {
    final Map<int, int> hifemMap = <int, int>{};
    final List<ModbusWriteCommand> remaining = <ModbusWriteCommand>[];
    final Set<int> hifemAddresses = <int>{
      for (
        int address = HifemModbus.startAddress;
        address <= HifemModbus.endAddress;
        address++
      )
        address,
      HifemModbus.applyAddress,
      HifemModbus.commandAddress,
    };
    for (final ModbusWriteCommand command in commands) {
      if (hifemAddresses.contains(command.address)) {
        hifemMap[command.address] = command.value;
      } else {
        remaining.add(command);
      }
    }
    if (hifemMap.isEmpty) {
      return _HifemBatchParseResult(remainingCommands: commands);
    }
    final HifemBatchPayload payload = HifemModbus.buildPayload(
      foreheadRf: hifemMap[hifemForeheadRfAddress] ?? 0,
      foreheadMagnetic: hifemMap[hifemForeheadHifesAddress] ?? 0,
      leftFaceRf: hifemMap[hifemLeftCheekRfAddress] ?? 0,
      leftFaceMagnetic: hifemMap[hifemLeftCheekHifesAddress] ?? 0,
      rightFaceRf: hifemMap[hifemRightCheekRfAddress] ?? 0,
      rightFaceMagnetic: hifemMap[hifemRightCheekHifesAddress] ?? 0,
      mode: hifemMap[hifemModeAddress] ?? 0,
    );
    final HifemBatchPayload normalizedPayload = HifemBatchPayload(
      startAddress: payload.startAddress,
      values: <int>[
        for (
          int address = HifemModbus.startAddress;
          address <= HifemModbus.endAddress;
          address++
        )
          hifemMap[address] ??
              payload.values[address - HifemModbus.startAddress],
      ],
      applyAddress: payload.applyAddress,
      commandAddress: payload.commandAddress,
      applyValue: hifemMap[HifemModbus.applyAddress] ?? 1,
      commandValue: hifemMap[HifemModbus.commandAddress] ?? 1,
      mode: payload.mode,
      foreheadRf: payload.foreheadRf,
      foreheadMagnetic: payload.foreheadMagnetic,
      leftFaceRf: payload.leftFaceRf,
      leftFaceMagnetic: payload.leftFaceMagnetic,
      rightFaceRf: payload.rightFaceRf,
      rightFaceMagnetic: payload.rightFaceMagnetic,
    );
    return _HifemBatchParseResult(
      remainingCommands: remaining,
      payload: normalizedPayload,
    );
  }

  Future<void> writeMultipleRegisters({
    required int startAddress,
    required List<int> values,
    String logTag = 'RedLight',
  }) async {
    if (values.isEmpty) return;
    final Uint8List frame = _buildWriteMultipleRegistersFrame(
      slaveId: slaveId,
      startAddress: startAddress,
      values: values,
    );
    final int quantity = values.length;
    debugPrint(
      '$logTag 0x10 startAddress=0x${startAddress.toRadixString(16).toUpperCase().padLeft(4, '0')} quantity=$quantity values=$values',
    );
    for (int i = 0; i < values.length; i++) {
      final int address = startAddress + i;
      debugPrint(
        '$logTag 0x10 map 0x${address.toRadixString(16).toUpperCase().padLeft(4, '0')} -> ${values[i]}',
      );
    }
    await _writeFrameAndValidateMultiple(
      frame: frame,
      startAddress: startAddress,
      quantity: quantity,
    );
  }

  Future<void> _writeFrameAndValidateMultiple({
    required Uint8List frame,
    required int startAddress,
    required int quantity,
  }) async {
    if (Platform.isAndroid) {
      final Uint8List response = await AndroidSerialPortService.instance
          .transceiveBytes(
            bytes: frame,
            path: portName,
            baudRate: baudRate,
            timeout: timeout,
          );
      _validateWriteMultipleRegistersResponse(
        response: response,
        startAddress: startAddress,
        quantity: quantity,
      );
      if (commandDelay > Duration.zero) {
        await Future<void>.delayed(commandDelay);
      }
      return;
    }

    if (!Platform.isWindows) {
      throw UnsupportedError(
        'Modbus RTU serial test requires Android or Windows desktop.',
      );
    }

    final SerialPort port = SerialPort(portName);
    SerialPortConfig? config;
    try {
      if (!port.openReadWrite()) {
        throw Exception(
          'Open serial port failed: $portName, ${SerialPort.lastError}',
        );
      }
      config = SerialPortConfig()
        ..baudRate = baudRate
        ..bits = 8
        ..parity = SerialPortParity.none
        ..stopBits = 1
        ..setFlowControl(SerialPortFlowControl.none);
      port.config = config;
      config = null;
      port.flush();
      final int written = port.write(frame, timeout: timeout.inMilliseconds);
      if (written != frame.length) {
        throw TimeoutException(
          'Serial write timeout: $written/${frame.length} bytes',
        );
      }
      final Uint8List response = port.read(8, timeout: timeout.inMilliseconds);
      _validateWriteMultipleRegistersResponse(
        response: response,
        startAddress: startAddress,
        quantity: quantity,
      );
      if (commandDelay > Duration.zero) {
        await Future<void>.delayed(commandDelay);
      }
    } finally {
      if (port.isOpen) port.close();
      config?.dispose();
      port.dispose();
    }
  }

  // 直接写单寄存器命令，通常用于调试或特殊场景。
  Future<void> writeSingleRegister({
    required int address,
    required int value,
    bool waitForResponse = true,
  }) async {
    if (waitForResponse) {
      await sendCommandQueue([
        ModbusWriteCommand(address: address, value: value),
      ]);
      return;
    }

    // Android 是正式运行环境：通过原生串口 bridge 写 /dev/ttyS0。
    if (Platform.isAndroid) {
      await _writeSingleRegisterAndroid(
        address: address,
        value: value,
        waitForResponse: waitForResponse,
      );
      return;
    }

    if (!Platform.isWindows) {
      throw UnsupportedError(
        'Modbus RTU serial test requires Android or Windows desktop.',
      );
    }

    final SerialPort port = SerialPort(portName);
    SerialPortConfig? config;

    try {
      if (!port.openReadWrite()) {
        throw Exception(
          'Open serial port failed: $portName, ${SerialPort.lastError}',
        );
      }

      config = SerialPortConfig()
        ..baudRate = baudRate
        ..bits = 8
        ..parity = SerialPortParity.none
        ..stopBits = 1
        ..setFlowControl(SerialPortFlowControl.none);
      port.config = config;
      config = null;
      port.flush();

      final Uint8List request = _buildWriteSingleRegisterFrame(
        slaveId: slaveId,
        address: address,
        value: value,
      );

      debugPrint('Modbus RTU TX: ${_formatBytes(request)}');
      final int written = port.write(request, timeout: timeout.inMilliseconds);
      if (written != request.length) {
        throw TimeoutException(
          'Serial write timeout: $written/${request.length} bytes',
        );
      }

      if (!waitForResponse) {
        debugPrint('Modbus RTU write sent without waiting response.');
        return;
      }

      final Uint8List response = port.read(8, timeout: timeout.inMilliseconds);
      debugPrint('Modbus RTU RX: ${_formatBytes(response)}');

      _validateWriteSingleRegisterResponse(
        response: response,
        address: address,
        value: value,
      );

      debugPrint('Modbus RTU write success: address $address = $value');
    } finally {
      if (port.isOpen) {
        port.close();
      }
      config?.dispose();
      port.dispose();
    }
  }

  // Windows 桌面环境下的串口命令队列发送实现，包含重试机制和响应验证。
  Future<void> _sendCommandQueueWindows(
    List<ModbusWriteCommand> commands,
    List<Uint8List> frames,
  ) async {
    final SerialPort port = SerialPort(portName);
    SerialPortConfig? config;

    try {
      if (!port.openReadWrite()) {
        throw Exception(
          'Open serial port failed: $portName, ${SerialPort.lastError}',
        );
      }

      config = SerialPortConfig()
        ..baudRate = baudRate
        ..bits = 8
        ..parity = SerialPortParity.none
        ..stopBits = 1
        ..setFlowControl(SerialPortFlowControl.none);
      port.config = config;
      config = null;
      port.flush();

      for (int index = 0; index < frames.length; index++) {
        await _writeFrameWithRetryWindows(
          port: port,
          command: commands[index],
          frame: frames[index],
        );
      }
    } finally {
      if (port.isOpen) {
        port.close();
      }
      config?.dispose();
      port.dispose();
    }
  }

  Future<void> _sendCommandQueueNoResponseWindows(
    List<_ModbusFrameBatch> batches,
  ) async {
    final SerialPort port = SerialPort(portName);
    SerialPortConfig? config;
    final Stopwatch queueStopwatch = Stopwatch()..start();

    try {
      if (!port.openReadWrite()) {
        throw Exception(
          'Open serial port failed: $portName, ${SerialPort.lastError}',
        );
      }

      config = SerialPortConfig()
        ..baudRate = baudRate
        ..bits = 8
        ..parity = SerialPortParity.none
        ..stopBits = 1
        ..setFlowControl(SerialPortFlowControl.none);
      port.config = config;
      config = null;
      port.flush();

      for (int index = 0; index < batches.length; index++) {
        final _ModbusFrameBatch batch = batches[index];
        final Uint8List frame = batch.frame;
        debugPrint(
          'Modbus RTU fast TX[${index + 1}/${batches.length}] '
          '${batch.description}: ${_formatBytes(frame)}',
        );
        final int written = port.write(frame, timeout: timeout.inMilliseconds);
        if (written != frame.length) {
          throw TimeoutException(
            'Serial write timeout: $written/${frame.length} bytes',
          );
        }
        if (commandDelay > Duration.zero && index < batches.length - 1) {
          await Future<void>.delayed(commandDelay);
        }
      }
      queueStopwatch.stop();
      debugPrint(
        'Modbus RTU fast queue complete: ${batches.length} frames total=${queueStopwatch.elapsedMilliseconds}ms',
      );
    } finally {
      if (port.isOpen) {
        port.close();
      }
      config?.dispose();
      port.dispose();
    }
  }

  // Windows 桌面环境下的串口写帧实现，包含重试机制和响应验证。
  Future<void> _writeFrameWithRetryWindows({
    required SerialPort port,
    required ModbusWriteCommand command,
    required Uint8List frame,
  }) async {
    Object? lastError;

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        port.flush();
        debugPrint(
          'Modbus RTU TX[${attempt + 1}/${maxRetries + 1}]: ${_formatBytes(frame)}',
        );
        final int written = port.write(frame, timeout: timeout.inMilliseconds);
        if (written != frame.length) {
          throw TimeoutException(
            'Serial write timeout: $written/${frame.length} bytes',
          );
        }

        final Uint8List response = port.read(
          8,
          timeout: timeout.inMilliseconds,
        );
        debugPrint('Modbus RTU RX: ${_formatBytes(response)}');

        _validateWriteSingleRegisterResponse(
          response: response,
          address: command.address,
          value: command.value,
        );

        debugPrint(
          'Modbus RTU write success: ${command.addressText} = ${command.value}',
        );
        if (commandDelay > Duration.zero) {
          await Future<void>.delayed(commandDelay);
        }
        return;
      } catch (error) {
        lastError = error;
        if (attempt < maxRetries) {
          await Future<void>.delayed(commandDelay);
        }
      }
    }

    throw ModbusRtuException(
      'Send failed: register ${command.addressText} ${_failureReason(lastError)}',
    );
  }

  // 其他模块如 PEMF 的命令构建方法可以类似添加。
  Future<void> _writeSingleRegisterAndroid({
    required int address,
    required int value,
    required bool waitForResponse,
  }) async {
    final Uint8List request = _buildWriteSingleRegisterFrame(
      slaveId: slaveId,
      address: address,
      value: value,
    );

    debugPrint('Modbus RTU TX: ${_formatBytes(request)}');
    if (!waitForResponse) {
      final int written = await AndroidSerialPortService.instance
          .writeBytesOnce(bytes: request, path: portName, baudRate: baudRate);
      if (written != request.length) {
        throw TimeoutException(
          'Serial write timeout: $written/${request.length} bytes',
        );
      }
      debugPrint('Modbus RTU write sent without waiting response.');
      return;
    }

    final Uint8List response = await AndroidSerialPortService.instance
        .transceiveBytes(
          bytes: request,
          path: portName,
          baudRate: baudRate,
          timeout: timeout,
        );
    debugPrint('Modbus RTU RX: ${_formatBytes(response)}');

    _validateWriteSingleRegisterResponse(
      response: response,
      address: address,
      value: value,
    );

    debugPrint('Modbus RTU write success: address $address = $value');
  }

  Uint8List _buildWriteSingleRegisterFrame({
    required int slaveId,
    required int address,
    required int value,
  }) {
    // 功能码 0x06：写单个 Holding Register。
    // 帧结构：slaveId, function, addressHi, addressLo, valueHi, valueLo, crcLo, crcHi。
    final Uint8List frame = Uint8List(8);
    final ByteData data = ByteData.sublistView(frame);

    data.setUint8(0, slaveId);
    data.setUint8(1, 0x06);
    data.setUint16(2, address);
    data.setUint16(4, value);

    final int crc = _crc16(frame.sublist(0, 6));
    data.setUint8(6, crc & 0xFF);
    data.setUint8(7, (crc >> 8) & 0xFF);

    return frame;
  }

  Uint8List _buildWriteMultipleRegistersFrame({
    required int slaveId,
    required int startAddress,
    required List<int> values,
  }) {
    final int quantity = values.length;
    final int byteCount = quantity * 2;
    final Uint8List frame = Uint8List(9 + byteCount);
    final ByteData data = ByteData.sublistView(frame);
    data.setUint8(0, slaveId);
    data.setUint8(1, 0x10);
    data.setUint16(2, startAddress);
    data.setUint16(4, quantity);
    data.setUint8(6, byteCount);
    for (int i = 0; i < quantity; i++) {
      data.setUint16(7 + i * 2, values[i] & 0xFFFF);
    }
    final int crc = _crc16(frame.sublist(0, frame.length - 2));
    data.setUint8(frame.length - 2, crc & 0xFF);
    data.setUint8(frame.length - 1, (crc >> 8) & 0xFF);
    return frame;
  }

  Uint8List _buildReadHoldingRegistersFrame({
    required int slaveId,
    required int address,
    required int quantity,
  }) {
    final Uint8List frame = Uint8List(8);
    final ByteData data = ByteData.sublistView(frame);

    data.setUint8(0, slaveId);
    data.setUint8(1, 0x03);
    data.setUint16(2, address);
    data.setUint16(4, quantity);

    final int crc = _crc16(frame.sublist(0, 6));
    data.setUint8(6, crc & 0xFF);
    data.setUint8(7, (crc >> 8) & 0xFF);
    return frame;
  }

  int _parseReadSingleRegisterResponse({required Uint8List response}) {
    if (response.length < 7) {
      throw ModbusRtuException(
        'Flow read failed: insufficient response ${response.length}/7',
      );
    }
    if (response[0] != slaveId || response[1] != 0x03 || response[2] != 0x02) {
      throw ModbusRtuException(
        'Flow read failed: header error ${_formatBytes(response)}',
      );
    }

    final int expectedCrc = _crc16(response.sublist(0, 5));
    final int actualCrc = response[5] | (response[6] << 8);
    if (expectedCrc != actualCrc) {
      throw ModbusRtuException(
        'Flow read failed: CRC error expected=${expectedCrc.toRadixString(16)} actual=${actualCrc.toRadixString(16)}',
      );
    }

    return ByteData.sublistView(response).getUint16(3);
  }

  int _crc16(List<int> bytes) {
    int crc = 0xFFFF;

    for (final int byte in bytes) {
      crc ^= byte;
      for (int bit = 0; bit < 8; bit++) {
        final bool lsbSet = (crc & 0x0001) != 0;
        crc >>= 1;
        if (lsbSet) {
          crc ^= 0xA001;
        }
      }
    }

    return crc & 0xFFFF;
  }

  void _validateWriteSingleRegisterResponse({
    required Uint8List response,
    required int address,
    required int value,
  }) {
    if (response.length >= 2 && response[1] == 0x86) {
      if (response.length != 5) {
        throw Exception(
          'Modbus RTU exception response length error: ${response.length}',
        );
      }

      final int responseCrc = response[3] | (response[4] << 8);
      final int expectedCrc = _crc16(response.sublist(0, 3));
      if (responseCrc != expectedCrc) {
        throw Exception(
          'Modbus RTU exception CRC mismatch: response=0x${responseCrc.toRadixString(16)}, expected=0x${expectedCrc.toRadixString(16)}',
        );
      }

      throw Exception(
        'Modbus RTU exception response: function=0x86, code=${response[2]}',
      );
    }

    if (response.length != 8) {
      throw Exception('Modbus RTU response length error: ${response.length}');
    }

    final int responseCrc = response[6] | (response[7] << 8);
    final int expectedCrc = _crc16(response.sublist(0, 6));
    if (responseCrc != expectedCrc) {
      throw Exception(
        'Modbus RTU CRC mismatch: response=0x${responseCrc.toRadixString(16)}, expected=0x${expectedCrc.toRadixString(16)}',
      );
    }

    if (response[0] != slaveId) {
      throw Exception('Modbus RTU Slave ID mismatch: ${response[0]}');
    }

    if (response[1] == 0x86) {
      throw Exception('Modbus RTU exception response: ${response[2]}');
    }

    if (response[1] != 0x06) {
      throw Exception('Modbus RTU function code error: ${response[1]}');
    }

    final ByteData data = ByteData.sublistView(response);
    final int responseAddress = data.getUint16(2);
    final int responseValue = data.getUint16(4);

    if (responseAddress != address || responseValue != value) {
      throw Exception(
        'Modbus RTU echo mismatch: sent $address=$value, received $responseAddress=$responseValue',
      );
    }
  }

  void _validateWriteMultipleRegistersResponse({
    required Uint8List response,
    required int startAddress,
    required int quantity,
  }) {
    if (response.length != 8) {
      throw Exception(
        'Modbus RTU multi-write response length error: ${response.length}',
      );
    }
    final int responseCrc = response[6] | (response[7] << 8);
    final int expectedCrc = _crc16(response.sublist(0, 6));
    if (responseCrc != expectedCrc) {
      throw Exception('Modbus RTU multi-write CRC mismatch');
    }
    if (response[0] != slaveId) {
      throw Exception(
        'Modbus RTU multi-write Slave ID mismatch: ${response[0]}',
      );
    }
    if (response[1] != 0x10) {
      throw Exception(
        'Modbus RTU multi-write function code error: ${response[1]}',
      );
    }
    final ByteData data = ByteData.sublistView(response);
    final int responseStartAddress = data.getUint16(2);
    final int responseQuantity = data.getUint16(4);
    if (responseStartAddress != startAddress || responseQuantity != quantity) {
      throw Exception(
        'Modbus RTU multi-write echo mismatch: sent start=$startAddress quantity=$quantity, got start=$responseStartAddress quantity=$responseQuantity',
      );
    }
  }

  String _formatBytes(Uint8List bytes) {
    if (bytes.isEmpty) return '<empty>';

    return bytes
        .map((int byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join(' ')
        .toUpperCase();
  }

  String _normalizeNativeError(String? message) {
    final String text = (message ?? '').trim();
    if (text.isEmpty) return 'Send failed: unknown serial error';
    return text;
  }

  String _failureReason(Object? error) {
    final String text = error?.toString() ?? '';
    if (text.toLowerCase().contains('timeout')) return 'Write timeout';
    if (text.isEmpty) return 'Write failed';
    return 'Write failed: $text';
  }
}

class ModbusWriteCommand {
  const ModbusWriteCommand({required this.address, required this.value});

  final int address;
  final int value;

  String get addressText =>
      '0x${address.toRadixString(16).toUpperCase().padLeft(4, '0')}';
}

class _ModbusFrameBatch {
  const _ModbusFrameBatch({required this.frame, required this.description});

  final Uint8List frame;
  final String description;
}

class ModbusRtuException implements Exception {
  const ModbusRtuException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _RedLightBatchParseResult {
  const _RedLightBatchParseResult({
    required this.remainingCommands,
    this.payload,
  });

  final List<ModbusWriteCommand> remainingCommands;
  final RedLightBatchPayload? payload;
}

class _PemfBatchParseResult {
  const _PemfBatchParseResult({required this.remainingCommands, this.payload});

  final List<ModbusWriteCommand> remainingCommands;
  final PemfBatchPayload? payload;
}

class _VatBatchParseResult {
  const _VatBatchParseResult({required this.remainingCommands, this.payload});

  final List<ModbusWriteCommand> remainingCommands;
  final VatBatchPayload? payload;
}

class _HydrogenBatchParseResult {
  const _HydrogenBatchParseResult({
    required this.remainingCommands,
    this.payload,
  });

  final List<ModbusWriteCommand> remainingCommands;
  final HydrogenBatchPayload? payload;
}

class _ChakraBatchParseResult {
  const _ChakraBatchParseResult({
    required this.remainingCommands,
    this.payload,
  });

  final List<ModbusWriteCommand> remainingCommands;
  final ChakraBatchPayload? payload;
}

class _TerahertzBatchParseResult {
  const _TerahertzBatchParseResult({
    required this.remainingCommands,
    this.payload,
  });

  final List<ModbusWriteCommand> remainingCommands;
  final TerahertzBatchPayload? payload;
}

class _FragranceBatchParseResult {
  const _FragranceBatchParseResult({
    required this.remainingCommands,
    this.payload,
  });

  final List<ModbusWriteCommand> remainingCommands;
  final FragranceBatchPayload? payload;
}

class _HifemBatchParseResult {
  const _HifemBatchParseResult({required this.remainingCommands, this.payload});

  final List<ModbusWriteCommand> remainingCommands;
  final HifemBatchPayload? payload;
}
