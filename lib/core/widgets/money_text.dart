import 'package:flutter/material.dart';

class MoneyText extends StatelessWidget {
  const MoneyText(this.amount, {super.key, this.style, this.currencySymbol = 'RWF'});

  final int amount;
  final TextStyle? style;
  final String currencySymbol;

  static String _grouped(int amount) {
    final negative = amount < 0;
    final digits = amount.abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return negative ? '-$buffer' : buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;
    return Text(
      '$currencySymbol ${_grouped(amount)}',
      style: base.copyWith(fontFeatures: [const FontFeature.tabularFigures()]),
    );
  }
}
