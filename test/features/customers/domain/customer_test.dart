import 'package:billa_mobile/core/formatting/currency.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/customers/domain/customer.dart';
import 'package:billa_mobile/features/customers/domain/customer_payment_stats.dart';

void main() {
  test('Customer.fromJson maps optional fields', () {
    final customer = Customer.fromJson({
      'id': 'c1',
      'name': 'Acme',
      'tin': null,
      'address': null,
      'phone': null,
      'email': null,
      'isActive': true,
      'createdAt': '2026-01-01T00:00:00.000Z',
    });

    expect(customer.name, 'Acme');
    expect(customer.tin, isNull);
    expect(customer.isActive, isTrue);
  });

  test('CustomerPaymentStats.fromJson handles a customer with no paid invoices yet', () {
    final stats = CustomerPaymentStats.fromJson({
      'paidInvoiceCount': 0,
      'averageDaysToPay': null,
      'onTimeRate': null,
    });

    expect(stats.paidInvoiceCount, 0);
    expect(stats.averageDaysToPay, isNull);
    expect(stats.onTimeRate, isNull);
  });

  test('reads the credit limit, what the customer owes and the portal link', () {
    final customer = Customer.fromJson({
      'id': 'c1',
      'name': 'Acme',
      'isActive': true,
      'createdAt': '2026-01-01T00:00:00.000Z',
      'creditLimit': 500000,
      'portalToken': 'tok123',
      'outstandingBalance': 120000,
      'outstandingTotals': [
        {'currency': 'RWF', 'amount': 70000},
        {'currency': 'USD', 'amount': 50000},
      ],
    });

    expect(customer.creditLimit, 500000);
    expect(customer.portalToken, 'tok123');
    expect(customer.outstandingBalance, 120000);
    expect(
      customer.outstandingTotals.map((t) => (t.currency, t.amount)),
      [(Currency.rwf, 70000), (Currency.usd, 50000)],
    );
  });

  test('a customer from a list, with none of those fields, has no limit and owes nothing', () {
    final customer = Customer.fromJson({
      'id': 'c1',
      'name': 'Acme',
      'isActive': true,
      'createdAt': '2026-01-01T00:00:00.000Z',
    });

    expect(customer.creditLimit, isNull);
    expect(customer.portalToken, isNull);
    expect(customer.outstandingBalance, 0);
    expect(customer.outstandingTotals, isEmpty);
  });
}
