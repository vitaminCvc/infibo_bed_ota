# Audio Prompt Device Volume Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Play every audio prompt at 30% of the tablet's current system media volume.

**Architecture:** Add `setVolume` to the prompt backend boundary and apply the fixed relative gain of `0.3` immediately before prompt playback. This leaves Android and iOS system media settings untouched and does not couple prompt playback to `VatMusicPlayer`.

**Tech Stack:** Flutter, Dart, `flutter_test`, `just_audio`.

---

### Task 1: Apply Prompt Playback Gain

**Files:**
- Modify: `test/audio_prompt_player_test.dart`
- Modify: `lib/pages/start/audio_prompt_player.dart`

- [ ] **Step 1: Write the failing test**

Add this test after `plays prompt assets from the beginning`:

```dart
test('plays prompts at 30 percent of the system media volume', () async {
  final FakeAudioPromptBackend backend = FakeAudioPromptBackend();
  final AudioPromptPlayer player = AudioPromptPlayer(audioPlayer: backend);

  await player.playWelcome();

  expect(backend.volumes, <double>[0.3]);
});
```

Add this field and method to `FakeAudioPromptBackend`:

```dart
final List<double> volumes = <double>[];

@override
Future<void> setVolume(double volume) async {
  volumes.add(volume);
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```powershell
flutter test test/audio_prompt_player_test.dart --plain-name "plays prompts at 30 percent of the system media volume"
```

Expected: compilation failure because `AudioPromptBackend` has no `setVolume` method.

- [ ] **Step 3: Write minimal implementation**

Extend `AudioPromptBackend` with:

```dart
Future<void> setVolume(double volume);
```

Implement it in `JustAudioPromptBackend`:

```dart
@override
Future<void> setVolume(double volume) => _player.setVolume(volume);
```

In `AudioPromptPlayer.playAsset`, apply the fixed relative gain before seeking and playing:

```dart
await player.setVolume(0.3);
await player.seek(Duration.zero);
await player.play();
```

- [ ] **Step 4: Run tests and analysis to verify the change**

Run:

```powershell
flutter test test/audio_prompt_player_test.dart
flutter analyze lib/pages/start/audio_prompt_player.dart test/audio_prompt_player_test.dart
```

Expected: the focused test suite and analysis both complete successfully.

- [ ] **Step 5: Commit**

Stage only the changed implementation and test files, then create the commit:

```powershell
git add lib/pages/start/audio_prompt_player.dart test/audio_prompt_player_test.dart
git commit -m "fix: limit audio prompts to 30 percent volume"
```
