import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/widgets/code_input.dart';

void main() {
  late TextEditingController controller;

  setUp(() {
    controller = TextEditingController();
  });

  Widget host({bool hasError = false}) => MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: CodeInput(fieldKey: const Key('code'), controller: controller, hasError: hasError),
          ),
        ),
      );

  testWidgets('shows each typed digit in its own box', (tester) async {
    await tester.pumpWidget(host());
    await tester.enterText(find.byKey(const Key('code')), '123');
    await tester.pump();

    for (final digit in ['1', '2', '3']) {
      expect(find.text(digit), findsOneWidget);
    }
    expect(controller.text, '123');
  });

  testWidgets('keeps digits only and stops at six', (tester) async {
    await tester.pumpWidget(host());
    await tester.enterText(find.byKey(const Key('code')), '12ab34567890');
    await tester.pump();

    expect(controller.text, '123456');
  });

  testWidgets('announces how many digits are entered', (tester) async {
    await tester.pumpWidget(host());
    await tester.enterText(find.byKey(const Key('code')), '12');
    await tester.pump();

    expect(tester.getSemantics(find.byType(CodeInput)).label, contains('2 of 6 digits entered'));
  });

  testWidgets('an error state shakes and settles', (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpWidget(host(hasError: true));
    await tester.pump(const Duration(milliseconds: 100));
    final moved = tester.getTopLeft(find.byType(CodeInput)).dx;
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.byType(CodeInput)).dx, moved);
    expect(tester.takeException(), isNull);
  });
}
