import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/documents/domain/document.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/domain/duplicate_draft.dart';

Document _source({
  DocumentType type = DocumentType.invoice,
  String? dueDate = '2026-02-15T00:00:00.000Z',
  String? referencedDocumentId,
}) =>
    Document(
      id: 'd-old',
      type: type,
      number: 'INV-0001',
      status: DocumentStatus.finalized,
      customerId: 'c1',
      customer: const DocumentCustomerRef(name: 'Acme'),
      issueDate: '2026-02-01T00:00:00.000Z',
      dueDate: dueDate,
      notes: 'Thanks for your business',
      customerReference: 'PO-77',
      language: DocumentLanguage.fr,
      subtotal: 10000,
      taxTotal: 1800,
      total: 11800,
      amountPaid: 11800,
      sentAt: '2026-02-01T10:00:00.000Z',
      publicToken: 'tok',
      referencedDocumentId: referencedDocumentId,
      createdAt: '2026-02-01T00:00:00.000Z',
      updatedAt: '2026-02-01T00:00:00.000Z',
      lines: const [
        DocumentLine(
          id: 'l1',
          itemId: 'i1',
          description: 'Cement',
          quantity: 10,
          unitPrice: 1000,
          taxRate: 18,
          discountType: DiscountType.percent,
          discountValue: 5,
          lineTotal: 9500,
          sortOrder: 0,
        ),
        DocumentLine(
          id: 'l2',
          description: 'Delivery',
          quantity: 1,
          unitPrice: 500,
          taxRate: 0,
          lineTotal: 500,
          sortOrder: 1,
        ),
      ],
    );

void main() {
  final today = DateTime(2026, 3, 10);

  test('keeps the customer, type, language, notes and every line with its discount', () {
    final draft = draftFromDocument(_source(), today: today);

    expect(draft.type, DocumentType.invoice);
    expect(draft.customerId, 'c1');
    expect(draft.language, DocumentLanguage.fr);
    expect(draft.notes, 'Thanks for your business');
    expect(draft.lines, hasLength(2));
    expect(draft.lines[0].itemId, 'i1');
    expect(draft.lines[0].description, 'Cement');
    expect(draft.lines[0].quantity, 10);
    expect(draft.lines[0].unitPrice, 1000);
    expect(draft.lines[0].taxRate, 18);
    expect(draft.lines[0].discountType, DiscountType.percent);
    expect(draft.lines[0].discountValue, 5);
    expect(draft.lines[1].itemId, isNull);
    expect(draft.lines[1].discountType, isNull);
  });

  test('is dated today and keeps the same payment terms', () {
    final draft = draftFromDocument(_source(), today: today);

    expect(draft.issueDate, '2026-03-10');
    expect(draft.dueDate, '2026-03-24');
  });

  test('has no due date when the original had none', () {
    expect(draftFromDocument(_source(dueDate: null), today: today).dueDate, isNull);
  });

  test('drops the customer purchase-order reference, which belongs to the original order', () {
    expect(draftFromDocument(_source(), today: today).customerReference, isNull);
  });

  test('a credit note keeps its reference invoice and other types never carry one', () {
    expect(
      draftFromDocument(_source(type: DocumentType.creditNote, referencedDocumentId: 'inv-9'), today: today).referencedDocumentId,
      'inv-9',
    );
    expect(draftFromDocument(_source(referencedDocumentId: 'inv-9'), today: today).referencedDocumentId, isNull);
  });

  test('sends no ids, numbers or payment state that would tie it to the original', () {
    final json = draftFromDocument(_source(), today: today).toJson();

    expect(json.containsKey('id'), isFalse);
    expect(json.containsKey('number'), isFalse);
    expect(json.containsKey('amountPaid'), isFalse);
    expect(json.containsKey('publicToken'), isFalse);
    final lines = (json['lines'] as List).cast<Map<String, dynamic>>();
    expect(lines.every((line) => !line.containsKey('id')), isTrue);
  });
}
