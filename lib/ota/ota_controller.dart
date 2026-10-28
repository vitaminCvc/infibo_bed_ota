import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:infibo_app/api/modbus/modbus_rtu_service.dart';
import 'android_update_gateway.dart';
import 'ota_config.dart';
import 'ota_manifest.dart';
import 'ota_service.dart';
import 'firmware_ota_service.dart';
import 'modbus_ota_transport.dart';

enum OtaPhase {
  idle,
  checking,
  checkingDevice,
  downloading,
  verifying,
  installing,
  installRequested,
  needsPermission,
  success,
  error,
  transferring,
  boardVerifying,
  boardInstalling,
  boardReconnecting,
}

class OtaController extends ChangeNotifier {
  OtaController({
    required this.service,
    required this.readRegister,
    FirmwareOtaService? firmwareService,
  }) : firmwareService =
           firmwareService ??
           FirmwareOtaService(transport: ModbusOtaTransport());
  static final instance = OtaController(
    service: OtaService(
      config: OtaConfig.environment(),
      gateway: AndroidUpdateGateway(),
    ),
    readRegister: const ModbusRtuService().readHoldingRegister,
  );
  final OtaService service;
  final FirmwareOtaService firmwareService;
  int? boardErrorCode;
  final Future<int> Function(int) readRegister;
  InstalledApp? installed;
  OtaManifest? manifest;
  int? boardVersion;
  OtaPhase phase = OtaPhase.idle;
  String? errorKey;
  String? noticeKey;
  double progress = 0;
  CancelToken? _cancelToken;
  bool _disposed = false;
  bool _refreshing = false;
  bool _resuming = false;
  static const _permissionRequestKey = 'ota_permission_app_request';
  bool get checking => _refreshing || phase == OtaPhase.checking;
  String? _promptedRelease;
  DateTime? checkedAt;
  bool get busy => {
    OtaPhase.checkingDevice,
    OtaPhase.downloading,
    OtaPhase.verifying,
    OtaPhase.installing,
    OtaPhase.installRequested,
    OtaPhase.transferring,
    OtaPhase.boardVerifying,
    OtaPhase.boardInstalling,
    OtaPhase.boardReconnecting,
  }.contains(phase);
  bool get canCancel =>
      phase == OtaPhase.downloading ||
      phase == OtaPhase.verifying ||
      phase == OtaPhase.transferring ||
      phase == OtaPhase.boardVerifying;
  bool get appAvailable =>
      installed != null &&
      manifest?.app?.isNewerThan(installed!.versionCode) == true;
  bool get firmwareAvailable =>
      boardVersion != null && manifest?.firmware != null;
  String get phaseKey => switch (phase) {
    OtaPhase.transferring => 'ota_board_transferring',
    OtaPhase.boardVerifying => 'ota_board_verifying',
    OtaPhase.boardInstalling => 'ota_board_installing',
    OtaPhase.boardReconnecting => 'ota_board_reconnecting',
    OtaPhase.idle => 'ota_idle',
    OtaPhase.checking => 'ota_checking',
    OtaPhase.checkingDevice => 'ota_checking_device',
    OtaPhase.downloading => 'ota_downloading',
    OtaPhase.verifying => 'ota_verifying',
    OtaPhase.installing => 'ota_opening_installer',
    OtaPhase.installRequested => 'ota_install_requested',
    OtaPhase.needsPermission => 'ota_needs_permission',
    OtaPhase.success => noticeKey ?? 'ota_success',
    OtaPhase.error => errorKey ?? 'ota_failed',
  };
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  String _error(Object error) =>
      error is PlatformException && error.code == 'OTA_INVALID_APK'
      ? (error.message?.contains('signing certificate') == true
            ? 'ota_signature_mismatch'
            : 'ota_apk_invalid')
      : error is PlatformException && error.code == 'OTA_INSTALL_ERROR'
      ? 'ota_installer_unavailable'
      : error is OtaFailure
      ? error.key
      : error is MissingPluginException
      ? 'ota_android_only'
      : error is DioException && CancelToken.isCancel(error)
      ? 'ota_cancelled'
      : 'ota_failed';
  Future<void> metadata({bool confirmInstall = false}) async {
    try {
      installed = await service.gateway.installedApp();
      final preferences = await SharedPreferences.getInstance();
      final expected = preferences.getInt('ota_pending_app_code');
      if (expected != null && (!busy || confirmInstall)) {
        if (installed!.versionCode == expected) {
          phase = OtaPhase.success;
          noticeKey = 'ota_success';
        } else {
          noticeKey = 'ota_install_not_completed';
        }
        await preferences.remove('ota_pending_app_code');
      }
      _notify();
    } catch (error) {
      errorKey = _error(error);
      _notify();
    }
  }

