# Login Authentication Feedback Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Show clear authentication feedback for registration, login, and password reset API responses.

**Architecture:** Add a small pure-Dart classifier for known backend authentication failures. Each page resolves its API message through the classifier, preserves unknown backend messages, and uses localized fallback text when the backend does not provide a useful response.

**Tech Stack:** Flutter, Dart, GetX, flutter_test.

---

### Task 1: Classify authentication failures

**Files:**
- Create: `lib/utils/auth_feedback.dart`
- Test: `test/auth_feedback_test.dart`

- [ ] **Step 1: Write failing tests**

```dart
expect(AuthFailureClassifier.classify('This account is already registered'),
    AuthFailure.accountAlreadyRegistered);
expect(AuthFailureClassifier.classify('Password is incorrect'),
    AuthFailure.invalidPassword);
expect(AuthFailureClassifier.classify('Verification code has expired'),
    AuthFailure.invalidVerificationCode);
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/auth_feedback_test.dart`
Expected: FAIL because `auth_feedback.dart` does not exist.

- [ ] **Step 3: Implement the classifier and message resolver**

```dart
enum AuthFailure { accountAlreadyRegistered, accountNotRegistered, invalidPassword, invalidVerificationCode, unknown }

class AuthFailureClassifier {
  static AuthFailure classify(String message) { /* normalize English and Chinese backend messages */ }
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/auth_feedback_test.dart`
Expected: PASS.

### Task 2: Use classified API feedback in login flows

**Files:**
- Modify: `lib/pages/login/login/ui.dart`
- Modify: `lib/pages/login/register/register.dart`
- Modify: `lib/pages/login/forgetpassword/forget.dart`

- [ ] **Step 1: Replace generic failed-request feedback with the shared resolver**

```dart
final String message = resolveAuthApiMessage(
  result.message,
  fallbackKey: 'login_failed',
);
```

- [ ] **Step 2: Add missing input validation, exception handling, and success handling**

```dart
if (result.isSuccess) {
  showFeedback(result.message, fallbackKey: 'register_success');
  await Future<void>.delayed(const Duration(milliseconds: 1200));
  Get.offNamed('/login');
}
```

- [ ] **Step 3: Verify all login-related tests and static analysis**

Run: `flutter test test/auth_feedback_test.dart; flutter analyze lib/pages/login lib/utils/auth_feedback.dart`
Expected: tests pass and analyzer reports no new issues in the modified sources.
