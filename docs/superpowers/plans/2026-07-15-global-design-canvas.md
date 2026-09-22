# Global Design Canvas Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Apply one centered 800 x 1280 `BoxFit.contain` transform to the whole Flutter application so every route and overlay uses the same logical viewport and device scale.

**Architecture:** `GetMaterialApp.builder` places `DesignCanvas` above the Navigator. `DesignCanvas` provides a fixed 800 x 1280 `MediaQuery`, lays out the Navigator at that size, and performs the only device-dependent transform; page-level wrappers are removed to prevent nested scaling.

**Tech Stack:** Flutter, Dart, GetX routing, `flutter_test`

---

## File Structure

- Create `test/design_canvas_test.dart`: focused widget and root integration regression tests.
- Modify `lib/components/designCanvas/design.dart`: fixed logical viewport, safe-area normalization, letterbox background, contain transform.
- Modify `lib/routes/index.dart`: root-level `DesignCanvas` installation.
- Modify `lib/components/index.dart`: remove nested canvas from the standard header shell.
- Modify `lib/components/userindex.dart`: remove nested canvas from the user header shell.
- Modify `lib/components/settingindex.dart`: remove nested canvas from the settings header shell.
- Modify `lib/pages/login/login/ui.dart`: remove nested canvas from login.
- Modify `lib/pages/login/register/register.dart`: remove nested canvas from registration.
- Modify `lib/pages/login/forgetpassword/forget.dart`: remove nested canvas from password reset.

### Task 1: Lock Down Fixed Canvas Behavior

**Files:**
- Create: `test/design_canvas_test.dart`
- Modify: `lib/components/designCanvas/design.dart`

- [ ] **Step 1: Write the failing widget test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/components/designCanvas/design.dart';

void main() {
  testWidgets('uses a fixed logical viewport and centered contain scale', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final GlobalKey canvasChildKey = GlobalKey();
    Size? logicalSize;
    EdgeInsets? logicalPadding;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(1000, 1000),
          padding: EdgeInsets.all(24),
          viewPadding: EdgeInsets.all(24),
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: DesignCanvas(
            child: Builder(
              builder: (BuildContext context) {
                logicalSize = MediaQuery.sizeOf(context);
                logicalPadding = MediaQuery.paddingOf(context);
                return ColoredBox(
                  key: canvasChildKey,
                  color: Colors.red,
                );
              },
            ),
          ),
        ),
      ),
    );

expect(logicalSize, const Size(800, 1280));
    expect(logicalPadding, EdgeInsets.zero);
    expect(
      tester.getTopLeft(find.byKey(canvasChildKey)),
      const Offset(187.5, 0),
    );
    expect(
      tester.getBottomRight(find.byKey(canvasChildKey)),
      const Offset(812.5, 1000),
    );
  });
}
```

- [ ] **Step 2: Run the test and verify RED**

Run:

```powershell
flutter test test/design_canvas_test.dart --plain-name "uses a fixed logical viewport and centered contain scale"
```

Expected: FAIL because descendants still observe the host `MediaQuery` size and padding.

- [ ] **Step 3: Implement the minimal fixed viewport**

Update `DesignCanvas` to expose a design-size constant, normalize safe-area geometry, center an 800 x 1280 child with `BoxFit.contain`, and paint unused space with `AppTheme.primaryColor`:

```dart
class DesignCanvas extends StatelessWidget {
  const DesignCanvas({super.key, required this.child});

  static const Size designSize = Size(800, 1280);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData designMediaQuery = MediaQuery.of(context).copyWith(
      size: designSize,
      padding: EdgeInsets.zero,
      viewPadding: EdgeInsets.zero,
      systemGestureInsets: EdgeInsets.zero,
      displayFeatures: const <DisplayFeature>[],
    );

