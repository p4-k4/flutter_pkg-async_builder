import 'dart:async';

import 'package:async_builder/async_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AsyncBuilder', () {
    testWidgets('renders initial state', (WidgetTester tester) async {
      final future = Completer<String>();

      await tester.pumpWidget(
        MaterialApp(
          home: AsyncBuilder<String>(
            future: future.future,
            builder: (context, state) {
              return switch (state) {
                AsyncInit() => const Text('Initial'),
                AsyncDone(data: final data) => Text('Data: $data'),
                AsyncError(error: final error) => Text('Error: $error'),
              };
            },
          ),
        ),
      );

      expect(find.text('Initial'), findsOneWidget);
    });

    testWidgets('renders done state when future completes successfully',
        (WidgetTester tester) async {
      final future = Future.value('Test Data');

      await tester.pumpWidget(
        MaterialApp(
          home: AsyncBuilder<String>(
            future: future,
            builder: (context, state) {
              return switch (state) {
                AsyncInit() => const Text('Initial'),
                AsyncDone(data: final data) => Text('Data: $data'),
                AsyncError(error: final error) => Text('Error: $error'),
              };
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Data: Test Data'), findsOneWidget);
    });

    testWidgets('renders error state when future completes with an error',
        (WidgetTester tester) async {
      final completer = Completer<String>();

      await tester.pumpWidget(
        MaterialApp(
          home: AsyncBuilder<String>(
            future: completer.future,
            builder: (context, state) {
              return switch (state) {
                AsyncInit() => const Text('Initial'),
                AsyncDone(data: final data) => Text('Data: $data'),
                AsyncError(error: final error) => Text('Error: $error'),
              };
            },
          ),
        ),
      );

      completer.completeError('Test Error');
      await tester.pumpAndSettle();

      expect(find.text('Error: Test Error'), findsOneWidget);
    });

    testWidgets('rebuilds when future changes', (WidgetTester tester) async {
      final completer1 = Completer<String>();
      final completer2 = Completer<String>();

      await tester.pumpWidget(
        MaterialApp(
          home: AsyncBuilder<String>(
            future: completer1.future,
            builder: (context, state) {
              return switch (state) {
                AsyncInit() => const Text('Initial'),
                AsyncDone(data: final data) => Text('Data: $data'),
                AsyncError(error: final error) => Text('Error: $error'),
              };
            },
          ),
        ),
      );

      expect(find.text('Initial'), findsOneWidget);

      completer1.complete('First');
      await tester.pumpAndSettle();
      expect(find.text('Data: First'), findsOneWidget);

      // Now, change the future
      await tester.pumpWidget(
        MaterialApp(
          home: AsyncBuilder<String>(
            future: completer2.future,
            builder: (context, state) {
              return switch (state) {
                AsyncInit() => const Text('Initial'),
                AsyncDone(data: final data) => Text('Data: $data'),
                AsyncError(error: final error) => Text('Error: $error'),
              };
            },
          ),
        ),
      );

      // Should be back to initial state
      expect(find.text('Initial'), findsOneWidget);

      completer2.complete('Second');
      await tester.pumpAndSettle();
      expect(find.text('Data: Second'), findsOneWidget);
    });
  });
}
