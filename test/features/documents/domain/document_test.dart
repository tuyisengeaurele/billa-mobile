import 'package:billa_mobile/core/formatting/currency.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/documents/domain/document.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';

Map<String, dynamic> _lineJson({String? discountType, String? discountValue}) => {
      'id': 'l1',
      'itemId': null,
      'description': 'Printing',
      'quantity': '2.00',
      'unitPrice': 5000,
      'taxRate': '18.00',
      'discountType': discountType,
      'discountValue': discountValue,
      'lineTotal': 10000,
      'sortOrder': 0,
    };

Map<String, dynamic> _documentJson({Map<String, dynamic>? extra}) => {
      'id': 'd1',
      'type': 'INVOICE',
      'number': 'INV-0001',
      'status': 'FINALIZED',
      'customerId': 'c1',
      'customer': {'name': 'Acme', 'email': 'acme@example.com'},
      'issueDate': '2026-01-01T00:00:00.000Z',
      'dueDate': '2026-01-31T00:00:00.000Z',
      'notes': null,
      'customerReference': null,
      'subtotal': 10000,
      'taxTotal': 1800,
      'total': 11800,
      'sentAt': null,
      'amountPaid': 0,
      'paymentStatus': null,
      'writtenOffAt': null,
      'writeOffReason': null,
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': '2026-01-01T00:00:00.000Z',
      'convertedFromId': null,
      'referencedDocumentId': null,
      ...?extra,
    };

