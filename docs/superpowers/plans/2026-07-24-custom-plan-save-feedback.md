# Custom Plan Save Feedback Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep the custom-plan naming dialog open during saving, prevent duplicate submissions, show a slow-response notice after five seconds, and allow an explicit retry after a terminal failure.

**Architecture:** A focused `SavePlanFeedbackController` owns save state and the five-second timer without widget dependencies. The editor page passes its existing `savePlan` call to that controller and renders the dialog from its state, preventing a second request while one is active.

**Tech Stack:** Flutter, Dart `Timer`, `ChangeNotifier`, GetX localization, `flutter_test`.

---

## File Structure

- Create: `lib/pages/customized/customizedPage/save_plan_feedback_controller.dart`
  - State transition: `editing -> saving -> slowResponse -> success | retry`.
- Modify: `lib/pages/customized/customizedPage/ui.dart:8-23, 1738-1764, 3465-3590`
  - Keep the dialog mounted while saving and render all save states.
- Modify: `lib/translation/app_translations.dart`
  - Add three status keys to all ten existing language maps.
- Create: `test/customized_save_feedback_controller_test.dart`
  - Test duplicate protection, five-second feedback, success, and retry.

### Task 1: Create controller tests

**Files:**
- Create: `test/customized_save_feedback_controller_test.dart`

- [ ] **Step 1: Write the failing tests**

```dart
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/pages/customized/customizedPage/save_plan_feedback_controller.dart';

void main() {
  test('submits only once while a request is pending', () async {
    final SavePlanFeedbackController controller = SavePlanFeedbackController();
    final Completer<void> request = Completer<void>();
    int calls = 0;

    controller.submit(() {
      calls += 1;
      return request.future;
    });
    controller.submit(() {
      calls += 1;
      return Future<void>.value();
    });

    expect(calls, 1);
    expect(controller.state, SavePlanFeedbackState.saving);
    request.complete();
    await pumpEventQueue();
    expect(controller.state, SavePlanFeedbackState.success);
    controller.dispose();
  });

  test('shows slow response after five seconds but remains non-retryable', () {
    fakeAsync((FakeAsync async) {
      final SavePlanFeedbackController controller = SavePlanFeedbackController();
      final Completer<void> request = Completer<void>();

      controller.submit(() => request.future);
      async.elapse(const Duration(seconds: 5));

      expect(controller.state, SavePlanFeedbackState.slowResponse);
      expect(controller.canSubmit, isFalse);
      controller.dispose();
    });
  });

  test('returns to retry state with the thrown error after a failed save', () async {
    final SavePlanFeedbackController controller = SavePlanFeedbackController();
    final StateError failure = StateError('network failed');

    await controller.submit(() => Future<void>.error(failure));

    expect(controller.state, SavePlanFeedbackState.retry);
    expect(controller.error, same(failure));
    expect(controller.canSubmit, isTrue);
    controller.dispose();
  });
}
```

- [ ] **Step 2: Verify that the test currently fails**

Run: `flutter test test/customized_save_feedback_controller_test.dart`

Expected: compilation failure because the controller file does not exist.

### Task 2: Implement the controller

**Files:**
- Create: `lib/pages/customized/customizedPage/save_plan_feedback_controller.dart`
- Test: `test/customized_save_feedback_controller_test.dart`

- [ ] **Step 1: Add the state enum and controller**

