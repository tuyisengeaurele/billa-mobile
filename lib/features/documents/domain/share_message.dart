import '../../../core/formatting/currency.dart';
import '../../../core/formatting/money.dart';
import '../../../core/formatting/short_date.dart';
import 'document_enums.dart';

/// The customer-facing page for a finalized document. The web client and the
/// API are served from one origin, so the API address is also the page's.
String publicDocumentUrl(String origin, String publicToken) {
  final base = origin.endsWith('/') ? origin.substring(0, origin.length - 1) : origin;
  return '$base/view/$publicToken';
}

/// The label before a document's date, or none for a type that has no date to show.
String? dueDateLabel(DocumentType type) => switch (type) {
      DocumentType.invoice => 'Due date',
      DocumentType.proforma || DocumentType.quote => 'Valid until',
      _ => null,
    };

String _lines(String opening, DocumentType type, String? dueDate, String link, bool payable) {
  final label = dueDateLabel(type);
  final canPay = payable && type == DocumentType.invoice;
  return [
    opening,
    if (label != null && dueDate != null) '$label: ${formatShortDate(dueDate)}.',
    '${canPay ? 'View and pay it here' : 'View it here'}: $link',
  ].join('\n');
}

/// Worded like the web app's WhatsApp reminder, so a customer hears the same thing from either app.
/// [payable] is whether the public page can take a MoMo payment, and it never can for a foreign invoice.
String reminderMessage({
  required String customer,
  required String business,
  required String? number,
  required int amountOwed,
  required String? dueDate,
  required String link,
  Currency currency = Currency.rwf,
  bool payable = false,
  ({String? label, int amount})? instalment,
}) {
  final reference = number == null ? 'invoice' : 'invoice $number';
  String money(int amount) => formatMoney(amount, currency: currency);
  final name = instalment?.label?.trim();
  final due = instalment == null
      ? ''
      : ', of which ${money(instalment.amount)} (${name == null || name.isEmpty ? 'the next instalment' : name}) is due now';
  final opening = 'Hello $customer, a reminder from $business that $reference has ${money(amountOwed)} outstanding$due.';
  return _lines(opening, DocumentType.invoice, dueDate, link, payable && currency == Currency.rwf);
}

String shareMessage({
  required String customer,
  required String business,
  required DocumentType type,
  required String typeLabel,
  required String? number,
  required int total,
  required String? dueDate,
  required String link,
  Currency currency = Currency.rwf,
  bool payable = false,
}) {
  final reference = number == null ? typeLabel : '$typeLabel $number';
  final opening = 'Hello $customer, $business sent you $reference for ${formatMoney(total, currency: currency)}.';
  return _lines(opening, type, dueDate, link, payable && currency == Currency.rwf);
}
