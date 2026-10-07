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
}
