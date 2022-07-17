import 'dart:async';

import 'package:flutter/widgets.dart';

abstract class StateSubscriber<S> extends StatefulWidget {
  const StateSubscriber({Key? key}) : super(key: key);
}

abstract class StateSubscriberState<S, T extends StateSubscriber<S>>
    extends State<T> {
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
