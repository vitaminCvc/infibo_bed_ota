# Chose Users Keyboard Layout Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prevent the add-user keyboard from resizing the underlying chose-users page while leaving the popup fixed in place.

**Architecture:** Keep the existing `AppHeaderPage` API and override its keyboard-inset behavior only at the `ChoseUsersPage` call site. The popup already disables inset-driven resizing, so no popup or shared-component changes are required.

**Tech Stack:** Flutter, Dart, `flutter_test`

## Global Constraints

- The chose-users page and add-user popup remain at their original size and position while the soft keyboard is visible.
- The keyboard may cover the lower portion of the popup.
- Other `AppHeaderPage` consumers retain the current default behavior.
- Preserve all pre-existing staged and unstaged changes in `lib/pages/choseusers/ui.dart`.
- Do not commit the implementation files because the target file already contains user-owned staged and unstaged work that cannot be separated safely into a complete standalone commit.

---

### Task 1: Disable keyboard-driven resizing on the chose-users page

**Files:**
- Create: `test/choseusers_keyboard_layout_test.dart`
- Modify: `lib/pages/choseusers/ui.dart` at the `AppHeaderPage` returned by `_ChoseUsersPageState.build`

**Interfaces:**
- Consumes: `AppHeaderPage({bool resizeToAvoidBottomInset = true, ...})`
- Produces: `ChoseUsersPage` root layout configured with `resizeToAvoidBottomInset: false`

- [ ] **Step 1: Write the failing regression test**

Create `test/choseusers_keyboard_layout_test.dart` with a focused assertion against the chose-users root page declaration. This source-level regression test avoids introducing dependency-injection changes solely to construct a page whose state immediately starts a backend request.

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('chose users page disables keyboard-driven scaffold resizing', () {
    final String source = File(
      'lib/pages/choseusers/ui.dart',
    ).readAsStringSync();

    expect(
      RegExp(
        r'return AppHeaderPage\(\s*resizeToAvoidBottomInset: false,',
      ).hasMatch(source),
      isTrue,
      reason: 'The underlying page must stay fixed when the popup keyboard opens.',
    );
  });
}
```

- [ ] **Step 2: Run the test and verify RED**

Run:

```powershell
flutter test test/choseusers_keyboard_layout_test.dart
```

Expected: FAIL because the `AppHeaderPage` call does not yet contain `resizeToAvoidBottomInset: false`.

- [ ] **Step 3: Implement the minimal production change**

In `lib/pages/choseusers/ui.dart`, change only the root `AppHeaderPage` call:

```dart
return AppHeaderPage(
  resizeToAvoidBottomInset: false,
  // 点击添加用户按钮时调用
  children: [
```

- [ ] **Step 4: Format the changed Dart files**

Run:

```powershell
dart format lib/pages/choseusers/ui.dart test/choseusers_keyboard_layout_test.dart
```

Expected: both files format successfully without altering unrelated files.

- [ ] **Step 5: Run the focused test and verify GREEN**

Run:

```powershell
flutter test test/choseusers_keyboard_layout_test.dart
```

Expected: PASS.

- [ ] **Step 6: Run related regression tests**

Run:

```powershell
flutter test test/choseusers_popup_logic_test.dart test/choseusers_keyboard_layout_test.dart
```

Expected: all tests PASS.

- [ ] **Step 7: Run static analysis**

Run:

```powershell
flutter analyze lib/pages/choseusers/ui.dart test/choseusers_keyboard_layout_test.dart
```

Expected: no errors or warnings introduced by these files.

- [ ] **Step 8: Review the final scoped diff without committing user work**

Run:

```powershell
git diff -- lib/pages/choseusers/ui.dart test/choseusers_keyboard_layout_test.dart
git status --short -- lib/pages/choseusers/ui.dart test/choseusers_keyboard_layout_test.dart
```

Expected: the production delta for this task is the single `resizeToAvoidBottomInset: false` argument plus the new regression test. Leave both implementation files uncommitted so existing user-owned changes in `ui.dart` remain untouched.
