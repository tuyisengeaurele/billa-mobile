/// The same presets the web offers, so a term means the same number of days in both apps.
const paymentTermOptions = <({int days, String label})>[
  (days: 0, label: 'Due on receipt'),
  (days: 7, label: 'Net 7'),
  (days: 14, label: 'Net 14'),
  (days: 30, label: 'Net 30'),
  (days: 60, label: 'Net 60'),
];

/// Counts calendar days, not 24-hour blocks, so a clock change never moves a due date by a day.
DateTime addDays(DateTime date, int days) => DateTime(date.year, date.month, date.day + days);

/// The preset that [issue] to [due] equals, or null for a custom gap.
int? matchPaymentTerm(DateTime issue, DateTime? due) {
  if (due == null) return null;
  final gap = DateTime.utc(due.year, due.month, due.day).difference(DateTime.utc(issue.year, issue.month, issue.day)).inDays;
  for (final option in paymentTermOptions) {
    if (option.days == gap) return option.days;
  }
  return null;
}
