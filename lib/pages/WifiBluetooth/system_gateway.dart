import 'dart:async';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:universal_ble/universal_ble.dart';

import 'connection_prompt_controller.dart';
import 'logic.dart';

class SystemWifiBluetoothGateway
    implements WifiBluetoothGateway, ConnectionDetailsGateway {
  SystemWifiBluetoothGateway({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity(),
      _isAndroid = Platform.isAndroid,
      _hasBlePermissions = _readSystemBlePermissions,
      _requestBlePermissions = _requestSystemBlePermissions,
      _readGattDeviceNames = _readSystemGattDeviceNames,
      _readClassicDeviceNames = _readAndroidClassicDeviceNames,
      _readWifiName = Platform.isAndroid
          ? _readAndroidWifiName
          : _readUnsupportedWifiName;

  @visibleForTesting
  SystemWifiBluetoothGateway.forTesting({
    required bool isAndroid,
    required Future<bool> Function() hasBlePermissions,
    required Future<void> Function() requestBlePermissions,
    required Future<List<String>> Function() readGattDeviceNames,
    required Future<List<String>> Function() readClassicDeviceNames,
    Future<String?> Function()? readWifiName,
  }) : _connectivity = Connectivity(),
       _isAndroid = isAndroid,
       _hasBlePermissions = hasBlePermissions,
       _requestBlePermissions = requestBlePermissions,
       _readGattDeviceNames = readGattDeviceNames,
       _readClassicDeviceNames = readClassicDeviceNames,
       _readWifiName = readWifiName ?? _readUnsupportedWifiName;

  final Connectivity _connectivity;
  final bool _isAndroid;
  final Future<bool> Function() _hasBlePermissions;
  final Future<void> Function() _requestBlePermissions;
  final Future<List<String>> Function() _readGattDeviceNames;
  final Future<List<String>> Function() _readClassicDeviceNames;
  final Future<String?> Function() _readWifiName;
  final StreamController<DeviceConnectionUpdate> _connectionUpdates =
      StreamController<DeviceConnectionUpdate>.broadcast();
  final Map<String, StreamSubscription<bool>> _deviceSubscriptions =
      <String, StreamSubscription<bool>>{};
  final Set<String> _connectedDeviceIds = <String>{};
  Future<void> _operationTail = Future<void>.value();
  bool _closing = false;

  @override
  Stream<NearbyBluetoothDevice> get scanResultStream =>
      UniversalBle.scanStream.map(
        (BleDevice device) => NearbyBluetoothDevice(
          id: device.deviceId,
          name: _displayName(device),
          rssi: device.rssi ?? -100,
        ),
      );

  @override
  Stream<BluetoothRadioStatus> get bluetoothStatusStream =>
      UniversalBle.availabilityStream.map(_mapAvailability);

  @override
  Stream<DeviceConnectionUpdate> get connectionStream =>
      _connectionUpdates.stream;

  @override
  Stream<WifiConnectionStatus> get wifiStatusStream =>
      _connectivity.onConnectivityChanged.map(_mapWifiStatus).distinct();

  @override
  Future<WifiConnectionStatus> readWifiStatus() async {
    final List<ConnectivityResult> results = await _connectivity
        .checkConnectivity();
    return _mapWifiStatus(results);
  }

  @override
  Future<bool> hasConnectedBleDevice() async {
    return await readConnectedBleDeviceName() != null;
  }

  @override
  Future<String?> readConnectedBleDeviceName() async {
    if (_isAndroid && !await _hasBlePermissions()) {
      try {
        // Android 12+ 的系统连接快照受附近设备权限保护，授权成功后再读取。
        await _requestBlePermissions();
      } catch (error) {
        debugPrint('请求附近设备权限失败: $error');
        return null;
      }
    }

    // GATT covers BLE devices. Android additionally needs native A2DP and
    // HEADSET snapshots because UniversalBle only exposes GATT connections.
    final List<Future<List<String>>> reads = <Future<List<String>>>[
      _readNamesSafely(_readGattDeviceNames, 'GATT'),
      if (_isAndroid) _readNamesSafely(_readClassicDeviceNames, 'A2DP/HEADSET'),
    ];
    final List<List<String>> snapshots = await Future.wait(reads);
    for (final String name in snapshots.expand((names) => names)) {
      final String normalizedName = name.trim();
      if (_isTargetBluetoothName(normalizedName)) return normalizedName;
    }
    return null;
  }

  @override
  Future<String?> readWifiName() async {
    final String rawName = (await _readWifiName())?.trim() ?? '';
    if (rawName.isEmpty || rawName == '<unknown ssid>') return null;

    // Android 可能为 SSID 自动包一层双引号，设置页只展示用户看到的网络名。
    if (rawName.length >= 2 &&
        rawName.startsWith('"') &&
        rawName.endsWith('"')) {
      return rawName.substring(1, rawName.length - 1);
    }
    return rawName;
  }

  static Future<bool> _readSystemBlePermissions() =>
      UniversalBle.hasPermissions(withAndroidFineLocation: false);

  static Future<void> _requestSystemBlePermissions() =>
      UniversalBle.requestPermissions(withAndroidFineLocation: false);

  static Future<List<String>> _readSystemGattDeviceNames() async {
    final AvailabilityState availability =
        await UniversalBle.getBluetoothAvailabilityState();
    if (availability != AvailabilityState.poweredOn) return <String>[];
    final List<BleDevice> devices = await UniversalBle.getSystemDevices(
      withServices: <String>[],
    );
    return devices
        .map((BleDevice device) => device.name?.trim() ?? '')
        .where((String name) => name.isNotEmpty)
        .toList(growable: false);
  }

  static const MethodChannel _bluetoothProfileChannel = MethodChannel(
    'infibo_app/android_bluetooth_profiles',
  );

  static const MethodChannel _wifiInfoChannel = MethodChannel(
    'infibo_app/android_wifi_info',
  );

  static Future<List<String>> _readAndroidClassicDeviceNames() async {
    final List<dynamic>? names = await _bluetoothProfileChannel
        .invokeListMethod<dynamic>('getConnectedClassicBluetoothDeviceNames');
    return (names ?? <dynamic>[])
        .whereType<String>()
        .map((String name) => name.trim())
        .where((String name) => name.isNotEmpty)
        .toList(growable: false);
  }

  static Future<String?> _readAndroidWifiName() =>
      _wifiInfoChannel.invokeMethod<String>('getConnectedWifiName');

  static Future<String?> _readUnsupportedWifiName() async => null;

  Future<List<String>> _readNamesSafely(
    Future<List<String>> Function() reader,
    String profile,
  ) async {
    try {
      return await reader();
    } catch (error) {
      // One unavailable Android profile must not hide a valid connection
      // reported by another supported Bluetooth profile.
      debugPrint('读取 $profile 蓝牙连接失败: $error');
      return <String>[];
    }
  }

  bool _isTargetBluetoothName(String name) {
    return name.trim().toLowerCase().startsWith('yjco');
  }

  @override
  Future<BluetoothRadioStatus> readBluetoothStatus() async {
    final AvailabilityState state =
        await UniversalBle.getBluetoothAvailabilityState();
    return _mapAvailability(state);
  }

  @override
  Future<void> startScan() {
    return _runExclusive(() async {
      await UniversalBle.requestPermissions(withAndroidFineLocation: false);
      if (_closing) return;
      await UniversalBle.startScan(
        platformConfig: PlatformConfig(
          android: AndroidOptions(
            requestLocationPermission: false,
            scanMode: AndroidScanMode.lowLatency,
          ),
        ),
      );
    });
  }

  @override
  Future<void> stopScan() {
    return _runExclusive(UniversalBle.stopScan);
  }

  @override
  Future<void> connect(String deviceId) {
    return _runExclusive(() async {
      if (await UniversalBle.isScanning()) await UniversalBle.stopScan();
      if (_closing) return;
      _watchConnection(deviceId);
      _emitConnection(deviceId, BluetoothLinkStatus.connecting);
      try {
        await UniversalBle.connect(
          deviceId,
          timeout: const Duration(seconds: 20),
        );
        final BleConnectionState state = await UniversalBle.getConnectionState(
          deviceId,
        );
        if (state != BleConnectionState.connected) {
          throw StateError('蓝牙设备未能建立连接');
        }
        _emitConnection(deviceId, BluetoothLinkStatus.connected);
      } catch (_) {
        _emitConnection(deviceId, BluetoothLinkStatus.disconnected);
        rethrow;
      }
    });
  }

  @override
  Future<void> disconnect(String deviceId) {
    return _runExclusive(() async {
      _watchConnection(deviceId);
      _emitConnection(deviceId, BluetoothLinkStatus.disconnecting);
      await UniversalBle.disconnect(
        deviceId,
        timeout: const Duration(seconds: 10),
      );
      final BleConnectionState state = await UniversalBle.getConnectionState(
        deviceId,
      );
      if (state == BleConnectionState.disconnected) {
        _emitConnection(deviceId, BluetoothLinkStatus.disconnected);
        return;
      }
      _emitConnection(deviceId, BluetoothLinkStatus.connected);
      throw StateError('蓝牙设备未能断开连接');
    });
  }

  @override
  Future<void> openWifiSettings() async {
    if (Platform.isAndroid) {
      final AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
      if (info.version.sdkInt >= 29) {
        await AppSettings.openAppSettingsPanel(AppSettingsPanelType.wifi);
        return;
      }
    }
    await AppSettings.openAppSettings(type: AppSettingsType.wifi);
  }

  @override
  Future<void> openBluetoothSettings() {
    return AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
  }

  void _watchConnection(String deviceId) {
    if (_deviceSubscriptions.containsKey(deviceId)) return;
    _deviceSubscriptions[deviceId] = UniversalBle.connectionStream(deviceId)
        .listen((bool connected) {
          _emitConnection(
            deviceId,
            connected
                ? BluetoothLinkStatus.connected
                : BluetoothLinkStatus.disconnected,
          );
        });
  }

  void _emitConnection(String deviceId, BluetoothLinkStatus status) {
    if (status == BluetoothLinkStatus.connected) {
      _connectedDeviceIds.add(deviceId);
    } else if (status == BluetoothLinkStatus.disconnected) {
      _connectedDeviceIds.remove(deviceId);
    }
    if (_connectionUpdates.isClosed) return;
    _connectionUpdates.add(
      DeviceConnectionUpdate(deviceId: deviceId, status: status),
    );
  }

  Future<T> _runExclusive<T>(Future<T> Function() action) {
    if (_closing) return Future<T>.error(StateError('连接页面已关闭'));

    final Completer<T> result = Completer<T>();
    final Future<void> previous = _operationTail;
    _operationTail = () async {
      try {
        await previous;
      } catch (_) {
        // A failed command must not block the following cleanup command.
      }
      if (_closing) {
        result.completeError(StateError('连接页面已关闭'));
        return;
      }
      try {
        result.complete(await action());
      } catch (error, stackTrace) {
        result.completeError(error, stackTrace);
      }
    }();
    return result.future;
  }

  String _displayName(BleDevice device) {
    final String name = device.name?.trim() ?? '';
    return name.isEmpty ? '未命名设备' : name;
  }

  WifiConnectionStatus _mapWifiStatus(List<ConnectivityResult> results) {
    return results.contains(ConnectivityResult.wifi)
        ? WifiConnectionStatus.connected
        : WifiConnectionStatus.disconnected;
  }

  BluetoothRadioStatus _mapAvailability(AvailabilityState state) {
    return switch (state) {
      AvailabilityState.poweredOn => BluetoothRadioStatus.ready,
      AvailabilityState.poweredOff => BluetoothRadioStatus.poweredOff,
      AvailabilityState.unauthorized => BluetoothRadioStatus.unauthorized,
      AvailabilityState.unsupported => BluetoothRadioStatus.unsupported,
      AvailabilityState.unknown ||
      AvailabilityState.resetting => BluetoothRadioStatus.unknown,
    };
  }

  Future<void> dispose() async {
    if (_closing) return;
    _closing = true;
    await _operationTail;
    try {
      if (await UniversalBle.isScanning()) await UniversalBle.stopScan();
    } catch (_) {
      // The platform may already be detached while the page is closing.
    }
    for (final String deviceId in _connectedDeviceIds.toList()) {
      try {
        await UniversalBle.disconnect(
          deviceId,
          timeout: const Duration(seconds: 5),
        );
      } catch (_) {
        // Best-effort teardown; Android may already have closed the adapter.
      }
    }
    _connectedDeviceIds.clear();
    for (final StreamSubscription<bool> subscription
        in _deviceSubscriptions.values) {
      await subscription.cancel();
    }
    await _connectionUpdates.close();
  }
}
