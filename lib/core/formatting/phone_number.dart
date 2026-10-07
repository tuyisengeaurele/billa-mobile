/// Digits ready for a `tel:` or WhatsApp link, or null when the text is not a
/// dialable number. Rwandan numbers are written locally as 07XXXXXXXX, but
/// WhatsApp links need the country code, so the local forms gain it.
String? normaliseRwandaNumber(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  // Letters mean this is a note rather than a number; stripping them would
  // dial something the user never wrote.
  if (RegExp(r'[A-Za-z]').hasMatch(trimmed)) return null;

  final digits = trimmed.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('250') && digits.length == 12) return digits;
  if (digits.startsWith('0') && digits.length == 10) return '250${digits.substring(1)}';
  if (digits.length == 9 && digits.startsWith('7')) return '250$digits';
  // Anything else with a plus sign, or long enough to carry its own country
  // code, is taken as international as written.
  if (trimmed.startsWith('+') && digits.length >= 8) return digits;
  return null;
}
