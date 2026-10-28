import 'package:infibo_app/config/app_brand.dart';

import 'ota_manifest.dart';

class OtaConfig {
  const OtaConfig({
    this.channel = 'official',
    this.manifestUrl = '',
    this.allowHttp = false,
  });
  factory OtaConfig.environment() {
    final uae = AppBrand.current.flavor == 'uaeBiohackn';
    const configuredChannel = String.fromEnvironment('OTA_CHANNEL');
    const configuredUrl = String.fromEnvironment('OTA_MANIFEST_URL');
    final channel = configuredChannel.isNotEmpty
        ? configuredChannel
        : uae
        ? 'uae_biohackn'
        : 'official';
    return OtaConfig(
      channel: channel,
      manifestUrl: configuredUrl.isNotEmpty
          ? configuredUrl
          : uae && channel == 'uae_biohackn'
          ? 'https://ota.infibo.net/ota/uae-biohackn.json'
          : '',
      allowHttp: const bool.fromEnvironment(
        'OTA_ALLOW_HTTP',
        defaultValue: false,
      ),
    );
  }
  final String channel;
  final String manifestUrl;
  final bool allowHttp;
  bool get configured => manifestUrl.trim().isNotEmpty;
  Uri get uri => checkedOtaUrl(manifestUrl, allowHttp: allowHttp);
}