  Future<void> restore() async {
    await metadata();
    if (!_disposed) await resume();
  }

  Future<void> refresh() async {
    if (busy || checking || _disposed) return;
    _refreshing = true;
    manifest = null;
    phase = OtaPhase.checking;
    errorKey = null;
    _notify();
    try {
      await metadata();
      if (installed == null) throw const OtaFailure('ota_android_only');
      if (!service.config.configured) {
        throw const OtaFailure('ota_not_configured');
      }
      final check = await service.check();
      installed = check.installed;
      manifest = check.manifest;
      checkedAt = DateTime.now();
      phase = noticeKey == 'ota_success' ? OtaPhase.success : OtaPhase.idle;
    } catch (error) {
      errorKey = _error(error);
      phase = OtaPhase.error;
    }
    try {
      boardVersion = await readRegister(0x0002);
    } catch (_) {
      boardVersion = null;
    }
    _refreshing = false;
    _notify();
  }

  bool takePrompt() {
    // 相同版本仍可手动重装，但不在每次启动时提醒重装当前版本。
    final promptFirmware =
        firmwareAvailable &&
        manifest!.firmware!.versionRegister != boardVersion;
    final signature =
        '${appAvailable ? manifest!.app!.versionCode : 0}:${promptFirmware ? manifest!.firmware!.versionRegister : 0}:$boardVersion';
    if (busy ||
        (!appAvailable && !promptFirmware) ||
        _promptedRelease == signature) {
      return false;
    }
    _promptedRelease = signature;
    return true;
  }

  Future<void> updateApp() async {
    final release = manifest?.app;
    if (busy || checking || !appAvailable || release == null || _disposed) {
      return;
    }
    await _updateApp(release);
  }

