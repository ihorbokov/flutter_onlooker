part of flutter_onlooker;

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
  N? _stateNotifier;

  @override
  void initState() {
    _stateNotifier = widget.notifier ?? context.read<N>();
    super.initState();
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
  S? get initialState => _stateNotifier?.initial<S>();

  @override
  void onNewState(S? state) => setState(() {});

  @override
  Stream<S?>? get stream => _stateNotifier?.getStateStream<S>();

  @override
  Widget build(BuildContext context) => widget.builder(context, currentState);
}
