import 'currency.dart';

/// "RWF 1,234,567" or "USD 1,250.50": grouped by thousands, with as many decimals as the currency has.
/// [symbol] replaces the currency code, and may be empty for chart labels that carry no code.
String formatMoney(int amount, {Currency currency = Currency.rwf, String? symbol}) {
  final per = currency.minorPerMajor;
  final absolute = amount.abs();
  final digits = (absolute ~/ per).toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  final fraction = currency.decimals == 0 ? '' : '.${(absolute % per).toString().padLeft(currency.decimals, '0')}';
  return '${symbol ?? currency.code} ${amount < 0 ? '-' : ''}$buffer$fraction';
}
