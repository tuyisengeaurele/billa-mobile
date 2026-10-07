/// "RWF 1,234,567": amounts are whole francs, grouped by thousands.
String formatMoney(int amount, {String symbol = 'RWF'}) {
  final digits = amount.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return '$symbol ${amount < 0 ? '-' : ''}$buffer';
}
