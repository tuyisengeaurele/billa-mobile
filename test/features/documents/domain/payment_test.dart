import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/domain/payment.dart';

void main() {
  test('Payment.fromJson parses a typical payment, ignoring unmodeled fields', () {
    final payment = Payment.fromJson({
      'id': 'pay1',
      'amount': 5000,
      'method': 'MOBILE_MONEY',
      'paidOn': '2026-01-05T00:00:00.000Z',
      'notes': null,
      'referenceNumber': 'TXN123',
      'payerName': 'John Doe',
      'receiptImageUrl': null,
      'receiptDocumentId': null,
      'voidedAt': null,
      'voidReason': null,
      'createdAt': '2026-01-05T00:00:00.000Z',
      'businessId': 'b1',
      'documentId': 'd1',
      'createdByUserId': 'u1',
      'momoPaymentRequestId': null,
    });

    expect(payment.id, 'pay1');
    expect(payment.amount, 5000);
    expect(payment.method, PaymentMethod.mobileMoney);
    expect(payment.referenceNumber, 'TXN123');
    expect(payment.voidedAt, isNull);
  });

  test('Payment.fromJson parses a voided payment', () {
    final payment = Payment.fromJson({
      'id': 'pay1',
      'amount': 5000,
      'method': 'CASH',
      'paidOn': '2026-01-05T00:00:00.000Z',
      'notes': null,
      'referenceNumber': null,
      'payerName': null,
      'receiptImageUrl': null,
      'receiptDocumentId': null,
      'voidedAt': '2026-01-06T00:00:00.000Z',
      'voidReason': 'Duplicate entry',
      'createdAt': '2026-01-05T00:00:00.000Z',
    });

    expect(payment.voidedAt, '2026-01-06T00:00:00.000Z');
    expect(payment.voidReason, 'Duplicate entry');
  });
}
