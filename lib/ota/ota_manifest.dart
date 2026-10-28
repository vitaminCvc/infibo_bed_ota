const maxOtaFileSize = 512 * 1024 * 1024;

Uri checkedOtaUrl(Object? value, {bool allowHttp = false}) {
  if (value is! String) throw const FormatException('Invalid update URL');
  final uri = Uri.tryParse(value);
  if (uri == null ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty ||
      uri.fragment.isNotEmpty ||
      (uri.scheme != 'https' && !(allowHttp && uri.scheme == 'http'))) {
    throw const FormatException('Update URL must use HTTPS');
  }
  return uri;
}

Map<String, dynamic> _object(Object? value) {
  if (value is! Map) throw const FormatException('Invalid update metadata');
  return Map<String, dynamic>.from(value);
}

String _text(Map<String, dynamic> value, String key) {
  final text = value[key];
  if (text is! String || text.trim().isEmpty || text.length > 4096) {
    throw FormatException('Invalid $key');
  }
  return text.trim();
}

int _integer(Map<String, dynamic> value, String key, int max) {
  final number = value[key];
  if (number is! int || number < 1 || number > max) {
    throw FormatException('Invalid $key');
  }
  return number;
}

int _hex(Object? value, int max) {
  final int? number = value is int
      ? value
      : value is String
      ? (value.startsWith('0x') || value.startsWith('0X')
            ? int.tryParse(value.substring(2), radix: 16)
            : int.tryParse(value))
      : null;
  if (number == null || number < 0 || number > max) {
    throw const FormatException('Invalid register or CRC');
  }
  return number;
}

String _hash(Map<String, dynamic> value) {
  final hash = _text(value, 'sha256').toLowerCase();
  if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(hash)) {
    throw const FormatException('Invalid SHA256');
  }
  return hash;
}

String _version(Map<String, dynamic> value) {
  final version = _text(value, 'version');
  if (version.length > 48 || !RegExp(r'^\d+\.\d+\.\d+$').hasMatch(version)) {
    throw const FormatException('Invalid version');
  }
  return version;
}

String _notes(Map<String, dynamic> value) {
  final notes = value['notes'] ?? '';
  if (notes is! String || notes.length > 10000) {
    throw const FormatException('Invalid release notes');
  }
  return notes;
}

const _notesLocales = {
  'zh_CN',
  'en_US',
  'es_ES',
  'pt_PT',
  'ru_RU',
  'pl_PL',
  'fr_FR',
  'ko_KR',
  'ar_SA',
  'de_DE',
  'tr_TR',
};

Map<String, String> _localizedNotes(Map<String, dynamic> value) {
  final raw = value['notes_i18n'];
  if (raw is! Map) return const {};
  // Optional explanatory text must never prevent an otherwise valid update.
  return Map.unmodifiable({
    for (final entry in raw.entries)
      if (_notesLocales.contains(entry.key) &&
          entry.value is String &&
          (entry.value as String).trim().isNotEmpty &&
          (entry.value as String).length <= 10000)
        entry.key as String: entry.value as String,
  });
}

class OtaFile {
  const OtaFile({
    required this.version,
    required this.url,
    required this.size,
    required this.sha256,
    this.notes = '',
    this.notesI18n = const {},
  });
  final String version;
  final Uri url;
  final int size;
  final String sha256;
  final String notes;
  final Map<String, String> notesI18n;

  String notesFor(String? locale) {
    final normalized = locale?.replaceAll('-', '_').toLowerCase();
    String? languageMatch;
    for (final entry in notesI18n.entries) {
      final key = entry.key.toLowerCase();
      if (normalized == key && entry.value.trim().isNotEmpty) {
        return entry.value;
      }
      if (normalized != null &&
          key.split('_').first == normalized.split('_').first &&
          entry.value.trim().isNotEmpty) {
        languageMatch = entry.value;
      }
    }
    if (languageMatch != null) return languageMatch;
    final english = notesI18n['en_US'];
    return english != null && english.trim().isNotEmpty ? english : notes;
  }
}

// 应用的更新发布信息
class AppRelease extends OtaFile {
  const AppRelease({
    required super.version,
    required super.url,
    required super.size,
    required super.sha256,
    super.notes,
    super.notesI18n,
    required this.versionCode,
    required this.packageName,
  });
  final int versionCode;
  final String packageName;
  bool isNewerThan(int installedCode) => versionCode > installedCode;

  factory AppRelease.parse(
    Object? json, {
    required String packageName,
    bool allowHttp = false,
  }) {
    final value = _object(json);
    final targetPackage = _text(value, 'package_name');
    if (targetPackage != packageName) {
      throw const FormatException('Update package does not match this app');
    }
    return AppRelease(
      version: _version(value),
      url: checkedOtaUrl(value['url'], allowHttp: allowHttp),
      size: _integer(value, 'size', maxOtaFileSize),
      sha256: _hash(value),
      notes: _notes(value),
      notesI18n: _localizedNotes(value),
      versionCode: _integer(value, 'version_code', 0x7fffffff),
      packageName: targetPackage,
    );
  }
}

class FirmwareRelease extends OtaFile {
  const FirmwareRelease({
    required super.version,
    required super.url,
    required super.size,
    required super.sha256,
    super.notes,

    super.notesI18n,
    required this.versionRegister,
    required this.crc32,
  });

  final int versionRegister;
  final int crc32;
  factory FirmwareRelease.parse(Object? json, {bool allowHttp = false}) {
    final value = _object(json);
    if (value['product'] != 'Immortal-Main-Board') {
      throw const FormatException('Wrong board product');
    }
    final version = _version(value);
    final parts = version.split('.').map(int.parse).toList();
    if (parts.any((v) => v > 15)) {
      throw const FormatException('Board version cannot fit the register');
    }
    final register = _hex(value['firmware_register'], 0xffff);
    if (register != ((parts[0] << 8) | (parts[1] << 4) | parts[2])) {
      throw const FormatException('Board version register mismatch');
    }
    final url = checkedOtaUrl(value['url'], allowHttp: allowHttp);
    final filename = value['file'] ?? url.pathSegments.lastOrNull;
    if (filename is! String || !filename.endsWith('_APP_OTA.bin')) {
      throw const FormatException('Only APP_OTA.bin is supported');
    }
    return FirmwareRelease(
      version: version,
      url: url,
      size: _integer(value, 'size', 2 * 1024 * 1024),
      sha256: _hash(value),
      notes: _notes(value),
      notesI18n: _localizedNotes(value),
      versionRegister: register,
      crc32: _hex(value['crc32'], 0xffffffff),
    );
  }
}

class OtaManifest {
  const OtaManifest({this.app, this.firmware});
  final AppRelease? app;
  final FirmwareRelease? firmware;
  factory OtaManifest.parse(
    Object? json, {
    required String channel,
    required String packageName,
    bool allowHttp = false,
  }) {
    final value = _object(json);
    if (value['schema'] != 1 ||
        value['channel'] != channel ||
        !{'official', 'china_test', 'uae_biohackn'}.contains(channel)) {
      throw const FormatException('Update schema or channel mismatch');
    }
    return OtaManifest(
      app: value['app'] == null
          ? null
          : AppRelease.parse(
              value['app'],
              packageName: packageName,
              allowHttp: allowHttp,
            ),
      firmware: value['firmware'] == null
          ? null
          : FirmwareRelease.parse(value['firmware'], allowHttp: allowHttp),
    );
  }
}
