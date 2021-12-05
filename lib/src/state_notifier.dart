part of flutter_onlooker;

/// A callback function that is used to return navigation result to the [StateNotifier].
typedef ResultConsumer<T> = void Function(Future<T>?);

/// This class provides mechanism of delivering new UI `states` and navigation
/// `events` to widgets. Widgets should use [getStateStream] and [getNavigationStream]
/// to observe on [StateNotifier] events.
abstract class StateNotifier {
  final _stateController = _StateController();
  final _navigationController = _NavigationController(
    StreamController<NavigationItem>.broadcast(),
  );

  bool _disposed = false;

  /// Defines whether [StateNotifier] was disposed.
  bool get disposed => _disposed;

  /// Registers observable state of `S` type that can be processed by this [StateNotifier].
  ///
  /// [initial] defines initial state of observable type.
  /// [broadcast] defines type of stream that will be created.
  ///
  /// Throws [StateError] if some type of `state` registered twice or if [StateNotifier] was disposed.
  @protected
  void observable<S>({S? initial, bool broadcast = false}) {
    if (_disposed) {
      throw StateError('Can\'t register state - $runtimeType is disposed.');
    }
    _stateController[S] = _StateItem<S>(
      broadcast ? StreamController<S?>.broadcast() : StreamController<S?>(),
      initialState: initial,
    );
  }

  /// Returns initial value for state of `S` type.
  ///
  /// Throws [StateError] if [StateNotifier] was disposed.
  /// Throws [ArgumentError] if state of such type was not registered.
  S? initial<S>() {
    if (_disposed) {
      throw StateError('Can\'t get initial state - $runtimeType is disposed.');
    }
    return _stateController[S].initialState as S?;
  }

  /// Returns the latest value for state of `S` type.
  ///
  /// Throws [StateError] if [StateNotifier] was disposed.
  /// Throws [ArgumentError] if state of such type was not registered.
  S? latest<S>() {
    if (_disposed) {
      throw StateError('Can\'t get latest state - $runtimeType is disposed.');
    }
    return _stateController[S].latestState as S?;
  }

  /// Checks whether a state of `S` type was registered before.
  ///
  /// Throws [StateError] if [StateNotifier] was disposed.
  bool contains<S>() {
    if (_disposed) {
      throw StateError('Can\'t check state - $runtimeType is disposed.');
    }
    return _stateController.containsKey(S);
  }

  /// Notifies a new state of `S` type.
  ///
  /// [state] defines new UI state.
  ///
  /// Throws [StateError] if [StateNotifier] was disposed.
  /// Throws [ArgumentError] if state of such type was not registered.
  @protected
  void notify<S>(S? state) {
    if (_disposed) {
      throw StateError('Can\'t notify - $runtimeType is disposed.');
    }
    _stateController[S].add(state);
  }

  /// Notifies a new navigation event.
  ///
  /// [route] defines data of navigation event.
  /// Returns a [Future] that completes to the `result` value that
  /// can be returned from `router` function using `return` keyword.
  ///
  /// Throws [StateError] if navigation result was returned twice or if [StateNotifier] was disposed.
  @protected
  Future<T?> navigate<T extends Object?>(dynamic route) {
    if (_disposed) {
      throw StateError('Can\'t navigate - $runtimeType is disposed.');
    }
    final resultCompleter = Completer<T?>();
    final resultConsumer = (Future<dynamic>? result) {
      if (resultCompleter.isCompleted) {
        throw StateError('Navigation result has been already returned.');
      }
      resultCompleter.complete(result?.then((dynamic value) => value as T?));
    };
    _navigationController.add(NavigationItem<T>(route, resultConsumer));
    return resultCompleter.future;
  }

  /// Returns state stream according to `S` type.
  ///
  /// Returns `null` if this [StateNotifier] was disposed.
  ///
  /// Throws [ArgumentError] if state of such type was not registered.
  Stream<S?>? getStateStream<S>() =>
      _disposed ? null : _stateController.getStream<S>();

  /// Returns navigation stream.
  ///
  /// Returns `null` if this [StateNotifier] was disposed.
  Stream<NavigationItem>? getNavigationStream() =>
      _disposed ? null : _navigationController.stream;

  /// Closes `state` and `navigation` streams.
  void dispose() {
    _disposed = true;
    _stateController.close();
    _navigationController.close();
  }
}

class _NavigationController<T> {
  final StreamController<T> _controller;

  _NavigationController(this._controller);

  void add(T navigationItem) {
    if (!_controller.isClosed && _controller.hasListener) {
      _controller.sink.add(navigationItem);
    }
  }

  Stream<T> get stream => _controller.stream;

  void close() => _controller.close();
}

class NavigationItem<T> {
  final dynamic route;
  final ResultConsumer<T> resultConsumer;

  NavigationItem(this.route, this.resultConsumer);
}

class _StateController extends MapBase<Type, _StateItem> {
  final _stateItems = <Type, _StateItem>{};

  @override
  _StateItem operator [](Object? key) {
    final stateItem = _stateItems[key];
    if (stateItem == null) {
      throw ArgumentError('State with type $key wasn\'t found as observable.');
    }
    return stateItem;
  }

  @override
  void operator []=(Type key, _StateItem value) {
    if (_stateItems.containsKey(key)) {
      throw ArgumentError('State with type $key is already observable.');
    }
    _stateItems[key] = value;
  }

  Stream<S?> getStream<S>() =>
      (this[S].controller as StreamController<S?>).stream;

  @override
  Iterable<Type> get keys => _stateItems.keys;

  @override
  _StateItem? remove(Object? key) => _stateItems.remove(key);

  @override
  void clear() => _stateItems.clear();

  void close() {
    forEach((_, item) => item.controller.close());
    clear();
  }
}

class _StateItem<S> {
  final StreamController<S?> controller;
  final S? initialState;
  S? latestState;

  _StateItem(this.controller, {this.initialState}) : latestState = initialState;

  void add(S? state) {
    if (!controller.isClosed && controller.hasListener) {
      controller.sink.add(state);
    }
  }
}