  // 权限设置可能重建 Activity，所以只保存用户已确认的版本资料，不保存任意文件路径。
  Future<void> _requestInstallPermission(AppRelease release) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _permissionRequestKey,
      jsonEncode({
        'channel': service.config.channel,
        'version': release.version,
        'version_code': release.versionCode,
        'package_name': release.packageName,
        'url': release.url.toString(),
        'size': release.size,
        'sha256': release.sha256,
      }),
    );
    phase = OtaPhase.needsPermission;
    _notify();
    await service.gateway.openInstallPermission();
  }

  Future<void> _updateApp(
    AppRelease release, {
    bool resumingPermission = false,
  }) async {
    phase = OtaPhase.checkingDevice;
    errorKey = null;
    noticeKey = null;
    progress = 0;
    _notify();
    _cancelToken = CancelToken();
    try {
      int state;
      try {
        state = await readRegister(0x0006);
      } catch (_) {
        throw const OtaFailure('ota_device_unavailable');
      }
      if (state != 0) throw const OtaFailure('ota_device_busy');
      // 没授权时先去设置，不再下载数百 MB 后才发现无法安装。
      if (!await service.gateway.canInstallPackages()) {
        await _requestInstallPermission(release);
        return;
      }
      await service.gateway.keepAwake(true);
      // download 会先校验缓存；只有真的请求网络时才显示下载 0%。
      phase = OtaPhase.verifying;
      _notify();
      final file = await service.download(
        release,
        cancelToken: _cancelToken,
        onProgress: (value) {
          progress = value;
          phase = value >= 1 ? OtaPhase.verifying : OtaPhase.downloading;
          _notify();
        },
      );
      if (_cancelToken!.isCancelled) throw const OtaFailure('ota_cancelled');
      phase = OtaPhase.installing;
      _notify();
      if (await readRegister(0x0006) != 0) {
        throw const OtaFailure('ota_device_busy');
      }
      // Persist before opening the installer: replacing this process can kill Dart immediately.
      final preferences = await SharedPreferences.getInstance();
      await preferences.setInt('ota_pending_app_code', release.versionCode);
      final action = await service.install(file, release);
      if (action == InstallAction.needsPermission) {
        await preferences.remove('ota_pending_app_code');
        await _requestInstallPermission(release);
      } else {
        await preferences.remove(_permissionRequestKey);
        phase = OtaPhase.installRequested;
      }
    } catch (error) {
      await (await SharedPreferences.getInstance()).remove(
        'ota_pending_app_code',
      );
      // 冷启动串口尚未就绪、或主板仍忙时保留授权后续任务；不绕过空闲检查。
      final waitingForBoard =
          error is OtaFailure &&
          {'ota_device_busy', 'ota_device_unavailable'}.contains(error.key);
      if (!resumingPermission || !waitingForBoard) {
        await (await SharedPreferences.getInstance()).remove(
          _permissionRequestKey,
        );
      }
      errorKey = _error(error);
      phase = OtaPhase.error;
    } finally {
      _cancelToken = null;
      try {
        await service.gateway.keepAwake(false);
      } catch (_) {}
      _notify();
    }
  }

  Future<void> updateFirmware() async {
    final release = manifest?.firmware;
    if (busy ||
        checking ||
        !firmwareAvailable ||
        release == null ||
        _disposed) {
      return;
    }
    phase = OtaPhase.checkingDevice;
    errorKey = null;
    noticeKey = null;
    boardErrorCode = null;
    progress = 0;
    _notify();
    _cancelToken = CancelToken();
    try {
      if (await readRegister(0x0006) != 0) {
        throw const OtaFailure('ota_device_busy');
      }
      await service.gateway.keepAwake(true);
      phase = OtaPhase.downloading;
      _notify();
      final file = await service.download(
        release,
        cancelToken: _cancelToken,
        onProgress: (value) {
          progress = value;
          phase = value >= 1 ? OtaPhase.verifying : OtaPhase.downloading;
          _notify();
        },
      );
      var completionNotice = 'ota_board_success';
      await firmwareService.upgrade(
        file,
        release,
        cancelToken: _cancelToken,
        onProgress: (value) {
          progress = value;
          _notify();
        },
        onPhase: (value) {
          if (value == 'ota_board_reinstall_unverified') {
            completionNotice = value;
          }
          phase = switch (value) {
            'ota_board_transferring' => OtaPhase.transferring,
            'ota_board_verifying' => OtaPhase.boardVerifying,
            'ota_board_installing' => OtaPhase.boardInstalling,
            'ota_board_reconnecting' => OtaPhase.boardReconnecting,
            'ota_board_success' => OtaPhase.boardReconnecting,
            _ => OtaPhase.checkingDevice,
          };
          if (phase == OtaPhase.transferring) progress = 0;
          _notify();
        },
      );
      boardVersion = release.versionRegister;
      noticeKey = completionNotice;
      phase = OtaPhase.success;
    } catch (error) {
      if (error is FirmwareOtaFailure) boardErrorCode = error.errorCode;
      errorKey = _error(error);
      phase = OtaPhase.error;
    } finally {
      _cancelToken = null;
      try {
        await service.gateway.keepAwake(false);
      } catch (_) {}
      _notify();
    }
  }

  void cancel() {
    if (canCancel) _cancelToken?.cancel();
  }

  Future<void> resume() async {
    if (_disposed ||
        _resuming ||
        checking ||
        (busy && phase != OtaPhase.installRequested)) {
      return;
    }
    _resuming = true;
    try {
      if (phase == OtaPhase.installRequested) {
        await metadata(confirmInstall: true);
        if (phase == OtaPhase.installRequested) phase = OtaPhase.idle;
        return;
      }
      final preferences = await SharedPreferences.getInstance();
      final saved = preferences.getString(_permissionRequestKey);
      if (saved == null) return;
      try {
        if (saved.length > 16 * 1024) throw const FormatException();
        final value = jsonDecode(saved);
        if (value is! Map || value['channel'] != service.config.channel) {
          throw const FormatException();
        }
        installed = await service.gateway.installedApp();
        final release = AppRelease.parse(
          value,
          packageName: installed!.packageName,
          allowHttp: service.config.allowHttp,
        );
        if (!release.isNewerThan(installed!.versionCode)) {
          await preferences.remove(_permissionRequestKey);
          phase = OtaPhase.idle;
          return;
        }
        phase = OtaPhase.needsPermission;
        // 用户未打开开关时只显示提示，不反复把人送回系统设置。
        if (!await service.gateway.canInstallPackages()) return;
        // 重新确认主板空闲、文件 SHA256、包名和签名；缓存正确时无网络下载。
        await _updateApp(release, resumingPermission: true);
      } on FormatException {
        await preferences.remove(_permissionRequestKey);
        throw const OtaFailure('ota_invalid_manifest');
      }
    } catch (error) {
      errorKey = _error(error);
      phase = OtaPhase.error;
    } finally {
      _resuming = false;
      _notify();
    }
  }

  Future<void> openInstallPermission() async {
    try {
      if (await service.gateway.canInstallPackages()) {
        await resume();
      } else {
        await service.gateway.openInstallPermission();
      }
    } catch (error) {
      errorKey = _error(error);
      phase = OtaPhase.error;
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelToken?.cancel();
    service.dispose();
    super.dispose();
  }
}
