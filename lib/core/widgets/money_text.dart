import 'package:flutter/material.dart';
import '../formatting/money.dart';

class MoneyText extends StatelessWidget {
  const MoneyText(this.amount, {super.key, this.style, this.currencySymbol = 'RWF'});

  final int amount;
  final TextStyle? style;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;
    return Text(
      formatMoney(amount, symbol: currencySymbol),
      style: base.copyWith(fontFeatures: [const FontFeature.tabularFigures()]),
    );
  }
}
