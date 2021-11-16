import 'package:flutter/material.dart';
import 'package:flutter_onlooker/flutter_onlooker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StateNotifierProvider<IncrementStateNotifier>(
        create: (_) => IncrementStateNotifier(),
        child: const MyHomePage(title: 'Onlooker Demo'),
        router: (context, dynamic route) {
          if (route is int) {
            showDialog<void>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Counter info'),
                content: Text('You\'ve clicked $route times!'),
              ),
            );
          }
        },
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            const SizedBox(
              height: 8.0,
            ),
            StateObserver<IncrementStateNotifier, int>(
              builder: (_, state) {
                return Text(
                  '$state',
                  style: Theme.of(context).textTheme.headline4,
                );
              },
            ),
            const SizedBox(
              height: 8.0,
            ),
            ElevatedButton(
              onPressed:
                  context.read<IncrementStateNotifier>()?.showCounterInfo,
              child: const Text(
                'Show counter value',
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: context.read<IncrementStateNotifier>()?.increment,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class IncrementStateNotifier extends StateNotifier {
  IncrementStateNotifier() {
    observable<int>(initial: 0);
  }

  void increment() {
    final latestState = latest<int>()!;
    notify<int>(latestState + 1);
  }

  void showCounterInfo() {
    final latestState = latest<int>()!;
    navigate(latestState);
  }
}
