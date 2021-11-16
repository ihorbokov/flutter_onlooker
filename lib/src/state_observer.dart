import 'dart:async';

import 'package:flutter/widgets.dart';

import 'state_notifier.dart';
import 'state_notifier_provider.dart';
import 'state_notifier_subscriber.dart';

/// Signature for the `builder` function which takes the `BuildContext` and
/// [state] and is responsible for returning a widget which is to be rendered.
typedef WidgetBuilder<S> = Widget Function(BuildContext context, S? state);

/// [StateObserver] handles building a widget in response to new `states`.
class StateObserver<N extends StateNotifier, S>
    extends StateNotifierSubscriber<N, S> {
  final N? notifier;
  final WidgetBuilder<S> builder;

  /// [StateObserver] rebuilds using [builder] function.
  /// An optional [notifier] can be passed directly.
  const StateObserver({
    Key? key,
    this.notifier,
    required this.builder,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StateObserverState<N, S>();
}

class _StateObserverState<N extends StateNotifier, S>
    extends StateNotifierSubscriberState<N, S, StateObserver<N, S>> {
  late final N? _stateNotifier;

  @override
  void initState() {
    _stateNotifier = widget.notifier ?? context.read<N>();
    super.initState();
  }

  @override
  S? get initialState => _stateNotifier?.initial<S>();

  @override
  void onNewState(S? state) => setState(() {});

  @override
  Stream<S?>? get stream => _stateNotifier?.getStateStream<S>();

  @override
  Widget build(BuildContext context) => widget.builder(context, currentState);
}
