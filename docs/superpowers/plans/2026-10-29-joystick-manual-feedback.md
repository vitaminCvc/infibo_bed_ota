# Joystick Manual Feedback Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans for this authorized change in the current checkout.

**Goal:** Separate gesture-owned manual feedback from firmware-owned automatic feedback.

**Architecture:** Keep the serial write bus and existing polling lifecycle. Restrict 0x0011 decoding to 0/3/4, pause reads throughout local holds, and remove status-driven writes.

**Tech Stack:** Flutter, Dart, flutter_test.

**Spec:** docs/superpowers/specs/2026-10-29-joystick-manual-feedback-design.md

## Constraints and review focus

- Only infibo_ota; firmware must supply the newly agreed 0/3/4 statuses.
- Preserve one-second debounce, release/cancel stop, page ordering and stale-response rejection.
- Local holds must survive old reads and external broadcasts.
- No poll may write a movement or stop command to 0x0010.
- Unknown and legacy manual statuses must not create manual lights.

## Task 1: Update protocol and gesture ownership

**Files:** lib/pages/joystick/ui.dart; test/joystick_status_sync_test.dart; test/lift_pages_status_sync_test.dart; test/lift_current_test.dart.

**Interfaces:** Preserve JoystickControl and command bus entry points used by main/start pages.

- [x] Replace reconciliation test expectations with read-only polling, legacy-status rejection and local-hold ownership tests; verify expected failures.
- [x] Restrict status decoding, pause manual reads, ignore external feedback during holds, remove control comparison/writes and obsolete reconciliation state.
- [x] Run component/page/sequence/water-quality/OTA regression tests, formatting, static analysis and diff checks.

User authorized implementation; no additional design approval is needed. Leave changes uncommitted unless asked to commit.

## Verification

- Before implementation, the updated component/page tests reported 16 expected failures for legacy feedback decoding, manual polling and status-driven writes. The external broadcast test was additionally checked against the old handler after ensuring the stream-triggered frame had rendered; it failed without the local-hold guard and passed with it.
- Final relevant regression run: 129 tests passed across joystick_status_sync, lift_pages_status_sync, lift_current, main_lift_current, start_lift_sequence, start_stop_sequence, main_modbus_send_order, main_startup_polling, the four water_quality test files, firmware_ota_service and serial_session_gate.
- `dart analyze` on all four changed Dart files: no issues found. Formatting and `git diff --check` passed.
- Full project suite was not rerun for this change. Earlier full-suite failures remain documented in the water-quality implementation plan.
- Reviewed that manual command values 1/2, one-second debounce and release/cancel stop remain unchanged; status polling has no control writes. Physical Android/board validation remains outstanding, requiring matching 0/3/4 board firmware.
