# Silent Water Quality Read Failure Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans for this small change in the current checkout. Steps use checkbox syntax.

**Goal:** Suppress automatic water-quality dialogs on read failure while retaining retries and hydrogen guards.

**Architecture:** Keep the existing controller polling and error state. Change only failure visibility handling; preserve active anomaly dialogs and dismissal.

**Tech Stack:** Flutter / Dart, flutter_test.

**Spec:** docs/superpowers/specs/2026-10-29-silent-water-quality-read-failure-design.md

## Global Constraints

- Preserve home read ordering, genuine anomaly dialogs and hydrogen guards.
- No new timers or dependencies; work in the existing checkout.

## Review Focus

- Home retries use onHomeWaterPollComplete; start retries use poll.
- Recovery must restore hydrogen eligibility only after a valid normal read.
- Genuine anomaly after startup failure must still open its dialog.
- Failed reads must not reopen dismissed genuine anomalies.
- A previous success dialog must not turn into an unavailable dialog.

## Task 1: Suppress read-failure dialogs

**Files:** Modify lib/components/water_quality/water_quality_controller.dart; test/water_quality_controller_test.dart; test/water_quality_widget_test.dart.

**Interfaces:** Existing enterPage, poll, onHomeWaterPollComplete and checkHydrogenBeforeCommand APIs remain unchanged.

- [x] Add controller and real overlay regression tests for the cases above.
- [x] Run focused tests and confirm failure at visibility assertions.
- [x] Update _readTds failure branch: hide unavailable dialogs without changing visibility during an active anomaly.
- [x] Run water-quality tests and targeted static analysis; inspect diff.

Execution decision: user explicitly authorized the chosen behavior; implement directly without another approval round. Leave changes uncommitted for review.

## Verification results

- Before fix: six regression cases failed on dialog visibility as expected.
- After fix: all 40 tests in water_quality_controller_test.dart, water_quality_widget_test.dart, water_quality_home_integration_test.dart and water_quality_command_guard_test.dart passed.
- `dart analyze` on the three changed Dart files: no issues found. `git diff --check`: clean.
- Full `flutter test --reporter expanded`: 571 passed, 9 skipped, 16 failed. No baseline run was performed, so these failures are not claimed to be proven pre-existing. Failed tests:
  - app_brand_test.dart: AppBrands provides the exact configuration for every flavor
  - choseusers_popup_background_test.dart: all add-user popup text uses 18px font size
  - device_info_panel_test.dart: device information panel uses English content and scrolls
  - manual_firmware_install_test.dart: manual target 304 has a clear confirmation that can be cancelled
  - preset_configs_test.dart: preset identifiers and corrected parameters match the source table
  - uae_logo_size_test.dart: UAE home preserves full SVG dimensions
  - uae_logo_size_test.dart: UAE settings preserves full SVG dimensions
  - uae_logo_size_test.dart: UAE device preserves full SVG dimensions
  - widget_test.dart: gender values are localized for the current language
  - widget_test.dart: Chinese backend messages use translated fallback outside Chinese
  - widget_test.dart: mode card header places icon and translated title in one row
  - widget_test.dart: mode card title keeps its default position in English
  - wifi_bluetooth_system_gateway_test.dart: fresh Android permission is granted before Bluetooth devices are read
  - wifi_bluetooth_system_gateway_test.dart: Android accepts an Inmortal A2DP or headset connection
  - wifi_bluetooth_system_gateway_test.dart: returns the real name of the first matching Bluetooth device
  - wifi_bluetooth_system_gateway_test.dart: non-Android platforms use the GATT snapshot only
- Hardware startup timing has not been tested on a physical Android device.
