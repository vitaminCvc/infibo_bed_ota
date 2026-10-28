import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/config/app_brand.dart';
import 'package:infibo_app/ota/ota_config.dart';

void main() {
  tearDown(() => AppBrand.configure(AppBrands.global));
  test('UAE direct launch uses its private HTTPS manifest', () {
    AppBrand.configure(AppBrands.uaeBiohackn);
    final config = OtaConfig.environment();
    expect(AppBrand.current.supportsOtaUpdates, isTrue);
    expect(config.channel, 'uae_biohackn');
    expect(
      config.uri.toString(),
      'https://ota.infibo.net/ota/uae-biohackn.json',
    );
    expect(config.allowHttp, isFalse);
  });
  test(
    'existing brands retain their OTA enablement and environment defaults',
    () {
      for (final brand in [
        AppBrands.global,
        AppBrands.india,
        AppBrands.spain,
        AppBrands.turkey,
        AppBrands.america,
        AppBrands.britain,
        AppBrands.australia,
      ]) {
        AppBrand.configure(brand);
        expect(brand.supportsOtaUpdates, brand.flavor == 'global');
        expect(OtaConfig.environment().channel, 'official');
        expect(OtaConfig.environment().configured, isFalse);
      }
    },
  );
}
