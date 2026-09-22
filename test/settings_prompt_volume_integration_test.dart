import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/designCanvas/design.dart';
import 'package:infibo_app/pages/settingpage/ui.dart';
import 'package:infibo_app/pages/start/audio_prompt_player.dart';
import 'package:infibo_app/stores/app_header_clock_store.dart';
import 'package:infibo_app/stores/user_store.dart';
import 'package:infibo_app/translation/app_translations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'settings opens volume panel and keeps volume across menu changes',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      Get.put(UserStore());
      await AudioPromptPlayer.instance.setVolume(20);
      await tester.binding.setSurfaceSize(const Size(800, 1280));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
        Get.reset();
      });
      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('zh', 'CN'),
          home: const DesignCanvas(child: SettingWidget()),
        ),
      );
      await tester.tap(find.text('提示音音量'));
      await tester.pump();
      expect(find.byType(Slider), findsOneWidget);
      expect(find.text('20%'), findsOneWidget);

      final Slider slider = tester.widget<Slider>(find.byType(Slider));
      slider.onChanged!(55);
      slider.onChangeEnd!(55);
      await tester.pump();
      await tester.tap(find.text('语言设置'));
      await tester.pump();
      expect(find.byType(Slider), findsNothing);
      await tester.tap(find.text('提示音音量'));
      await tester.pump();
      expect(find.text('55%'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      Get.delete<AppHeaderClockController>(force: true);
      await AudioPromptPlayer.instance.setVolume(20);
    },
  );
}
