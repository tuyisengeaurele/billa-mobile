import 'document.dart';
import 'document_draft_input.dart';
import 'document_enums.dart';

String _isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

/// A new draft that repeats [source]: same customer and lines, dated today,
/// with the same time allowed to pay. Anything that identifies the original
/// (number, payments, sent state, the customer's own order reference) is left
/// behind on purpose.
DocumentDraftInput draftFromDocument(Document source, {DateTime? today}) {
  final now = today ?? DateTime.now();
  final date = DateTime(now.year, now.month, now.day);

  String? dueDate;
  if (source.dueDate != null) {
    final issued = DateTime.parse(source.issueDate);
    final due = DateTime.parse(source.dueDate!);
    final terms = DateTime.utc(due.year, due.month, due.day).difference(DateTime.utc(issued.year, issued.month, issued.day));
    dueDate = _isoDate(date.add(terms));
  }

  return DocumentDraftInput(
    type: source.type,
    customerId: source.customerId,
    issueDate: _isoDate(date),
    dueDate: dueDate,
    notes: source.notes,
    // Only a credit note points at an invoice; copying the link onto any other
    // type would be rejected or, worse, accepted and wrong.
    referencedDocumentId: source.type == DocumentType.creditNote ? source.referencedDocumentId : null,
    language: source.language,
    lines: [
      for (final line in source.lines)
        DocumentLineInput(
          itemId: line.itemId,
          description: line.description,
          quantity: line.quantity,
          unitPrice: line.unitPrice,
          taxRate: line.taxRate,
          discountType: line.discountType,
          discountValue: line.discountValue,
        ),
    ],
  );
}
