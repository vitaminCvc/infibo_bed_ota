# Chose Users Keyboard Layout Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prevent the add-user keyboard from resizing the underlying chose-users page while leaving the popup fixed in place.

**Architecture:** Keep the existing `AppHeaderPage` API and override its keyboard-inset behavior only at the `ChoseUsersPage` call site. Allow a `ChoseUsersLogic` instance to be injected into the page so a real widget test can avoid the backend while measuring the root layout before and after keyboard insets. The popup already disables inset-driven resizing, so no popup or shared-component changes are required.

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
- Modify: `lib/pages/choseusers/ui.dart` at `ChoseUsersPage`, `_ChoseUsersPageState.initState`, and the `AppHeaderPage` returned by `_ChoseUsersPageState.build`

**Interfaces:**
- Consumes: `AppHeaderPage({bool resizeToAvoidBottomInset = true, ...})`
- Produces: `ChoseUsersPage({ChoseUsersLogic? logic})` and a root layout configured with `resizeToAvoidBottomInset: false`

- [ ] **Step 1: Write the failing regression test**

Create `test/choseusers_keyboard_layout_test.dart` with a widget test that injects a repository with no users, opens the real page, applies a 284-pixel keyboard inset, and checks that the page body keeps the same size.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infibo_app/pages/choseusers/logic.dart';
import 'package:infibo_app/pages/choseusers/ui.dart';
import 'package:infibo_app/stores/app_header_clock_store.dart';
import 'package:infibo_app/stores/user_store.dart';

void main() {
  testWidgets('chose users page stays fixed when keyboard opens', (
    WidgetTester tester,
  ) async {
    Get.testMode = true;
    tester.view.physicalSize = const Size(800, 1280);
    tester.view.devicePixelRatio = 1;
    Get.put(UserStore());
    Get.put<AppHeaderClockController>(_TestClockController());
    addTearDown(() {
      tester.view.resetViewInsets();
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      Get.reset();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        home: ChoseUsersPage(
          logic: ChoseUsersLogic(repository: _EmptyChoseUsersRepository()),
        ),
      ),
    );
    await tester.pump();

    final Finder pageBody = find.byType(SafeArea).first;
    final Size sizeBeforeKeyboard = tester.getSize(pageBody);

    tester.view.viewInsets = const FakeViewPadding(bottom: 284);
    await tester.pump();

    expect(tester.getSize(pageBody), sizeBeforeKeyboard);
  });
}

class _TestClockController extends AppHeaderClockController {
  @override
  void startClock() {}
}

class _EmptyChoseUsersRepository implements ChoseUsersRepository {
  @override
  Future<List<UserItemData>> listUsers() async => <UserItemData>[];

  @override
  Future<UserItemData> addUser(UserItemData user) async => user;

  @override
  Future<void> deleteUser(int id) async {}

  @override
  Future<void> dispose() async {}
}
```

- [ ] **Step 2: Run the test and verify RED**

Run:

```powershell
flutter test test/choseusers_keyboard_layout_test.dart
```

Expected: FAIL because the `SafeArea` height shrinks by 284 pixels when the `AppHeaderPage` still uses its default keyboard avoidance.

- [ ] **Step 3: Implement the minimal production change**

In `lib/pages/choseusers/ui.dart`, accept an optional testable logic dependency and initialize the state from it:

```dart
class ChoseUsersPage extends StatefulWidget {
  const ChoseUsersPage({super.key, this.logic});

  final ChoseUsersLogic? logic;

  @override
  State<ChoseUsersPage> createState() => _ChoseUsersPageState();
}
```

Change the state field and initialize it before `_loadUsers()`:

```dart
late final ChoseUsersLogic _logic;

@override
void initState() {
  super.initState();
  _logic = widget.logic ?? ChoseUsersLogic();
  _loadUsers();
}
```

Then change the root `AppHeaderPage` call:

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
