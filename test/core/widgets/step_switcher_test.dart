import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/widgets/step_switcher.dart';

void main() {
  testWidgets('cross-fades to the new step and leaves no old step behind', (tester) async {
    Widget host(String step) => MaterialApp(
          home: StepSwitcher(child: Text(step, key: ValueKey(step))),
        );

    await tester.pumpWidget(host('first'));
    await tester.pumpWidget(host('second'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('first'), findsOneWidget);
    expect(find.text('second'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('first'), findsNothing);
    expect(find.text('second'), findsOneWidget);
  });

  testWidgets('does not animate when the step is unchanged', (tester) async {
    Widget host(String label) => MaterialApp(
          home: StepSwitcher(child: Text(label, key: const ValueKey('same'))),
        );

    await tester.pumpWidget(host('one'));
    await tester.pumpWidget(host('two'));

    expect(find.text('two'), findsOneWidget);
    expect(find.text('one'), findsNothing);
  });
}
