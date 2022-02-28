import 'dart:async';

import 'package:flutter/widgets.dart';

import 'state_notifier.dart';
import 'state_notifier_provider.dart';
import 'state_subscriber.dart';

/// Signature for the `buildWhen` function which takes the previous `state` and
/// the current `state` and is responsible for returning a [bool] which
/// determines whether to rebuild [StateObserver] with the current `state`.
typedef BuilderCondition<S> = bool Function(S previous, S current);

/// Signature for the `builder` function which takes the `BuildContext` and
/// [state] and is responsible for returning a widget which is to be rendered.
typedef WidgetBuilder<S> = Widget Function(BuildContext context, S state);

/// [StateObserver] handles building a widget in response to new `states`.
class StateObserver<N extends StateNotifier, S> extends StateSubscriber<S> {
  final N? notifier;
  final BuilderCondition<S>? buildWhen;
  final WidgetBuilder<S> builder;

  /// [StateObserver] rebuilds using [builder] function.
  ///
  /// An optional [notifier] can be passed directly.
  ///
  /// An optional [buildWhen] can be implemented for more granular control over
  /// how often [StateObserver] rebuilds.
  const StateObserver({
    Key? key,
    this.notifier,
    this.buildWhen,
    required this.builder,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StateObserverState<N, S>();
}

class _StateObserverState<N extends StateNotifier, S>
    extends StateSubscriberState<S, StateObserver<N, S>> {
  late N _stateNotifier = widget.notifier ?? context.read<N>();

  late S _state = _initialState;

  S get _initialState {
    final initial = _stateNotifier.initial<S>();
    final latest = _stateNotifier.latest<S>();
    return initial != latest ? latest : initial;
  }

  @override
  void didUpdateWidget(covariant StateObserver<N, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldStateNotifier = oldWidget.notifier ?? context.read<N>();
    final currentStateNotifier = widget.notifier ?? oldStateNotifier;
    if (oldStateNotifier != currentStateNotifier) {
      _stateNotifier = currentStateNotifier;
      resubscribe();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final stateNotifier = widget.notifier ?? context.read<N>();
    if (_stateNotifier != stateNotifier) {
      _stateNotifier = stateNotifier;
      resubscribe();
    }
  }

  @override
  void onNewState(S state) {
    if (widget.buildWhen?.call(_state, state) ?? true) {
      setState(() => _state = state);
    }
  }

  @override
  Stream<S>? get stream => _stateNotifier.getStateStream<S>();

  @override
  Widget build(BuildContext context) => widget.builder(context, _state);
}
