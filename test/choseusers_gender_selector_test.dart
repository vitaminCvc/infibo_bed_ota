import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infibo_app/pages/choseusers/Popup/user_Popup_gender.dart';
import 'package:infibo_app/translation/app_translations.dart';

void main() {
  for (final MapEntry<String, Map<String, String>> translations
      in AppTranslations().keys.entries) {
    testWidgets('gender choices do not overflow in ${translations.key}', (
      WidgetTester tester,
    ) async {
      Get.testMode = true;
      addTearDown(Get.reset);

      final List<String> parts = translations.key.split('_');
      final Locale locale = Locale(parts.first, parts.last);

      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: locale,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 320,
                child: GenderSelector(value: '男', onChanged: (_) {}),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.text(translations.value['male']!),
        findsOneWidget,
        reason: '${translations.key} should render its short male label',
      );
      expect(
        find.text(translations.value['female']!),
        findsOneWidget,
        reason: '${translations.key} should render its short female label',
      );

      expect(
        tester.takeException(),
        isNull,
        reason: '${translations.key} should fit within the popup content width',
      );
    });
  }
}
