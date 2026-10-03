import 'package:billa_mobile/core/formatting/currency.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/receivables/domain/outstanding_invoice.dart';

void main() {
  test('OutstandingInvoice.fromJson parses a typical result', () {
    final invoice = OutstandingInvoice.fromJson({
      'id': 'd1',
      'number': 'INV-0001',
      'customerName': 'Acme',
      'total': 10000,
      'amountOwed': 4000,
      'dueDate': '2026-01-01',
      'daysOverdue': 12,
      'agingBucket': '0-30',
    });

    expect(invoice.id, 'd1');
    expect(invoice.amountOwed, 4000);
    expect(invoice.agingBucket, '0-30');
  });

  test('handles a null dueDate and number', () {
    final invoice = OutstandingInvoice.fromJson({
      'id': 'd1',
      'number': null,
      'customerName': 'Acme',
      'total': 10000,
      'amountOwed': 10000,
      'dueDate': null,
      'daysOverdue': 0,
      'agingBucket': 'current',
    });

    expect(invoice.number, isNull);
    expect(invoice.dueDate, isNull);
  });

  test('carries the invoice currency and the balance in RWF', () {
    final invoice = OutstandingInvoice.fromJson({
      'id': 'd1',
      'number': 'INV-0002',
      'customerName': 'Acme',
      'total': 125050,
      'amountOwed': 100000,
      'currency': 'USD',
      'amountOwedRwf': 1450000,
      'dueDate': '2026-01-01',
      'daysOverdue': 0,
      'agingBucket': 'current',
    });

    expect(invoice.currency, Currency.usd);
    expect(invoice.amountOwedRwf, 1450000);
  });

  test('an older response with no currency reads as RWF', () {
    final invoice = OutstandingInvoice.fromJson({
      'id': 'd1',
      'number': null,
      'customerName': 'Acme',
      'total': 10000,
      'amountOwed': 10000,
      'dueDate': null,
      'daysOverdue': 0,
      'agingBucket': 'current',
    });

    expect(invoice.currency, Currency.rwf);
    expect(invoice.amountOwedRwf, 0);
  });

  test('reads what is due now and which instalment it is, and copes without them', () {
    final base = {
      'id': 'd1',
      'customerName': 'Acme',
      'total': 10000,
      'amountOwed': 7000,
      'daysOverdue': 0,
      'agingBucket': 'current',
    };

    final onPlan = OutstandingInvoice.fromJson({...base, 'amountDue': 3000, 'nextInstallmentLabel': 'Deposit'});
    final off = OutstandingInvoice.fromJson(base);

    expect(onPlan.amountDue, 3000);
    expect(onPlan.nextInstallmentLabel, 'Deposit');
    expect(off.amountDue, isNull);
    expect(off.nextInstallmentLabel, isNull);
  });
}
