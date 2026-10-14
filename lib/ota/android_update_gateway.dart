import 'dart:io';
import 'package:flutter/services.dart';
import 'ota_manifest.dart';

class InstalledApp {
  const InstalledApp({
    required this.packageName,
    required this.version,
    required this.versionCode,
  });
  final String packageName;
  final String version;
  final int versionCode;
}

enum InstallAction { requested, needsPermission }

abstract interface class UpdateGateway {
  Future<InstalledApp> installedApp();
  Future<String> cacheDirectory();
  Future<InstallAction> install(File file, AppRelease release);
  Future<void> openInstallPermission();
  Future<void> keepAwake(bool enabled);
}

class AndroidUpdateGateway implements UpdateGateway {
  static const channel = MethodChannel('infibo_app/ota');
  @override
  Future<InstalledApp> installedApp() async {
    final value = await channel.invokeMapMethod<String, dynamic>(
      'installedApp',
    );
    if (value == null) throw PlatformException(code: 'OTA_INFO_UNAVAILABLE');
    return InstalledApp(
      packageName: value['packageName'] as String,
      version: value['version'] as String,
      versionCode: value['versionCode'] as int,
    );
  }

  @override
  Future<String> cacheDirectory() async =>
      (await channel.invokeMethod<String>('cacheDirectory'))!;
  @override
  Future<InstallAction> install(File file, AppRelease release) async {
    final result = await channel.invokeMethod<String>('installApk', {
      'path': file.path,
      'versionCode': release.versionCode,
      'size': release.size,
      'sha256': release.sha256,
    });
    if (result == 'needs_permission') return InstallAction.needsPermission;
    if (result != 'requested') {
      throw PlatformException(code: 'OTA_INSTALL_FAILED');
    }
    return InstallAction.requested;
  }

  @override
  Future<void> openInstallPermission() =>
      channel.invokeMethod<void>('openInstallPermission');
  @override
  Future<void> keepAwake(bool enabled) =>
      channel.invokeMethod<void>('keepAwake', {'enabled': enabled});
}
