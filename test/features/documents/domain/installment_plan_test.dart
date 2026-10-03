import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/documents/domain/document_draft_input.dart';
import 'package:billa_mobile/features/documents/domain/installment_plan.dart';

InstallmentInput _row(int amount, {String due = '2026-10-01', String? label}) =>
    InstallmentInput(label: label, amount: amount, dueDate: due);

void main() {
  group('splitEvenly', () {
    test('shares the total and puts the leftover on the last part', () {
      expect(splitEvenly(10000, 3), [3333, 3333, 3334]);
      expect(splitEvenly(100, 2), [50, 50]);
      expect(splitEvenly(7, 3), [2, 2, 3]);
    });

    test('always adds back up to the total', () {
      for (final total in [1, 9, 100, 12345, 999999]) {
        for (var parts = 2; parts <= 12; parts++) {
          expect(splitEvenly(total, parts).fold(0, (a, b) => a + b), total);
        }
      }
    });
  });

  group('percentOfTotal', () {
    test('rounds to a whole amount', () {
      expect(percentOfTotal(10000, 30), 3000);
      expect(percentOfTotal(1001, 33.3), 333);
    });

    test('stays between nothing and the whole total', () {
      expect(percentOfTotal(10000, -5), 0);
      expect(percentOfTotal(10000, 250), 10000);
    });
  });

  group('addMonths', () {
    test('moves by calendar months and keeps the day when it can', () {
      expect(addMonths(DateTime(2026, 10, 15), 1), DateTime(2026, 11, 15));
      expect(addMonths(DateTime(2026, 12, 15), 2), DateTime(2027, 2, 15));
    });

    test('a day that does not exist in the next month lands on its last day', () {
      expect(addMonths(DateTime(2026, 1, 31), 1), DateTime(2026, 2, 28));
      expect(addMonths(DateTime(2028, 1, 31), 1), DateTime(2028, 2, 29));
      expect(addMonths(DateTime(2026, 3, 31), 1), DateTime(2026, 4, 30));
    });
  });

  group('withBalance', () {
    test('the last row is whatever is left of the total', () {
      final rows = withBalance([_row(3000), _row(0)], 10000);

      expect(rows.map((r) => r.amount), [3000, 7000]);
    });

    test('follows the total when it changes', () {
      final rows = [_row(3000), _row(2000), _row(0)];

      expect(withBalance(rows, 10000).map((r) => r.amount), [3000, 2000, 5000]);
      expect(withBalance(rows, 12000).map((r) => r.amount), [3000, 2000, 7000]);
    });

    test('keeps names and dates', () {
      final rows = withBalance([_row(3000, label: 'Deposit', due: '2026-10-01'), _row(0, due: '2026-11-01')], 10000);

      expect(rows.first.label, 'Deposit');
      expect(rows.last.dueDate, '2026-11-01');
    });
  });

  group('installmentPlanProblem', () {
    test('a good plan has no problem', () {
      expect(installmentPlanProblem(10000, withBalance([_row(3000), _row(0)], 10000)), isNull);
    });

    test('needs at least two rows', () {
      expect(
        installmentPlanProblem(10000, [_row(10000)]),
        'Add at least two instalments, or choose to pay in full.',
      );
    });

    test('allows no more than twelve', () {
      final rows = List.generate(13, (_) => _row(1));
      expect(installmentPlanProblem(13, rows), 'Use 12 instalments or fewer.');
    });

    test('earlier rows that already reach the total leave nothing for the balance', () {
      final rows = withBalance([_row(10000), _row(0)], 10000);

      expect(
        installmentPlanProblem(10000, rows),
        'The earlier instalments already add up to the whole total. Lower them so the balance is more than zero.',
      );
    });

    test('an amount of zero in an earlier row is refused', () {
      final rows = withBalance([_row(0), _row(0)], 10000);

      expect(
        installmentPlanProblem(10000, rows),
        'Each instalment must be an amount greater than zero.',
      );
    });

    test('a row without a date is refused', () {
      final rows = withBalance([_row(3000, due: ''), _row(0)], 10000);

      expect(installmentPlanProblem(10000, rows), 'Each instalment needs a due date.');
    });

    test('works in the smallest unit of a foreign currency', () {
      // USD 100.00 in two parts is two rows of 5000 cents.
      final rows = withBalance([_row(5000), _row(0)], 10000);

      expect(rows.map((r) => r.amount), [5000, 5000]);
      expect(installmentPlanProblem(10000, rows), isNull);
    });
  });

  group('plan presets', () {
    test('equal parts split the total and fall one month apart from the first date', () {
      final rows = buildPreset(
        PlanPreset.threeParts,
        total: 10000,
        issueDate: DateTime(2026, 9, 1),
        firstDue: DateTime(2026, 10, 1),
      );

      expect(rows.map((r) => r.amount), [3333, 3333, 3334]);
      expect(rows.map((r) => r.dueDate), ['2026-10-01', '2026-11-01', '2026-12-01']);
    });

    test('two equal parts', () {
      final rows = buildPreset(
        PlanPreset.twoParts,
        total: 10001,
        issueDate: DateTime(2026, 9, 1),
        firstDue: DateTime(2026, 10, 1),
      );

      expect(rows.map((r) => r.amount), [5000, 5001]);
    });

    test('a deposit is due on the issue date and the balance a month later', () {
      final rows = buildPreset(
        PlanPreset.deposit,
        total: 10000,
        issueDate: DateTime(2026, 9, 1),
        firstDue: DateTime(2026, 10, 1),
      );

      expect(rows.map((r) => (r.label, r.amount, r.dueDate)), [
        ('Deposit', 3000, '2026-09-01'),
        ('Balance', 7000, '2026-10-01'),
      ]);
    });
  });
}
