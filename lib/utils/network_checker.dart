import 'package:connectivity_plus/connectivity_plus.dart';

/// 网络状态检测工具。
class NetworkChecker {
  NetworkChecker._();

  /// 检查当前设备是否已连接到网络（Wi-Fi / 以太网 / 移动数据）。
  /// 返回 true 表示有网络连接，false 表示无网络。
  static Future<bool> isConnected() async {
    final List<ConnectivityResult> results =
        await Connectivity().checkConnectivity();
    return results.any(
      (ConnectivityResult result) => result != ConnectivityResult.none,
    );
  }
}
