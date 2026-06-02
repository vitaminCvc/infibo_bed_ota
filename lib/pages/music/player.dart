// VAT 音乐播放器。
//
// 集中维护播放列表、当前歌曲、音量和播放状态快照。
import 'package:infibo_app/pages/music/logic.dart';
import 'package:just_audio/just_audio.dart';

class VatMusicPlaybackSnapshot {
  const VatMusicPlaybackSnapshot({
    // 当前选中的歌曲ID
    required this.selectedSongId,
    //音量
    required this.volume,
    //是否正在进行播放
    required this.wasPlaying,
    //当前播放的索引
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
  ConcatenatingAudioSource? _playlist;
  String _selectedSongId = defaultSongId;
  int _volume = 50;

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
      currentIndex: _player.currentIndex,
      position: _player.position,
    );
  }

  Future<bool> previewSong(String songId, int volume) async {
    final int index = _playableIndexForSongId(songId);
    if (index < 0) return false;

    _selectedSongId = songId;
    await setVolume(volume);
    await _ensurePlaylist(initialIndex: index);
    await _player.seek(Duration.zero, index: index);
    await _player.play();
    return true;
  }

  Future<void> applySelection(
    String songId, {
    required int volume,
    required bool playNow,
    bool restart = false,
  }) async {
    _selectedSongId = songId;
    await setVolume(volume);

    if (restart) {
      final int index = _playableIndexForSongId(songId);
      if (index >= 0) {
        await _ensurePlaylist(initialIndex: index);
        await _player.seek(Duration.zero, index: index);
      }
    }

    if (playNow) {
      await playForVatPhase();
    } else {
      await _player.pause();
    }
  }

  Future<void> playForVatPhase() async {
    final int index = _playableIndexForSongId(_selectedSongId);
    if (index < 0) return;

    await _ensurePlaylist(initialIndex: index);
    await _player.setVolume(_volume / 100);
    await _player.play();
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
    //如果当前索引不为空，就把播放器恢复到当时的那首歌，当时的播放位置
    if (snapshot.currentIndex != null) {
      //确保播放列表存在.不能直接让播放器跳到第几首歌，前提是播放器里面已经有播放列表
      await _ensurePlaylist(initialIndex: snapshot.currentIndex!);

      //恢复播放进度
      await _player.seek(snapshot.position, index: snapshot.currentIndex);
    }

    if (shouldPlay && snapshot.wasPlaying) {
      await playForVatPhase();
    } else {
      await _player.pause();
    }
  }

  Future<void> setVolume(int volume) async {
    _volume = volume.clamp(0, 100).toInt();
    await _player.setVolume(_volume / 100);
  }

  Future<void> _ensurePlaylist({required int initialIndex}) async {
    if (_playlist != null) return;

    final List<Song> songs = _playableSongs;
    if (songs.isEmpty) return;

    _playlist = ConcatenatingAudioSource(
      children: [
        for (final Song song in songs) AudioSource.asset(song.assetPath!),
      ],
    );
    await _player.setAudioSource(
      _playlist!,
      initialIndex: initialIndex.clamp(0, songs.length - 1).toInt(),
    );
    await _player.setLoopMode(LoopMode.all);
  }

  int _playableIndexForSongId(String songId) {
    final List<Song> songs = _playableSongs;
    return songs.indexWhere((song) => song.id == songId);
  }
}
