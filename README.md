# Async Builder

A Flutter widget that simplifies handling asynchronous operations. It provides a builder that returns a widget based on the current state of a `Future`.

This package is an alternative to the `FutureBuilder` widget, but with a simplified state management using a sealed `AsyncState` class.

## Features

*   Handles the different states of a `Future`: initial, loading, success, and error.
*   Provides a clean and concise way to build widgets based on the `Future`'s state.
*   Strongly typed using generics for better code safety.
*   Automatically handles `Future` changes and widget lifecycle.

## Getting started

To use this package, add `async_builder` as a dependency in your `pubspec.yaml` file.

```yaml
dependencies:
  async_builder: ^1.0.0
```

Then, import the package in your Dart code:

```dart
import 'package:async_builder/async_builder.dart';
```

## Usage

The `AsyncBuilder` widget takes a `future` and a `builder` function. The `builder` function provides the `BuildContext` and the current `AsyncState`.

You can use a `switch` statement on the `state` to build different widgets for each case: `AsyncInit`, `AsyncDone`, and `AsyncError`.

### Basic Example

```dart
import 'package:flutter/material.dart';
import 'package:async_builder/async_builder.dart';

class MyWidget extends StatelessWidget {
  final Future<String> _calculation = Future<String>.delayed(
    const Duration(seconds: 2),
    () => 'Data Loaded',
  );

  @override
  Widget build(BuildContext context) {
    return AsyncBuilder<String>(
      future: _calculation,
      builder: (context, state) {
        return switch (state) {
          AsyncInit() => const CircularProgressIndicator(),
          AsyncDone(data: final data) => Text(data),
          AsyncError(error: final error) => Text('Error: $error'),
        };
      },
    );
  }
}
```

### Handling State Changes

`AsyncBuilder` automatically listens for changes to the `future` you provide. If you pass a new `future` to the widget (for example, if it's rebuilt with a different value), `AsyncBuilder` will automatically unsubscribe from the old `future` and subscribe to the new one, starting from the `AsyncInit` state.

This is useful for scenarios where the asynchronous operation depends on other parts of your application's state.

```dart
class UserProfile extends StatefulWidget {
  final String userId;

  const UserProfile({super.key, required this.userId});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late Future<String> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUser(widget.userId);
  }

  @override
  void didUpdateWidget(UserProfile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      setState(() {
        _userFuture = _fetchUser(widget.userId);
      });
    }
  }

  Future<String> _fetchUser(String userId) async {
    // In a real app, you would make a network request here.
    await Future.delayed(const Duration(seconds: 1));
    return 'User $userId';
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBuilder<String>(
      future: _userFuture,
      builder: (context, state) {
        return switch (state) {
          AsyncInit() => const Center(child: CircularProgressIndicator()),
          AsyncDone(data: final user) => Center(child: Text(user)),
          AsyncError(error: final e) => Center(child: Text('Error: $e')),
        };
      },
    );
  }
}
```

## Additional information

This package is authored by [p4-k4](https://github.com/p4-k4).

To contribute to this package, please visit the [GitHub repository](https://github.com/p4-k4/async_builder).

If you encounter any issues or have suggestions for improvements, please file an issue on the [issue tracker](https://github.com/p4-k4/async_builder/issues).