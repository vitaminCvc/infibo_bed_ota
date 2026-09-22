import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infibo_app/pages/choseusers/Popup/user_Popup.dart';
import 'package:infibo_app/pages/choseusers/Popup/user_Popup_button.dart';
import 'package:infibo_app/translation/app_translations.dart';

void _expectSpanFontSize(InlineSpan span, double? inheritedFontSize) {
  final double? fontSize = span.style?.fontSize ?? inheritedFontSize;
  if (span is TextSpan) {
    final bool isMaterialIcon = span.style?.fontFamily == 'MaterialIcons';
    if ((span.text?.isNotEmpty ?? false) && !isMaterialIcon) {
      expect(fontSize, 18, reason: 'Unexpected font size for "${span.text}"');
    }
    for (final InlineSpan child in span.children ?? const <InlineSpan>[]) {
      _expectSpanFontSize(child, fontSize);
    }
  }
}

void main() {
  testWidgets('add-user popup fills its frame with the supplied background', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('zh', 'CN'),
        home: const Scaffold(body: Center(child: Popup())),
      ),
    );

    final Finder background = find.byWidgetPredicate((Widget widget) {
      if (widget is! Image || widget.image is! AssetImage) return false;
      return (widget.image as AssetImage).assetName ==
          'assets/Choseusers/UserPopup.png';
    });

    expect(background, findsOneWidget);
    if (background.evaluate().isEmpty) return;

    expect(tester.getRect(background), tester.getRect(find.byType(Popup)));
    expect(tester.widget<Image>(background).fit, BoxFit.fill);
  });

  testWidgets('popup action buttons size themselves from content and padding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PopupActionButtons(
              onCancel: () {},
              onConfirm: () {},
              cancelLabel: 'A',
              confirmLabel: 'Longer button label',
            ),
          ),
        ),
      ),
    );

    final Size cancelTextSize = tester.getSize(find.text('A'));
    final Size confirmTextSize = tester.getSize(
      find.text('Longer button label'),
    );
    final Size buttonGroupSize = tester.getSize(
      find.byType(PopupActionButtons),
    );

    expect(
      buttonGroupSize.width,
      closeTo(cancelTextSize.width + confirmTextSize.width + 116, 0.01),
    );
    expect(
      buttonGroupSize.height,
      closeTo(
        (cancelTextSize.height > confirmTextSize.height
                ? cancelTextSize.height
                : confirmTextSize.height) +
            10,
        0.01,
      ),
    );
  });

  testWidgets('all add-user popup text uses 18px font size', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('zh', 'CN'),
        home: const Scaffold(body: Center(child: Popup())),
      ),
    );

    final Finder popupText = find.descendant(
      of: find.byType(Popup),
      matching: find.byType(RichText),
    );
    expect(popupText, findsWidgets);
    for (final RichText text in tester.widgetList<RichText>(popupText)) {
      _expectSpanFontSize(text.text, null);
    }

    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pump();

    final Finder validationText = find.descendant(
      of: find.byType(SnackBar),
      matching: find.byType(RichText),
    );
    expect(validationText, findsWidgets);
    for (final RichText text in tester.widgetList<RichText>(validationText)) {
      _expectSpanFontSize(text.text, null);
    }
  });
}
