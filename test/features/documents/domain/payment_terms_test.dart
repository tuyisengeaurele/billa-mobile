import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/documents/domain/payment_terms.dart';

void main() {
  test('offers the same terms as the web', () {
    expect(paymentTermOptions.map((o) => (o.days, o.label)), [
      (0, 'Due on receipt'),
      (7, 'Net 7'),
      (14, 'Net 14'),
      (30, 'Net 30'),
      (60, 'Net 60'),
    ]);
  });

  test('adds calendar days across a month and a year end', () {
    expect(addDays(DateTime(2026, 1, 31), 30), DateTime(2026, 3, 2));
    expect(addDays(DateTime(2026, 12, 20), 30), DateTime(2027, 1, 19));
    expect(addDays(DateTime(2026, 5, 5), 0), DateTime(2026, 5, 5));
  });

  test('adding days ignores daylight saving by counting calendar days, not hours', () {
    expect(addDays(DateTime(2026, 3, 28), 2), DateTime(2026, 3, 30));
  });

  test('recognises a preset gap and calls anything else custom', () {
    final issue = DateTime(2026, 9, 1);
    expect(matchPaymentTerm(issue, DateTime(2026, 9, 1)), 0);
    expect(matchPaymentTerm(issue, DateTime(2026, 9, 8)), 7);
    expect(matchPaymentTerm(issue, DateTime(2026, 9, 15)), 14);
    expect(matchPaymentTerm(issue, DateTime(2026, 10, 1)), 30);
    expect(matchPaymentTerm(issue, DateTime(2026, 10, 31)), 60);
    expect(matchPaymentTerm(issue, DateTime(2026, 9, 11)), isNull);
    expect(matchPaymentTerm(issue, null), isNull);
    expect(matchPaymentTerm(issue, DateTime(2026, 8, 25)), isNull);
  });
}
