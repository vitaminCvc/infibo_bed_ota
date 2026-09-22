import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/pages/WifiBluetooth/system_gateway.dart';

void main() {
  test(
    'fresh Android permission is granted before Bluetooth devices are read',
    () async {
      bool granted = false;
      final List<String> events = <String>[];
      final SystemWifiBluetoothGateway gateway =
          SystemWifiBluetoothGateway.forTesting(
            isAndroid: true,
            hasBlePermissions: () async {
              events.add('check:$granted');
              return granted;
            },
            requestBlePermissions: () async {
              events.add('request');
              granted = true;
            },
            readGattDeviceNames: () async {
              events.add('gatt');
              return granted ? <String>['Inmortal_GATT'] : <String>[];
            },
            readClassicDeviceNames: () async {
              events.add('classic');
              return <String>[];
            },
          );

      expect(await gateway.hasConnectedBleDevice(), isTrue);
      expect(events, <String>['check:false', 'request', 'gatt', 'classic']);
    },
  );

  test('Android accepts an Inmortal A2DP or headset connection', () async {
    int permissionRequests = 0;
    final SystemWifiBluetoothGateway gateway =
        SystemWifiBluetoothGateway.forTesting(
          isAndroid: true,
          hasBlePermissions: () async => true,
          requestBlePermissions: () async {
            permissionRequests++;
          },
          readGattDeviceNames: () async => <String>[],
          readClassicDeviceNames: () async => <String>['INMORTAL Speaker'],
        );

    expect(await gateway.hasConnectedBleDevice(), isTrue);
    expect(permissionRequests, 0);
  });

  test(
    'returns the real name of the first matching Bluetooth device',
    () async {
      final SystemWifiBluetoothGateway gateway =
          SystemWifiBluetoothGateway.forTesting(
            isAndroid: true,
            hasBlePermissions: () async => true,
            requestBlePermissions: () async {},
            readGattDeviceNames: () async => <String>['Other device'],
            readClassicDeviceNames: () async => <String>[
              '  Inmortal Speaker  ',
              'Inmortal Headset',
            ],
          );

      expect(await gateway.readConnectedBleDeviceName(), 'Inmortal Speaker');
    },
  );

  test('returns the Wi-Fi name supplied by the platform reader', () async {
    final SystemWifiBluetoothGateway gateway =
        SystemWifiBluetoothGateway.forTesting(
          isAndroid: true,
          hasBlePermissions: () async => true,
          requestBlePermissions: () async {},
          readGattDeviceNames: () async => <String>[],
          readClassicDeviceNames: () async => <String>[],
          readWifiName: () async => 'HOME-SJSK-5G',
        );

    expect(await gateway.readWifiName(), 'HOME-SJSK-5G');
  });

  test(
    'other connected Bluetooth device names do not satisfy the prompt',
    () async {
      final SystemWifiBluetoothGateway gateway =
          SystemWifiBluetoothGateway.forTesting(
            isAndroid: true,
            hasBlePermissions: () async => true,
            requestBlePermissions: () async {},
            readGattDeviceNames: () async => <String>['MyInmortal Device'],
            readClassicDeviceNames: () async => <String>['小爱音箱-5002'],
          );

      expect(await gateway.hasConnectedBleDevice(), isFalse);
    },
  );

  test('non-Android platforms use the GATT snapshot only', () async {
    int classicReads = 0;
    final SystemWifiBluetoothGateway gateway =
        SystemWifiBluetoothGateway.forTesting(
          isAndroid: false,
          hasBlePermissions: () async => true,
          requestBlePermissions: () async {},
          readGattDeviceNames: () async => <String>[' Inmortal_Device '],
          readClassicDeviceNames: () async {
            classicReads++;
            return <String>['Inmortal Classic'];
          },
        );

    expect(await gateway.hasConnectedBleDevice(), isTrue);
    expect(classicReads, 0);
  });

  test(
    'denied Android permission returns disconnected without reading devices',
    () async {
      int deviceReads = 0;
      final SystemWifiBluetoothGateway gateway =
          SystemWifiBluetoothGateway.forTesting(
            isAndroid: true,
            hasBlePermissions: () async => false,
            requestBlePermissions: () async => throw StateError('denied'),
            readGattDeviceNames: () async {
              deviceReads++;
              return <String>['Inmortal_GATT'];
            },
            readClassicDeviceNames: () async {
              deviceReads++;
              return <String>['Inmortal Speaker'];
            },
          );

      expect(await gateway.hasConnectedBleDevice(), isFalse);
      expect(deviceReads, 0);
    },
  );
}
