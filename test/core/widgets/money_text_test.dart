import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
