import 'package:flutter/material.dart';
import '../formatting/currency.dart';
import '../formatting/money.dart';
import '../privacy/privacy_scope.dart';

class MoneyText extends StatelessWidget {
  const MoneyText(this.amount, {super.key, this.style, this.currency = Currency.rwf, this.currencySymbol});

  final int amount;
  final TextStyle? style;
  final Currency currency;
  final String? currencySymbol;

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;
    final hidden = PrivacyScope.hiddenOf(context);
    final symbol = currencySymbol ?? currency.code;
    final text = Text(
      hidden ? '$symbol \u2022\u2022\u2022\u2022' : formatMoney(amount, currency: currency, symbol: symbol),
      style: base.copyWith(fontFeatures: [const FontFeature.tabularFigures()]),
    );
    // Dots read aloud as noise; say what they mean.
    return hidden ? Semantics(label: 'Amount hidden', excludeSemantics: true, child: text) : text;
  }
}
