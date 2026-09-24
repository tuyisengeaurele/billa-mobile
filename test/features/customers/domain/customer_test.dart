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
}
