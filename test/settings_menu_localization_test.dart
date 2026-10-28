import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/designCanvas/design.dart';
import 'package:infibo_app/config/app_brand.dart';
import 'package:infibo_app/pages/settingpage/ui.dart';
import 'package:infibo_app/stores/app_header_clock_store.dart';
import 'package:infibo_app/stores/user_store.dart';
import 'package:infibo_app/translation/app_translations.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _menuKeys = [
  'language_setting',
  'date_time',
  'device_info',
  'wifi_ble',
  'history_record',
  'prompt_volume',
  'status_detection',
  'system_update',
];

void main() {
  test('compact menu names preserve the full Polish panel titles', () {
    final polish = AppTranslations().keys['pl_PL']!;
    expect(polish['settings_menu_device_info'], 'O urządzeniu');
    expect(polish['settings_menu_prompt_volume'], 'Głośność');
    expect(polish['settings_menu_system_update'], 'Aktualizacje');
    expect(polish['device_info'], 'Informacje o urządzeniu');
    expect(polish['prompt_volume'], 'Głośność komunikatów');
    expect(polish['system_update'], 'Aktualizacja systemu');
  });

  for (final localeKey in AppTranslations().keys.keys) {
    testWidgets('settings menu stays readable in $localeKey', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1280));
      SharedPreferences.setMockInitialValues({});
      Get.testMode = true;
      AppBrand.configure(AppBrands.global);
      Get.put(UserStore());
      Get.put<AppHeaderClockController>(_Clock());
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.binding.setSurfaceSize(null);
        Get.reset();
      });
      await tester.runAsync(() async {
        final font = FontLoader('SettingsMenuTest');
        font.addFont(
          rootBundle.load('assets/fonts/MicrosoftYaHei-Regular.ttf'),
        );
        await font.load();
      });
      final parts = localeKey.split('_');
      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: Locale(parts[0], parts[1]),
          theme: ThemeData(fontFamily: 'SettingsMenuTest'),
          home: const DesignCanvas(child: SettingWidget()),
        ),
      );
      await tester.pumpAndSettle();
      final localizedTitle =
          AppTranslations().keys[localeKey]!['settings_menu_title'] ??
          'setting_menu'.tr;
      final title = find.text(localizedTitle);
      expect(title, findsOneWidget);
      expect(
        tester.getSize(title).height,
        lessThanOrEqualTo(36),
        reason: '$localeKey settings title must remain on one line',
      );
      for (final key in _menuKeys) {
        final menuKey = 'settings_menu_$key';
        final translations = AppTranslations().keys[localeKey]!;
        final label = translations[menuKey] ?? translations[key]!;
        final text = find.descendant(
          of: find.byType(InkWell),
          matching: find.text(label),
        );
        expect(text, findsOneWidget, reason: '$localeKey $key');
        final paragraph = tester.renderObject<RenderParagraph>(text);
        final row = tester.renderObject<RenderBox>(
          find.ancestor(of: text, matching: find.byType(Row)).first,
        );
        final scale = paragraph.getTransformTo(row).storage[0].abs();
        final size = tester.widget<Text>(text).style!.fontSize!;
        expect(
          size * scale,
          greaterThanOrEqualTo(16),
          reason: '$localeKey $key: $label becomes too small',
        );
        expect(
          paragraph.didExceedMaxLines,
          isFalse,
          reason: '$localeKey $key must remain complete',
        );
      }
      expect(tester.takeException(), isNull);
    });
  }
}

class _Clock extends AppHeaderClockController {
  final _time = '16:37'.obs;
  final _date = '2026.10.23'.obs;
  @override
  String get timeText => _time.value;
  @override
  String get dateText => _date.value;
  @override
  void startClock() {}
}
