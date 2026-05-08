// Modbus RTU 写寄存器服务。
//
// 目前主要用于向下位机主控板发送“写单寄存器 0x06”命令。
// Android 真机走 AndroidSerialPortService + /dev/ttyS0；
// Windows 调试时仍保留 flutter_libserialport 分支，便于桌面串口测试。
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:infibo_app/services/android_serial_port_service.dart';

class ModbusRtuService {
  final String portName;
  final int baudRate;
  final int slaveId;
  final Duration timeout;

  const ModbusRtuService({
    this.portName = AndroidSerialPortService.defaultPath,
    this.baudRate = AndroidSerialPortService.defaultBaudRate,
    this.slaveId = 16,
    this.timeout = const Duration(seconds: 1),
  });

  /// 启动，发送 0x0004 = 1 命令。
  Future<void> start() async {
    await writeSingleRegister(address: 0x0004, value: 1);
  }

  /// 停止，发送 0x0004 = 2 命令。
  Future<void> pause() async {
    await writeSingleRegister(address: 0x0004, value: 2);
  }

  Future<void> writeSingleRegister({
    required int address,
    required int value,
  }) async {
    // Android 是正式运行环境：通过原生串口 bridge 写 /dev/ttyS0。
    if (Platform.isAndroid) {
      await _writeSingleRegisterAndroid(address: address, value: value);
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

  Future<void> _writeSingleRegisterAndroid({
    required int address,
    required int value,
  }) async {
    // 订阅接收事件，等待本次写寄存器的 8 字节回包。
    final AndroidSerialPortService serialPort =
        AndroidSerialPortService.instance;
    final Completer<Uint8List> responseCompleter = Completer<Uint8List>();

    final StreamSubscription<AndroidSerialPortEvent> subscription = serialPort
        .events
        .listen((AndroidSerialPortEvent event) {
          if (responseCompleter.isCompleted) return;

          switch (event.type) {
            case AndroidSerialPortEventType.rx:
              responseCompleter.complete(event.bytes ?? Uint8List(0));
              break;
            case AndroidSerialPortEventType.error:
              responseCompleter.completeError(
                Exception(event.message ?? 'Unknown serial error'),
              );
              break;
          }
        });

    try {
      await serialPort.openSerialPort(path: portName, baudRate: baudRate);

      final Uint8List request = _buildWriteSingleRegisterFrame(
        slaveId: slaveId,
        address: address,
        value: value,
      );

      debugPrint('Modbus RTU TX: ${_formatBytes(request)}');
      final int written = await serialPort.sendBytes(request);
      if (written != request.length) {
        throw TimeoutException(
          'Serial write timeout: $written/${request.length} bytes',
        );
      }

      final Uint8List response = await responseCompleter.future.timeout(
        timeout,
      );
      debugPrint('Modbus RTU RX: ${_formatBytes(response)}');

      _validateWriteSingleRegisterResponse(
        response: response,
        address: address,
        value: value,
      );

      debugPrint('Modbus RTU write success: address $address = $value');
    } finally {
      await subscription.cancel();
      await serialPort.closeSerialPort();
    }
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

  void _validateWriteSingleRegisterResponse({
    required Uint8List response,
    required int address,
    required int value,
  }) {
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
}
