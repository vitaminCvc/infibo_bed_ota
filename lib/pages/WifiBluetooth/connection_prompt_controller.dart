import 'dart:async';

import 'package:flutter/foundation.dart';

import 'logic.dart';

enum ConnectionCheckStatus { checking, disconnected, connected }

abstract interface class ConnectionPromptGateway {
  Stream<WifiConnectionStatus> get wifiStatusStream;

  Future<WifiConnectionStatus> readWifiStatus();

  Future<bool> hasConnectedBleDevice();

  Future<void> openWifiSettings();

  Future<void> openBluetoothSettings();
}

/// 在连接状态之外，提供设置页需要展示的真实网络与设备名称。
///
/// 弹窗仍只关心“是否连接”，设置页通过这个扩展接口读取详细信息；两者由同一个
/// 系统网关实现，因此不会出现两套不同的蓝牙设备筛选规则。
abstract interface class ConnectionDetailsGateway
    implements ConnectionPromptGateway {
  Future<String?> readWifiName();

  Future<String?> readConnectedBleDeviceName();
}

class ConnectionPromptController extends ChangeNotifier {
  ConnectionPromptController({required ConnectionPromptGateway gateway})
    : _gateway = gateway;

  final ConnectionPromptGateway _gateway;
  StreamSubscription<WifiConnectionStatus>? _wifiStatusSubscription;
  Future<void>? _refreshInFlight;
  bool _refreshPending = false;
  bool _skippedForCurrentOutage = false;
  bool _manualVisible = false;
  bool _disposed = false;
  ConnectionCheckStatus _wifiStatus = ConnectionCheckStatus.checking;
  ConnectionCheckStatus _bleStatus = ConnectionCheckStatus.checking;

  ConnectionCheckStatus get wifiStatus => _wifiStatus;
  ConnectionCheckStatus get bleStatus => _bleStatus;

  bool get allConnected =>
      wifiStatus == ConnectionCheckStatus.connected &&
      bleStatus == ConnectionCheckStatus.connected;

  bool get shouldShow =>
      _manualVisible || (!_skippedForCurrentOutage && !allConnected);

  Future<void> initialize() {
    if (_disposed || _wifiStatusSubscription != null) {
      return _refreshInFlight ?? Future<void>.value();
    }
    _wifiStatusSubscription = _gateway.wifiStatusStream.listen(
      (WifiConnectionStatus _) {
        unawaited(refresh());
      },
      onError: (Object error, StackTrace stackTrace) {
        if (_disposed) return;
        debugPrint('监听 Wi-Fi 状态失败: $error');
        unawaited(refresh());
      },
    );
    return refresh();
  }

  Future<void> refresh() {
    if (_disposed) return Future<void>.value();
    final Future<void>? inFlight = _refreshInFlight;
    if (inFlight != null) {
      // 进行中的读取完成后仅补做一次，确保设置返回等触发不会复用旧快照。
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
      await _refreshConnectionState();
    } while (!_disposed && _refreshPending);
  }

  ///刷新连接状态
  Future<void> _refreshConnectionState() async {
    final (WifiConnectionStatus wifi, bool bleConnected) = await (
      _readWifiStatus(),
      _readBleConnection(),
    ).wait;
    if (_disposed) return;

    _wifiStatus = wifi == WifiConnectionStatus.connected
        ? ConnectionCheckStatus.connected
        : ConnectionCheckStatus.disconnected;
    _bleStatus = bleConnected
        ? ConnectionCheckStatus.connected
        : ConnectionCheckStatus.disconnected;
    if (allConnected) {
      // 仅在 Wi-Fi 和蓝牙均恢复后，才重置本次断线的跳过状态。
      _skippedForCurrentOutage = false;
    }
    _notifyListeners();
  }

  Future<WifiConnectionStatus> _readWifiStatus() async {
    try {
      return await _gateway.readWifiStatus();
    } catch (_) {
      return WifiConnectionStatus.disconnected;
    }
  }

  Future<bool> _readBleConnection() async {
    try {
      return await _gateway.hasConnectedBleDevice();
    } catch (_) {
      return false;
    }
  }

  void skipForCurrentRun() {
    _manualVisible = false;
    _skippedForCurrentOutage = true;
    _notifyListeners();
  }

  void showManually() {
    _manualVisible = true;
    // 手动打开先清空旧快照，避免系统读取期间展示过期连接结果。
    _wifiStatus = ConnectionCheckStatus.checking;
    _bleStatus = ConnectionCheckStatus.checking;
    _notifyListeners();
    unawaited(refresh());
  }

  ///打开Wifi设置
  Future<void> openWifiSettings() async {
    try {
      await _gateway.openWifiSettings();
    } catch (error) {
      debugPrint('打开 Wi-Fi 设置失败: $error');
    }
  }

  ///打开蓝牙设置
  Future<void> openBluetoothSettings() async {
    try {
      await _gateway.openBluetoothSettings();
    } catch (error) {
      debugPrint('打开蓝牙设置失败: $error');
    }
  }

  ///通知监听器状态更新
  void _notifyListeners() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    final StreamSubscription<WifiConnectionStatus>? subscription =
        _wifiStatusSubscription;
    if (subscription != null) unawaited(subscription.cancel());
    super.dispose();
  }
}
