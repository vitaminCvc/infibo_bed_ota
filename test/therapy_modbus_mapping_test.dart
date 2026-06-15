import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/api/modbus/red_light_modbus.dart';
import 'package:infibo_app/api/modbus/vat_modbus.dart';

void main() {
  test('red light writes pulse frequency and duty cycle', () {
    final RedLightBatchPayload payload = RedLightModbus.buildPayload(
      strength660: 100,
      strength850: 50,
      mode: 1,
      pulseFrequencyHz: 20,
      dutyCyclePercent: 70,
    );

    expect(payload.values[3], 200); // 0x0066, unit 0.1Hz
    expect(payload.values[4], 70); // 0x0067
  });

  test('VAT writes separate main energy and volume values', () {
    final VatBatchPayload payload = VatModbus.buildPayload(
      frequencyHz: 20,
      energyPercent: 40,
      volumePercent: 50,
      musicIndex: 2,
    );

    expect(payload.values[2], 40); // 0x0182 main channel energy
    expect(payload.values[3], 0); // 0x0183 left channel
    expect(payload.values[4], 0); // 0x0184 right channel
    expect(payload.values[9], 50); // 0x0189 volume
  });
}
