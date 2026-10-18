import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

enum TourStep {
  add,
  brand,
  name,
  price,
  date,
  reminders,
  save,
  record,
  calendar,
  filter,
  settings,
}

const editorTourSteps = {
  TourStep.name,
  TourStep.price,
  TourStep.date,
  TourStep.reminders,
  TourStep.save,
};

class TourState {
  const TourState(this.step, {this.paused = false, this.stepReady = true});
  final TourStep? step;
  final bool paused;
  final bool stepReady;
}

class GuidedTourController extends Notifier<TourState> {
  final keys = <String, GlobalKey>{};
  final geometry = ValueNotifier<int>(0);
  bool _disposed = false;
  int _modalDepth = 0;
  int firstStepIndex = 0;
  bool Function(TourStep step)? _validator;
  @override
  TourState build() {
    ref.onDispose(() {
      _disposed = true;
      geometry.dispose();
    });
    return const TourState(null);
  }

  GlobalKey keyFor(String id) =>
      keys.putIfAbsent(id, () => GlobalKey(debugLabel: 'tour-$id'));
  void changedGeometry() {
    if (!_disposed) geometry.value++;
  }

  bool _isReady(TourStep? step) =>
      step == null ? true : (_validator?.call(step) ?? true);

  void registerValidator(bool Function(TourStep step) validator) {
    _validator = validator;
    WidgetsBinding.instance.addPostFrameCallback((_) => refreshStepReady());
  }

  void unregisterValidator(bool Function(TourStep step) validator) {
    if (_validator == validator) _validator = null;
  }

  void refreshStepReady() {
    if (_disposed || state.step == null) return;
    final ready = _isReady(state.step);
    if (state.stepReady != ready) {
      state = TourState(state.step, paused: state.paused, stepReady: ready);
    }
  }

  void start({bool existing = false}) {
    _modalDepth = 0;
    firstStepIndex = existing ? TourStep.record.index : 0;
    final initial = existing ? TourStep.record : TourStep.add;
    state = TourState(initial, stepReady: _isReady(initial));
  }

  void move(TourStep step) {
    if (!_disposed && state.step != null) {
      state = TourState(step, stepReady: _isReady(step));
    }
  }

  void advanceIf(TourStep expected, TourStep next) {
    if (state.step == expected) move(next);
  }

  void next() {
    final step = state.step;
    if (step != null && step != TourStep.settings && _isReady(step)) {
      move(TourStep.values[step.index + 1]);
    }
  }

  void back() {
    final step = state.step;
    if (step != null && editorTourSteps.contains(step) && step != TourStep.name) {
      move(TourStep.values[step.index - 1]);
    }
  }

  void editorClosed() {
    if (_disposed || !editorTourSteps.contains(state.step)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed && editorTourSteps.contains(state.step)) {
        move(TourStep.add);
      }
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  Future<void> finish() async {
    state = const TourState(null);
    final prefs = await ref.read(preferencesProvider.future);
    await prefs.setBool('guidedTourComplete', true);
  }

  Future<T> withModal<T>(Future<T> Function() action) async {
    final active = state.step != null;
    if (active) {
      _modalDepth++;
      state = TourState(
        state.step,
        paused: true,
        stepReady: _isReady(state.step),
      );
    }
    try {
      return await action();
    } finally {
      if (active && !_disposed) {
        _modalDepth--;
        state = TourState(
          state.step,
          paused: _modalDepth > 0,
          stepReady: _isReady(state.step),
        );
        changedGeometry();
      }
    }
  }
}

final guidedTourProvider = NotifierProvider<GuidedTourController, TourState>(
  GuidedTourController.new,
);
