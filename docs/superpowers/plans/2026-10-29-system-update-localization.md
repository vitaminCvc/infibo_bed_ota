# System Update Localization and Layout

**Goal:** Complete the existing 11 locales for the OTA system update screen and keep the English firmware title and update status on the same row.

**Design:** Preserve Chinese, English and Polish translations, add native Spanish, Portuguese, Russian, French, Korean, Arabic, German and Turkish for all 92 OTA strings. Preserve placeholders and firmware/install semantics. Use bounded flexible header columns instead of a wrapping list, allowing long translations and large text to wrap within their own columns. Use directional spacing/borders and LTR version numbers under RTL. Keep confirmations, release-note locale selection and progress overlay localized.

**Scope:** infibo_ota; the other app has no system update screen. Two independent translation tasks supply the native locale tables, while the root handles integration, layout and verification. User authorized implementation; do not commit or alter existing unrelated changes.

- [x] Reproduce English header alignment and missing native translation wiring in tests.
- [x] Wire all translations and implement adaptive directional layout.
- [x] Verify all 11 languages at normal/narrow widths and large text, confirmations, progress and real settings page; review rendered samples and regression checks.

## Font and RTL findings

The original Microsoft YaHei asset does not include Arabic or Hangul glyphs. Added the OFL-licensed Noto Sans Arabic font and a static Hangul/Jamo derivative of Noto Sans KR, registered as OTA-specific fallbacks. Licenses are included in bundled assets; source and derivation details are in assets/fonts/OTA-FONTS.md. These fonts preserve the primary font for other scripts. Arabic timestamps use an LTR isolate and version/upgrade numbers keep LTR order within RTL layouts.

## Verification

- Before changes, tests reproduced English firmware title/status on separate rows and untranslated locale fallback to English.
- 194 relevant tests passed across all 11 locale page/confirmation cases, 44 localized progress-stage cases, settings integration, update controller/transport/service, localized release notes, menu localization and UAE OTA configuration.
- Capture run: 71 tests passed including previews. Inspected English, German, Arabic and Korean panel/confirmation renderings; English firmware title and available-update status each fit on a single line at 411 px. Verified narrow 320 px at 2x text scale, RTL direction, cancellation restrictions and no unintended downloads.
- Static analysis of changed OTA files and tests reports no issues; formatting and whitespace checks pass. Full project suite and physical Android screen validation were not performed. Changes remain uncommitted.
- This completes built-in UI localization. Release-note content still uses the server's notes_i18n entries and existing fallback policy; the app does not invent translations for administrator-authored notes.
