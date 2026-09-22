# Summary Page Dual-Aspect Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep 16:10 summary behavior unchanged while making the 16:9 summary fixed, non-scrollable, vertically expanded, and keyboard-safe.

**Architecture:** Read the current layout profile from `AppLayoutScope`. Use the existing scroll canvas for 16:10 and a full-height fixed canvas for 16:9; calculate the feedback and confirmation positions from the available height and translate the 16:9 canvas by the actual keyboard inset.

**Tech Stack:** Flutter, Dart, `flutter_test`

## Global Constraints

- Preserve the user's existing visual and business-logic changes.
- Do not make the 16:9 summary page scrollable.
- Use a 221-unit feedback box and an 80-unit bottom margin for the confirmation button on 16:9.
- Keep the confirmation button 24 units above the keyboard when it is visible.

---

### Task 1: Lock the 16:9 geometry with failing tests

**Files:**
- Modify: `test/dual_aspect_layout_test.dart`

- [x] Add a widget test asserting no `SingleChildScrollView`, a 221-unit feedback card, and an 80-unit confirmation-button bottom margin.
- [x] Add a keyboard-inset test asserting the confirmation button remains at least 24 units above the keyboard.
- [x] Run both tests and confirm they fail against the previous scrollable implementation.

### Task 2: Implement the layout-profile branch

**Files:**
- Modify: `lib/pages/summary/summary.dart`

- [x] Read `AppLayoutScope.of(context).is16x9`.
- [x] Keep the existing fixed 800×1160 scroll view for 16:10.
- [x] Build 16:9 with a clipped, non-scrollable full-height canvas.
- [x] Calculate the button top from the canvas height, 56-unit button height, and 80-unit bottom margin.
- [x] Calculate the feedback top from the button top, 46-unit gap, and 221-unit feedback height.
- [x] Translate the 16:9 canvas by the keyboard inset while retaining a 24-unit visible gap.

### Task 3: Verify

**Files:**
- Test: `test/dual_aspect_layout_test.dart`

- [x] Run the two focused regression tests.
- [x] Run the complete dual-aspect test file.
- [x] Run static analysis on the modified source and test files.
- [ ] Build and install the global debug APK on the connected 16:9 tablet.
- [ ] Review the final diff and confirm unrelated dirty-worktree changes remain untouched.
