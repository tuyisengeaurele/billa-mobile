import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/formatting/currency.dart';
import 'package:billa_mobile/features/documents/presentation/widgets/currency_section.dart';

void main() {
  Widget host({
    Currency currency = Currency.rwf,
    double? rate,
    String? hint,
    bool repriceNote = false,
    bool locked = false,
    ValueChanged<Currency>? onCurrency,
    ValueChanged<double?>? onRate,
  }) =>
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: CurrencySection(
            currency: currency,
            exchangeRate: rate,
            rateHint: hint,
            repriceNote: repriceNote,
            locked: locked,
            onCurrencyChanged: onCurrency ?? (_) {},
            onRateChanged: onRate ?? (_) {},
          ),
        ),
      );

  testWidgets('RWF shows the currency and no rate field', (tester) async {
    await tester.pumpWidget(host());

    expect(find.text('RWF (Rwandan franc)'), findsOneWidget);
    expect(find.byKey(const Key('document-editor-rate')), findsNothing);
  });

  testWidgets('a foreign currency shows the rate with where it came from', (tester) async {
    await tester.pumpWidget(host(currency: Currency.usd, rate: 1450.5, hint: 'The rate you used last.'));

    expect(find.byKey(const Key('document-editor-rate')), findsOneWidget);
    expect(find.text('1450.5'), findsOneWidget);
    expect(find.textContaining('The rate you used last.'), findsOneWidget);
  });

  testWidgets('typing a rate reports a number, and clearing it reports none', (tester) async {
    final rates = <double?>[];
    await tester.pumpWidget(host(currency: Currency.usd, rate: 1450, onRate: rates.add));

    await tester.enterText(find.byKey(const Key('document-editor-rate')), '1500.25');
    await tester.enterText(find.byKey(const Key('document-editor-rate')), '');

    expect(rates, [1500.25, null]);
  });

  testWidgets('the rate box ignores letters, a second dot and more than six decimals', (tester) async {
    final rates = <double?>[];
    await tester.pumpWidget(host(currency: Currency.usd, rate: 1450, onRate: rates.add));

    await tester.enterText(find.byKey(const Key('document-editor-rate')), '14a5');
    await tester.enterText(find.byKey(const Key('document-editor-rate')), '1.2.3');
    await tester.enterText(find.byKey(const Key('document-editor-rate')), '1.1234567');

    expect(rates, isEmpty);
  });

  testWidgets('a foreign currency with no rate says what to do', (tester) async {
    await tester.pumpWidget(host(currency: Currency.usd));

    expect(find.text('Enter the exchange rate for USD'), findsOneWidget);
  });

  testWidgets('says when the prices were not converted', (tester) async {
    await tester.pumpWidget(host(currency: Currency.usd, rate: 1450, repriceNote: true));

    expect(find.textContaining('Check them in USD'), findsOneWidget);
  });

  testWidgets('a locked currency explains why it cannot change', (tester) async {
    await tester.pumpWidget(host(currency: Currency.usd, rate: 1450, locked: true));

    expect(find.text('Kept the same as the invoice this document is for.'), findsOneWidget);
    final field = tester.widget<TextField>(find.byKey(const Key('document-editor-rate')));
    expect(field.enabled, isFalse);
  });

  testWidgets('choosing another currency reports it', (tester) async {
    Currency? chosen;
    await tester.pumpWidget(host(onCurrency: (value) => chosen = value));

    await tester.tap(find.byKey(const Key('document-editor-currency')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('USD (US dollar)').last);
    await tester.pumpAndSettle();

    expect(chosen, Currency.usd);
  });

  testWidgets('the longest currency name fits a narrow phone without overflowing', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: SizedBox(
          width: 220,
          child: CurrencySection(
            currency: Currency.tzs,
            exchangeRate: 0.5,
            onCurrencyChanged: (_) {},
            onRateChanged: (_) {},
          ),
        ),
      ),
    ));

    expect(tester.takeException(), isNull);
  });
}
