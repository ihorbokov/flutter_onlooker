import 'dart:async';

import 'package:flutter/widgets.dart';

import 'state_notifier.dart';

abstract class StateNotifierSubscriber<N extends StateNotifier, S>
    extends StatefulWidget {
  const StateNotifierSubscriber({Key? key}) : super(key: key);
}

abstract class StateNotifierSubscriberState<N extends StateNotifier, S,
    T extends StateNotifierSubscriber<N, S>> extends State<T> {
  StreamSubscription<S?>? _subscription;

  S? currentState;

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

  void _subscribe() {
    _subscription = stream?.listen((S? state) {
      currentState = state;
      onNewState(state);
    });
  }

  @protected
  void onNewState(covariant S? state);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
