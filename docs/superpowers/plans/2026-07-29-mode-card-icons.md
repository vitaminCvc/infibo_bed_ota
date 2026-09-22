# Mode Card Icons Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the ten preset card backgrounds and render each localized title beside its separately declared icon with a 5 logical-pixel gap.

**Architecture:** Keep the existing `_ModeCard` stack and page positioning. Extend `_ModeCardData` with an icon asset and header coordinates, then replace the title-only overlay with a `Row` containing the icon, `SizedBox(width: 5)`, and `titleKey.tr`.

**Tech Stack:** Flutter, Dart, GetX translations, Flutter widget tests

---

### Task 1: Lock the header-row behavior with a widget test

**Files:**
- Modify: `test/widget_test.dart`

- [ ] Add a widget test that pumps `MainPage`, finds the translated deep-relax title, and verifies its nearest `Row` contains an `Image`, a `SizedBox(width: 5)`, and the title `Text` in that order.
- [ ] Run `flutter test test/widget_test.dart --plain-name "mode card header places icon and translated title in one row"` and confirm it fails because the current title has no `Row` ancestor.

### Task 2: Install and declare the preset artwork

**Files:**
- Replace: `assets/Mode/AntiAging.png`
- Replace: `assets/Mode/DeepRelaxation.png`
- Replace: `assets/Mode/EmotonnalHealing.png`
- Replace: `assets/Mode/EnergyBoost.png`
- Replace: `assets/Mode/FullCare.png`
- Replace: `assets/Mode/ImmuneBoost.png`
- Replace: `assets/Mode/PainRelief.png`
- Replace: `assets/Mode/SleepEnhancement.png`
- Replace: `assets/Mode/SportsRehabilitation.png`
- Replace: `assets/Mode/StressRelief.png`
- Create: `assets/Mode/AntiAging_Icon.png`
- Create: `assets/Mode/DeepRelaxation_Icon.png`
- Create: `assets/Mode/EmotionalHealing_Icon.png`
- Create: `assets/Mode/EnergyBoost_Icon.png`
- Create: `assets/Mode/FullCare_Icon.png`
- Create: `assets/Mode/ImmuneBoost_Icon.png`
- Create: `assets/Mode/PainRelief_Icon.png`
- Create: `assets/Mode/SleepEnhancement_Icon.png`
- Create: `assets/Mode/SportsRehabilitation_Icon.png`
- Create: `assets/Mode/StressRelief_Icon.png`
- Modify: `lib/constants/assets.dart`

- [ ] Copy each supplied background over its semantic existing asset while preserving its original dimensions.
- [ ] Copy and rename each supplied icon according to the confirmed existing-card mapping.
- [ ] Add lowerCamelCase icon constants such as `antiAgingIcon` pointing to the semantic `_Icon.png` paths.

### Task 3: Render semantic icons and localized titles in one row

**Files:**
- Modify: `lib/pages/main/ui.dart`

- [ ] Add `iconAsset`, `headerLeft`, and `headerTop` to `_ModeCardData` and populate all ten cards using their semantic `Assets` icon constants and original icon origins.
- [ ] Replace the title-only `Positioned` widget with `Positioned(left: item.headerLeft, top: item.headerTop, child: Row(...))`.
- [ ] Use the icon at its intrinsic size, `const SizedBox(width: 5)`, and the existing translated title style and overflow behavior.
- [ ] Run the focused widget test and confirm it passes.

### Task 4: Verify the complete change

**Files:**
- Verify all files above

- [ ] Run `dart format lib/constants/assets.dart lib/pages/main/ui.dart test/widget_test.dart`.
- [ ] Run the focused widget test again.
- [ ] Run `flutter analyze lib/constants/assets.dart lib/pages/main/ui.dart test/widget_test.dart`.
- [ ] Compare all twenty asset dimensions and verify every new background matches its card width and every icon path exists.
- [ ] Review `git diff` to confirm no unrelated edits were overwritten.
