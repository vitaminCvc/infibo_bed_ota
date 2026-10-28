import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/ota/ota_manifest.dart';

Map<String, Object?> release({int code = 2}) => {
  'schema': 1,
  'channel': 'official',
  'app': {
    'version': '1.1.0',
    'version_code': code,
    'package_name': 'com.infibo.app.global',
    'url': 'https://updates.example/app.apk',
    'size': 32,
    'sha256': 'a' * 64,
    'notes': 'Fixes',
  },
};
OtaManifest parse(Map<String, Object?> value) => OtaManifest.parse(
  value,
  channel: 'official',
  packageName: 'com.infibo.app.global',
);

void main() {
  test(
    'UAE channel accepts its own package and rejects other packages/channels',
    () {
      Map<String, Object?> uae() {
        final value = release()..['channel'] = 'uae_biohackn';
        (value['app'] as Map)['package_name'] = 'com.infibo.app.uae.biohackn';
        return value;
      }

      OtaManifest parseUae(Map<String, Object?> value) => OtaManifest.parse(
        value,
        channel: 'uae_biohackn',
        packageName: 'com.infibo.app.uae.biohackn',
      );
      expect(parseUae(uae()).app!.packageName, 'com.infibo.app.uae.biohackn');
      expect(() => parseUae(release()), throwsFormatException);
      final wrong = uae();
      (wrong['app'] as Map)['package_name'] = 'com.infibo.app.global';
      expect(() => parseUae(wrong), throwsFormatException);
      expect(
        parseUae({
          'schema': 1,
          'channel': 'uae_biohackn',
          'app': null,
          'firmware': null,
        }).app,
        isNull,
      );
    },
  );

  test('rejects non application OTA firmware names including Bootloader', () {
    for (final filename in [
      'board.bin',
      '厂家固件.BIN',
      'Immortal-Main-Bootloader-OTA-v1.3.1.bin',
    ]) {
      expect(
        () => FirmwareRelease.parse({
          'product': 'Immortal-Main-Board',
          'version': '1.3.1',
          'firmware_register': '0x0131',
          'file': filename,
          'url': 'https://updates.example/file.bin',
          'size': 32,
          'sha256': 'b' * 64,
          'crc32': '0x2F599FDA',
        }),
        throwsFormatException,
      );
    }
  });

  test(
    'software update compares numeric build code rather than display version',
    () {
      expect(parse(release()).app!.isNewerThan(1), isTrue);
      expect(parse(release()).app!.isNewerThan(2), isFalse);
      expect(parse(release(code: 1)).app!.isNewerThan(3), isFalse);
    },
  );
  test('rejects wrong channel and wrong package', () {
    expect(
      () => parse(release()..['channel'] = 'china_test'),
      throwsFormatException,
    );
    final wrong = release();
    (wrong['app'] as Map)['package_name'] = 'com.infibo.app.india';
    expect(() => parse(wrong), throwsFormatException);
  });
  test('rejects unsafe URLs, bad hashes and invalid sizes', () {
    for (final entry in <MapEntry<String, Object>>[
      const MapEntry('url', 'http://updates.example/app.apk'),
      const MapEntry('url', 'file:///sdcard/app.apk'),
      const MapEntry('url', 'https://user:password@updates.example/app.apk'),
      const MapEntry('sha256', 'abc'),
      const MapEntry('size', 0),
      const MapEntry('size', 1024 * 1024 * 1024),
      const MapEntry('version_code', 0),
    ]) {
      final bad = release();
      (bad['app'] as Map)[entry.key] = entry.value;
      expect(
        () => parse(bad),
        throwsFormatException,
        reason: '${entry.key}: ${entry.value}',
      );
    }
  });
  test(
    'parses board manifest and verifies version register agrees with version',
    () {
      final value = release()
        ..['firmware'] = {
          'product': 'Immortal-Main-Board',
          'version': '1.2.5',
          'firmware_register': '0x0125',
          'url': 'https://updates.example/main_APP_OTA.bin',
          'size': 27492,
          'sha256': 'b' * 64,
          'crc32': '0x2F599FDA',
        };
      final board = parse(value).firmware!;
      expect(board.versionRegister, 0x0125);
      expect(board.crc32, 0x2f599fda);
      (value['firmware'] as Map)['firmware_register'] = '0x0124';
      expect(() => parse(value), throwsFormatException);
    },
  );
  test('empty manifest is not a fabricated available update', () {
    final empty = parse({'schema': 1, 'channel': 'official'});
    expect(empty.app, isNull);
    expect(empty.firmware, isNull);
  });
  test('only explicit test opt-in allows HTTP', () {
    final value = release();
    (value['app'] as Map)['url'] = 'http://localhost/app.apk';
    expect(
      OtaManifest.parse(
        value,
        channel: 'official',
        packageName: 'com.infibo.app.global',
        allowHttp: true,
      ).app,
      isNotNull,
    );
  });
}
