# Onlooker
<p>
<a href="https://pub.dev/packages/flutter_onlooker"><img src="https://img.shields.io/pub/v/flutter_onlooker.svg" alt="Pub"></a>
<a href="https://pub.dev/packages/very_good_analysis"><img src="https://img.shields.io/badge/style-very_good_analysis-B22C89.svg" alt="style: very good analysis"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
</p>

A state management library that provides a simple solution for updating state and navigation.

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
    navigate<void>('/route-name', arguments: _counter);
  }
}
```
2. `StateObserver` handles building a widget in response to new `states`. It takes 3 parameters:
* required `builder` function that takes the `BuildContext` and `state`, this function is responsible for returning a widget which is to be rendered.
* An optional `notifier` that can be passed directly or with using `StateNotifierProvider`.
* An optional `buildWhen` can be implemented for more granular control over how often `StateObserver` rebuilds.
```dart
StateObserver<IncrementStateNotifier, int>(
  builder: (_, state) {
    return Text(
      '$state',
      style: Theme.of(context).textTheme.headlineMedium,
    );
  },
)
```
3. `StateNotifierProvider` takes a `create` function that is responsible for creating the `StateNotifier`, `child` widget that will have access to the `StateNotifier` instance via `Provider.of<StateNotifier>(context)` or `context.read<StateNotifier>()` and optional `router` function that will receive navigation events.
```dart
StateNotifierProvider<IncrementStateNotifier>(
  create: (_) => IncrementStateNotifier(),
  child: const MyHomePage(title: 'Onlooker Demo'),
  router: (context, routeName, arguments) {
    return showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Route is '$routeName'"),
        content: Text("You've clicked $arguments times!"),
      ),
    );
  },
)
```
