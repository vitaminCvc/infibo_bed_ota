import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infibo_app/pages/settingpage/prompt_volume_settings_panel.dart';
import 'package:infibo_app/pages/start/audio_prompt_player.dart';
import 'package:infibo_app/translation/app_translations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });
  tearDown(Get.reset);

  Future<void> showPanel(WidgetTester tester, AudioPromptPlayer player) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('zh', 'CN'),
        home: Scaffold(
          body: SizedBox(
            width: 380,
            child: PromptVolumeSettingsPanel(player: player),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows current volume and saves only when the drag ends', (
    tester,
  ) async {
    final AudioPromptPlayer player = AudioPromptPlayer();
    await player.setVolume(35);
    await player.saveVolume();
    await showPanel(tester, player);
    expect(find.text('35%'), findsOneWidget);

    final Finder slider = find.byType(Slider);
    final Offset center = tester.getCenter(slider);
    final TestGesture gesture = await tester.startGesture(center);
    await gesture.moveBy(const Offset(50, 0));
    await tester.pump();
    expect(player.volume, greaterThan(35));
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('audio_prompt_volume'), 35);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(prefs.getInt('audio_prompt_volume'), player.volume);
    expect(find.text('${player.volume}%'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('supports mute and maximum volume', (tester) async {
    final AudioPromptPlayer player = AudioPromptPlayer();
    await showPanel(tester, player);
    Slider slider = tester.widget<Slider>(find.byType(Slider));
    slider.onChanged!(0);
    slider.onChangeEnd!(0);
    await tester.pumpAndSettle();
    expect(player.volume, 0);
    expect(find.text('0%', skipOffstage: false), findsWidgets);

    slider = tester.widget<Slider>(find.byType(Slider));
    slider.onChanged!(100);
    slider.onChangeEnd!(100);
    await tester.pumpAndSettle();
    final AudioPromptPlayer restored = AudioPromptPlayer();
    await restored.loadVolume();
    expect(restored.volume, 100);
  });

  testWidgets('save failure is visible and can be retried by adjusting again', (
    tester,
  ) async {
    final FailingSavePlayer player = FailingSavePlayer();
    await showPanel(tester, player);
    final Slider slider = tester.widget<Slider>(find.byType(Slider));
    slider.onChanged!(60);
    slider.onChangeEnd!(60);
    await tester.pumpAndSettle();
    expect(find.text('音量保存失败，请重新调节后重试'), findsOneWidget);
    expect(tester.takeException(), isNull);

    player.failSave = false;
    slider.onChanged!(70);
    slider.onChangeEnd!(70);
    await tester.pumpAndSettle();
    expect(find.text('音量保存失败，请重新调节后重试'), findsNothing);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('audio_prompt_volume'), 70);
  });

  testWidgets('all supported languages fit a narrow settings panel', (
    tester,
  ) async {
    for (final String locale in AppTranslations().keys.keys) {
      final List<String> codes = locale.split('_');
      await tester.pumpWidget(
        GetMaterialApp(
          key: ValueKey(locale),
          translations: AppTranslations(),
          locale: Locale(codes[0], codes[1]),
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 400,
              child: PromptVolumeSettingsPanel(player: AudioPromptPlayer()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: locale);
      for (final String key in <String>[
        'prompt_volume',
        'prompt_volume_hint',
        'prompt_volume_update_failed',
        'prompt_volume_save_failed',
      ]) {
        expect(
          AppTranslations().keys[locale]![key],
          isNotEmpty,
          reason: '$locale: $key',
        );
      }
    }
  });
}

class FailingSavePlayer extends AudioPromptPlayer {
  bool failSave = true;

  @override
  Future<void> saveVolume() async {
    if (failSave) throw StateError('save failed');
    await super.saveVolume();
  }
}
