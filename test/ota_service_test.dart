import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/ota/android_update_gateway.dart';
import 'package:infibo_app/ota/ota_config.dart';
import 'package:infibo_app/ota/ota_manifest.dart';
import 'package:infibo_app/ota/ota_service.dart';

class FakeUpdateGateway implements UpdateGateway {
  FakeUpdateGateway(this.directory);
  final Directory directory;
  int installations = 0;
  @override
  Future<InstalledApp> installedApp() async => const InstalledApp(
    packageName: 'com.infibo.app.global',
    version: '1.0.0',
    versionCode: 1,
  );
  @override
  Future<String> cacheDirectory() async => directory.path;
  @override
  Future<InstallAction> install(File file, AppRelease release) async {
    installations++;
    return InstallAction.requested;
  }

  @override
  Future<void> openInstallPermission() async {}
  @override
  Future<void> keepAwake(bool enabled) async {}
}

void main() {
  late HttpServer server;
  late Directory directory;
  late FakeUpdateGateway gateway;
  late OtaService service;
  final data = List<int>.generate(300, (i) => i & 0xff);
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('infibo-ota-test-');
    gateway = FakeUpdateGateway(directory);
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      if (request.uri.path == '/redirect') {
        request.response.statusCode = 302;
        request.response.headers.set('Location', '/file');
      } else {
        request.response.add(data);
      }
      await request.response.close();
    });
    service = OtaService(
      config: const OtaConfig(allowHttp: true),
      gateway: gateway,
    );
  });
  tearDown(() async {
    service.dispose();
    await server.close(force: true);
    await directory.delete(recursive: true);
  });
  AppRelease release({int? size, String? hash, String path = '/file'}) =>
      AppRelease(
        version: '1.1.0',
        versionCode: 2,
        packageName: 'com.infibo.app.global',
        url: Uri.parse('http://127.0.0.1:${server.port}$path'),
        size: size ?? data.length,
        sha256: hash ?? sha256.convert(data).toString(),
      );
  test(
    'downloads and verifies complete bytes without installing automatically',
    () async {
      final file = await service.download(release());
      expect(await file.readAsBytes(), data);
      expect(gateway.installations, 0);
      expect(
        directory.listSync().where((f) => f.path.endsWith('.part')),
        isEmpty,
      );
      expect(await service.install(file, release()), InstallAction.requested);
      expect(gateway.installations, 1);
    },
  );
  test(
    'wrong hash and wrong length remove partial files and never install',
    () async {
      for (final bad in [
        release(hash: 'a' * 64),
        release(size: 301),
        release(size: 10),
      ]) {
        await expectLater(service.download(bad), throwsA(isA<OtaFailure>()));
        expect(gateway.installations, 0);
        expect(
          directory.listSync().where((f) => f.path.endsWith('.part')),
          isEmpty,
        );
      }
    },
  );
  test('cancellation does not produce an installable package', () async {
    final token = CancelToken();
    await expectLater(
      service.download(
        release(),
        cancelToken: token,
        onProgress: (value) {
          token.cancel();
        },
      ),
      throwsA(isA<OtaFailure>()),
    );
    expect(gateway.installations, 0);
    expect(directory.listSync(), isEmpty);
  });
  test(
    'rejects redirected downloads rather than trusting a changed transport',
    () async {
      await expectLater(
        service.download(release(path: '/redirect')),
        throwsA(isA<OtaFailure>()),
      );
    },
  );
  test('rechecks downloaded package before invoking installer', () async {
    final file = await service.download(release());
    await file.writeAsBytes([1, 2, 3]);
    await expectLater(
      service.install(file, release()),
      throwsA(isA<OtaFailure>()),
    );
    expect(gateway.installations, 0);
  });
  test(
    'cancellation also stops a verified cached package from proceeding',
    () async {
      final cached = await service.download(release());
      final token = CancelToken();
      await expectLater(
        service.download(
          release(),
          cancelToken: token,
          onProgress: (_) {
            token.cancel();
          },
        ),
        throwsA(
          isA<OtaFailure>().having((e) => e.key, 'reason', 'ota_cancelled'),
        ),
      );
      expect(await cached.exists(), isTrue);
      expect(gateway.installations, 0);
    },
  );
  test('missing service configuration fails explicitly', () async {
    await expectLater(
      service.check(),
      throwsA(
        isA<OtaFailure>().having((e) => e.key, 'reason', 'ota_not_configured'),
      ),
    );
  });
}
