import 'dart:async';

import 'package:flutter/widgets.dart';

import 'state_notifier.dart';
import 'state_observer.dart';

abstract class StateNotifierSubscriber<N extends StateNotifier, S>
    extends StatefulWidget {
  final Condition<S>? condition;

  const StateNotifierSubscriber({Key? key, this.condition}) : super(key: key);
}

abstract class StateNotifierSubscriberState<N extends StateNotifier, S,
    T extends StateNotifierSubscriber<N, S>> extends State<T> {
  StreamSubscription<S?>? _subscription;

  S? currentState;
  S? previousState;

  @protected
  Stream<S?>? get stream;

  @protected
  S? get initialState => null;

  @override
  void initState() {
    super.initState();
    currentState = initialState;
    _subscribe();
  }

  @protected
  void onNewState(covariant S? state);

  void _subscribe() => _subscription = stream?.listen(_handleState);

  void _handleState(S? state) {
    if (widget.condition?.call(previousState, state) ?? true) {
      previousState = currentState;
      currentState = state;
      onNewState(state);
    }
  }

  void _unsubscribe() => _subscription?.cancel();

  @protected
  void resubscribe() {
    _unsubscribe();
    _subscribe();
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }
}
