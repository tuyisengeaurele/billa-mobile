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
}
