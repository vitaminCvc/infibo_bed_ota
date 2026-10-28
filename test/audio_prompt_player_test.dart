import 'dart:async';
import 'dart:io';

import 'package:infibo_app/config/app_brand.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/pages/start/audio_prompt_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'each brand plays its own three prompts and keeps the shared water prompt',
    () async {
      final original = AppBrand.current;
      addTearDown(() => AppBrand.configure(original));
      for (final brand in [
        AppBrands.global,
        AppBrands.india,
        AppBrands.spain,
        AppBrands.turkey,
        AppBrands.america,
        AppBrands.britain,
        AppBrands.australia,
        AppBrands.uaeBiohackn,
      ]) {
        AppBrand.configure(brand);
        final backends = <FakeAudioPromptBackend>[];
        final player = AudioPromptPlayer(
          audioPlayerFactory: () {
            final backend = FakeAudioPromptBackend();
            backends.add(backend);
            return backend;
          },
        );
        await player.preloadWelcomeSafely();
        await player.playWelcomeSafely();
        await player.playStartSafely();
        await player.playEndSafely();
        await player.playWaterSafely();
        final folder = brand.flavor == 'uaeBiohackn'
            ? 'assets/branding/uaeBiohackn/audio'
            : 'assets/AudioPrompt';
        expect(backends.expand((b) => b.playedAssets).toList(), [
          '$folder/welcome.mp3',
          '$folder/start.mp3',
          '$folder/end.mp3',
          'assets/AudioPrompt/water.mp3',
        ], reason: brand.flavor);
        for (final backend in backends) {
          expect(File(backend.currentAsset!).existsSync(), isTrue);
        }
      }
    },
  );

  test('UAE cold-start prompt plays once with saved prompt volume', () async {
    final original = AppBrand.current;
    addTearDown(() => AppBrand.configure(original));
    AppBrand.configure(AppBrands.uaeBiohackn);
    SharedPreferences.setMockInitialValues({'audio_prompt_volume': 35});
    final backend = FakeAudioPromptBackend();
    final player = AudioPromptPlayer(audioPlayer: backend);
    await player.loadVolume();
    await Future.wait([
      player.playStartupOnceSafely(),
      player.playStartupOnceSafely(),
    ]);
    await player.playStartupOnceSafely();
    expect(backend.playedAssets, [
      'assets/branding/uaeBiohackn/audio/startup.mp3',
    ]);
    expect(backend.volumes.last, 0.35);
    expect(File(backend.currentAsset!).existsSync(), isTrue);
    final nextProcess = FakeAudioPromptBackend();
    await AudioPromptPlayer(audioPlayer: nextProcess).playStartupOnceSafely();
    expect(nextProcess.playCount, 1);
  });

  test('other brands do not load or play the UAE startup prompt', () async {
    final original = AppBrand.current;
    addTearDown(() => AppBrand.configure(original));
    for (final brand in [
      AppBrands.global,
      AppBrands.india,
      AppBrands.spain,
      AppBrands.turkey,
      AppBrands.america,
      AppBrands.britain,
      AppBrands.australia,
    ]) {
      AppBrand.configure(brand);
      final backend = FakeAudioPromptBackend();
      await AudioPromptPlayer(audioPlayer: backend).playStartupOnceSafely();
      expect(backend.loadedAssets, isEmpty, reason: brand.flavor);
      expect(backend.playCount, 0);
    }
  });

  test(
    'startup audio failure is contained and not retried during the session',
    () async {
      final original = AppBrand.current;
      addTearDown(() => AppBrand.configure(original));
      AppBrand.configure(AppBrands.uaeBiohackn);
      final backend = FakeAudioPromptBackend()..throwOnLoad = true;
      final player = AudioPromptPlayer(audioPlayer: backend);
      await player.playStartupOnceSafely();
      await player.playStartupOnceSafely();
      expect(backend.loadedAssets.length, 1);
      expect(backend.playCount, 0);
    },
  );

  test('missing saved volume keeps the 20 percent default', () async {
    final AudioPromptPlayer player = AudioPromptPlayer();
    await player.loadVolume();
    expect(player.volume, 20);
  });

  test(
    'saved volume is restored for the first playback of a new player',
    () async {
      final AudioPromptPlayer original = AudioPromptPlayer();
      await original.setVolume(65);
      await original.saveVolume();

      final FakeAudioPromptBackend backend = FakeAudioPromptBackend();
      final AudioPromptPlayer restored = AudioPromptPlayer(
        audioPlayer: backend,
      );
      await restored.loadVolume();
      await restored.playWelcome();

      expect(restored.volume, 65);
      expect(backend.volumes, <double>[0.65]);
    },
  );

  test('muted volume remains muted after restoring', () async {
    final AudioPromptPlayer original = AudioPromptPlayer();
    await original.setVolume(0);
    await original.saveVolume();

    final AudioPromptPlayer restored = AudioPromptPlayer();
    await restored.loadVolume();
    expect(restored.volume, 0);
  });

  test('temporary volume changes do not overwrite the saved setting', () async {
    final AudioPromptPlayer original = AudioPromptPlayer();
    await original.setVolume(35);
    await original.saveVolume();
    await original.setVolume(80);

    final AudioPromptPlayer restored = AudioPromptPlayer();
    await restored.loadVolume();
    expect(restored.volume, 35);
  });

  test('invalid saved volume type falls back to 20 percent', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'audio_prompt_volume': 'invalid',
    });
    final AudioPromptPlayer player = AudioPromptPlayer();
    await player.loadVolume();
    expect(player.volume, 20);
  });

  test('out of range saved volumes are clamped', () async {
    for (final int value in <int>[-10, 120]) {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'audio_prompt_volume': value,
      });
      final AudioPromptPlayer player = AudioPromptPlayer();
      await player.loadVolume();
      expect(player.volume, value < 0 ? 0 : 100);
    }
  });

  test('defines the three startup flow prompt assets', () {
    expect(AudioPromptAssets.welcome, 'assets/AudioPrompt/welcome.mp3');
    expect(AudioPromptAssets.start, 'assets/AudioPrompt/start.mp3');
    expect(AudioPromptAssets.end, 'assets/AudioPrompt/end.mp3');
    expect(AudioPromptAssets.water, 'assets/AudioPrompt/water.mp3');
  });

  test('plays prompt assets from the beginning', () async {
    final FakeAudioPromptBackend backend = FakeAudioPromptBackend();
    final AudioPromptPlayer player = AudioPromptPlayer(audioPlayer: backend);

    await player.playWelcome();
    await player.playStart();
    await player.playEnd();
    await player.playWater();

    expect(backend.loadedAssets, <String>[
      AudioPromptAssets.welcome,
      AudioPromptAssets.start,
      AudioPromptAssets.end,
      AudioPromptAssets.water,
    ]);
    expect(backend.seekPositions, <Duration>[
      Duration.zero,
      Duration.zero,
      Duration.zero,
      Duration.zero,
    ]);
    expect(backend.playCount, 4);
  });

  test('plays prompts at 20 percent by default', () async {
    final FakeAudioPromptBackend backend = FakeAudioPromptBackend();
    final AudioPromptPlayer player = AudioPromptPlayer(audioPlayer: backend);

    await player.playWelcome();

    expect(backend.volumes, <double>[0.20]);
    expect(player.volume, 20);
  });

  test('all future prompts use the selected volume', () async {
    final FakeAudioPromptBackend backend = FakeAudioPromptBackend();
    final AudioPromptPlayer player = AudioPromptPlayer(audioPlayer: backend);

    await player.setVolume(65);
    await player.playWelcome();
    await player.playStart();
    await player.playEnd();
    await player.playWater();

    expect(player.volume, 65);
    expect(backend.volumes, <double>[0.65, 0.65, 0.65, 0.65]);
  });

  test(
    'volume changes update playing and preloaded prompts without restarting',
    () async {
      final List<FakeAudioPromptBackend> backends = <FakeAudioPromptBackend>[];
      final AudioPromptPlayer player = AudioPromptPlayer(
        audioPlayerFactory: () {
          final FakeAudioPromptBackend backend = FakeAudioPromptBackend();
          backends.add(backend);
          return backend;
        },
      );

      await player.playEnd();
      await player.preloadWater();
      await player.setVolume(40);

      expect(backends[0].volumes, <double>[0.20, 0.4]);
      expect(backends[1].volumes, <double>[0.4]);
      expect(backends[0].playCount, 1);
      expect(backends[0].stopCount, 0);
      expect(backends[1].playCount, 0);
    },
  );

  test('clamps volume to zero through 100 including mute', () async {
    final FakeAudioPromptBackend backend = FakeAudioPromptBackend();
    final AudioPromptPlayer player = AudioPromptPlayer(audioPlayer: backend);

    await player.setVolume(-10);
    expect(player.volume, 0);
    await player.playWater();
    expect(backend.volumes.last, 0.0);

    await player.setVolume(120);
    expect(player.volume, 100);
    expect(backend.volumes.last, 1.0);

    await player.setVolume(0);
    expect(player.volume, 0);
    expect(backend.volumes.last, 0.0);
  });

  test(
    'skips empty prompt asset paths without touching audio backend',
    () async {
      final FakeAudioPromptBackend backend = FakeAudioPromptBackend();
      final AudioPromptPlayer player = AudioPromptPlayer(audioPlayer: backend);

      await player.playAsset('');

      expect(backend.loadedAssets, isEmpty);
      expect(backend.seekPositions, isEmpty);
      expect(backend.playCount, 0);
    },
  );

  test('safe playback swallows audio backend failures', () async {
    final FakeAudioPromptBackend backend = FakeAudioPromptBackend()
      ..throwOnLoad = true;
    final AudioPromptPlayer player = AudioPromptPlayer(audioPlayer: backend);

    await player.playEndSafely();

    expect(backend.loadedAssets, <String>[AudioPromptAssets.end]);
    expect(backend.seekPositions, isEmpty);
    expect(backend.playCount, 0);
  });

  test('does not auto-stop when owner page is disposed', () async {
    final FakeAudioPromptBackend backend = FakeAudioPromptBackend();
    final AudioPromptPlayer player = AudioPromptPlayer(audioPlayer: backend);

    await player.disposeOwner();

    expect(backend.stopCount, 0);
  });

  test(
    'preloads welcome so button playback does not reload the asset',
    () async {
      final FakeAudioPromptBackend backend = FakeAudioPromptBackend();
      final AudioPromptPlayer player = AudioPromptPlayer(audioPlayer: backend);

      await player.preloadWelcome();
      await player.playWelcome();

      expect(backend.loadedAssets, <String>[AudioPromptAssets.welcome]);
      expect(backend.seekPositions, <Duration>[Duration.zero]);
      expect(backend.playCount, 1);
    },
  );

  test(
    'preloads water so warning playback does not reload the asset',
    () async {
      final FakeAudioPromptBackend backend = FakeAudioPromptBackend();
      final AudioPromptPlayer player = AudioPromptPlayer(audioPlayer: backend);

      await player.preloadWater();
      await player.playWater();

      expect(backend.loadedAssets, <String>[AudioPromptAssets.water]);
      expect(backend.seekPositions, <Duration>[Duration.zero]);
      expect(backend.playCount, 1);
    },
  );

  test('preloading water does not interrupt a playing end prompt', () async {
    final List<FakeAudioPromptBackend> backends = <FakeAudioPromptBackend>[];
    final AudioPromptPlayer player = AudioPromptPlayer(
      audioPlayerFactory: () {
        final FakeAudioPromptBackend backend = FakeAudioPromptBackend();
        backends.add(backend);
        return backend;
      },
    );

    await player.playEnd();
    await player.preloadWater();

    expect(backends, hasLength(2));
    expect(backends[0].loadedAssets, <String>[AudioPromptAssets.end]);
    expect(backends[0].playedAssets, <String>[AudioPromptAssets.end]);
    expect(backends[1].loadedAssets, <String>[AudioPromptAssets.water]);
    expect(backends[1].playedAssets, isEmpty);
  });

  test('waits for welcome playback before starting the start prompt', () async {
    final List<ControlledAudioPromptBackend> backends =
        <ControlledAudioPromptBackend>[];
    final AudioPromptPlayer player = AudioPromptPlayer(
      audioPlayerFactory: () {
        final ControlledAudioPromptBackend backend =
            ControlledAudioPromptBackend();
        backends.add(backend);
        return backend;
      },
    );

    final Future<void> welcomePlayback = player.playWelcomeSafely();
    final Future<void> startPlayback = player.playStartAfter(welcomePlayback);

    await Future<void>.delayed(Duration.zero);
    expect(backends, hasLength(1));
    expect(backends.single.playedAssets, <String>[AudioPromptAssets.welcome]);

    backends.single.completePlayback();
    await Future<void>.delayed(Duration.zero);

    expect(backends, hasLength(2));
    expect(backends[1].playedAssets, <String>[AudioPromptAssets.start]);

    backends[1].completePlayback();
    await startPlayback;
  });

  test('waits for prompts again on the second startup sequence', () async {
    final Map<String, StickyCompletedAudioPromptBackend> backends =
        <String, StickyCompletedAudioPromptBackend>{};
    final AudioPromptPlayer trackedPlayer = AudioPromptPlayer(
      audioPlayerFactory: () {
        final StickyCompletedAudioPromptBackend backend =
            StickyCompletedAudioPromptBackend();
        backend.onLoad = (String assetPath) => backends[assetPath] = backend;
        return backend;
      },
    );

    Future<void> runTrackedSequence() async {
      final Future<void> welcomePlayback = trackedPlayer.playWelcomeSafely();
      await Future<void>.delayed(Duration.zero);
      final Future<void> startPlayback = trackedPlayer.playStartAfter(
        welcomePlayback,
      );
      backends[AudioPromptAssets.welcome]!.completePlayback();
      await Future<void>.delayed(Duration.zero);
      backends[AudioPromptAssets.start]!.completePlayback();
      await startPlayback;
    }

    await runTrackedSequence();

    final Future<void> secondWelcome = trackedPlayer.playWelcomeSafely();
    final Future<void> secondStart = trackedPlayer.playStartAfter(
      secondWelcome,
    );
    await Future<void>.delayed(Duration.zero);

    expect(backends[AudioPromptAssets.welcome]!.pendingPlaybackCount, 1);
    expect(backends[AudioPromptAssets.start]!.playCount, 1);

    backends[AudioPromptAssets.welcome]!.completePlayback();
    await Future<void>.delayed(Duration.zero);
    expect(backends[AudioPromptAssets.start]!.playCount, 2);

    backends[AudioPromptAssets.start]!.completePlayback();
    await secondStart;
  });
}

