import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/domain/payment_input.dart';

void main() {
  test('PaymentInput.toJson matches the backend request shape', () {
    const input = PaymentInput(amount: 5000, method: PaymentMethod.cash, paidOn: '2026-01-05');

    final json = input.toJson();

    expect(json['amount'], 5000);
    expect(json['method'], 'CASH');
    expect(json['paidOn'], '2026-01-05');
    expect(json['generateReceipt'], false);
    expect(json['notes'], isNull);
  });

  test('round-trips through fromJson', () {
    const input = PaymentInput(
      amount: 10000,
      method: PaymentMethod.mobileMoney,
      paidOn: '2026-01-05',
      notes: 'Partial payment',
      referenceNumber: 'TXN1',
      payerName: 'Jane',
      receiptImageUrl: '/uploads/x.png',
      generateReceipt: true,
    );

    final roundTripped = PaymentInput.fromJson(input.toJson());

    expect(roundTripped, input);
  });
}
