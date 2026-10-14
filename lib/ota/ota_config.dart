import 'ota_manifest.dart';

class OtaConfig {
  const OtaConfig({
    this.channel = 'official',
    this.manifestUrl = '',
    this.allowHttp = false,
  });
  factory OtaConfig.environment() => const OtaConfig(
    channel: String.fromEnvironment('OTA_CHANNEL', defaultValue: 'official'),
    manifestUrl: String.fromEnvironment('OTA_MANIFEST_URL'),
    allowHttp: bool.fromEnvironment('OTA_ALLOW_HTTP', defaultValue: false),
  );
  final String channel;
  final String manifestUrl;
  final bool allowHttp;
  bool get configured => manifestUrl.trim().isNotEmpty;
  Uri get uri => checkedOtaUrl(manifestUrl, allowHttp: allowHttp);
}
