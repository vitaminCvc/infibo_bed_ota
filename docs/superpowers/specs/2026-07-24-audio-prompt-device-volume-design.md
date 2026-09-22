# Audio Prompt Device Volume Design

## Goal

Play every asset in `assets/AudioPrompt/` at 30% of the tablet's current
system media volume.

## Approach

`AudioPromptPlayer` owns a separate `just_audio` player for each prompt asset.
The `JustAudioPromptBackend` will set its player volume to `0.3` before a
prompt starts. In `just_audio`, that is a relative gain multiplier, so the
tablet's system media volume remains authoritative and unchanged.

The background music player and its in-app volume control are out of scope.

## Error Handling

The existing safe playback wrappers continue to catch audio backend failures.
If applying the prompt volume fails, safe playback logs and skips the prompt
using the existing error path.

## Verification

Add a unit test that asserts a prompt backend receives `0.3` before playback.
Run the focused prompt-player test and static analysis for the changed files.
