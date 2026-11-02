# Device Offline Status Plan

**Goal:** Add offline state to main and settings device information in both projects, using RGB(153,153,153) for label and indicator.

**Design:** Start offline before any valid 0x0006 response. A failed, timed-out or invalid state read sets offline. Successful reads restore ready, or fault for existing values 3/5. Poll every five seconds using the existing main cycle and a lifecycle-owned settings timer; do not repeat firmware-version reads. Share status decoding and translation keys. Preserve normal/fault colors and add offline translations for all 11 existing locales.

**Scope:** MainPage, DeviceInfo, shared device status enum, translations, UI regression tests and timer cleanup in existing device-info tests. Existing joystick work remains intact.

- [x] Reproduce missing offline behavior in real-page widget tests before implementation.
- [x] Implement three-state display, polling and translations in both projects.
- [x] Verify startup/pending response, timeout/disconnection, invalid response, fault/normal recovery, layouts, disposal and existing device-info/joystick/water regressions.

User authorized implementation directly. No commit, deployment or physical board action is included.

## Verification results

- 214 relevant regression tests passed, including the 16 new offline UI cases, existing firmware/app version checks, status-detection/settings-menu checks, joystick/page/sequence and water-quality tests. OTA project also ran firmware OTA and serial-session regressions.
- Offline label and status indicator are both exactly #999999. Verified initial pending reads, timeouts, disconnection, invalid register data, reconnect to normal/fault, both page layouts, localized English/French/Arabic, and late success/failure after unmount.
- Existing firmware tests now isolate firmware-register callbacks from the newly added status polling; firmware version is still read once per entry. Device-info test widgets are disposed to release the new status timers.
- Analysis has no new issues: DeviceInfo.dart retains the existing unused _RuntimeStatistics and filename-style diagnostics; the non-OTA project also retains the existing main-page unused connection_prompt_host import.
- Formatting and git diff whitespace checks passed. Full project suite and physical Android/board tests were not run for this change. No commits were created.
