# Onlooker
A state management library which provides a simple solution for updating state and navigation.

## Usage
Lets take a look at how to use `flutter_onlooker`. The library provides: `StateNotifier`, `StateObserver` and `StateNotifierProvider` classes.

1. `StateNotifier` is responsible for registering and notifying states. Also it can emit navigation events. Let's look on the main methods of this class.
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
    observable<int>(initial: _counter); //registers a state which can be processed by this StateNotifier
  }

  void useCase() {
    final initialState = initial<int>(); //0 - initial value of state int
    final latestState = latest<int>(); //0 - the latest value of state int
    final containsState = contains<int>(); //true - int state is registered for this StateNotifier
    notify<int>(++_counter); //notifies StateObserver about new state
    navigate<void>(_counter); //emits new navigation event to StateNotifierProvider
  }
}
```
2. `StateObserver` handles building a widget in response to new `states`. It takes 2 parameters:
* required `builder` function which takes the `BuildContext` and `state`, this function is responsible for returning a widget which is to be rendered. `state` value can be null, because `initial` value is optional in `observable<S>` method.
* An optional `notifier` which can be passed directly or with using `StateNotifierProvider`.
```dart
StateObserver<IncrementStateNotifier, int>(
    builder: (_, state) {
        final value = state ?? 0;
        return Text(
        '$value',
        style: Theme.of(context).textTheme.headline4,
    );
  },
);
```
3. `StateNotifierProvider` - takes a `create` function that is responsible for creating the `StateNotifier`, `child` widget which will have access to the `StateNotifier` instance via `Provider.of<StateNotifier>(context)` or `context.read<StateNotifier>()` and optional `router` function which will receive navigation events.
```dart
StateNotifierProvider<IncrementStateNotifier>(
    create: (_) => IncrementStateNotifier(),
    child: const HomePage(title: 'Flutter Onlooker Demo'),
    router: (context, route) {
        if (route is int?) {
            final value = route ?? 0;
            showDialog(
            context: context,
            builder: (_) => AlertDialog(
                title: const Text('Counter info'),
                content: Text('You have clicked $value times!'),
            ),
         );
      }
   },
);
```
