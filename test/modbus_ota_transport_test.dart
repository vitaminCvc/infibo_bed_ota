import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/ota/modbus_ota_transport.dart';
import 'package:infibo_app/ota/ota_checksums.dart';
import 'package:infibo_app/services/android_serial_port_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'builds valid read/0x10/control frames and rejects ordinary traffic during OTA',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      const channel = MethodChannel('infibo_app/android_serial_port');
      final frames = <Uint8List>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            expect(call.method, 'transceiveBytes');
            final frame = (call.arguments as Map)['bytes'] as Uint8List;
            frames.add(frame);
            expect(
              modbusCrc16(frame.sublist(0, frame.length - 2)),
              frame[frame.length - 2] | frame.last << 8,
            );
            final data = frame[1] == 3
                ? <int>[16, 3, 4, 0x12, 0x34, 0xab, 0xcd]
                : frame.sublist(0, 6);
            final crc = modbusCrc16(data);
            return Uint8List.fromList([...data, crc & 255, crc >> 8]);
          });
      final transport = ModbusOtaTransport(interval: Duration.zero);
      try {
        await transport.open();
        await expectLater(
          AndroidSerialPortService.instance.sendBytes(Uint8List.fromList([1])),
          throwsStateError,
        );
        expect(await transport.read(0x030f, 2), [0x1234, 0xabcd]);
        await transport.writeMultiple(0x0320, List.filled(64, 0xaaff));
        await transport.writeSingle(0x0300, 0xa002);
        expect(frames[1].length, 137);
        expect(frames[1].sublist(0, 9), [16, 16, 3, 32, 0, 64, 128, 170, 255]);
        expect(frames[2].length, 8);
        expect(frames[2].sublist(0, 6), [16, 6, 3, 0, 160, 2]);
      } finally {
        await transport.close();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );
}
