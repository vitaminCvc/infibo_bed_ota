import 'dart:async';

import 'package:flutter/foundation.dart';

enum SavePlanFeedbackState { editing, saving, slowResponse, retry, success }

class SavePlanFeedbackController extends ChangeNotifier {
  SavePlanFeedbackController({
    this.slowResponseAfter = const Duration(seconds: 5),
  });

  final Duration slowResponseAfter;

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
    _slowResponseTimer = Timer(slowResponseAfter, () {
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
