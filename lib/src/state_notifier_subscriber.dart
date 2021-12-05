import 'dart:async';

import 'package:flutter/material.dart';

import '../flutter_onlooker.dart';

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

  void _subscribe() {
    _subscription = stream?.listen((S? state) {
      if (widget.condition?.call(previousState, state) ?? true) {
        previousState = currentState;
        currentState = state;
        onNewState(state);
      }
    });
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }

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
