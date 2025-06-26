import 'package:flutter/material.dart';

/// A Flutter widget that simplifies handling asynchronous operations.
///
/// It provides a builder that returns a widget based on the current state of a [Future].
/// This widget is an alternative to [FutureBuilder], but with a simplified state
/// management using a sealed [AsyncState] class.
class AsyncBuilder<T> extends StatefulWidget {
  /// Creates an [AsyncBuilder] widget.
  ///
  /// The [future] argument must not be null.
  /// The [builder] argument must not be null.
  const AsyncBuilder({super.key, required this.future, required this.builder});

  /// The asynchronous computation to which this builder is currently connected.
  final Future<T> future;

  /// A function that builds a widget depending on the state of the [future].
  ///
  /// The [builder] is provided with the [BuildContext] and the current [AsyncState].
  final Widget Function(BuildContext, AsyncState<T>) builder;

  @override
  State<AsyncBuilder<T>> createState() => _AsyncBuilderState<T>();
}

class _AsyncBuilderState<T> extends State<AsyncBuilder<T>> {
  AsyncState<T> _state = const AsyncInit();

  @override
  void initState() {
    super.initState();
    _subscribeToFuture();
  }

  @override
  void didUpdateWidget(AsyncBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.future != widget.future) {
      _state = const AsyncInit();
      _subscribeToFuture();
    }
  }

  void _subscribeToFuture() {
    widget.future
        .then((data) {
          if (mounted) {
            setState(() {
              _state = AsyncDone(data);
            });
          }
        })
        .catchError((error) {
          if (mounted) {
            setState(() {
              _state = AsyncError(error);
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _state);
  }
}

/// Represents the state of an asynchronous operation.
sealed class AsyncState<T> {
  /// Creates an [AsyncState].
  const AsyncState();
}

/// The initial state of an asynchronous operation, before it has completed.
class AsyncInit<T> extends AsyncState<T> {
  /// Creates an [AsyncInit] state.
  const AsyncInit();
}

/// The state of an asynchronous operation that has completed successfully.
class AsyncDone<T> extends AsyncState<T> {
  /// The data returned by the asynchronous operation.
  final T data;

  /// Creates an [AsyncDone] state with the given [data].
  const AsyncDone(this.data);
}

/// The state of an asynchronous operation that has completed with an error.
class AsyncError<T> extends AsyncState<T> {
  /// The error that occurred during the asynchronous operation.
  final Object error;

  /// Creates an [AsyncError] state with the given [error].
  const AsyncError(this.error);
}