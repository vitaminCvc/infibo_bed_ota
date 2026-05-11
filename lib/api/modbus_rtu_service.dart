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

  /// PEMF总模式地址。
  static const int pemfTotalModeAddress = 0x00C7;

  ///PEMF总频率地址。
  static const int pemfTotalFrequencyAddress = 0x00CE;

  /// PEMF输出强度地址。
  static const int pemfTotalIntensityAddress = 0x00D0;

  /// PEMF输出波形地址。
  static const int pemfTotalWaveformAddress = 0x00D1;

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
  /// 红光总命令地址，发送 0x0066 = 3 和 0x0004 = 3 命令。
  Future<void> pauseTherapy() {
    return sendCommandQueue(const [
      ModbusWriteCommand(address: redLightTotalCommandAddress, value: 3),
      ModbusWriteCommand(address: systemCommandAddress, value: 3),
    ]);
  }

  // 继续总命令，发送 0x0004 = 4 和 0x0066 = 4 命令。
  Future<void> resumeTherapy() {
    return sendCommandQueue(const [
      ModbusWriteCommand(address: redLightTotalCommandAddress, value: 4),
      ModbusWriteCommand(address: systemCommandAddress, value: 4),
    ]);
  }

  // 停止总命令。
  Future<void> stopTherapy() {
    return sendCommandQueue(buildStopTherapyCommands());
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

  // 构建停止治疗的命令列表，除了关闭红光模块，还发送系统停止命令。
  List<ModbusWriteCommand> buildStopTherapyCommands() {
    return const [
      ModbusWriteCommand(address: redLightTotalCommandAddress, value: 2),
      ModbusWriteCommand(address: systemCommandAddress, value: 2),
      ModbusWriteCommand(address: redLight660EnableAddress, value: 0),
      ModbusWriteCommand(address: redLight660PowerAddress, value: 0),
      ModbusWriteCommand(address: redLight850EnableAddress, value: 0),
      ModbusWriteCommand(address: redLight850PowerAddress, value: 0),
      ModbusWriteCommand(address: redLightTotalEnableAddress, value: 0),
    ];
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
      '参数下发失败：寄存器 ${command.addressText} ${_failureReason(lastError)}',
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
    if (text.isEmpty) return '参数下发失败：未知串口错误';
    return text;
  }

  String _failureReason(Object? error) {
    final String text = error?.toString() ?? '';
    if (text.toLowerCase().contains('timeout')) return '写入超时';
    if (text.isEmpty) return '写入失败';
    return '写入失败：$text';
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
