import 'dart:async';

import 'package:flutter/foundation.dart';

///构建连接提示对话框WiFi连接状态
///【unknown】位置状态
///【disconnected】未连接
///【connected】已连接
enum WifiConnectionStatus { unknown, disconnected, connected }

enum BluetoothRadioStatus {
  unknown,
  unsupported,
  unauthorized,
  poweredOff,
  ready,
}

///构建连接提示对话框蓝牙连接状态
///【disconnected】未连接
///【connecting】连接中
///【connected】已连接
///【disconnecting】断开连接
enum BluetoothLinkStatus { disconnected, connecting, connected, disconnecting }

@immutable
class NearbyBluetoothDevice {
  ///构建连接提示对话框附近蓝牙设备
  const NearbyBluetoothDevice({
    required this.id,
    required this.name,
    required this.rssi,
    this.linkStatus = BluetoothLinkStatus.disconnected,
  });

  ///构建连接提示对话框附近蓝牙设备ID
  final String id;

  ///构建连接提示对话框附近蓝牙设备名称
  ///【name】设备名称
  final String name;

  ///构建连接提示对话框附近蓝牙设备信号强度
  ///【rssi】信号强度，单位为dBm
  ///【-100】最强信号
  ///【-50】中等信号
  ///【-0】最弱信号0
  final int rssi;
  final BluetoothLinkStatus linkStatus;

  NearbyBluetoothDevice copyWith({
    String? name,
    int? rssi,
    BluetoothLinkStatus? linkStatus,
  }) {
    return NearbyBluetoothDevice(
      id: id,
      name: name ?? this.name,
      rssi: rssi ?? this.rssi,
      linkStatus: linkStatus ?? this.linkStatus,
    );
  }
}

@immutable
class DeviceConnectionUpdate {
  const DeviceConnectionUpdate({required this.deviceId, required this.status});

  final String deviceId;
  final BluetoothLinkStatus status;
}

abstract interface class WifiBluetoothGateway {
  Stream<NearbyBluetoothDevice> get scanResultStream;

  Stream<BluetoothRadioStatus> get bluetoothStatusStream;

  Stream<DeviceConnectionUpdate> get connectionStream;

  Future<WifiConnectionStatus> readWifiStatus();

  Future<BluetoothRadioStatus> readBluetoothStatus();

  Future<void> startScan();

  Future<void> stopScan();

  Future<void> connect(String deviceId);

  Future<void> disconnect(String deviceId);

  Future<void> openWifiSettings();

  Future<void> openBluetoothSettings();
}

class WifiBluetoothController extends ChangeNotifier {
  WifiBluetoothController({required WifiBluetoothGateway gateway})
    : _gateway = gateway;

  final WifiBluetoothGateway _gateway;
  final Map<String, NearbyBluetoothDevice> _devices =
      <String, NearbyBluetoothDevice>{};
  final Map<String, BluetoothLinkStatus> _connectionStates =
      <String, BluetoothLinkStatus>{};
  final Set<String> _busyDeviceIds = <String>{};
  final List<StreamSubscription<Object?>> _subscriptions =
      <StreamSubscription<Object?>>[];

  bool _initializing = true;
  bool _scanning = false;
  bool _disposed = false;
  WifiConnectionStatus _wifiStatus = WifiConnectionStatus.unknown;
  BluetoothRadioStatus _bluetoothStatus = BluetoothRadioStatus.unknown;
  String? _errorMessage;

  bool get initializing => _initializing;
  bool get scanning => _scanning;
  WifiConnectionStatus get wifiStatus => _wifiStatus;
  BluetoothRadioStatus get bluetoothStatus => _bluetoothStatus;
  String? get errorMessage => _errorMessage;
  Set<String> get busyDeviceIds => Set<String>.unmodifiable(_busyDeviceIds);
  List<NearbyBluetoothDevice> get devices {
    final List<NearbyBluetoothDevice> result = _devices.values.toList();
    result.sort(
      (NearbyBluetoothDevice left, NearbyBluetoothDevice right) =>
          right.rssi.compareTo(left.rssi),
    );
    return List<NearbyBluetoothDevice>.unmodifiable(result);
  }

  Future<void> initialize() async {
    _subscriptions
      ..add(_gateway.scanResultStream.listen(_upsertDevice))
      ..add(_gateway.bluetoothStatusStream.listen(_setBluetoothStatus))
      ..add(_gateway.connectionStream.listen(_setConnectionStatus));

    try {
      final (
        WifiConnectionStatus wifi,
        BluetoothRadioStatus bluetooth,
      ) = await (
        _gateway.readWifiStatus(),
        _gateway.readBluetoothStatus(),
      ).wait;
      _wifiStatus = wifi;
      _bluetoothStatus = bluetooth;
    } catch (error) {
      _errorMessage = _describeError(error);
    } finally {
      if (!_disposed) {
        _initializing = false;
        _notifyListeners();
      }
    }
  }

