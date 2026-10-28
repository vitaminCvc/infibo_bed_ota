import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infibo_app/api/dio/login/login_models.dart';
import 'package:infibo_app/components/index.dart';
import 'package:infibo_app/components/logout_menu.dart';
import 'package:infibo_app/components/settingindex.dart' as settings_header;
import 'package:infibo_app/config/app_brand.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/stores/app_header_clock_store.dart';
import 'package:infibo_app/stores/user_store.dart';
import 'package:infibo_app/translation/app_translations.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    AppBrand.configure(AppBrands.global);
    Get.put<UserStore>(UserStore());
    Get.put<AppHeaderClockController>(_StaticClockController());
  });

  tearDown(() {
    Get.reset();
    AppBrand.configure(AppBrands.global);
  });

  testWidgets('settings logo back action keeps its original bounds', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1280));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('pl', 'PL'),
        home: const settings_header.AppSettingHeaderPage(enableLogoBack: true),
      ),
    );
    await tester.pumpAndSettle();
    final logo = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName == Assets.mainLogo,
    );
    final tapTarget = find
        .ancestor(of: logo, matching: find.byType(GestureDetector))
        .first;
    expect(tester.getTopLeft(logo).dx, closeTo(48, 0.01));
    expect(tester.getSize(tapTarget).width, closeTo(242, 0.01));
  });

  for (final localeEntry in AppTranslations().keys.entries) {
    testWidgets(
      'header labels fit without moving clock or margins in ${localeEntry.key}',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1280));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final parts = localeEntry.key.split('_');

        for (final role in ['user', 'admin', 'operator']) {
          UserStore.instance.currentUser.value = LoginResult(
            id: 1,
            email: 'header@example.test',
            role: role,
          );
          await tester.pumpWidget(
            GetMaterialApp(
              translations: AppTranslations(),
              locale: Locale(parts[0], parts[1]),
              home: const AppHeaderPage(enableLogout: true),
            ),
          );
          await tester.pumpAndSettle();

          final label = find.text(localeEntry.value['settings']!);
          final settings = find
              .ancestor(of: label, matching: find.byType(GestureDetector))
              .first;
          final settingsRect = tester.getRect(settings);
          final userRect = tester.getRect(find.byType(LogoutMenu));
          final labelRect = tester.getRect(label);
          final paragraph = tester.renderObject<RenderParagraph>(label);

          expect(settingsRect.right, closeTo(756, 0.01));
          expect(settingsRect.left - userRect.right, closeTo(8, 0.01));
          expect(tester.getCenter(find.text('12:00')).dx, closeTo(400, 0.01));
          expect(tester.getTopLeft(find.text('12:00')).dy, closeTo(27.5, 0.01));
          expect(
            tester.getCenter(find.text('2026.10.23')).dx,
            closeTo(400, 0.01),
          );
          expect(
            tester.getTopLeft(find.text('2026.10.23')).dy,
            closeTo(57.5, 0.01),
          );
          expect(labelRect.right, lessThanOrEqualTo(settingsRect.right - 8));
          expect(
            labelRect.width,
            greaterThanOrEqualTo(
              paragraph.getMaxIntrinsicWidth(double.infinity) - 0.01,
            ),
          );
          expect(tester.takeException(), isNull);
        }
      },
    );
  }

  for (final brand in [
    AppBrands.global,
    AppBrands.india,
    AppBrands.spain,
    AppBrands.turkey,
    AppBrands.america,
    AppBrands.britain,
    AppBrands.australia,
    AppBrands.uaeBiohackn,
  ]) {
    testWidgets('aligns home and settings clocks for ${brand.flavor}', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1280));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      AppBrand.configure(brand);
      Rect? homeTime;
      Rect? homeDate;
      for (final settingsPage in [false, true]) {
        await tester.pumpWidget(
          GetMaterialApp(
            translations: AppTranslations(),
            locale: const Locale('pl', 'PL'),
            home: settingsPage
                ? const settings_header.AppSettingHeaderPage()
                : const AppHeaderPage(),
          ),
        );
        await tester.pumpAndSettle();
        final timeRect = tester.getRect(find.text('12:00'));
        final dateRect = tester.getRect(find.text('2026.10.23'));
        expect(timeRect.center.dx, closeTo(400, 0.01));
        expect(dateRect.center.dx, closeTo(400, 0.01));
        if (settingsPage) {
          expect(timeRect, homeTime);
          expect(dateRect, homeDate);
        } else {
          homeTime = timeRect;
          homeDate = dateRect;
        }
        expect(tester.takeException(), isNull);
      }
    });
  }
}

class _StaticClockController extends AppHeaderClockController {
  final RxString _date = '2026.10.23'.obs;
  final RxString _time = '12:00'.obs;

  @override
  String get dateText => _date.value;

  @override
  String get timeText => _time.value;

  @override
  void startClock() {}
}