    return ColoredBox(
      color: AppTheme.primaryColor,
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          child: SizedBox.fromSize(
            size: designSize,
            child: MediaQuery(data: designMediaQuery, child: child),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run the focused test and verify GREEN**

Run the command from Step 2. Expected: PASS.

### Task 2: Install the Canvas Above Navigation

**Files:**
- Modify: `test/design_canvas_test.dart`
- Modify: `lib/routes/index.dart`

- [ ] **Step 1: Add the failing root integration test**

Add this import:

```dart
import 'package:infibo_app/routes/index.dart';
```

Then add the test inside `main`:

```dart
testWidgets('root installs exactly one canvas above the Navigator', (
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    getRootWidget(initialRoute: '/login', locale: const Locale('zh', 'CN')),
  );
  await tester.pump();

  expect(find.byType(DesignCanvas), findsOneWidget);
  expect(
    find.descendant(
      of: find.byType(DesignCanvas),
      matching: find.byType(Navigator),
    ),
    findsOneWidget,
  );
});
```

- [ ] **Step 2: Run the integration test and verify RED**

Run:

```powershell
flutter test test/design_canvas_test.dart --plain-name "root installs exactly one canvas above the Navigator"
```

Expected: FAIL because the existing canvas is below the Navigator.

- [ ] **Step 3: Add the root builder**

Import `DesignCanvas` in `lib/routes/index.dart` and add:

```dart
builder: (BuildContext context, Widget? child) {
  return DesignCanvas(child: child ?? const SizedBox.shrink());
},
```

Expected intermediate state: the test reports two canvases because the login page still contains its page-level wrapper.

### Task 3: Remove Nested Page Canvases

**Files:**
- Modify: `lib/components/index.dart`
- Modify: `lib/components/userindex.dart`
- Modify: `lib/components/settingindex.dart`
- Modify: `lib/pages/login/login/ui.dart`
- Modify: `lib/pages/login/register/register.dart`
- Modify: `lib/pages/login/forgetpassword/forget.dart`

- [ ] **Step 1: Remove shared-shell wrappers**

In each shared header file, remove the `design.dart` import and replace:

```dart
body: DesignCanvas(
  child: SizedBox(...),
),
```

with:

```dart
body: SizedBox(...),
```

- [ ] **Step 2: Remove authentication-page wrappers**

Remove the `design.dart` import from all three authentication files and return each existing `Scaffold` directly instead of wrapping it in `DesignCanvas`. Do not change any child widget, timer, form, or navigation behavior.

- [ ] **Step 3: Verify there is one production installation point**

Run:

```powershell
rg -n --glob '*.dart' "DesignCanvas" lib
```

Expected matches: the class declaration in `design.dart` and the root builder use in `routes/index.dart` only.

- [ ] **Step 4: Run both regression tests and verify GREEN**

Run:

```powershell
flutter test test/design_canvas_test.dart
```

Expected: PASS with two tests.

### Task 4: Format and Verify

**Files:**
- Modify mechanically: all Dart files changed above.

- [ ] **Step 1: Format only task files**

```powershell
dart format lib/components/designCanvas/design.dart lib/routes/index.dart lib/components/index.dart lib/components/userindex.dart lib/components/settingindex.dart lib/pages/login/login/ui.dart lib/pages/login/register/register.dart lib/pages/login/forgetpassword/forget.dart test/design_canvas_test.dart
```

- [ ] **Step 2: Run focused static analysis**

```powershell
flutter analyze lib/components/designCanvas/design.dart lib/routes/index.dart lib/components/index.dart lib/components/userindex.dart lib/components/settingindex.dart lib/pages/login/login/ui.dart lib/pages/login/register/register.dart lib/pages/login/forgetpassword/forget.dart test/design_canvas_test.dart
```

Expected: no new analyzer errors.

- [ ] **Step 3: Run the full test suite**

```powershell
flutter test
```

Expected: all tests pass. Report any unrelated pre-existing failure with its exact test name.

- [ ] **Step 4: Inspect the final diff**

```powershell
git diff -- lib/components/designCanvas/design.dart lib/routes/index.dart lib/components/index.dart lib/components/userindex.dart lib/components/settingindex.dart lib/pages/login/login/ui.dart lib/pages/login/register/register.dart lib/pages/login/forgetpassword/forget.dart test/design_canvas_test.dart
```

Confirm that authentication and shared-shell changes only remove nested wrappers/imports and that existing user edits remain intact.

## Commit Policy

Do not create an implementation commit in this working tree. Several target files already contain overlapping user changes, so a path-limited commit would still bundle unrelated edits from those files. Leave the verified implementation unstaged for the user to review.