```dart
import 'dart:async';

import 'package:flutter/foundation.dart';

enum SavePlanFeedbackState { editing, saving, slowResponse, retry, success }

class SavePlanFeedbackController extends ChangeNotifier {
  SavePlanFeedbackState _state = SavePlanFeedbackState.editing;
  Timer? _slowResponseTimer;
  Object? _error;

  SavePlanFeedbackState get state => _state;
  Object? get error => _error;
  bool get canSubmit =>
      _state == SavePlanFeedbackState.editing ||
      _state == SavePlanFeedbackState.retry;

  Future<void> submit(Future<void> Function() save) async {
    if (!canSubmit) return;

    _error = null;
    _setState(SavePlanFeedbackState.saving);
    _slowResponseTimer = Timer(const Duration(seconds: 5), () {
      if (_state == SavePlanFeedbackState.saving) {
        _setState(SavePlanFeedbackState.slowResponse);
      }
    });

    try {
      await save();
      _setState(SavePlanFeedbackState.success);
    } catch (error) {
      _error = error;
      _setState(SavePlanFeedbackState.retry);
    } finally {
      _slowResponseTimer?.cancel();
      _slowResponseTimer = null;
    }
  }

  void _setState(SavePlanFeedbackState value) {
    if (_state == value) return;
    _state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _slowResponseTimer?.cancel();
    super.dispose();
  }
}
```

- [ ] **Step 2: Run the controller test**

Run: `flutter test test/customized_save_feedback_controller_test.dart`

Expected: PASS.

- [ ] **Step 3: Commit**

```powershell
git add lib/pages/customized/customizedPage/save_plan_feedback_controller.dart test/customized_save_feedback_controller_test.dart
git commit -m "feat: guard custom plan saves"
```

### Task 3: Wire the dialog to the controller

**Files:**
- Modify: `lib/pages/customized/customizedPage/ui.dart:8-23, 1738-1764, 3465-3590`
- Test: `test/customized_save_feedback_controller_test.dart`

- [ ] **Step 1: Construct a stable save payload and wait for dialog success**

Replace the current `showDialog<String>` result flow with:

```dart
Future<void> _showSaveDialog() async {
  final List<String> featureIds = _buildPlanFeatureIds();
  final int durationMinutes = _selectedDurationMinutes();
  final bool? didSave = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => _PlanNameDialog(
      controller: _nameController,
      onSave: (String name) => _logic.savePlan(
        name: name,
        featureIds: featureIds,
        durationMinutes: durationMinutes,
      ),
    ),
  );

  if (didSave == true && mounted) {
    Get.back(result: true);
  }
}
```

- [ ] **Step 2: Convert `_PlanNameDialog` into a `StatefulWidget`**

Add `required this.onSave` with type `Future<void> Function(String name)`.
Its state owns and disposes a `SavePlanFeedbackController`. Implement the
confirm handler exactly as follows:

```dart
Future<void> _submit() async {
  final String name = widget.controller.text.trim();
  if (name.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('plan_name_empty'.tr)),
    );
    return;
  }

  await _saveFeedback.submit(() => widget.onSave(name));
  if (!mounted || _saveFeedback.state != SavePlanFeedbackState.success) {
    return;
  }
  Navigator.of(context).pop(true);
}
```

Use `AnimatedBuilder(animation: _saveFeedback, ...)` for the dialog body.
When `canSubmit` is false, set `enabled: false` on the text field and set
both button callbacks to `null`. Update `_PlanNameDialogButton.onTap` to
`VoidCallback?` so a null callback disables its `GestureDetector`.

Render:
- `CircularProgressIndicator(strokeWidth: 2)` plus `plan_saving.tr` for
  `saving`;
- the same indicator plus `plan_save_slow.tr` for `slowResponse`;
- `plan_save_retry.tr` for `retry`, except show
  `CustomizedPlanNameException.message` when that is the captured error.

Only the success path calls `Navigator.pop(true)`; the retry path retains the
name and the stable payload for a new explicit submit.

- [ ] **Step 3: Run focused checks**

Run: `flutter test test/customized_save_feedback_controller_test.dart test/customized_logic_test.dart`

Expected: PASS.

Run: `flutter analyze lib/pages/customized/customizedPage/ui.dart lib/pages/customized/customizedPage/save_plan_feedback_controller.dart`

Expected: no diagnostics introduced by this change.

- [ ] **Step 4: Commit**

```powershell
git add lib/pages/customized/customizedPage/ui.dart
git commit -m "feat: show custom plan save progress"
```

