import 'dart:typed_data';
import 'package:infibo_app/services/android_serial_port_service.dart';
import 'package:infibo_app/services/serial_session_gate.dart';
import 'firmware_ota_service.dart';
import 'ota_checksums.dart';
import 'ota_service.dart';

class ModbusOtaTransport implements FirmwareTransport {
  ModbusOtaTransport({
    AndroidSerialPortService? serial,
    this.slaveId = 0x10,
    this.timeout = const Duration(seconds: 6),
    this.interval = const Duration(milliseconds: 30),
  }) : serial = serial ?? AndroidSerialPortService.instance;
  final AndroidSerialPortService serial;
  final int slaveId;
  final Duration timeout, interval;
  SerialLease? _lease;
  @override
  Future<void> open() async {
    if (_lease != null) throw StateError('Already open');
    _lease = await serial.beginExclusiveSession();
  }

  @override
  Future<void> close() async {
    final lease = _lease;
    _lease = null;
    await lease?.release();
  }

  List<int> _word(int value) => [(value >> 8) & 255, value & 255];
  Future<Uint8List> _exchange(List<int> bytes, int function) async {
    final lease = _lease;
    if (lease == null) throw StateError('OTA transport is closed');
    final crc = modbusCrc16(bytes);
    try {
      final response = await serial.transceiveExclusive(
        lease: lease,
        bytes: Uint8List.fromList([...bytes, crc & 255, crc >> 8]),
        timeout: timeout,
      );
      if (response.length < 5 ||
          response[0] != slaveId ||
          modbusCrc16(response.sublist(0, response.length - 2)) !=
              (response[response.length - 2] | response.last << 8)) {
        throw const OtaFailure('ota_transfer_failed');
      }
      if (response[1] == (function | 0x80)) {
        throw const OtaFailure('ota_protocol_unsupported');
      }
      if (response[1] != function) {
        throw const OtaFailure('ota_transfer_failed');
      }
      return response;
    } finally {
      if (interval > Duration.zero) await Future<void>.delayed(interval);
    }
  }

  @override
  Future<List<int>> read(int address, int count) async {
    if (count < 1 || count > 125) throw ArgumentError.value(count);
    final response = await _exchange([
      slaveId,
      3,
      ..._word(address),
      ..._word(count),
    ], 3);
    if (response.length != 5 + count * 2 || response[2] != count * 2) {
      throw const OtaFailure('ota_transfer_failed');
    }
    return [
      for (var i = 0; i < count; i++)
        (response[3 + i * 2] << 8) | response[4 + i * 2],
    ];
  }

  @override
  Future<void> writeSingle(int address, int value) async {
    final request = [slaveId, 6, ..._word(address), ..._word(value)];
    final response = await _exchange(request, 6);
    if (response.length != 8 ||
        !List.generate(6, (i) => response[i] == request[i]).every((v) => v)) {
      throw const OtaFailure('ota_transfer_failed');
    }
  }

  @override
  Future<void> writeMultiple(int address, List<int> values) async {
    if (values.isEmpty ||
        values.length > 123 ||
        values.any((v) => v < 0 || v > 65535)) {
      throw ArgumentError.value(values);
    }
    final header = [slaveId, 0x10, ..._word(address), ..._word(values.length)];
    final response = await _exchange([
      ...header,
      values.length * 2,
      for (final value in values) ..._word(value),
    ], 0x10);
    if (response.length != 8 ||
        !List.generate(6, (i) => response[i] == header[i]).every((v) => v)) {
      throw const OtaFailure('ota_transfer_failed');
    }
  }
}
