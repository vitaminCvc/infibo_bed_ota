import 'package:infibo_app/pages/music/logic.dart';
import 'package:just_audio/just_audio.dart';

class VatMusicPlaybackSnapshot {
  const VatMusicPlaybackSnapshot({
    required this.selectedSongId,
    required this.volume,
    required this.wasPlaying,
    this.currentIndex,
    this.position = Duration.zero,
  });

  final String selectedSongId;
  final int volume;
  final bool wasPlaying;
  final int? currentIndex;
  final Duration position;
}

class VatMusicPlayer {
  VatMusicPlayer._();

  static final VatMusicPlayer instance = VatMusicPlayer._();

  final AudioPlayer _player = AudioPlayer();
  String? _loadedSongId;
  String _selectedSongId = defaultSongId;
  int _volume = 50;
  int? _appliedVolume;
  LoopMode? _appliedLoopMode;

  List<Song> get _playableSongs =>
      allSongs.where((song) => song.assetPath != null).toList();

  int get volume => _volume;
  String get selectedSongId => _selectedSongId;
  bool get isPlaying => _player.playing;

  VatMusicPlaybackSnapshot captureSnapshot() {
    return VatMusicPlaybackSnapshot(
      selectedSongId: _selectedSongId,
      volume: _volume,
      wasPlaying: _player.playing,
      currentIndex: _playableIndexForSongId(_selectedSongId),
      position: _player.position,
    );
  }

  Future<bool> previewSong(String songId, int volume) async {
    if (_playableIndexForSongId(songId) < 0) return false;

    _selectedSongId = songId;
    await setVolume(volume);
    await _ensureSongLoaded(songId);
    await _player.seek(Duration.zero);
    await _player.play();
    return true;
  }

  Future<void> applySelection(
    String songId, {
    required int volume,
    required bool playNow,
    bool restart = false,
    bool singleLoop = false,
  }) async {
    _selectedSongId = songId;
    await setVolume(volume);

    if (restart && _playableIndexForSongId(songId) >= 0) {
      await _ensureSongLoaded(songId);
      await _player.seek(Duration.zero);
    }

    if (playNow) {
      await playForVatPhase(singleLoop: singleLoop);
    } else {
      await _player.pause();
    }
  }

  Future<void> playForVatPhase({bool singleLoop = false}) async {
    if (_playableIndexForSongId(_selectedSongId) < 0) return;

    await _ensureSongLoaded(_selectedSongId);
    await _setLoopMode(singleLoop ? LoopMode.one : LoopMode.all);
    await _applyVolume();
    if (!_player.playing) {
      await _player.play();
    }
  }

  Future<void> pause() => _player.pause();

  Future<void> stop() async {
    await _player.pause();
    await _player.seek(Duration.zero);
  }

  Future<void> restore(
    VatMusicPlaybackSnapshot snapshot, {
    required bool shouldPlay,
  }) async {
    _selectedSongId = snapshot.selectedSongId;
    await setVolume(snapshot.volume);

    if (_playableIndexForSongId(snapshot.selectedSongId) >= 0) {
      await _ensureSongLoaded(snapshot.selectedSongId);
      await _player.seek(snapshot.position);
    }

    if (shouldPlay && snapshot.wasPlaying) {
      await playForVatPhase();
    } else {
      await _player.pause();
    }
  }

  Future<void> setVolume(int volume) async {
    final int nextVolume = volume.clamp(0, 100).toInt();
    if (_volume == nextVolume && _appliedVolume == nextVolume) return;

    _volume = nextVolume;
    await _applyVolume();
  }

  Future<void> prepareForVatPhase(
    String songId, {
    required int volume,
    bool singleLoop = false,
  }) async {
    if (_playableIndexForSongId(songId) < 0) return;

    _selectedSongId = songId;
    await setVolume(volume);
    await _ensureSongLoaded(songId);
    await _player.seek(Duration.zero);
    await _setLoopMode(singleLoop ? LoopMode.one : LoopMode.all);
  }

  Future<void> _ensureSongLoaded(String songId) async {
    if (_loadedSongId == songId) return;

    final Song? song = findSongById(songId);
    final String? assetPath = song?.assetPath;
    if (assetPath == null) return;

    await _player.setAudioSource(AudioSource.asset(assetPath));
    _loadedSongId = songId;
    _appliedLoopMode = null;
  }

  Future<void> _applyVolume() async {
    if (_appliedVolume == _volume) return;

    await _player.setVolume(_volume / 100);
    _appliedVolume = _volume;
  }

  Future<void> _setLoopMode(LoopMode loopMode) async {
    if (_appliedLoopMode == loopMode) return;

    await _player.setLoopMode(loopMode);
    _appliedLoopMode = loopMode;
  }

  int _playableIndexForSongId(String songId) {
    final List<Song> songs = _playableSongs;
    return songs.indexWhere((song) => song.id == songId);
  }
}
