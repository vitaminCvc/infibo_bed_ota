import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/api/modbus/modbus_rtu_service.dart';
import 'package:infibo_app/config/app_brand.dart';

// 只替代串口传输，保留真实 startWaterFilling 的硬件能力判断。
class RecordingWaterService extends ModbusRtuService {
  final List<ModbusWriteCommand> writes = [];

  @override
  Future<void> sendCommandQueue(List<ModbusWriteCommand> commands) async {
    writes.addAll(commands);
  }
}

void main() {
  tearDown(() => AppBrand.configure(AppBrands.global));

  test('India build flag gates the actual filling command', () async {
    AppBrand.configure(AppBrands.india);
    final service = RecordingWaterService();
    await service.startWaterFilling();
    if (const bool.fromEnvironment('INDIA_AUTO_WATER_FILLING', defaultValue: true)) {
      expect(service.writes, hasLength(1));
      expect(service.writes.single.address, 0x01EB);
      expect(service.writes.single.value, 1);
    } else {
      expect(service.writes, isEmpty);
    }
  });

  for (final brand in [
    AppBrands.global,
    AppBrands.spain,
    AppBrands.turkey,
    AppBrands.america,
    AppBrands.britain,
    AppBrands.australia,
  ]) {
    test('${brand.flavor} still sends the filling command', () async {
      AppBrand.configure(brand);
      final service = RecordingWaterService();
      await service.startWaterFilling();
      expect(service.writes, hasLength(1));
      expect(service.writes.single.address, 0x01EB);
      expect(service.writes.single.value, 1);
    });
  }
}
