import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/formatting/currency.dart';

void main() {
  test('each currency knows how many decimals it has', () {
    expect(Currency.rwf.decimals, 0);
    expect(Currency.usd.decimals, 2);
    expect(Currency.ugx.decimals, 0);
    expect(Currency.usd.minorPerMajor, 100);
    expect(Currency.rwf.minorPerMajor, 1);
  });

  test('an unknown or missing code reads as RWF instead of breaking a screen', () {
    expect(Currency.fromCode('USD'), Currency.usd);
    expect(Currency.fromCode('JPY'), Currency.rwf);
    expect(Currency.fromCode(null), Currency.rwf);
    expect(currencyFromJson(42), Currency.rwf);
    expect(currencyToJson(Currency.kes), 'KES');
  });

  test('a rate parses from a number, a numeric string or null', () {
    expect(rateFromJson(1450.5), 1450.5);
    expect(rateFromJson(1450), 1450.0);
    expect(rateFromJson('1450.25'), 1450.25);
    expect(rateFromJson(null), isNull);
    expect(rateFromJson('abc'), isNull);
  });

  group('parseMajorAmount', () {
    test('turns typed whole units into the smallest unit', () {
      expect(parseMajorAmount('12.50', Currency.usd), 1250);
      expect(parseMajorAmount('1,250.5', Currency.usd), 125050);
      expect(parseMajorAmount('5000', Currency.rwf), 5000);
      expect(parseMajorAmount(' 7 ', Currency.rwf), 7);
    });

    test('rounds extra decimals instead of failing', () {
      expect(parseMajorAmount('12.999', Currency.usd), 1300);
      expect(parseMajorAmount('12.5', Currency.rwf), 13);
    });

    test('rejects text that is not an amount', () {
      expect(parseMajorAmount('', Currency.usd), isNull);
      expect(parseMajorAmount('.', Currency.usd), isNull);
      expect(parseMajorAmount('abc', Currency.usd), isNull);
      expect(parseMajorAmount('1.2.3', Currency.usd), isNull);
      expect(parseMajorAmount('-5', Currency.usd), isNull);
    });

    test('accepts a trailing or leading dot while the user is still typing', () {
      expect(parseMajorAmount('12.', Currency.usd), 1200);
      expect(parseMajorAmount('.5', Currency.usd), 50);
    });
  });

  test('minorToMajorText drops trailing zeros and keeps zero readable', () {
    expect(minorToMajorText(1250, Currency.usd), '12.5');
    expect(minorToMajorText(1200, Currency.usd), '12');
    expect(minorToMajorText(1205, Currency.usd), '12.05');
    expect(minorToMajorText(10000, Currency.usd), '100');
    expect(minorToMajorText(0, Currency.usd), '0');
    expect(minorToMajorText(5000, Currency.rwf), '5000');
  });

  test('toRwf and fromRwf go through the rate, RWF for one whole unit', () {
    expect(toRwf(1000, Currency.usd, 1400), 14000);
    expect(fromRwf(14000, Currency.usd, 1400), 1000);
    expect(toRwf(5000, Currency.rwf, null), 5000);
    expect(toRwf(1000, Currency.usd, null), 0);
    expect(fromRwf(14000, Currency.usd, 0), 0);
  });

  test('convertMinor reprices through RWF and gives up when a rate is missing', () {
    expect(convertMinor(14000, from: Currency.rwf, fromRate: null, to: Currency.usd, toRate: 1400), 1000);
    expect(convertMinor(1000, from: Currency.usd, fromRate: 1400, to: Currency.rwf, toRate: null), 14000);
    expect(convertMinor(1000, from: Currency.usd, fromRate: 1400, to: Currency.eur, toRate: 1500), 933);
    expect(convertMinor(1000, from: Currency.usd, fromRate: null, to: Currency.rwf, toRate: null), isNull);
    expect(convertMinor(1000, from: Currency.rwf, fromRate: null, to: Currency.usd, toRate: null), isNull);
    expect(convertMinor(1000, from: Currency.usd, fromRate: null, to: Currency.usd, toRate: null), 1000);
  });

  test('rateProblem asks for a rate on foreign currencies only', () {
    expect(rateProblem(Currency.rwf, null), isNull);
    expect(rateProblem(Currency.usd, 1400), isNull);
    expect(rateProblem(Currency.usd, null), 'Enter the exchange rate for USD');
    expect(rateProblem(Currency.usd, 0), 'Enter the exchange rate for USD');
    expect(rateProblem(Currency.usd, 2000000), 'That exchange rate looks too high');
  });

  test('sumByCurrency never adds dollars to francs and lists RWF first', () {
    final totals = sumByCurrency([
      (currency: Currency.usd, amount: 500),
      (currency: Currency.rwf, amount: 4000),
      (currency: Currency.usd, amount: 250),
      (currency: Currency.rwf, amount: 1000),
    ]);

    expect(totals, [
      (currency: Currency.rwf, amount: 5000),
      (currency: Currency.usd, amount: 750),
    ]);
  });
}
