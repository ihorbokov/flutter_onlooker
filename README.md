# Onlooker
A state management library which provides a simple solution for updating state and navigation.

## Usage
Lets take a look at how to use `flutter_onlooker`. The library provides: `StateNotifier`, `StateObserver` and `StateNotifierProvider` classes.

1. `StateNotifier` is responsible for registering and notifying states. Also it can emit navigation events. The main methods of this class:
* `observable<S>` - registers observable state of `S` type.
* `initial<S>` - returns initial value for state of `S` type.
* `latest<S>` - returns the latest value for state of `S` type.
* `contains<S>` - checks whether a state of `S` type was registered before.
* `notify<S>` - notifies a new state of `S` type.
* `navigate<T extends Object?>` - notifies a new navigation event.

```dart
class IncrementStateNotifier extends StateNotifier {
  int _counter = 0;

  IncrementStateNotifier() {
    observable<int>(initial: _counter);
  }

  void useCase() {
    final initialState = initial<int>();
    final latestState = latest<int>();
    final containsState = contains<int>();

    notify<int>(++_counter);
    navigate<void>(_counter);
  }
}
```
2. `StateObserver` handles building a widget in response to new `states`. It takes 3 parameters:
* required `builder` function which takes the `BuildContext` and `state`, this function is responsible for returning a widget which is to be rendered.
* An optional `notifier` which can be passed directly or with using `StateNotifierProvider`.
* An optional `buildWhen` can be implemented for more granular control over how often `StateObserver` rebuilds.
```dart
StateObserver<IncrementStateNotifier, int>(
  builder: (_, state) {
    return Text(
      '$state',
      style: Theme.of(context).textTheme.headline4,
    );
  },
)
```
3. `StateNotifierProvider` - takes a `create` function that is responsible for creating the `StateNotifier`, `child` widget which will have access to the `StateNotifier` instance via `Provider.of<StateNotifier>(context)` or `context.read<StateNotifier>()` and optional `router` function which will receive navigation events.
```dart
StateNotifierProvider<IncrementStateNotifier>(
  create: (_) => IncrementStateNotifier(),
  child: const MyHomePage(title: 'Onlooker Demo'),
  router: (context, dynamic route) {
    return showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Counter info'),
        content: Text('You\'ve clicked $route times!'),
      ),
    );
  },
)
```
