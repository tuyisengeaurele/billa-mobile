import '../../../core/formatting/money.dart';
import 'customer.dart';

/// The WhatsApp text for a customer's statement, worded like the web app's so a customer hears the same
/// thing from either. What is owed is listed one currency at a time and never added together.
String statementMessage({
  required String customer,
  required String business,
  required List<OutstandingTotal> totals,
  required String portalUrl,
  required bool payable,
}) {
  final owed = totals.map((total) => formatMoney(total.amount, currency: total.currency)).join(' + ');
  return [
    'Hello $customer, this is your statement from $business. You currently owe $owed.',
    '${payable ? 'See and pay your invoices here' : 'See your invoices here'}: $portalUrl',
  ].join('\n');
}