void main() {
  test('DocumentLine.fromJson parses decimal strings into doubles', () {
    final line = DocumentLine.fromJson(_lineJson());
    expect(line.quantity, 2.0);
    expect(line.taxRate, 18.0);
    expect(line.discountValue, isNull);
    expect(line.discountType, isNull);
  });

  test('DocumentLine.fromJson parses a discount', () {
    final line = DocumentLine.fromJson(_lineJson(discountType: 'PERCENT', discountValue: '10.00'));
    expect(line.discountType, DiscountType.percent);
    expect(line.discountValue, 10.0);
  });

  test('Document.fromJson parses a detail response with lines and a converted-from link', () {
    final json = _documentJson(extra: {
      'lines': [_lineJson()],
      'convertedFrom': {'id': 'p1', 'number': 'PRO-0001', 'type': 'PROFORMA'},
      'convertedTo': null,
      'referencedDocument': null,
    });

    final document = Document.fromJson(json);

    expect(document.lines, hasLength(1));
    expect(document.convertedFrom?.id, 'p1');
    expect(document.convertedFrom?.type, DocumentType.proforma);
    expect(document.convertedTo, isNull);
  });

  test('Document.fromJson defaults lines and refs when parsing a list row (keys absent)', () {
    final document = Document.fromJson(_documentJson());

    expect(document.lines, isEmpty);
    expect(document.convertedFrom, isNull);
    expect(document.convertedTo, isNull);
    expect(document.referencedDocument, isNull);
    expect(document.paymentStatus, isNull);
  });

  test('reads the public token that the customer-facing page is built from', () {
    expect(Document.fromJson(_documentJson(extra: {'publicToken': 'abc123'})).publicToken, 'abc123');
    expect(Document.fromJson(_documentJson()).publicToken, isNull);
  });

  test('reads the document language', () {
    expect(Document.fromJson(_documentJson(extra: {'language': 'FR'})).language, DocumentLanguage.fr);
    expect(Document.fromJson(_documentJson(extra: {'language': 'EN'})).language, DocumentLanguage.en);
  });

  test('defaults to English when the server does not send a language', () {
    expect(Document.fromJson(_documentJson()).language, DocumentLanguage.en);
  });

  test('language names are shown in their own language', () {
    expect(documentLanguageLabel(DocumentLanguage.en), 'English');
    expect(documentLanguageLabel(DocumentLanguage.fr), 'Français');
  });

  test('a document with no currency reads as RWF, as older responses have none', () {
    final document = Document.fromJson(_documentJson());

    expect(document.currency, Currency.rwf);
    expect(document.exchangeRate, isNull);
    expect(document.installments, isEmpty);
    expect(document.recurrenceInterval, isNull);
    expect(document.nextInstallment, isNull);
    expect(document.business, isNull);
  });

  test('a foreign document carries its currency and the rate saved with it', () {
    final document = Document.fromJson(_documentJson(extra: {'currency': 'USD', 'exchangeRate': 1450.5}));

    expect(document.currency, Currency.usd);
    expect(document.exchangeRate, 1450.5);
  });

  test('a currency the app does not know reads as RWF', () {
    expect(Document.fromJson(_documentJson(extra: {'currency': 'JPY'})).currency, Currency.rwf);
  });

  test('reads a payment plan, the next instalment and whether the business takes MoMo', () {
    final document = Document.fromJson(_documentJson(extra: {
      'installments': [
        {'id': 'i1', 'sortOrder': 0, 'label': 'Deposit', 'amount': 4000, 'dueDate': '2026-10-01T00:00:00.000Z'},
        {'id': 'i2', 'sortOrder': 1, 'label': null, 'amount': 7800, 'dueDate': '2026-11-01T00:00:00.000Z'},
      ],
      'nextInstallment': {
        'label': 'Deposit',
        'amount': 4000,
        'dueDate': '2026-10-01',
        'paid': 1000,
        'remaining': 3000,
        'status': 'PARTIALLY_PAID',
      },
      'business': {'momoEnabled': true},
    }));

    expect(document.installments.map((step) => step.amount), [4000, 7800]);
    expect(document.installments.first.label, 'Deposit');
    expect(document.installments.last.label, isNull);
    expect(document.nextInstallment!.remaining, 3000);
    expect(document.business!.momoEnabled, isTrue);
  });

  test('reads a repeat schedule', () {
    final document = Document.fromJson(
      _documentJson(extra: {'recurrenceInterval': 'MONTHLY', 'recurrenceEndDate': '2027-01-01T00:00:00.000Z'}),
    );

    expect(document.recurrenceInterval, 'MONTHLY');
    expect(document.recurrenceEndDate, '2027-01-01T00:00:00.000Z');
  });

  test('reads the schedule the server works out from the payments, and none when there is no plan', () {
    final withPlan = Document.fromJson(_documentJson(extra: {
      'schedule': [
        {
          'label': 'Deposit',
          'amount': 4000,
          'dueDate': '2026-10-01',
          'paid': 4000,
          'remaining': 0,
          'status': 'PAID',
          'isOverdue': false,
          'number': 1,
          'count': 2,
        },
        {
          'label': null,
          'amount': 7800,
          'dueDate': '2026-11-01',
          'paid': 0,
          'remaining': 7800,
          'status': 'UNPAID',
          'isOverdue': false,
          'number': 2,
          'count': 2,
        },
      ],
    }));
    final withoutPlan = Document.fromJson(_documentJson(extra: {'schedule': null}));

    expect(withPlan.schedule.map((s) => (s.label, s.amount, s.status, s.number)), [
      ('Deposit', 4000, 'PAID', 1),
      (null, 7800, 'UNPAID', 2),
    ]);
    expect(withoutPlan.schedule, isEmpty);
    expect(Document.fromJson(_documentJson()).schedule, isEmpty);
  });

  test('reads when a repeating invoice next repeats', () {
    final document = Document.fromJson(_documentJson(extra: {
      'recurrenceInterval': 'MONTHLY',
      'recurrenceEndDate': '2027-01-01T00:00:00.000Z',
      'nextRecurrenceAt': '2026-11-01T00:00:00.000Z',
    }));

    expect(document.nextRecurrenceAt, '2026-11-01T00:00:00.000Z');
    expect(Document.fromJson(_documentJson()).nextRecurrenceAt, isNull);
  });
}
