const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// "1 Oct 2026". Spelled out by hand so it reads the same on every phone and in the web app, and read as
/// the UTC calendar day because a due date is a day, not a moment.
String formatShortDate(String iso) {
  final parsed = DateTime.tryParse(iso);
  if (parsed == null) return iso;
  // A date with no zone is a calendar day and is kept as written; a value with a zone is already in UTC.
  final date = parsed.isUtc ? parsed : DateTime.utc(parsed.year, parsed.month, parsed.day);
  return '${date.day} ${_months[date.month - 1]} ${date.year}';
}