  Future<void> connect(String deviceId) async {
    if (_scanning) {
      await stopScan();
      if (_disposed) return;
    }
    _errorMessage = null;
    _busyDeviceIds.add(deviceId);
    _notifyListeners();
    try {
      await _gateway.connect(deviceId);
    } catch (error) {
      if (!_disposed) {
        _errorMessage = _describeError(error);
        _setConnectionStatus(
          DeviceConnectionUpdate(
            deviceId: deviceId,
            status: BluetoothLinkStatus.disconnected,
          ),
        );
      }
    } finally {
      _busyDeviceIds.remove(deviceId);
      _notifyListeners();
    }
  }

  Future<void> disconnect(String deviceId) async {
    _errorMessage = null;
    _busyDeviceIds.add(deviceId);
    _notifyListeners();
    try {
      await _gateway.disconnect(deviceId);
    } catch (error) {
      if (!_disposed) {
        _errorMessage = _describeError(error);
        _setConnectionStatus(
          DeviceConnectionUpdate(
            deviceId: deviceId,
            status: BluetoothLinkStatus.connected,
          ),
        );
      }
    } finally {
      _busyDeviceIds.remove(deviceId);
      _notifyListeners();
    }
  }

  Future<void> startScan() async {
    _errorMessage = null;
    if (_busyDeviceIds.isNotEmpty) {
      _errorMessage = '请等待当前蓝牙连接操作完成';
      _notifyListeners();
      return;
    }
    if (_bluetoothStatus != BluetoothRadioStatus.ready) {
      _errorMessage = '请先开启蓝牙并允许“附近设备”权限';
      _notifyListeners();
      return;
    }

    _devices.removeWhere((String deviceId, NearbyBluetoothDevice _) {
      final BluetoothLinkStatus? status = _connectionStates[deviceId];
      return status == null || status == BluetoothLinkStatus.disconnected;
    });
    _notifyListeners();
    try {
      await _gateway.startScan();
      if (_disposed) {
        try {
          await _gateway.stopScan();
        } catch (_) {
          // The owned gateway may already be shutting down with the page.
        }
        return;
      }
      _scanning = true;
    } catch (error) {
      _errorMessage = _describeError(error);
      _scanning = false;
    }
    _notifyListeners();
  }

  Future<void> stopScan() async {
    try {
      await _gateway.stopScan();
    } catch (error) {
      _errorMessage = _describeError(error);
    } finally {
      _scanning = false;
      _notifyListeners();
    }
  }

  Future<void> refreshWifiStatus() async {
    try {
      _wifiStatus = await _gateway.readWifiStatus();
    } catch (error) {
      _errorMessage = _describeError(error);
    }
    _notifyListeners();
  }

  Future<void> openWifiSettings() async {
    await _runSettingsAction(_gateway.openWifiSettings);
  }

  Future<void> openBluetoothSettings() async {
    await _runSettingsAction(_gateway.openBluetoothSettings);
  }

  Future<void> _runSettingsAction(Future<void> Function() action) async {
    _errorMessage = null;
    try {
      await action();
    } catch (error) {
      _errorMessage = _describeError(error);
      _notifyListeners();
    }
  }

  ///构建连接提示对话框更新附近蓝牙设备状态
  void _upsertDevice(NearbyBluetoothDevice device) {
    final BluetoothLinkStatus linkStatus =
        _connectionStates[device.id] ?? device.linkStatus;
    _devices[device.id] = device.copyWith(linkStatus: linkStatus);
    _notifyListeners();
  }

  void _setBluetoothStatus(BluetoothRadioStatus status) {
    _bluetoothStatus = status;
    if (status != BluetoothRadioStatus.ready && _scanning) {
      _scanning = false;
      unawaited(_stopScanAfterRadioLoss());
    }
    _notifyListeners();
  }

  Future<void> _stopScanAfterRadioLoss() async {
    try {
      await _gateway.stopScan();
    } catch (error) {
      _errorMessage = _describeError(error);
      _notifyListeners();
    }
  }

  void _setConnectionStatus(DeviceConnectionUpdate update) {
    _connectionStates[update.deviceId] = update.status;
    final NearbyBluetoothDevice? device = _devices[update.deviceId];
    if (device == null) return;
    _devices[update.deviceId] = device.copyWith(linkStatus: update.status);
    _notifyListeners();
  }

  String _describeError(Object error) {
    return error.toString().replaceFirst('Bad state: ', '');
  }

  void _notifyListeners() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    for (final StreamSubscription<Object?> subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    super.dispose();
  }
}
