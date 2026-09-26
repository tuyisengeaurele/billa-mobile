import 'package:flutter/material.dart';
import '../formatting/money.dart';
import '../privacy/privacy_scope.dart';

class MoneyText extends StatelessWidget {
  const MoneyText(this.amount, {super.key, this.style, this.currencySymbol = 'RWF'});

  final int amount;
  final TextStyle? style;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;
    final hidden = PrivacyScope.hiddenOf(context);
    final text = Text(
      hidden ? '$currencySymbol \u2022\u2022\u2022\u2022' : formatMoney(amount, symbol: currencySymbol),
      style: base.copyWith(fontFeatures: [const FontFeature.tabularFigures()]),
    );
    // Dots read aloud as noise; say what they mean.
    return hidden ? Semantics(label: 'Amount hidden', excludeSemantics: true, child: text) : text;
  }
}
