import 'dart:async';

import 'package:flutter/widgets.dart';

/// {@template state_subscriber}
/// Base [StatefulWidget] class for widgets that listens to `states`.
/// {@endtemplate}
abstract class StateSubscriber<S> extends StatefulWidget {
  /// {@macro state_subscriber}
  const StateSubscriber({Key? key}) : super(key: key);
}

/// Base [State] class for the [StateSubscriber].
abstract class StateSubscriberState<S, T extends StateSubscriber<S>>
    extends State<T> {
  StreamSubscription<S>? _subscription;

  /// A source of asynchronous `states`.
  @protected
  Stream<S>? get stream;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  /// Notifies about new `state` from the subscriber's [stream].
  @protected
  void onNewState(S state);

  void _subscribe() => _subscription = stream?.listen(onNewState);

  void _unsubscribe() => _subscription?.cancel();

  /// Resubscribes to the subscriber's [stream].
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