### Task 4: Add localized messages and final verification

**Files:**
- Modify: `lib/translation/app_translations.dart`
- Test: `test/customized_save_feedback_controller_test.dart`

- [ ] **Step 1: Add the three keys next to `save_plan` in every locale map**

```dart
// Chinese
'plan_saving': '正在保存，请稍后',
'plan_save_slow': '保存响应较慢，请稍后',
'plan_save_retry': '保存失败，请重试',
// English
'plan_saving': 'Saving, please wait',
'plan_save_slow': 'Saving is taking longer than expected, please wait',
'plan_save_retry': 'Save failed, please try again',
// Spanish
'plan_saving': 'Guardando, espere por favor',
'plan_save_slow': 'El guardado tarda más de lo esperado, espere por favor',
'plan_save_retry': 'Error al guardar, inténtelo de nuevo',
// Portuguese
'plan_saving': 'Salvando, aguarde',
'plan_save_slow': 'O salvamento está demorando, aguarde',
'plan_save_retry': 'Falha ao salvar, tente novamente',
// Russian
'plan_saving': 'Сохранение, пожалуйста, подождите',
'plan_save_slow': 'Сохранение занимает больше времени, пожалуйста, подождите',
'plan_save_retry': 'Не удалось сохранить, повторите попытку',
// French
'plan_saving': 'Enregistrement en cours, veuillez patienter',
'plan_save_slow': 'La réponse d’enregistrement est plus longue que prévu, veuillez patienter',
'plan_save_retry': 'Échec de l’enregistrement, veuillez réessayer',
// Korean
'plan_saving': '저장 중입니다. 잠시만 기다려 주세요',
'plan_save_slow': '저장 응답이 지연되고 있습니다. 잠시만 기다려 주세요',
'plan_save_retry': '저장하지 못했습니다. 다시 시도해 주세요',
// Arabic
'plan_saving': 'جارٍ الحفظ، يرجى الانتظار',
'plan_save_slow': 'يستغرق الحفظ وقتًا أطول، يرجى الانتظار',
'plan_save_retry': 'فشل الحفظ، يرجى المحاولة مرة أخرى',
// German
'plan_saving': 'Wird gespeichert, bitte warten',
'plan_save_slow': 'Das Speichern dauert länger als erwartet, bitte warten',
'plan_save_retry': 'Speichern fehlgeschlagen, bitte erneut versuchen',
// Turkish
'plan_saving': 'Kaydediliyor, lütfen bekleyin',
'plan_save_slow': 'Kaydetme yanıtı gecikiyor, lütfen bekleyin',
'plan_save_retry': 'Kaydetme başarısız oldu, lütfen tekrar deneyin',
```

- [ ] **Step 2: Verify localization coverage**

Run: `rg -n "'plan_(saving|save_slow|save_retry)'" lib/translation/app_translations.dart`

Expected: 30 matches: three keys in each of ten locale maps.

- [ ] **Step 3: Run all focused automated checks**

Run: `flutter test test/customized_save_feedback_controller_test.dart test/customized_logic_test.dart`

Expected: PASS.

Run: `flutter analyze lib/pages/customized/customizedPage/ui.dart lib/pages/customized/customizedPage/save_plan_feedback_controller.dart lib/translation/app_translations.dart`

Expected: no diagnostics introduced by this change.

- [ ] **Step 4: Manual acceptance check**

Open a custom plan, press Save Plan, and enter a valid name. Confirm the
dialog stays open with a spinner until success. With the API delayed beyond five
seconds, confirm the slow-response notice appears and Save remains disabled.
With a backend rejection or network failure, confirm the dialog retains the
name, displays retry feedback, and allows one new save attempt. Rapid repeated
taps during any pending request must produce one create or update request.

- [ ] **Step 5: Commit**

```powershell
git add lib/translation/app_translations.dart
git commit -m "feat: localize custom plan save status"
```
