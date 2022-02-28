import 'dart:async';

import 'package:flutter/widgets.dart';

abstract class StateNotifierSubscriber<S> extends StatefulWidget {
  const StateNotifierSubscriber({Key? key}) : super(key: key);
}

abstract class StateNotifierSubscriberState<S,
    T extends StateNotifierSubscriber<S>> extends State<T> {
  StreamSubscription<S>? _subscription;

  @protected
  Stream<S>? get stream;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @protected
  void onNewState(S state);

  void _subscribe() => _subscription = stream?.listen(onNewState);

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
