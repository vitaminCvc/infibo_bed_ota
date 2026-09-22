# Country Header Restoration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restore each country application's original header Logo dimensions, position, and spacing in the unified flavor project.

**Architecture:** Keep country-specific presentation data in `AppBrandConfig`. The three header components consume that data instead of assuming the global layout. Preserve original ordering for India, and use configured clock gaps for Spain.

**Tech Stack:** Flutter, Dart, flutter_test.

---

### Task 1: Specify Country Header Rules

**Files:**
- Modify: `test/app_brand_test.dart`
- Modify: `lib/config/app_brand.dart`

- [ ] **Step 1: Write the failing test**

Add assertions for global `242x44` leading, India `187x33` trailing with `-11` page inset, Spain `143x29` leading with `179` setting/user clock gaps, and Turkey `242x44` leading.

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/app_brand_test.dart`

Expected: FAIL because `AppBrandConfig` does not expose header layout rules.

- [ ] **Step 3: Write minimal implementation**

Add immutable header layout data to `AppBrandConfig` and populate the four original configurations.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/app_brand_test.dart`

Expected: PASS.

### Task 2: Consume Header Rules

**Files:**
- Modify: `lib/components/index.dart`
- Modify: `lib/components/settingindex.dart`
- Modify: `lib/components/userindex.dart`

- [ ] **Step 1: Use the configured Logo size**

Replace fixed `242x44` Image dimensions with `AppBrand.current.headerLayout.logoWidth` and `logoHeight`.

- [ ] **Step 2: Restore original row ordering and gaps**

Keep global and Turkey leading layouts. Use the original India trailing order and page right inset. Use Spain's original setting/user clock gap.

- [ ] **Step 3: Verify behavior**

Run: `flutter test test/app_brand_test.dart`

Expected: PASS.

### Task 3: Validate and Review

**Files:**
- Test: `test/app_brand_test.dart`

- [ ] **Step 1: Run focused checks**

Run: `flutter test test/app_brand_test.dart` and `flutter analyze lib/config/app_brand.dart lib/components/index.dart lib/components/settingindex.dart lib/components/userindex.dart`.

- [ ] **Step 2: Build one non-global flavor**

Run: `flutter build apk --debug --flavor india --target lib/main_india.dart`.

Expected: successful India APK build with restored header configuration.
