import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:infibo_app/ota/android_update_gateway.dart';
import 'package:infibo_app/ota/ota_config.dart';
import 'package:infibo_app/ota/ota_manifest.dart';
import 'package:infibo_app/ota/ota_service.dart';
import 'package:infibo_app/ota/ota_controller.dart';

class TestGateway implements UpdateGateway {
  bool permission = true;
  int permissionScreens = 0;
  @override
  Future<bool> canInstallPackages() async => permission;
  int code = 1;
  String version = '1.0.0';
  int installs = 0;
  final awake = <bool>[];
  InstallAction action = InstallAction.requested;
  @override
  Future<InstalledApp> installedApp() async => InstalledApp(
    packageName: 'com.infibo.app.global',
    version: version,
    versionCode: code,
  );
  @override
  Future<String> cacheDirectory() async => Directory.systemTemp.path;
  @override
  Future<InstallAction> install(File file, AppRelease release) async {
    installs++;
    return action;
  }

  @override
  Future<void> keepAwake(bool value) async {
    awake.add(value);
  }

  @override
  Future<void> openInstallPermission() async {
    permissionScreens++;
  }
}

class TestService extends OtaService {
  TestService(TestGateway gateway)
    : super(
        config: const OtaConfig(manifestUrl: 'https://example.test/manifest'),
        gateway: gateway,
      );
  final release = AppRelease(
    version: '1.1.0',
    url: Uri.parse('https://example.test/app.apk'),
    size: 3,
    sha256: 'a' * 64,
    versionCode: 2,
    packageName: 'com.infibo.app.global',
  );
  Completer<File>? pendingDownload;
  int downloads = 0;
  int checks = 0;
  OtaManifest? publishedManifest;
  @override
  Future<UpdateCheck> check() async {
    checks++;
    return UpdateCheck(
      await gateway.installedApp(),
      publishedManifest ?? OtaManifest(app: release),
    );
  }

  @override
  Future<File> download(
    OtaFile release, {
    CancelToken? cancelToken,
    void Function(double)? onProgress,
  }) async {
    downloads++;
    if (pendingDownload == null) return File('verified-test.apk');
    return Future.any([
      pendingDownload!.future,
      cancelToken!.whenCancel.then<File>(
        (_) => throw const OtaFailure('ota_cancelled'),
      ),
    ]);
  }

