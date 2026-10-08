import 'package:infibo_app/api/modbus/modbus_rtu_service.dart';

class WaterQualityCommandGuard {
  const WaterQualityCommandGuard._();
  static List<ModbusWriteCommand> filter(
    List<ModbusWriteCommand> commands, {
    required bool canUseHydrogen,
  }) => commands.where((command) {
    if (canUseHydrogen) return true;
    if (command.address >= 0x01C0 && command.address <= 0x01C4) {
      return (command.address == 0x01C0 || command.address == 0x01C2) &&
          command.value == 0;
    }
    if (command.address == 0x01D0) return false;
    if (command.address == 0x01D1) {
      return const {2, 3, 5}.contains(command.value);
    }
    return true;
  }).toList();
}
