# Custom Plan Save Feedback Design

## Scope

Improve the naming dialog shown after a user saves a custom plan from the
custom-plan editor. The change applies to the editor dialog in
`lib/pages/customized/customizedPage/ui.dart`; it does not alter the separate
rename action in the custom-plan list.

## Problem

The dialog currently closes immediately after the user presses Confirm. The
save request then runs outside the dialog, with no in-progress state and no
recoverable presentation for a failed request. A user can submit again while a
previous request is still in flight.

## Selected Behaviour

The naming dialog owns a three-state save flow:

1. **Editing**: the name field, Cancel, and Save are enabled. Empty names show
   the existing validation message.
2. **Saving**: after Save is pressed, the dialog remains open. Its input,
   Cancel, and Save controls are disabled. A small `CircularProgressIndicator`
   and the localized message "正在保存，请稍后" are shown. Only one save future
   may be active.
3. **Retry available**: a failed request restores the entered name and enables
   Save again. The dialog displays a localized "保存失败，请重试" message. The
   user can then explicitly press Save once more.

The dialog closes and the editor navigates back only after `savePlan` resolves
successfully.

## Five-Second Rule

At five seconds without a response, the dialog changes its helper text to a
localized slow-response message, such as "保存响应较慢，请稍后", while retaining
the spinner and disabled controls. It must not offer retry at this point.

The HTTP client currently uses 10-second connect/send/receive timeouts. A
five-second UI timeout does not cancel a Dio request; releasing Save at five
seconds could submit a second create request while the first request later
succeeds, creating duplicate plans. Retry becomes available only when the
original request returns a failure or reaches its actual terminal timeout.

## Error Handling

- Preserve existing local validation errors, including empty or duplicate plan
  names, without starting a request.
- Convert both `CustomizedPlanNameException` and unexpected save errors into
  the retry-available state. Do not let an exception dismiss the dialog or
  leave its controls disabled.
- Keep the user-entered name and the generated plan parameters unchanged for
  every retry.
- Cancel the five-second display timer when the request reaches a terminal
  success or failure state and when the dialog is disposed.

## Data Flow

`_PlanNameDialog` receives an asynchronous save callback from the editor. It
owns transient dialog state and invokes the callback exactly once per tap.
`_showSaveDialog` constructs the stable save payload once and returns success
to the dialog only after `CustomizedEditLogic.savePlan` completes. The editor
calls `Get.back(result: true)` only after the dialog reports success.

## Localization

Add localized strings for the in-progress, slow-response, and retry messages
to every language map currently supported by `app_translations.dart`.

## Acceptance Criteria

- Repeated taps while saving issue one API call only.
- The dialog stays visible with a spinner during the save request.
- At five seconds, a slow-response message is visible and Save remains
  disabled.
- On success, the dialog and editor close exactly once.
- On backend rejection, network failure, or Dio timeout, the dialog remains
  visible, shows a retry message, and permits one new attempt.
- Existing name validation and editing an existing plan remain functional.
