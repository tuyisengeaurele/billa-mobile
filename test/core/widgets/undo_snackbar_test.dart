import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/widgets/undo_snackbar.dart';

void main() {
  Future<void> show(WidgetTester tester, Future<void> Function() onUndo) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showUndoSnackBar(context, message: 'Acme deactivated', onUndo: onUndo),
            child: const Text('go'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 750));
  }

  testWidgets('shows the message with an Undo action', (tester) async {
    await show(tester, () async {});

    expect(find.text('Acme deactivated'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
  });

  testWidgets('Undo runs the reversal once', (tester) async {
    var undone = 0;
    await show(tester, () async => undone++);

    await tester.tap(find.text('Undo'));
    await tester.pump();

    expect(undone, 1);
  });

  testWidgets('goes away by itself after a few seconds', (tester) async {
    await show(tester, () async {});

    await tester.pump(const Duration(seconds: 7));
    await tester.pumpAndSettle();

    expect(find.text('Acme deactivated'), findsNothing);
  });

  testWidgets('a reversal that fails says why instead of silently leaving things as they were', (tester) async {
    await show(
      tester,
      () async => throw DioException(requestOptions: RequestOptions(path: '/x'), type: DioExceptionType.connectionError),
    );

    await tester.tap(find.text('Undo'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 750));

    expect(find.text('Check your connection and try again'), findsOneWidget);
  });

  testWidgets('a new message replaces the old one instead of queueing behind it', (tester) async {
    await show(tester, () async {});
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Acme deactivated'), findsOneWidget);
  });
}