  @override
  Future<InstallAction> install(File file, AppRelease release) =>
      gateway.install(file, release);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late TestGateway gateway;
  late TestService service;
  late OtaController controller;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    gateway = TestGateway();
    service = TestService(gateway);
    controller = OtaController(
      service: service,
      readRegister: (address) async => address == 2 ? 0x0124 : 0,
    );
  });
  tearDown(() => controller.dispose());
  test(
    'requests permission before downloading and resumes after granting it',
    () async {
      gateway.permission = false;
      await controller.refresh();
      await controller.updateApp();
      expect(service.downloads, 0);
      expect(gateway.installs, 0);
      expect(gateway.permissionScreens, 1);
      expect(controller.phase, OtaPhase.needsPermission);
      await controller.resume();
      expect(gateway.permissionScreens, 1);
      expect(service.downloads, 0);
      gateway.permission = true;
      await controller.resume();
      expect(service.downloads, 1);
      expect(gateway.installs, 1);
      expect(controller.phase, OtaPhase.installRequested);
    },
  );
  test('permission continuation survives controller recreation', () async {
    gateway.permission = false;
    await controller.refresh();
    await controller.updateApp();
    controller.dispose();
    gateway.permission = true;
    service = TestService(gateway);
    controller = OtaController(service: service, readRegister: (_) async => 0);
    await controller.metadata();
    await controller.resume();
    expect(service.downloads, 1);
    expect(gateway.installs, 1);
    expect(controller.phase, OtaPhase.installRequested);
  });
  test(
    'resuming after permission still checks that the board is idle',
    () async {
      gateway.permission = false;
      await controller.refresh();
      await controller.updateApp();
      controller.dispose();
      gateway.permission = true;
      service = TestService(gateway);
      controller = OtaController(
        service: service,
        readRegister: (_) async => 1,
      );
      await controller.resume();
      expect(service.downloads, 0);
      expect(gateway.installs, 0);
      expect(controller.errorKey, 'ota_device_busy');
    },
  );
  test('duplicate resume events start only one continuation', () async {
    gateway.permission = false;
    await controller.refresh();
    await controller.updateApp();
    gateway.permission = true;
    service.pendingDownload = Completer<File>();
    final first = controller.resume();
    await Future<void>.delayed(Duration.zero);
    await controller.resume();
    expect(service.downloads, 1);
    service.pendingDownload!.complete(File('verified-test.apk'));
    await first;
    expect(gateway.installs, 1);
  });
  test(
    'corrupted saved permission request never installs or downloads',
    () async {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString('ota_permission_app_request', '{invalid');
      await controller.resume();
      expect(service.downloads, 0);
      expect(gateway.installs, 0);
      expect(controller.errorKey, 'ota_invalid_manifest');
      expect(preferences.getString('ota_permission_app_request'), isNull);
    },
  );
  test(
    'permission continuation survives board startup and resumes when idle',
    () async {
      gateway.permission = false;
      await controller.refresh();
      await controller.updateApp();
      controller.dispose();
      gateway.permission = true;
      var ready = false;
      service = TestService(gateway);
      controller = OtaController(
        service: service,
        readRegister: (_) async {
          if (!ready) throw const OtaFailure('ota_device_unavailable');
          return 0;
        },
      );
      await controller.resume();
      expect(controller.errorKey, 'ota_device_unavailable');
      expect(gateway.installs, 0);
      ready = true;
      await controller.resume();
      expect(service.downloads, 1);
      expect(gateway.installs, 1);
      expect(controller.phase, OtaPhase.installRequested);
    },
  );
  test(
    'metadata cannot consume install confirmation while install is in flight',
    () async {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setInt('ota_pending_app_code', 2);
      controller.phase = OtaPhase.installing;
      await controller.metadata();
      expect(preferences.getInt('ota_pending_app_code'), 2);
    },
  );
  test(
    'checking updates blocks starting an installation from stale metadata',
    () async {
      await controller.refresh();
      controller.phase = OtaPhase.checking;
      await controller.updateApp();
      expect(service.downloads, 0);
      expect(gateway.installs, 0);
    },
  );
  test(
    'published board target permits newer, equal and lower versions without equal-version prompts',
    () async {
      await controller.refresh();
      controller.manifest = OtaManifest(
        firmware: FirmwareRelease(
          version: '1.2.5',
          url: Uri.parse('https://example.test/main_APP_OTA.bin'),
          size: 10,
          sha256: 'a' * 64,
          versionRegister: 0x0125,
          crc32: 0,
        ),
      );
      expect(controller.firmwareAvailable, isTrue);
      expect(controller.takePrompt(), isTrue);
      expect(controller.takePrompt(), isFalse);
      controller.boardVersion = 0x0125;
      expect(controller.firmwareAvailable, isTrue);
      expect(controller.takePrompt(), isFalse);
      controller.boardVersion = 0x0130;
      expect(controller.firmwareAvailable, isTrue);
      expect(controller.takePrompt(), isTrue);
      controller.boardVersion = null;
      expect(controller.firmwareAvailable, isFalse);
    },
  );
  test('checks versions and prompts once per release in a session', () async {
    await controller.refresh();
    expect(controller.appAvailable, isTrue);
    expect(controller.boardVersion, 0x0124);
    expect(controller.takePrompt(), isTrue);
    expect(controller.takePrompt(), isFalse);
  });
  test('rejects update while the board reports running', () async {
    controller.dispose();
    controller = OtaController(
      service: service,
      readRegister: (address) async => 1,
    );
    await controller.refresh();
    await controller.updateApp();
    expect(service.downloads, 0);
    expect(gateway.installs, 0);
    expect(controller.errorKey, 'ota_device_busy');
  });
  test(
    'duplicate clicks cannot start a second download and cancellation releases resources',
    () async {
      await controller.refresh();
      service.pendingDownload = Completer<File>();
      final operation = controller.updateApp();
      await Future<void>.delayed(Duration.zero);
      expect(controller.busy, isTrue);
      await controller.updateApp();
      expect(service.downloads, 1);
      controller.cancel();
      await operation;
      expect(gateway.installs, 0);
      expect(controller.busy, isFalse);
      expect(gateway.awake.last, isFalse);
    },
  );
  test(
    'requesting installation is not success; resume verifies actual installed code',
    () async {
      await controller.refresh();
      await controller.updateApp();
      expect(gateway.installs, 1);
      expect(controller.phase, OtaPhase.installRequested);
      expect(controller.busy, isTrue);
      gateway.code = 2;
      await controller.resume();
      expect(controller.phase, OtaPhase.success);
      expect(controller.busy, isFalse);
      expect(controller.appAvailable, isFalse);
    },
  );
  test(
    'permission is actionable and is not recorded as a completed installation',
    () async {
      gateway.action = InstallAction.needsPermission;
      await controller.refresh();
      await controller.updateApp();
      expect(controller.phase, OtaPhase.needsPermission);
      expect(controller.busy, isFalse);
      expect(
        (await SharedPreferences.getInstance()).getInt('ota_pending_app_code'),
        isNull,
      );
    },
  );
}
