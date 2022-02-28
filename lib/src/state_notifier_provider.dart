import 'package:flutter/widgets.dart';

import 'state_notifier.dart';
import 'state_notifier_subscriber.dart';

/// A function that creates an object of type [T].
typedef Create<T> = T Function(BuildContext context);

/// A function that listens for navigation events.
/// Return navigation `result` from this function to get that in [StateNotifier].
typedef Router<T> = Future<T>? Function(
  BuildContext context,
  dynamic route,
);

/// Exposes the [read] method.
extension ReadContext on BuildContext {
  /// Obtain a value from the nearest ancestor provider of type [StateNotifier].
  N read<N extends StateNotifier>({bool listen = false}) =>
      Provider.of<N>(this, listen: listen);
}

/// A generic implementation of [InheritedWidget] that allows to obtain [StateNotifier]
/// using [Provider.of] for any descendant of this widget.
class Provider<N extends StateNotifier> extends InheritedWidget {
  final N stateNotifier;

  const Provider._({
    Key? key,
    required this.stateNotifier,
    required Widget child,
  }) : super(key: key, child: child);

  /// Obtains the nearest [StateNotifier] up its widget tree.
  ///
  /// The build context is rebuilt when [StateNotifier] is changed if [listen] set to `true`.
  static N of<N extends StateNotifier>(
    BuildContext context, {
    bool listen = false,
  }) {
    final provider = listen
        ? context.dependOnInheritedWidgetOfExactType<Provider<N>>()
        : context.getElementForInheritedWidgetOfExactType<Provider<N>>()?.widget
            as Provider<N>;
    assert(provider != null, 'No Provider<${N.runtimeType}> found in context.');
    return provider!.stateNotifier;
  }

  @override
  bool updateShouldNotify(Provider<N> oldWidget) =>
      oldWidget.stateNotifier != stateNotifier;
}

/// Takes a [Create] function that is responsible for creating the [StateNotifier],
/// [child] which will have access to the instance via `Provider.of<StateNotifier>(context)` or
/// `context.read<StateNotifier>()` and optional [router] function that will receive navigation events.
class StateNotifierProvider<N extends StateNotifier>
    extends StateNotifierSubscriber<NavigationItem> {
  final Create<N> create;
  final Widget child;
  final Router? router;

  const StateNotifierProvider({
    Key? key,
    required this.create,
    required this.child,
    this.router,
  }) : super(key: key);

  @override
  _StateNotifierProviderState<N> createState() =>
      _StateNotifierProviderState<N>();
}

class _StateNotifierProviderState<N extends StateNotifier>
    extends StateNotifierSubscriberState<NavigationItem,
        StateNotifierProvider<N>> {
  late final N _stateNotifier = widget.create(context);

  @override
  Widget build(BuildContext context) {
    return Provider._(
      stateNotifier: _stateNotifier,
      child: widget.child,
    );
  }

  @override
  void onNewState(NavigationItem state) {
    final result = widget.router?.call(context, state.route);
    state.resultConsumer(result);
  }

  @override
  Stream<NavigationItem>? get stream =>
      widget.router == null ? null : _stateNotifier.getNavigationStream();

  @override
  void dispose() {
    _stateNotifier.dispose();
    super.dispose();
  }
}
