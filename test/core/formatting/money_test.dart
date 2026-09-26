import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/formatting/money.dart';

void main() {
  test('groups thousands with commas and prefixes the currency', () {
    expect(formatMoney(0), 'RWF 0');
    expect(formatMoney(999), 'RWF 999');
    expect(formatMoney(1000), 'RWF 1,000');
    expect(formatMoney(1234567), 'RWF 1,234,567');
  });

  test('keeps the sign on negative amounts', () {
    expect(formatMoney(-2500), 'RWF -2,500');
  });

  test('accepts another currency symbol', () {
    expect(formatMoney(5000, symbol: 'USD'), 'USD 5,000');
  });
}
