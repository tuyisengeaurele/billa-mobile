import 'document_draft_input.dart';

/// The web's limit, and the server refuses a longer plan.
const maxInstallments = 12;

/// The total shared over some instalments; any leftover goes on the last one, so the parts always add back up.
List<int> splitEvenly(int total, int parts) {
  final each = total ~/ parts;
  return [for (var i = 0; i < parts; i++) i == parts - 1 ? total - each * (parts - 1) : each];
}

/// A percentage of the total in whole units, kept between nothing and the whole total.
int percentOfTotal(int total, double percent) => (total * percent / 100).round().clamp(0, total);

/// Moves by calendar months. A day the next month does not have (the 31st) lands on that month's last day.
DateTime addMonths(DateTime date, int months) {
  final monthIndex = date.month - 1 + months;
  final year = date.year + monthIndex ~/ 12;
  final month = monthIndex % 12 + 1;
  final lastDay = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, date.day > lastDay ? lastDay : date.day);
}

String _isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

/// Every row as typed except the last, which is always what is left of the total. A plan saved this way
/// can never disagree with the invoice, however the lines change afterwards.
List<InstallmentInput> withBalance(List<InstallmentInput> rows, int total) {
  if (rows.isEmpty) return rows;
  final earlier = rows.take(rows.length - 1).fold<int>(0, (sum, row) => sum + row.amount);
  return [
    ...rows.take(rows.length - 1),
    InstallmentInput(label: rows.last.label, amount: total - earlier, dueDate: rows.last.dueDate),
  ];
}

/// Why a plan cannot be saved, in plain words, or null when it is fine. [rows] are the rows with the balance
/// already applied. The messages are the web's where it has one.
String? installmentPlanProblem(int total, List<InstallmentInput> rows) {
  if (rows.length < 2) return 'Add at least two instalments, or choose to pay in full.';
  if (rows.length > maxInstallments) return 'Use $maxInstallments instalments or fewer.';
  if (rows.any((row) => row.dueDate.trim().isEmpty)) return 'Each instalment needs a due date.';
  final earlier = rows.take(rows.length - 1).fold<int>(0, (sum, row) => sum + row.amount);
  if (earlier >= total && rows.take(rows.length - 1).every((row) => row.amount > 0)) {
    return 'The earlier instalments already add up to the whole total. Lower them so the balance is more than zero.';
  }
  if (rows.any((row) => row.amount <= 0)) return 'Each instalment must be an amount greater than zero.';
  return null;
}

enum PlanPreset { twoParts, threeParts, deposit }

/// The rows a preset starts from; every one can be edited afterwards, and the last is always the balance.
List<InstallmentInput> buildPreset(
  PlanPreset preset, {
  required int total,
  required DateTime issueDate,
  required DateTime firstDue,
}) {
  switch (preset) {
    case PlanPreset.twoParts:
    case PlanPreset.threeParts:
      final parts = preset == PlanPreset.twoParts ? 2 : 3;
      final amounts = splitEvenly(total, parts);
      return [
        for (var i = 0; i < parts; i++)
          InstallmentInput(amount: amounts[i], dueDate: _isoDate(addMonths(firstDue, i))),
      ];
    case PlanPreset.deposit:
      final deposit = percentOfTotal(total, 30);
      return [
        InstallmentInput(label: 'Deposit', amount: deposit, dueDate: _isoDate(issueDate)),
        InstallmentInput(label: 'Balance', amount: total - deposit, dueDate: _isoDate(firstDue)),
      ];
  }
}
