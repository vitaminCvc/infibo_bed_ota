import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/ota/ota_manifest.dart';

void main() {
  Map<String, Object?> data() => {
    'version': '1.2.0',
    'version_code': 2,
    'package_name': 'com.infibo.app.global',
    'url': 'https://example.com/app.apk',
    'size': 32,
    'sha256': 'a' * 64,
    'notes': '中文说明',
    'notes_i18n': {
      'zh_CN': '中文说明',
      'en_US': 'Fixes',
      'pl_PL': 'Poprawki',
      'pt_PT': 'Correções',
    },
  };
  AppRelease parse(Map<String, Object?> value) =>
      AppRelease.parse(value, packageName: 'com.infibo.app.global');
  test(
    'selects current language, accepts locale separators and region fallback',
    () {
      final release = parse(data());
      expect(release.notesFor('pl_PL'), 'Poprawki');
      expect(release.notesFor('pl-PL'), 'Poprawki');
      expect(release.notesFor('pt_BR'), 'Correções');
      expect(release.notesFor('zh_CN'), '中文说明');
      expect(release.notesFor('de_DE'), 'Fixes');
      expect(release.notesFor(null), 'Fixes');
    },
  );
  test(
    'old manifests and missing or invalid optional translations retain raw notes',
    () {
      for (final translations in [
        null,
        'invalid',
        {'pl_PL': 123},
        {'pl_PL': ' '},
        {'xx': 'bad'},
      ]) {
        final value = data()..['notes_i18n'] = translations;
        expect(parse(value).notesFor('pl_PL'), '中文说明');
      }
    },
  );
  test(
    'corrupt optional entry does not discard valid translations or the update',
    () {
      final value = data()
        ..['notes_i18n'] = {
          'pl_PL': 123,
          'en_US': 'Fixes',
          'de_DE': 'a' * 10001,
        };
      expect(parse(value).notesFor('pl_PL'), 'Fixes');
    },
  );
  test('firmware uses the same language selection', () {
    final value = data()
      ..remove('version_code')
      ..remove('package_name');
    value.addAll({
      'product': 'Immortal-Main-Board',
      'firmware_register': '0x0120',
      'crc32': '0x12345678',
      'file': 'board_APP_OTA.bin',
    });
    expect(FirmwareRelease.parse(value).notesFor('pl_PL'), 'Poprawki');
  });
}
