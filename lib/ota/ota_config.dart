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
    final indiaAlteon = AppBrand.current.flavor == 'india';
    final spainQvita = AppBrand.current.flavor == 'spain';
    final australiaHalsa = AppBrand.current.flavor == 'australia';
    final americaLngvty = AppBrand.current.flavor == 'america';
    final britainOmnia = AppBrand.current.flavor == 'britain';
    final turkeyOmnia = AppBrand.current.flavor == 'turkey';
    const configuredChannel = String.fromEnvironment('OTA_CHANNEL');
    const configuredUrl = String.fromEnvironment('OTA_MANIFEST_URL');
    final channel = configuredChannel.isNotEmpty
        ? configuredChannel
        : uae
        ? 'uae_biohackn'
        : indiaAlteon
        ? 'india_alteon'
        : spainQvita
        ? 'spain_qvita'
        : australiaHalsa
        ? 'australia_halsa'
        : americaLngvty
        ? 'america_lngvty'
        : britainOmnia
        ? 'britain_omnia'
        : turkeyOmnia
        ? 'turkey_omnia'
        : 'official';
    return OtaConfig(
      channel: channel,
      manifestUrl: configuredUrl.isNotEmpty
          ? configuredUrl
          : uae && channel == 'uae_biohackn'
          ? 'https://ota.infibo.net/ota/uae-biohackn.json'
          : indiaAlteon && channel == 'india_alteon'
          ? 'https://ota.infibo.net/ota/india-alteon.json'
          : spainQvita && channel == 'spain_qvita'
          ? 'https://ota.infibo.net/ota/spain-qvita.json'
          : australiaHalsa && channel == 'australia_halsa'
          ? 'https://ota.infibo.net/ota/australia-halsa.json'
          : americaLngvty && channel == 'america_lngvty'
          ? 'https://ota.infibo.net/ota/america-lngvty.json'
          : britainOmnia && channel == 'britain_omnia'
          ? 'https://ota.infibo.net/ota/britain-omnia.json'
          : turkeyOmnia && channel == 'turkey_omnia'
          ? 'https://ota.infibo.net/ota/turkey-omnia.json'
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
