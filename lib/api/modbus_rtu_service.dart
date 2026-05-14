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
import 'package:infibo_app/services/android_serial_port_service.dart';

class ModbusRtuService {
  /// 系统控制命令寄存器地址。
  static const int systemCommandAddress = 0x0004;

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////红光模块相关寄存器地址//////////////////

  /// 红光总命令地址。
  static const int redLightTotalEnableAddress = 0x0063;

  /// 红光总模式地址。
  static const int redLightTotalModeAddress = 0x0065;

  /// 红光总命令地址。
  static const int redLightTotalCommandAddress = 0x0066;

  /// 红光660nm 启用地址。
  static const int redLight660EnableAddress = 0x0077;

  /// 红光660nm 模式地址。
  static const int redLight660ModeAddress = 0x0079;

  /// 红光660nm 功率地址。
  static const int redLight660PowerAddress = 0x007C;

  /// 红光850nm 启用地址。
  static const int redLight850EnableAddress = 0x008B;

  /// 红光850nm 模式地址。
  static const int redLight850ModeAddress = 0x008D;

  /// 红光850nm 功率地址。
  static const int redLight850PowerAddress = 0x0090;

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////PEMF模块相关寄存器地址//////////////////

  /// PEMF总命令地址。
  static const int pemfTotalCommandAddress = 0x00CA;

  /// PEMF总启用地址。
  static const int pemfTotalEnableAddress = 0x00C8;

  /// PEMF总模式地址。
  static const int pemfTotalModeAddress = 0x00C7;

  ///PEMF总频率地址。
  static const int pemfTotalFrequencyAddress = 0x00CE;

  /// PEMF输出强度地址。
  static const int pemfTotalIntensityAddress = 0x00D0;

  /// PEMF输出波形地址。
  static const int pemfTotalWaveformAddress = 0x00D1;

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////VAT模块相关寄存器地址//////////////////

  /// VAT总启用地址。
  static const int vatEnableAddress = 0x01F3;

  /// VAT模式地址。
  static const int vatModeAddress = 0x01F5;

  /// VAT命令地址。
  static const int vatCommandAddress = 0x01F6;

  /// VAT频率地址。
  static const int vatFrequencyAddress = 0x01FC;

  /// VAT强度地址。
  static const int vatIntensityAddress = 0x01F9;

  /// VAT音乐索引地址。
  static const int vatMusicIndexAddress = 0x0201;

  /// 分子氢使能地址。
  static const int hydrogenEnableAddress = 0x0257;

  /// 分子氢模式地址。
  static const int hydrogenModeAddress = 0x0259;

  /// 分子氢命令地址。
  static const int hydrogenCommandAddress = 0x025A;

  /// 分子氢浓度地址。
  static const int hydrogenConcentrationAddress = 0x025D;

  /// 分子氢流量地址（只读）。
  static const int hydrogenFlowAddress = 0x025F;
  static const int chakraEnableAddress = 0x02BB;
  static const int chakraModeAddress = 0x02BD;
  static const int chakraCommandAddress = 0x02BE;
  static const Map<String, int> chakraStrengthAddressMap = <String, int>{
    'crown': 0x02C1,
    'third_eye': 0x02C2,
    'throat': 0x02C3,
    'heart': 0x02C4,
    'solar_plexus': 0x02C5,
    'sacral': 0x02C6,
    'root': 0x02C7,
  };
  static const int terahertzEnableAddress = 0x031F;
  static const int terahertzModeAddress = 0x0321;
  static const int terahertzCommandAddress = 0x0322;
  static const int terahertzPowerAddress = 0x0325;
  static const int terahertzFrequencyAddress = 0x0326;
  static const int terahertzWaveAddress = 0x0327;
  static const int fragranceEnableAddress = 0x0383;
  static const int fragranceModeAddress = 0x0385;
  static const int fragranceCommandAddress = 0x0386;
  static const int fragranceTypeAddress = 0x0389;
  static const int hifemEnableAddress = 0x03E7;
  static const int hifemModeAddress = 0x03E9;
  static const int hifemCommandAddress = 0x03EA;
  static const int hifemForeheadRfAddress = 0x03ED;
  static const int hifemForeheadHifesAddress = 0x03EE;
  static const int hifemLeftCheekRfAddress = 0x03EF;
  static const int hifemLeftCheekHifesAddress = 0x03F0;
  static const int hifemRightCheekRfAddress = 0x03F1;
  static const int hifemRightCheekHifesAddress = 0x03F2;

  final String portName; // Android 上通常是 /dev/ttyS0。
  final int baudRate; // 115200。
  final int slaveId; // 16。
  final Duration timeout; // 1 秒。
  final Duration commandDelay; // 命令间延迟，默认 40ms，兼顾性能和稳定性。
  final int maxRetries; // 最大重试次数，默认 2 次。

