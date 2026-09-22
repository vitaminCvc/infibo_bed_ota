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

  test(
    'shows slow response after its configured delay but remains non-retryable',
    () async {
      final SavePlanFeedbackController controller = SavePlanFeedbackController(
        slowResponseAfter: Duration.zero,
      );
      final Completer<void> request = Completer<void>();

      controller.submit(() => request.future);
      await pumpEventQueue();

      expect(controller.state, SavePlanFeedbackState.slowResponse);
      expect(controller.canSubmit, isFalse);
      controller.dispose();
    },
  );

  test(
    'returns to retry state with the thrown error after a failed save',
    () async {
      final SavePlanFeedbackController controller =
          SavePlanFeedbackController();
      final StateError failure = StateError('network failed');

      await controller.submit(() => Future<void>.error(failure));

      expect(controller.state, SavePlanFeedbackState.retry);
      expect(controller.error, same(failure));
      expect(controller.canSubmit, isTrue);
      controller.dispose();
    },
  );
}
