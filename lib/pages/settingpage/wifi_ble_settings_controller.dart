import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:infibo_app/pages/WifiBluetooth/connection_prompt_controller.dart';
import 'package:infibo_app/pages/WifiBluetooth/logic.dart';

/// 设置页 WIFI & BLE 面板的连接详情状态。
///
/// Wi-Fi 的连接状态和 SSID 分开保存：Android 可能因定位权限或定位服务关闭而
/// 隐藏 SSID，但此时设备依然连接着 Wi-Fi，界面不能把它误判为断线。
class WifiBleSettingsController extends ChangeNotifier {
  WifiBleSettingsController({required ConnectionDetailsGateway gateway})
    : _gateway = gateway;

  final ConnectionDetailsGateway _gateway;
  StreamSubscription<WifiConnectionStatus>? _wifiStatusSubscription;
  Future<void>? _refreshInFlight;
  bool _refreshPending = false;
  bool _disposed = false;

  ConnectionCheckStatus _wifiStatus = ConnectionCheckStatus.checking;
  ConnectionCheckStatus _bleStatus = ConnectionCheckStatus.checking;
  String? _wifiName;
  String? _bluetoothName;

  ConnectionCheckStatus get wifiStatus => _wifiStatus;
  ConnectionCheckStatus get bleStatus => _bleStatus;
  String? get wifiName => _wifiName;
  String? get bluetoothName => _bluetoothName;

  Future<void> initialize() {
    if (_disposed || _wifiStatusSubscription != null) {
      return _refreshInFlight ?? Future<void>.value();
    }
    _wifiStatusSubscription = _gateway.wifiStatusStream.listen(
      (_) => unawaited(refresh()),
      onError: (Object error, StackTrace stackTrace) {
        if (_disposed) return;
        debugPrint('监听设置页 Wi-Fi 状态失败: $error');
        unawaited(refresh());
      },
    );
    return refresh();
  }

  Future<void> refresh() {
    if (_disposed) return Future<void>.value();
    final Future<void>? inFlight = _refreshInFlight;
    if (inFlight != null) {
      // 系统设置返回等事件可能与定时刷新重叠，当前读取完成后最多补做一次。
      _refreshPending = true;
      return inFlight;
    }

    late final Future<void> refreshFuture;
    refreshFuture = _runRefreshLoop().whenComplete(() {
      if (identical(_refreshInFlight, refreshFuture)) {
        _refreshInFlight = null;
      }
    });
    _refreshInFlight = refreshFuture;
    return refreshFuture;
  }

  Future<void> _runRefreshLoop() async {
    do {
      _refreshPending = false;
      await _refreshConnectionDetails();
    } while (!_disposed && _refreshPending);
  }

  Future<void> _refreshConnectionDetails() async {
    final (WifiConnectionStatus wifi, String? bluetoothName) = await (
      _readWifiStatus(),
      _readBluetoothName(),
    ).wait;

    // 仅在 Wi-Fi 确实连接时读取 SSID，避免断网时弹出无意义的定位权限请求。
    final String? wifiName = wifi == WifiConnectionStatus.connected
        ? await _readWifiName()
        : null;
    if (_disposed) return;

    _wifiStatus = wifi == WifiConnectionStatus.connected
        ? ConnectionCheckStatus.connected
        : ConnectionCheckStatus.disconnected;
    _wifiName = _normalizeName(wifiName);
    _bluetoothName = _normalizeName(bluetoothName);
    _bleStatus = _bluetoothName == null
        ? ConnectionCheckStatus.disconnected
        : ConnectionCheckStatus.connected;
    notifyListeners();
  }

  Future<WifiConnectionStatus> _readWifiStatus() async {
    try {
      return await _gateway.readWifiStatus();
    } catch (error) {
      debugPrint('读取设置页 Wi-Fi 状态失败: $error');
      return WifiConnectionStatus.disconnected;
    }
  }

  Future<String?> _readWifiName() async {
    try {
      return await _gateway.readWifiName();
    } catch (error) {
      // SSID 不可读不等同于 Wi-Fi 未连接，保留连接状态并让界面显示兜底文字。
      debugPrint('读取 Wi-Fi 名称失败: $error');
      return null;
    }
  }

  Future<String?> _readBluetoothName() async {
    try {
      return await _gateway.readConnectedBleDeviceName();
    } catch (error) {
      debugPrint('读取蓝牙设备名称失败: $error');
      return null;
    }
  }

  String? _normalizeName(String? value) {
    final String name = value?.trim() ?? '';
    return name.isEmpty ? null : name;
  }

  Future<void> openWifiSettings() => _gateway.openWifiSettings();

  Future<void> openBluetoothSettings() => _gateway.openBluetoothSettings();

  @override
  void dispose() {
    _disposed = true;
    final StreamSubscription<WifiConnectionStatus>? subscription =
        _wifiStatusSubscription;
    if (subscription != null) unawaited(subscription.cancel());
    super.dispose();
  }
}
