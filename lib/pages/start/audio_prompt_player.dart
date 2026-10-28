import 'package:infibo_app/config/app_brand.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioPromptAssets {
  const AudioPromptAssets._();

  static String get welcome => AppBrand.current.flavor == 'uaeBiohackn'
      ? 'assets/branding/uaeBiohackn/audio/welcome.mp3'
      : 'assets/AudioPrompt/welcome.mp3';
  static String get start => AppBrand.current.flavor == 'uaeBiohackn'
      ? 'assets/branding/uaeBiohackn/audio/start.mp3'
      : 'assets/AudioPrompt/start.mp3';
  static String get end => AppBrand.current.flavor == 'uaeBiohackn'
      ? 'assets/branding/uaeBiohackn/audio/end.mp3'
      : 'assets/AudioPrompt/end.mp3';
  static String? get startup => AppBrand.current.flavor == 'uaeBiohackn'
      ? 'assets/branding/uaeBiohackn/audio/startup.mp3'
      : null;

  static const String water = 'assets/AudioPrompt/water.mp3';
}

abstract class AudioPromptBackend {
  Future<void> loadAsset(String assetPath);
  Future<void> setVolume(double volume);
  Future<void> seek(Duration position);
  Future<void> play();
  Future<void> stop();
}

class JustAudioPromptBackend implements AudioPromptBackend {
  JustAudioPromptBackend([AudioPlayer? player])
    : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  @override
  Future<void> loadAsset(String assetPath) {
    return _player.setAudioSource(AudioSource.asset(assetPath));
  }

  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> stop() => _player.stop();
}

class AudioPromptPlayer {
  AudioPromptPlayer({
    AudioPromptBackend? audioPlayer,
    AudioPromptBackend Function()? audioPlayerFactory,
  }) : _audioPlayerFactory =
           audioPlayerFactory ??
           (audioPlayer == null
               ? () => JustAudioPromptBackend()
               : () => audioPlayer);

  static final AudioPromptPlayer instance = AudioPromptPlayer();

  ///设置默认值统一为20
  static const int defaultVolume = 20;
  static const String _volumePreferenceKey = 'audio_prompt_volume';

  final AudioPromptBackend Function() _audioPlayerFactory;
  final Map<String, AudioPromptBackend> _playersByAssetPath =
      <String, AudioPromptBackend>{};
  final Set<String> _loadedAssetPaths = <String>{};

  int _volume = defaultVolume;
  bool _startupPromptStarted = false;

  /// 提示音音量百分比（0～100），独立于音乐播放器。
  int get volume => _volume;

  /// 应用启动时调用；未保存或保存值类型异常时使用默认音量。（恢复保存值，没有配置或类型异常时使用 20%；保存的 0% 会正确恢复为静音。保留实时调节与保存两个接口，方便后续实现“拖动时调节、松手时保存”。）
  Future<void> loadVolume() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final Object? savedVolume = prefs.get(_volumePreferenceKey);
      await setVolume(savedVolume is int ? savedVolume : defaultVolume);
    } catch (e) {
      // 配置读取失败不阻止应用启动，保留当前音量。
      debugPrint('audio prompt volume restore skipped: $e');
    }
  }

  /// 滑动结束后保存，避免拖动时每次音量变化都写入配置。（使用现有的sharedpreferences保存当前音量）
  Future<void> saveVolume() async {
    final int volumeToSave = _volume;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool saved = await prefs.setInt(_volumePreferenceKey, volumeToSave);
    if (!saved) {
      throw StateError('audio prompt volume could not be saved');
    }
  }

  /// 同步调整已创建的提示音播放器，包括正在播放的提示音。
  Future<void> setVolume(int volume) async {
    _volume = volume.clamp(0, 100).toInt();
    final double normalizedVolume = _volume / 100;
    await Future.wait(
      _playersByAssetPath.values.toSet().map(
        (player) => player.setVolume(normalizedVolume),
      ),
    );
  }

  /// Called once after the first app frame, never on page entry or resume.
  Future<void> playStartupOnceSafely() async {
    final String? asset = AudioPromptAssets.startup;
    if (_startupPromptStarted || asset == null) return;
    // Set before awaiting so concurrent calls cannot start duplicate playback.
    _startupPromptStarted = true;
    await playAssetSafely(asset);
  }

  Future<void> playWelcome() =>
      playAsset(AudioPromptAssets.welcome, resetCompletedPlayback: true);

  Future<void> playStart() =>
      playAsset(AudioPromptAssets.start, resetCompletedPlayback: true);

  Future<void> playEnd() => playAsset(AudioPromptAssets.end);

  Future<void> playWater() => playAsset(AudioPromptAssets.water);

  Future<void> playWelcomeSafely() =>
      playAssetSafely(AudioPromptAssets.welcome, resetCompletedPlayback: true);

  Future<void> playStartSafely() =>
      playAssetSafely(AudioPromptAssets.start, resetCompletedPlayback: true);

  Future<void> playStartAfter(Future<void> previousPlayback) async {
    await previousPlayback;
    await playStartSafely();
  }

  Future<void> playEndSafely() => playAssetSafely(AudioPromptAssets.end);

  Future<void> playWaterSafely() => playAssetSafely(AudioPromptAssets.water);

  Future<void> preloadWelcome() => preloadAsset(AudioPromptAssets.welcome);

  Future<void> preloadWater() => preloadAsset(AudioPromptAssets.water);

  Future<void> preloadWelcomeSafely() =>
      preloadAssetSafely(AudioPromptAssets.welcome);

  Future<void> preloadWaterSafely() =>
      preloadAssetSafely(AudioPromptAssets.water);

  Future<void> preloadAsset(String assetPath) async {
    if (assetPath.trim().isEmpty || _loadedAssetPaths.contains(assetPath)) {
      return;
    }

    await _playerForAsset(assetPath).loadAsset(assetPath);
    _loadedAssetPaths.add(assetPath);
  }

  Future<void> playAsset(
    String assetPath, {
    bool resetCompletedPlayback = false,
  }) async {
    if (assetPath.trim().isEmpty) return;

    await preloadAsset(assetPath);
    final AudioPromptBackend player = _playerForAsset(assetPath);
    await player.setVolume(_volume / 100);
    if (resetCompletedPlayback) {
      await player.stop();
    }
    await player.seek(Duration.zero);
    await player.play();
  }

  Future<void> preloadAssetSafely(String assetPath) async {
    try {
      await preloadAsset(assetPath);
    } catch (e) {
      debugPrint('audio prompt preload skipped: $e');
    }
  }

  Future<void> playAssetSafely(
    String assetPath, {
    bool resetCompletedPlayback = false,
  }) async {
    try {
      await playAsset(
        assetPath,
        resetCompletedPlayback: resetCompletedPlayback,
      );
    } catch (e) {
      debugPrint('audio prompt playback skipped: $e');
    }
  }

  Future<void> stop() async {
    for (final AudioPromptBackend player in _playersByAssetPath.values) {
      await player.stop();
    }
  }

  Future<void> stopSafely() async {
    try {
      await stop();
    } catch (e) {
      debugPrint('audio prompt stop skipped: $e');
    }
  }

  Future<void> disposeOwner() async {}

  AudioPromptBackend _playerForAsset(String assetPath) {
    return _playersByAssetPath.putIfAbsent(assetPath, _audioPlayerFactory);
  }
}
