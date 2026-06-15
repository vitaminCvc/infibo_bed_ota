import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/api/modbus/pemf_modbus.dart';

void main() {
  test('PEMF writes carrier frequency to C2 and defaults Burst C3 to zero', () {
    final PemfBatchPayload payload = PemfModbus.buildPayload(
      frequencyHz: 12,
      intensity: 30,
      waveform: 0,
    );

    expect(payload.startAddress, 0x00C2);
    expect(payload.values.length, 8);
    expect(payload.values[0], 12); // 0x00C2 carrier frequency
    expect(payload.values[1], 0); // 0x00C3 Burst frequency
  });
}
