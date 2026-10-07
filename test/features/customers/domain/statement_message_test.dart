import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/formatting/currency.dart';
import 'package:billa_mobile/features/customers/domain/customer.dart';
import 'package:billa_mobile/features/customers/domain/statement_message.dart';

void main() {
  test('names the customer, the business, what is owed and where to see it', () {
    final message = statementMessage(
      customer: 'Acme Ltd',
      business: 'Kigali Traders',
      totals: const [OutstandingTotal(currency: Currency.rwf, amount: 70000)],
      portalUrl: 'https://x/portal/tok',
      payable: false,
    );

    expect(
      message,
      'Hello Acme Ltd, this is your statement from Kigali Traders. You currently owe RWF 70,000.\n'
      'See your invoices here: https://x/portal/tok',
    );
  });

  test('says the invoices can be paid there when the business takes MoMo', () {
    final message = statementMessage(
      customer: 'Acme',
      business: 'B',
      totals: const [OutstandingTotal(currency: Currency.rwf, amount: 1000)],
      portalUrl: 'u',
      payable: true,
    );

    expect(message, contains('See and pay your invoices here: u'));
  });

  test('lists what is owed one currency at a time, never added together', () {
    final message = statementMessage(
      customer: 'Acme',
      business: 'B',
      totals: const [
        OutstandingTotal(currency: Currency.rwf, amount: 70000),
        OutstandingTotal(currency: Currency.usd, amount: 50000),
      ],
      portalUrl: 'u',
      payable: false,
    );

    expect(message, contains('You currently owe RWF 70,000 + USD 500.00.'));
  });

  test('contains no em dashes', () {
    final message = statementMessage(
      customer: 'A',
      business: 'B',
      totals: const [OutstandingTotal(currency: Currency.rwf, amount: 1)],
      portalUrl: 'u',
      payable: true,
    );

    expect(message.contains('\u2014'), isFalse);
  });
}
