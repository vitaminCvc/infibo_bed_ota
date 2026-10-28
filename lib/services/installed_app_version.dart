import 'package:flutter/services.dart';

/// 当前设备实际安装的 App 版本。
///
/// 不读取 pubspec.yaml，也不写死显示文字：打包工具的 --build-name 和
/// --build-number 会写入 APK，Android 再从这个 APK 的安装信息中读取。
class InstalledAppVersion {
  const InstalledAppVersion(this.name, this.number);

  final String name;
  final int number;

  String get displayText => 'V$name';

  static const _channel = MethodChannel('infibo_app/app_info');

  /// 原生实现位于 android/.../AndroidAppInfoBridge.kt。
  /// 这里只读版本，不会检查更新、安装 APK 或修改任何设备信息。
  static Future<InstalledAppVersion> read() async {
    final info = await _channel.invokeMapMethod<String, Object?>('getVersion');
    final name = info?['versionName'];
    final number = info?['versionCode'];
    if (name is! String ||
        name.trim().isEmpty ||
        number is! int ||
        number < 1) {
      throw const FormatException('Installed APK version is unavailable');
    }
    return InstalledAppVersion(name, number);
  }
}
