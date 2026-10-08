import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/api/modbus/modbus_rtu_service.dart';
import 'package:infibo_app/components/water_quality/water_quality_command_guard.dart';

void main() {
  test(
    'unavailable water blocks hydrogen activation but preserves other modules',
    () {
      final result = WaterQualityCommandGuard.filter(const [
        ModbusWriteCommand(address: 0x0064, value: 1),
        ModbusWriteCommand(address: 0x01C0, value: 1),
        ModbusWriteCommand(address: 0x01C2, value: 80),
        ModbusWriteCommand(address: 0x01D0, value: 1),
        ModbusWriteCommand(address: 0x01D1, value: 1),
        ModbusWriteCommand(address: 0x01D1, value: 4),
        ModbusWriteCommand(address: 0x0004, value: 1),
      ], canUseHydrogen: false);
      expect(result.map((c) => c.address).toList(), [0x0064, 0x0004]);
    },
  );
  test(
    'hydrogen stop pause and disable remain possible with invalid water',
    () {
      final result = WaterQualityCommandGuard.filter(const [
        ModbusWriteCommand(address: 0x01D1, value: 2),
        ModbusWriteCommand(address: 0x01D1, value: 3),
        ModbusWriteCommand(address: 0x01C2, value: 0),
        ModbusWriteCommand(address: 0x01C0, value: 0),
        ModbusWriteCommand(address: 0x01EB, value: 1),
      ], canUseHydrogen: false);
      expect(result.map((c) => c.value).toList(), [2, 3, 0, 0, 1]);
    },
  );
  test('valid water preserves full hydrogen configuration and resume', () {
    final result = WaterQualityCommandGuard.filter(const [
      ModbusWriteCommand(address: 0x01C0, value: 1),
      ModbusWriteCommand(address: 0x01C2, value: 80),
      ModbusWriteCommand(address: 0x01D0, value: 1),
      ModbusWriteCommand(address: 0x01D1, value: 4),
    ], canUseHydrogen: true);
    expect(result.map((c) => c.value).toList(), [1, 80, 1, 4]);
  });
}
