import 'dart:math' as math;

/// The currencies a document can be written in. Amounts are whole numbers of a
/// currency's smallest unit (francs for RWF, cents for USD), exactly as the API stores them.
enum Currency {
  rwf('RWF', 'Rwandan franc', 0),
  usd('USD', 'US dollar', 2),
  eur('EUR', 'Euro', 2),
  gbp('GBP', 'British pound', 2),
  kes('KES', 'Kenyan shilling', 2),
  ugx('UGX', 'Ugandan shilling', 0),
  tzs('TZS', 'Tanzanian shilling', 2);

  const Currency(this.code, this.label, this.decimals);

  final String code;
  final String label;
  final int decimals;

  int get minorPerMajor => math.pow(10, decimals).toInt();

  /// A code the app does not know reads as RWF, as on the web, so a currency added
  /// on the server never breaks a screen that has not learned it yet.
  static Currency fromCode(Object? value) {
    for (final currency in values) {
      if (currency.code == value) return currency;
    }
    return Currency.rwf;
  }
}

Currency currencyFromJson(Object? value) => Currency.fromCode(value);

String currencyToJson(Currency value) => value.code;

double? rateFromJson(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

/// "12.50" typed in a price box becomes 1250 for USD and 13 for RWF. Null for text that is not an amount.
int? parseMajorAmount(String text, Currency currency) {
  final cleaned = text.replaceAll(RegExp(r'[\s,]'), '');
  if (cleaned.isEmpty || cleaned == '.' || !RegExp(r'^\d*\.?\d*$').hasMatch(cleaned)) return null;
  return (double.parse(cleaned) * currency.minorPerMajor).round();
}

/// 1250 for USD becomes "12.5" for a price box; whole units for RWF.
String minorToMajorText(int minor, Currency currency) {
  if (currency.decimals == 0) return minor.toString();
  final text = (minor / currency.minorPerMajor).toStringAsFixed(currency.decimals);
  return text.replaceFirst(RegExp(r'\.?0+$'), '');
}

/// What an amount in [currency] is worth in RWF at [rate] (RWF for one whole unit).
int toRwf(int minor, Currency currency, double? rate) {
  if (currency == Currency.rwf) return minor;
  if (rate == null || rate <= 0) return 0;
  return (minor / currency.minorPerMajor * rate).round();
}

/// What an RWF amount comes to in [currency] at [rate], in that currency's smallest unit.
int fromRwf(int rwf, Currency currency, double? rate) {
  if (currency == Currency.rwf) return rwf;
  if (rate == null || rate <= 0) return 0;
  return (rwf / rate * currency.minorPerMajor).round();
}

/// Re-prices an amount when a draft changes currency, going through RWF. Null when a rate is missing.
int? convertMinor(
  int minor, {
  required Currency from,
  required double? fromRate,
  required Currency to,
  required double? toRate,
}) {
  if (from == to) return minor;
  if (from != Currency.rwf && !(fromRate != null && fromRate > 0)) return null;
  if (to != Currency.rwf && !(toRate != null && toRate > 0)) return null;
  return fromRwf(toRwf(minor, from, fromRate), to, toRate);
}

/// A rate has to be a positive number; RWF documents have none.
String? rateProblem(Currency currency, double? rate) {
  if (currency == Currency.rwf) return null;
  if (rate == null || !rate.isFinite || rate <= 0) return 'Enter the exchange rate for ${currency.code}';
  if (rate > 1000000) return 'That exchange rate looks too high';
  return null;
}

typedef MoneyAmount = ({Currency currency, int amount});

/// Adds amounts one currency at a time, RWF first, so a total never adds dollars to francs.
List<MoneyAmount> sumByCurrency(Iterable<MoneyAmount> items) {
  final totals = <Currency, int>{};
  for (final item in items) {
    totals[item.currency] = (totals[item.currency] ?? 0) + item.amount;
  }
  return [
    for (final currency in Currency.values)
      if (totals.containsKey(currency)) (currency: currency, amount: totals[currency]!),
  ];
}
