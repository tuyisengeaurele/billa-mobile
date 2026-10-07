/// "just now", "5 min ago", "3 h ago", "2 d ago", then the plain date. [now]
/// is injectable so the result is stable under test.
String relativeTime(String iso, {DateTime? now}) {
  final then = DateTime.tryParse(iso);
  if (then == null) return iso.split('T').first;
  final age = (now ?? DateTime.now()).difference(then);
  if (age.inMinutes < 1) return 'just now';
  if (age.inMinutes < 60) return '${age.inMinutes} min ago';
  if (age.inHours < 24) return '${age.inHours} h ago';
  if (age.inDays < 7) return '${age.inDays} d ago';
  return iso.split('T').first;
}