class FakeAudioPromptBackend implements AudioPromptBackend {
  final List<String> loadedAssets = <String>[];
  final List<String> playedAssets = <String>[];
  final List<Duration> seekPositions = <Duration>[];
  final List<double> volumes = <double>[];
  int playCount = 0;
  int stopCount = 0;
  bool throwOnLoad = false;
  bool playing = false;
  String? currentAsset;

  @override
  Future<void> loadAsset(String assetPath) async {
    final bool wasPlaying = playing;
    loadedAssets.add(assetPath);
    if (throwOnLoad) throw StateError('load failed');
    currentAsset = assetPath;
    if (wasPlaying) playedAssets.add(assetPath);
  }

  @override
  Future<void> play() async {
    playing = true;
    playCount++;
    if (currentAsset != null) playedAssets.add(currentAsset!);
  }

  @override
  Future<void> seek(Duration position) async {
    seekPositions.add(position);
  }

  @override
  Future<void> setVolume(double volume) async {
    volumes.add(volume);
  }

  @override
  Future<void> stop() async {
    playing = false;
    stopCount++;
  }
}

class ControlledAudioPromptBackend extends FakeAudioPromptBackend {
  final Completer<void> _playbackCompleter = Completer<void>();

  @override
  Future<void> play() async {
    await super.play();
    await _playbackCompleter.future;
  }

  void completePlayback() {
    _playbackCompleter.complete();
  }
}

class StickyCompletedAudioPromptBackend extends FakeAudioPromptBackend {
  final List<Completer<void>> _playbackCompleters = <Completer<void>>[];
  void Function(String assetPath)? onLoad;

  int get pendingPlaybackCount => _playbackCompleters
      .where((Completer<void> item) => !item.isCompleted)
      .length;

  @override
  Future<void> loadAsset(String assetPath) async {
    await super.loadAsset(assetPath);
    onLoad?.call(assetPath);
  }

  @override
  Future<void> play() async {
    if (playing) return;
    await super.play();
    final Completer<void> completer = Completer<void>();
    _playbackCompleters.add(completer);
    await completer.future;
  }

  void completePlayback() {
    _playbackCompleters.last.complete();
  }
}
