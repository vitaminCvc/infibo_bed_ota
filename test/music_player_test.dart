import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/pages/music/logic.dart';
import 'package:infibo_app/pages/music/player.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  test('lets the latest rapid music preview request win', () async {
    final FakeVatAudioPlayer audioPlayer = FakeVatAudioPlayer();
    final VatMusicPlayer player = VatMusicPlayer(audioPlayer: audioPlayer);

    final List<bool> results = await Future.wait(<Future<bool>>[
      player.previewSong(allSongs[0].id, 50),
      player.previewSong(allSongs[1].id, 50),
      player.previewSong(allSongs[2].id, 50),
    ]);

    expect(results, <bool>[true, true, true]);
    expect(audioPlayer.maxConcurrentLoads, greaterThan(1));
    expect(audioPlayer.playedSongIds, <String>[allSongs[2].id]);
  });
}

class FakeVatAudioPlayer implements VatAudioPlayer {
  int activeLoads = 0;
  int maxConcurrentLoads = 0;
  String? loadedSongId;
  final List<String> playedSongIds = <String>[];

  @override
  bool playing = false;

  @override
  Duration position = Duration.zero;

  @override
  Future<void> pause() async {
    playing = false;
  }

  @override
  Future<void> play() async {
    playing = true;
    if (loadedSongId != null) playedSongIds.add(loadedSongId!);
  }

  @override
  Future<void> seek(Duration position) async {
    this.position = position;
  }

  @override
  Future<void> setAudioSource(AudioSource source) async {
    activeLoads++;
    maxConcurrentLoads = maxConcurrentLoads < activeLoads
        ? activeLoads
        : maxConcurrentLoads;
    if (activeLoads > 1) {
      activeLoads--;
      throw PlayerInterruptedException('Connection aborted');
    }

    await Future<void>.delayed(const Duration(milliseconds: 10));
    loadedSongId = source.sequence.first.tag?.toString();
    activeLoads--;
  }

  @override
  Future<void> setLoopMode(LoopMode loopMode) async {}

  @override
  Future<void> setVolume(double volume) async {}
}
