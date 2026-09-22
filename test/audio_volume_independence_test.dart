import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/pages/music/player.dart';
import 'package:infibo_app/pages/start/audio_prompt_player.dart';

import 'audio_prompt_player_test.dart' show FakeAudioPromptBackend;
import 'music_player_test.dart' show FakeVatAudioPlayer;

void main() {
  test('prompt and music volume changes do not affect each other', () async {
    final FakeAudioPromptBackend promptBackend = FakeAudioPromptBackend();
    final RecordingMusicBackend musicBackend = RecordingMusicBackend();
    final AudioPromptPlayer prompts = AudioPromptPlayer(
      audioPlayer: promptBackend,
    );
    final VatMusicPlayer music = VatMusicPlayer(audioPlayer: musicBackend);

    await music.setVolume(60);
    await prompts.playWater();
    await prompts.setVolume(0);
    expect(music.volume, 60);
    expect(musicBackend.volumes, <double>[0.6]);

    await music.setVolume(80);
    expect(prompts.volume, 0);
    expect(promptBackend.volumes, <double>[0.2, 0.0]);

    await prompts.setVolume(100);
    expect(music.volume, 80);
    expect(musicBackend.volumes, <double>[0.6, 0.8]);
  });
}

class RecordingMusicBackend extends FakeVatAudioPlayer {
  final List<double> volumes = <double>[];

  @override
  Future<void> setVolume(double volume) async => volumes.add(volume);
}
