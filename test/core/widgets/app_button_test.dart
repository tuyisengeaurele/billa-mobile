import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/widgets/app_button.dart';

void main() {
  testWidgets('tapping invokes onPressed when not loading', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: AppButton(label: 'Save', onPressed: () => tapped = true),
    ));

    await tester.tap(find.text('Save'));
    expect(tapped, isTrue);
  });

  testWidgets('shows a spinner and ignores taps while loading', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: AppButton(label: 'Save', onPressed: () => tapped = true, isLoading: true),
    ));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Save'), findsNothing);
    await tester.tap(find.byType(AppButton));
    expect(tapped, isFalse);
  });
}
