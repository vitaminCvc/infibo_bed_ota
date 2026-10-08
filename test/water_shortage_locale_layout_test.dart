import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/water_shortage_dialog.dart';
import 'package:infibo_app/translation/app_translations.dart';

void main() {
  for (final entry in AppTranslations().keys.entries) {
    testWidgets('shortage message fits a small screen in ${entry.key}', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
        Get.reset();
      });
      final parts = entry.key.split('_');
      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: Locale(parts[0], parts[1]),
          home: Scaffold(
            body: Center(
              child: WaterShortageDialog(
                readyToFill: false,
                onButtonTap: () {},
              ),
            ),
          ),
        ),
      );
      expect(
        find.text(entry.value['water_level_shortage_message']!),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      final upper = find.text(entry.value['water_level_shortage_message']!);
      final lower = find.text(entry.value['water_level_shortage_unavailable']!);
      expect(lower, findsOneWidget);
      expect(tester.widget<Text>(upper).style!.color, const Color(0xFFD3D3D3));
      expect(tester.widget<Text>(lower).style!.color, const Color(0xFFA2A2A2));
      expect(
        tester.getBottomLeft(upper).dy,
        lessThan(tester.getTopLeft(find.byType(Image)).dy),
      );
      expect(
        tester.getBottomLeft(find.byType(Image)).dy,
        lessThan(tester.getTopLeft(lower).dy),
      );
      // 按钮位于文案下方，且默认展示 “Ready?” 文案。
      expect(
        find.text(entry.value['water_level_ready_button']!),
        findsOneWidget,
      );
      final Finder button = find.byKey(
        const ValueKey<String>('water_level_filling_button'),
      );
      expect(button, findsOneWidget);
      // 自适应按钮可随译文增宽，但不能超出卡片边界。
      final Rect cardBounds = tester.getRect(find.byType(ClipRRect).first);
      final Rect buttonBounds = tester.getRect(button);
      expect(buttonBounds.left, greaterThanOrEqualTo(cardBounds.left));
      expect(buttonBounds.right, lessThanOrEqualTo(cardBounds.right));
      expect(buttonBounds.top, greaterThanOrEqualTo(cardBounds.top));
      expect(buttonBounds.bottom, lessThanOrEqualTo(cardBounds.bottom));
      final Rect labelBounds = tester.getRect(
        find.text(entry.value['water_level_ready_button']!),
      );
      expect(labelBounds.center.dx, closeTo(buttonBounds.center.dx, 0.01));
      expect(labelBounds.center.dy, closeTo(buttonBounds.center.dy, 0.01));
      expect(
        tester.getTopLeft(button).dy,
        greaterThan(tester.getBottomLeft(lower).dy),
      );
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
