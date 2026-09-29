import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/documents/domain/document_draft_input.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';

void main() {
  test('DocumentDraftInput.toJson matches the backend request shape', () {
    const input = DocumentDraftInput(
      type: DocumentType.invoice,
      customerId: 'c1',
      issueDate: '2026-08-19',
      lines: [
        DocumentLineInput(description: 'Printing', quantity: 2, unitPrice: 5000, taxRate: 18),
      ],
    );

    final json = input.toJson();

    expect(json['type'], 'INVOICE');
    expect(json['customerId'], 'c1');
    expect(json['issueDate'], '2026-08-19');
    expect(json['dueDate'], isNull);
    expect(json['language'], 'EN');
    expect(json['lines'], hasLength(1));
    expect(json['lines'][0]['description'], 'Printing');
    expect(json['lines'][0]['quantity'], 2);
    expect(json['lines'][0]['unitPrice'], 5000);
    expect(json['lines'][0]['taxRate'], 18);
  });

  test('DocumentLineInput.toJson carries an optional discount', () {
    const line = DocumentLineInput(
      description: 'Cement',
      quantity: 1,
      unitPrice: 10000,
      taxRate: 18,
      discountType: DiscountType.percent,
      discountValue: 10,
    );

    final json = line.toJson();

    expect(json['discountType'], 'PERCENT');
    expect(json['discountValue'], 10);
  });

  test('round-trips through fromJson', () {
    const input = DocumentDraftInput(
      type: DocumentType.creditNote,
      customerId: 'c1',
      issueDate: '2026-08-19',
      referencedDocumentId: 'inv1',
      language: DocumentLanguage.fr,
      lines: [],
    );

    final roundTripped = DocumentDraftInput.fromJson(input.toJson());

    expect(roundTripped, input);
  });

  test('leaves out due date, notes, reference and item link when they are empty, because the server rejects null for them', () {
    const input = DocumentDraftInput(
      type: DocumentType.invoice,
      customerId: 'c1',
      issueDate: '2026-08-19',
      lines: [DocumentLineInput(description: 'Printing', quantity: 2, unitPrice: 5000, taxRate: 18)],
    );

    final json = input.toJson();

    for (final key in ['dueDate', 'notes', 'customerReference', 'referencedDocumentId']) {
      expect(json.containsKey(key), isFalse, reason: key);
    }
    final line = (json['lines'] as List).single as Map<String, dynamic>;
    for (final key in ['itemId', 'discountType', 'discountValue']) {
      expect(line.containsKey(key), isFalse, reason: 'line $key');
    }
  });

  test('sends those fields when they have values', () {
    const input = DocumentDraftInput(
      type: DocumentType.creditNote,
      customerId: 'c1',
      issueDate: '2026-08-19',
      dueDate: '2026-09-19',
      notes: 'Thanks',
      customerReference: 'PO-1',
      referencedDocumentId: 'inv-1',
      lines: [DocumentLineInput(itemId: 'i1', description: 'Cement', quantity: 1, unitPrice: 100, taxRate: 0)],
    );

    final json = input.toJson();

    expect(json['dueDate'], '2026-09-19');
    expect(json['notes'], 'Thanks');
    expect(json['customerReference'], 'PO-1');
    expect(json['referencedDocumentId'], 'inv-1');
    expect(((json['lines'] as List).single as Map)['itemId'], 'i1');
  });
}
