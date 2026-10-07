import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';

void main() {
  test('DocumentType round-trips every value', () {
    for (final type in DocumentType.values) {
      expect(documentTypeFromJson(documentTypeToJson(type)), type);
    }
    expect(documentTypeToJson(DocumentType.deliveryNote), 'DELIVERY_NOTE');
    expect(documentTypeToJson(DocumentType.creditNote), 'CREDIT_NOTE');
  });

  test('DocumentType.fromJson rejects an unknown value', () {
    expect(() => documentTypeFromJson('SOMETHING_ELSE'), throwsArgumentError);
  });

  test('DocumentStatus round-trips both values', () {
    expect(documentStatusFromJson('DRAFT'), DocumentStatus.draft);
    expect(documentStatusFromJson('FINALIZED'), DocumentStatus.finalized);
    expect(documentStatusToJson(DocumentStatus.draft), 'DRAFT');
  });

  test('PaymentStatus handles null and round-trips every value', () {
    expect(paymentStatusFromJson(null), isNull);
    expect(paymentStatusToJson(null), isNull);
    for (final status in PaymentStatus.values) {
      expect(paymentStatusFromJson(paymentStatusToJson(status)), status);
    }
    expect(paymentStatusToJson(PaymentStatus.partiallyPaid), 'PARTIALLY_PAID');
    expect(paymentStatusToJson(PaymentStatus.writtenOff), 'WRITTEN_OFF');
  });

  test('DiscountType handles null and round-trips every value', () {
    expect(discountTypeFromJson(null), isNull);
    expect(discountTypeToJson(null), isNull);
    expect(discountTypeFromJson('PERCENT'), DiscountType.percent);
    expect(discountTypeFromJson('FLAT'), DiscountType.flat);
  });

  test('DocumentLanguage round-trips both values', () {
    expect(documentLanguageFromJson('EN'), DocumentLanguage.en);
    expect(documentLanguageFromJson('FR'), DocumentLanguage.fr);
    expect(documentLanguageToJson(DocumentLanguage.en), 'EN');
    expect(documentLanguageToJson(DocumentLanguage.fr), 'FR');
  });

  test('PaymentMethod round-trips every value', () {
    for (final method in PaymentMethod.values) {
      expect(paymentMethodFromJson(paymentMethodToJson(method)), method);
    }
    expect(paymentMethodToJson(PaymentMethod.bankTransfer), 'BANK_TRANSFER');
    expect(paymentMethodToJson(PaymentMethod.mobileMoney), 'MOBILE_MONEY');
  });
}
