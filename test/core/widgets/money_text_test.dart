import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/privacy/privacy_scope.dart';
import 'package:billa_mobile/core/widgets/money_text.dart';

void main() {
  testWidgets('groups thousands and shows the currency symbol', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MoneyText(1234567)));
    expect(find.text('RWF 1,234,567'), findsOneWidget);
  });

  testWidgets('renders zero and small amounts without grouping', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MoneyText(0)));
    expect(find.text('RWF 0'), findsOneWidget);
    await tester.pumpWidget(const MaterialApp(home: MoneyText(950)));
    expect(find.text('RWF 950'), findsOneWidget);
  });

  testWidgets('renders negative amounts with a leading minus', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MoneyText(-5000)));
    expect(find.text('RWF -5,000'), findsOneWidget);
  });

  testWidgets('applies tabular figures to the resolved style', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MoneyText(1000)));
    final text = tester.widget<Text>(find.text('RWF 1,000'));
    expect(text.style!.fontFeatures, contains(const FontFeature.tabularFigures()));
  });

  testWidgets('shows dots instead of the amount while privacy mode hides amounts', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PrivacyScope(hidden: true, child: MoneyText(1234567))));

    expect(find.text('RWF ••••'), findsOneWidget);
    expect(find.textContaining('1,234'), findsNothing);
  });

  testWidgets('hidden amounts still keep the tabular style so layouts do not jump', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PrivacyScope(hidden: true, child: MoneyText(1000))));

    final text = tester.widget<Text>(find.text('RWF ••••'));
    expect(text.style!.fontFeatures, contains(const FontFeature.tabularFigures()));
  });

  testWidgets('screen readers hear that the amount is hidden, not the dots', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(const MaterialApp(home: PrivacyScope(hidden: true, child: MoneyText(1000))));

    expect(find.bySemanticsLabel('Amount hidden'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('shows the amount when the scope says visible', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PrivacyScope(hidden: false, child: MoneyText(1000))));

    expect(find.text('RWF 1,000'), findsOneWidget);
  });
}
