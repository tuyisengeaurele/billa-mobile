import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/formatting/currency.dart';
import 'package:billa_mobile/features/documents/domain/exchange_rates.dart';

void main() {
  test('reads the rate and where it came from for each currency', () {
    final rates = ExchangeRates.fromJson({
      'rates': {'USD': 1450.5, 'EUR': 1600},
      'info': {
        'USD': {'source': 'BNR', 'date': '2026-09-29'},
        'EUR': {'source': 'LAST_USED', 'date': null},
      },
    });

    expect(rates[Currency.usd]!.rate, 1450.5);
    expect(rates[Currency.usd]!.source, 'BNR');
    expect(rates[Currency.eur]!.rate, 1600.0);
    expect(rates[Currency.gbp], isNull);
    expect(rates[Currency.rwf], isNull);
  });

  test('ignores a currency code the app does not know and tolerates missing info', () {
    final rates = ExchangeRates.fromJson({
      'rates': {'JPY': 9.5, 'USD': 1450},
    });

    expect(rates[Currency.usd]!.rate, 1450.0);
    expect(rates[Currency.usd]!.source, 'UNKNOWN');
  });

  test('says where a prefilled rate came from', () {
    expect(
      rateHint(const RateQuote(rate: 1450, source: 'BNR', date: '2026-09-29')),
      'National Bank of Rwanda reference rate, 29 Sep 2026.',
    );
    expect(rateHint(const RateQuote(rate: 1450, source: 'LAST_USED')), 'The rate you used last.');
    expect(rateHint(null), isNull);
  });
}