  // 其他参数如数据位、停止位、校验等 Modbus RTU 标准配置固定为 8N1，无需暴露。
  const ModbusRtuService({
    this.portName = AndroidSerialPortService.defaultPath,
    this.baudRate = AndroidSerialPortService.defaultBaudRate,
    this.slaveId = 16,
    this.timeout = const Duration(seconds: 1),
    this.commandDelay = const Duration(milliseconds: 40),
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
  }) {
    return sendCommandQueue(
      buildStopTherapyCommands(
        stopRed: stopRed,
        stopVat: stopVat,
        stopPemf: stopPemf,
        stopHydrogen: stopHydrogen,
        stopChakra: stopChakra,
        stopTerahertz: stopTerahertz,
        stopHifem: stopHifem,
        stopFragrance: stopFragrance,
      ),
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
    await sendCommandQueue(
      buildRedLightCommands(
        strength660: strength660,
        strength850: strength850,
        mode: mode,
      ),
    );
  }

  /// 当前阶段不需要红光时，停止红光模块并关闭两个波长输出。
  Future<void> stopRedLight() async {
    await sendCommandQueue(buildStopRedLightCommands());
  }

  /// 下发当前 5 分钟节点参数，全部成功后最后发送系统启动命令。
  Future<void> startWithCommands(List<ModbusWriteCommand> parameterCommands) {
    return sendCommandQueue([
      ...parameterCommands,
      const ModbusWriteCommand(address: systemCommandAddress, value: 1),
    ]);
  }

  // 构建红光模块相关寄存器的写命令列表。
  List<ModbusWriteCommand> buildRedLightCommands({
    required int strength660,
    required int strength850,
    required int mode,
  }) {
    final int safe660 = _clampPercent(strength660);
    final int safe850 = _clampPercent(strength850);
    final int safeMode = mode == 0 ? 0 : 1;
    final bool enabled = safe660 > 0 || safe850 > 0;

    return [
      ModbusWriteCommand(
        address: redLightTotalEnableAddress,
        value: enabled ? 1 : 0,
      ),
      ModbusWriteCommand(address: redLightTotalModeAddress, value: safeMode),
      ModbusWriteCommand(
        address: redLight660EnableAddress,
        value: safe660 > 0 ? 1 : 0,
      ),
      ModbusWriteCommand(address: redLight660ModeAddress, value: safeMode),
      ModbusWriteCommand(address: redLight660PowerAddress, value: safe660),
      ModbusWriteCommand(
        address: redLight850EnableAddress,
        value: safe850 > 0 ? 1 : 0,
      ),
      ModbusWriteCommand(address: redLight850ModeAddress, value: safeMode),
      ModbusWriteCommand(address: redLight850PowerAddress, value: safe850),
      ModbusWriteCommand(
        address: redLightTotalCommandAddress,
        value: enabled ? 1 : 2,
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
  }) {
    return [
      if (stopRed) ...buildStopRedLightCommands(),
      if (stopPemf) ...[
        const ModbusWriteCommand(address: pemfTotalCommandAddress, value: 2),
        const ModbusWriteCommand(address: pemfTotalIntensityAddress, value: 0),
        const ModbusWriteCommand(address: pemfTotalModeAddress, value: 0),
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
      if (stopHifem) ...[
        const ModbusWriteCommand(address: hifemCommandAddress, value: 2),
        const ModbusWriteCommand(address: hifemForeheadRfAddress, value: 0),
        const ModbusWriteCommand(address: hifemForeheadHifesAddress, value: 0),
        const ModbusWriteCommand(address: hifemLeftCheekRfAddress, value: 0),
        const ModbusWriteCommand(address: hifemLeftCheekHifesAddress, value: 0),
        const ModbusWriteCommand(address: hifemRightCheekRfAddress, value: 0),
        const ModbusWriteCommand(
          address: hifemRightCheekHifesAddress,
          value: 0,
        ),
        const ModbusWriteCommand(address: hifemEnableAddress, value: 0),
      ],
      if (stopFragrance) ...[
        const ModbusWriteCommand(address: fragranceCommandAddress, value: 2),
        const ModbusWriteCommand(address: fragranceEnableAddress, value: 0),
      ],
      const ModbusWriteCommand(address: systemCommandAddress, value: 2),
    ];
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
        const ModbusWriteCommand(address: redLightTotalCommandAddress, value: 3),
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
        const ModbusWriteCommand(address: redLightTotalCommandAddress, value: 4),
    ];
  }

  /// 构建脉轮模块参数与启动命令
  List<ModbusWriteCommand> buildChakraCommands({
    required Map<String, int> strengths,
    int mode = 0,
  }) {
    final int safeMode = mode.clamp(0, 1).toInt();
    final List<ModbusWriteCommand> commands = <ModbusWriteCommand>[
      const ModbusWriteCommand(address: chakraEnableAddress, value: 1),
      ModbusWriteCommand(address: chakraModeAddress, value: safeMode),
    ];

    for (final MapEntry<String, int> entry in strengths.entries) {
      final int? address = chakraStrengthAddressMap[entry.key];
      if (address == null) continue;
      commands.add(
        ModbusWriteCommand(address: address, value: _clampPercent(entry.value)),
      );
    }

    commands.add(
      const ModbusWriteCommand(address: chakraCommandAddress, value: 1),
    );
    return commands;
  }

  /// 构建太赫兹模块参数与启动命令
  List<ModbusWriteCommand> buildTerahertzCommands({
    required int frequency,
    required int power,
    required int mode,
    required int wave,
  }) {
    final int safeFrequency = frequency.clamp(1, 100).toInt();
    final int safePower = _clampPercent(power);
    final int safeMode = mode.clamp(0, 2).toInt();
    final int safeWave = wave.clamp(0, 2).toInt();

    return [
      const ModbusWriteCommand(address: terahertzEnableAddress, value: 1),
      ModbusWriteCommand(address: terahertzModeAddress, value: safeMode),
      ModbusWriteCommand(address: terahertzPowerAddress, value: safePower),
      ModbusWriteCommand(
        address: terahertzFrequencyAddress,
        value: safeFrequency,
      ),
      ModbusWriteCommand(address: terahertzWaveAddress, value: safeWave),
      const ModbusWriteCommand(address: terahertzCommandAddress, value: 1),
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
    return [
      const ModbusWriteCommand(address: hifemEnableAddress, value: 1),
      ModbusWriteCommand(
        address: hifemForeheadRfAddress,
        value: _clampPercent(foreheadRf),
      ),
      ModbusWriteCommand(
        address: hifemForeheadHifesAddress,
        value: _clampPercent(foreheadHifes),
      ),
      ModbusWriteCommand(
        address: hifemLeftCheekRfAddress,
        value: _clampPercent(leftCheekRf),
      ),
      ModbusWriteCommand(
        address: hifemLeftCheekHifesAddress,
        value: _clampPercent(leftCheekHifes),
      ),
      ModbusWriteCommand(
        address: hifemRightCheekRfAddress,
        value: _clampPercent(rightCheekRf),
      ),
      ModbusWriteCommand(
        address: hifemRightCheekHifesAddress,
        value: _clampPercent(rightCheekHifes),
      ),
      const ModbusWriteCommand(address: hifemCommandAddress, value: 1),
    ];
  }

  /// 构建香氛模块参数与启动命令。
  List<ModbusWriteCommand> buildFragranceCommands({required int type}) {
    final int safeType = type.clamp(0, 4).toInt();

    return [
      const ModbusWriteCommand(address: fragranceEnableAddress, value: 1),
      ModbusWriteCommand(address: fragranceTypeAddress, value: safeType),
      const ModbusWriteCommand(address: fragranceCommandAddress, value: 1),
    ];
  }

  /// 构建 VAT 参数命令列表。
  List<ModbusWriteCommand> buildVatParamCommands({
    required int frequency,
    required int intensity,
    required int musicIndex,
  }) {
    final int safeFrequency = frequency.clamp(0, 100);
    final int safeIntensity = intensity.clamp(0, 100);
    final int safeMusicIndex = musicIndex.clamp(0, 65535);
    debugPrint(
      'VAT params: freq=$safeFrequency intensity=$safeIntensity musicIndex=$safeMusicIndex',
    );

    return [
      const ModbusWriteCommand(address: vatEnableAddress, value: 1),
      const ModbusWriteCommand(address: vatModeAddress, value: 0),
      ModbusWriteCommand(address: vatFrequencyAddress, value: safeFrequency),
      ModbusWriteCommand(address: vatIntensityAddress, value: safeIntensity),
      ModbusWriteCommand(address: vatMusicIndexAddress, value: safeMusicIndex),
    ];
  }

  /// 写入 VAT 音乐索引到硬件。
  Future<void> writeVatMusicIndex(int musicIndex) async {
    final int safeIndex = musicIndex.clamp(0, 255);
    await sendCommandQueue([
      ModbusWriteCommand(address: vatMusicIndexAddress, value: safeIndex),
    ]);
    debugPrint('VAT music index written: $safeIndex');
  }

  List<ModbusWriteCommand> buildHydrogenParamCommands({
    required int concentration,
  }) {
    final int safeConcentration = _clampPercent(concentration);
    debugPrint('Hydrogen concentration=$safeConcentration%');
    debugPrint('Hydrogen TX address=0x0257 value=1');
    debugPrint('Hydrogen TX address=0x0259 value=0');
    debugPrint('Hydrogen TX address=0x025D value=$safeConcentration');

    return [
      const ModbusWriteCommand(address: hydrogenEnableAddress, value: 1),
      const ModbusWriteCommand(address: hydrogenModeAddress, value: 0),
      ModbusWriteCommand(
        address: hydrogenConcentrationAddress,
        value: safeConcentration,
      ),
    ];
  }

  /// 读取氢气流量（0x03 读保持寄存器）。
  Future<int> readHydrogenFlow() async {
    try {
      final int value = await readHoldingRegister(hydrogenFlowAddress);
      debugPrint('Hydrogen flow RX address=0x025F value=$value');
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

  int _clampPercent(int value) => value.clamp(0, 100).toInt();

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

class ModbusRtuException implements Exception {
  const ModbusRtuException(this.message);

  final String message;

  @override
  String toString() => message;
}
