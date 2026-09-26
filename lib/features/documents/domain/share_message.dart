import '../../../core/formatting/money.dart';

/// The customer-facing page for a finalized document. The web client and the
/// API are served from one origin, so the API address is also the page's.
String publicDocumentUrl(String origin, String publicToken) {
  final base = origin.endsWith('/') ? origin.substring(0, origin.length - 1) : origin;
  return '$base/view/$publicToken';
}

String reminderMessage({
  required String customer,
  required String? number,
  required int amountOwed,
  required String link,
}) {
  final what = number == null ? 'your invoice' : 'invoice $number';
  return 'Hello $customer, a friendly reminder that $what has ${formatMoney(amountOwed)} outstanding. '
      'You can view it and pay here: $link Thank you.';
}

String shareMessage({
  required String customer,
  required String typeLabel,
  required String? number,
  required int total,
  required String link,
}) {
  final what = number == null ? 'your $typeLabel' : '$typeLabel $number';
  return 'Hello $customer, here is $what for ${formatMoney(total)}: $link Thank you.';
}
