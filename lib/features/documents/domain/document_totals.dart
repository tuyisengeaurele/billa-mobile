import 'document_draft_input.dart';
import 'document_enums.dart';

class LineTotals {
  const LineTotals({required this.lineTotal, required this.taxAmount, required this.discountAmount});

  final int lineTotal;
  final int taxAmount;
  final int discountAmount;

  @override
  bool operator ==(Object other) =>
      other is LineTotals &&
      other.lineTotal == lineTotal &&
      other.taxAmount == taxAmount &&
      other.discountAmount == discountAmount;

  @override
  int get hashCode => Object.hash(lineTotal, taxAmount, discountAmount);
}

class DocumentTotals {
  const DocumentTotals({required this.lines, required this.subtotal, required this.taxTotal, required this.total});

  final List<LineTotals> lines;
  final int subtotal;
  final int taxTotal;
  final int total;
}

DocumentTotals calculateDocumentTotals(List<DocumentLineInput> lines) {
  final computed = lines.map((line) {
    final rawLineTotal = (line.quantity * line.unitPrice).round();
    final rawDiscount = switch (line.discountType) {
      DiscountType.percent => (rawLineTotal * ((line.discountValue ?? 0) / 100)).round(),
      DiscountType.flat => (line.discountValue ?? 0).round(),
      null => 0,
    };
    final discountAmount = rawDiscount.clamp(0, rawLineTotal);
    final lineTotal = rawLineTotal - discountAmount;
    final taxAmount = (lineTotal * (line.taxRate / 100)).round();
    return LineTotals(lineTotal: lineTotal, taxAmount: taxAmount, discountAmount: discountAmount);
  }).toList();

  final subtotal = computed.fold(0, (sum, line) => sum + line.lineTotal);
  final taxTotal = computed.fold(0, (sum, line) => sum + line.taxAmount);
  return DocumentTotals(lines: computed, subtotal: subtotal, taxTotal: taxTotal, total: subtotal + taxTotal);
}
