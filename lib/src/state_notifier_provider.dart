import 'package:flutter/widgets.dart';
import 'package:flutter_onlooker/src/state_notifier.dart';
import 'package:flutter_onlooker/src/state_subscriber.dart';

/// A function that creates an object of type [T].
typedef Create<T> = T Function(BuildContext context);

/// A function that listens for navigation events.
/// Return navigation `result` from this function
/// to get that in [StateNotifier].
typedef Router = Future<dynamic>? Function(
  BuildContext context,
  dynamic route,
);

/// Exposes the [read] method.
extension ReadContext on BuildContext {
  /// Obtain a value from the nearest ancestor provider of type [StateNotifier].
  N read<N extends StateNotifier>({bool listen = false}) =>
      Provider.of<N>(this, listen: listen);
}

/// A generic implementation of [InheritedWidget] that allows to obtain
/// [StateNotifier] using [Provider.of] for any descendant of this widget.
class Provider<N extends StateNotifier> extends InheritedWidget {
  const Provider._({
    required this.stateNotifier,
    required Widget child,
    Key? key,
  }) : super(key: key, child: child);

  /// The nearest [StateNotifier] up its widget tree.
  final N stateNotifier;

  /// Obtains the nearest [StateNotifier] up its widget tree.
  ///
  /// The build context is rebuilt when [StateNotifier] is changed
  /// if [listen] set to `true`.
  static N of<N extends StateNotifier>(
    BuildContext context, {
    bool listen = false,
  }) {
    final provider = listen
        ? context.dependOnInheritedWidgetOfExactType<Provider<N>>()
        : context.getElementForInheritedWidgetOfExactType<Provider<N>>()?.widget
            as Provider<N>?;
    assert(provider != null, 'No Provider<${N.runtimeType}> found in context.');
    return provider!.stateNotifier;
  }

  @override
  bool updateShouldNotify(Provider<N> oldWidget) =>
      oldWidget.stateNotifier != stateNotifier;
}

/// {@template state_notifier_provider}
/// Takes a [Create] function that is responsible for creating
/// the [StateNotifier], [child] which will have access to the instance via
/// `Provider.of<StateNotifier>(context)` or `context.read<StateNotifier>()`
/// and optional [router] function that will receive navigation events.
class StateNotifierProvider<N extends StateNotifier>
    extends StateSubscriber<NavigationItem> {
  /// {@macro state_notifier_provider}
  const StateNotifierProvider({
    required this.create,
    required this.child,
    this.router,
    Key? key,
  }) : super(key: key);

  /// The function that is responsible for creating the [StateNotifier].
  final Create<N> create;

  /// The widget which will have access to the [StateNotifier].
  final Widget child;

  /// An optional function that will receive navigation events.
  final Router? router;

  @override
  State<StateNotifierProvider<N>> createState() =>
      _StateNotifierProviderState<N>();
}

class _StateNotifierProviderState<N extends StateNotifier>
    extends StateSubscriberState<NavigationItem, StateNotifierProvider<N>> {
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
    _stateNotifier.close();
    super.dispose();
  }
}
