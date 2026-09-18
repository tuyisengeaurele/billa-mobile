import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/documents/domain/document_draft_input.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/domain/document_totals.dart';

DocumentLineInput _line({
  double quantity = 1,
  required int unitPrice,
  required double taxRate,
  DiscountType? discountType,
  double? discountValue,
}) =>
    DocumentLineInput(
      description: 'Line',
      quantity: quantity,
      unitPrice: unitPrice,
      taxRate: taxRate,
      discountType: discountType,
      discountValue: discountValue,
    );

void main() {
  test('computes line totals, subtotal, tax, and total', () {
    final result = calculateDocumentTotals([
      _line(quantity: 2, unitPrice: 5000, taxRate: 18),
      _line(quantity: 1, unitPrice: 1000, taxRate: 0),
    ]);

    expect(result.lines[0], const LineTotals(lineTotal: 10000, taxAmount: 1800, discountAmount: 0));
    expect(result.lines[1], const LineTotals(lineTotal: 1000, taxAmount: 0, discountAmount: 0));
    expect(result.subtotal, 11000);
    expect(result.taxTotal, 1800);
    expect(result.total, 12800);
  });

  test('returns zeros for an empty line list', () {
    final result = calculateDocumentTotals([]);
    expect(result.lines, isEmpty);
    expect(result.subtotal, 0);
    expect(result.taxTotal, 0);
    expect(result.total, 0);
  });

  test('rounds fractional quantities to the nearest RWF', () {
    final result = calculateDocumentTotals([_line(quantity: 2.5, unitPrice: 1000, taxRate: 10)]);
    expect(result.lines[0].lineTotal, 2500);
    expect(result.lines[0].taxAmount, 250);
  });

  test('applies a percentage discount before computing tax', () {
    final result = calculateDocumentTotals([
      _line(unitPrice: 10000, taxRate: 18, discountType: DiscountType.percent, discountValue: 10),
    ]);

    expect(result.lines[0], const LineTotals(lineTotal: 9000, taxAmount: 1620, discountAmount: 1000));
    expect(result.subtotal, 9000);
    expect(result.total, 10620);
  });

  test('applies a flat discount before computing tax', () {
    final result = calculateDocumentTotals([
      _line(unitPrice: 10000, taxRate: 18, discountType: DiscountType.flat, discountValue: 2000),
    ]);

    expect(result.lines[0], const LineTotals(lineTotal: 8000, taxAmount: 1440, discountAmount: 2000));
  });

  test('clamps a discount so a line can never go negative', () {
    final result = calculateDocumentTotals([
      _line(unitPrice: 5000, taxRate: 18, discountType: DiscountType.flat, discountValue: 9000),
    ]);

    expect(result.lines[0], const LineTotals(lineTotal: 0, taxAmount: 0, discountAmount: 5000));
  });

  test('treats a missing discountType as no discount', () {
    final result = calculateDocumentTotals([_line(unitPrice: 5000, taxRate: 18)]);
    expect(result.lines[0].discountAmount, 0);
  });
}
