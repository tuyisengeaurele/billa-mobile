import '../../../core/formatting/currency.dart';
import '../../../core/formatting/short_date.dart';

class RateQuote {
  const RateQuote({required this.rate, required this.source, this.date});

  /// RWF for one whole unit of the currency.
  final double rate;

  /// `BNR` for the bank's reference rate, `LAST_USED` for the rate this business used last.
  final String source;
  final String? date;
}

class ExchangeRates {
  const ExchangeRates(this._quotes);

  factory ExchangeRates.fromJson(Map<String, dynamic> json) {
    final rates = (json['rates'] as Map?) ?? const {};
    final info = (json['info'] as Map?) ?? const {};
    final quotes = <Currency, RateQuote>{};
    for (final entry in rates.entries) {
      final currency = Currency.values.where((c) => c.code == entry.key).firstOrNull;
      final rate = rateFromJson(entry.value);
      if (currency == null || currency == Currency.rwf || rate == null) continue;
      final detail = info[entry.key] as Map?;
      quotes[currency] = RateQuote(
        rate: rate,
        source: (detail?['source'] as String?) ?? 'UNKNOWN',
        date: detail?['date'] as String?,
      );
    }
    return ExchangeRates(quotes);
  }

  final Map<Currency, RateQuote> _quotes;

  RateQuote? operator [](Currency currency) => _quotes[currency];
}

/// Where a prefilled rate came from, shown until the user types their own.
String? rateHint(RateQuote? quote) {
  if (quote == null) return null;
  if (quote.source == 'BNR' && quote.date != null) {
    return 'National Bank of Rwanda reference rate, ${formatShortDate(quote.date!)}.';
  }
  return 'The rate you used last.';
}
