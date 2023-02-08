import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_onlooker/src/state_notifier.dart';
import 'package:flutter_onlooker/src/state_notifier_provider.dart';
import 'package:flutter_onlooker/src/state_subscriber.dart';

/// Signature for the `buildWhen` function which takes the previous `state` and
/// the current `state` and is responsible for returning a [bool] which
/// determines whether to rebuild [StateObserver] with the current `state`.
typedef BuilderCondition<S> = bool Function(S previous, S current);

/// Signature for the `builder` function which takes the `BuildContext` and
/// [state] and is responsible for returning a widget which is to be rendered.
typedef WidgetBuilder<S> = Widget Function(BuildContext context, S state);

/// {@template state_observer}
/// [StateObserver] rebuilds using [builder] function in response
/// to new `states`.
///
/// An optional [notifier] can be passed directly.
///
/// An optional [buildWhen] can be implemented for more granular control over
/// how often [StateObserver] rebuilds.
/// {@endtemplate}
class StateObserver<N extends StateNotifier, S> extends StateSubscriber<S> {
  /// {@macro state_observer}
  const StateObserver({
    required this.builder,
    this.notifier,
    this.buildWhen,
    Key? key,
  }) : super(key: key);

  /// The function which will be invoked on each widget build.
  final WidgetBuilder<S> builder;

  /// An optional [StateNotifier] can be passed directly.
  final N? notifier;

  /// An optional function can be implemented for more granular control over
  /// how often [StateObserver] rebuilds.
  final BuilderCondition<S>? buildWhen;

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
