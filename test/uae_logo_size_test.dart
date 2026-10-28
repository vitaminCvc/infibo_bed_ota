import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/brand_logo.dart';
import 'package:infibo_app/components/index.dart';
import 'package:infibo_app/components/settingindex.dart';
import 'package:infibo_app/config/app_brand.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/pages/settingpage/DeviceInfo.dart';
import 'package:infibo_app/stores/app_header_clock_store.dart';
import 'package:infibo_app/stores/user_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader('InfiboSettingsYaHei')
          ..addFont(rootBundle.load('assets/fonts/MicrosoftYaHei-Regular.ttf')))
        .load();
  });
  setUp(() {
    Get.testMode = true;
    Get.put(UserStore());
    Get.put<AppHeaderClockController>(_Clock());
    AppBrand.configure(AppBrands.uaeBiohackn);
  });
  tearDown(() {
    AppBrand.configure(AppBrands.global);
    Get.reset();
  });

  for (final page in ['home', 'settings', 'device']) {
    testWidgets('UAE $page preserves full SVG dimensions', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1701));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        GetMaterialApp(
          theme: ThemeData(fontFamily: 'InfiboSettingsYaHei'),
          // Keep the legacy device menu text within its fixed columns, so this
          // test isolates logo dimensions without changing any image scaling.
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(0.8)),
            child: child!,
          ),
          home: switch (page) {
            'home' => const AppHeaderPage(),
            'settings' => const AppSettingHeaderPage(),
            _ => const DeviceInfoPage(),
          },
        ),
      );
      await tester.pumpAndSettle();
      final logo = find.byWidgetPredicate(
        (w) => w is BrandLogo && w.asset == Assets.mainLogo,
      );
      expect(tester.getSize(logo), const Size(197, 54));
      expect(AppBrand.current.loginLogoSize, const Size(380, 123));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}

class _Clock extends AppHeaderClockController {
  final _time = '12:00'.obs;
  final _date = '2026.10.27'.obs;
  @override
  String get timeText => _time.value;
  @override
  String get dateText => _date.value;
  @override
  void startClock() {}
}
