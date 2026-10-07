import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/widgets/error_state.dart';

void main() {
  testWidgets('shows the message and a working retry action', (tester) async {
    var retried = false;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: ErrorState(
        message: "Couldn't load your documents",
        onRetry: () => retried = true,
      ),
    ));

    expect(find.text("Couldn't load your documents"), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });

  testWidgets('honors a custom retry label', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: ErrorState(message: 'Failed', onRetry: () {}, retryLabel: 'Try again'),
    ));

    expect(find.text('Try again'), findsOneWidget);
  });
}
