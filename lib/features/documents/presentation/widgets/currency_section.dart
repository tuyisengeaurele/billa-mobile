import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/formatting/currency.dart';

/// The currency of a draft and, for a foreign one, the rate that turns it into RWF in reports.
class CurrencySection extends StatefulWidget {
  const CurrencySection({
    super.key,
    required this.currency,
    required this.exchangeRate,
    required this.onCurrencyChanged,
    required this.onRateChanged,
    this.rateHint,
    this.repriceNote = false,
    this.locked = false,
    this.lockedNote = 'Kept the same as the invoice this document is for.',
  });

  final Currency currency;
  final double? exchangeRate;
  final String? rateHint;
  final bool repriceNote;
  final bool locked;
  final String lockedNote;
  final ValueChanged<Currency> onCurrencyChanged;
  final ValueChanged<double?> onRateChanged;

  @override
  State<CurrencySection> createState() => _CurrencySectionState();
}

// The same rule as the web's rate box: digits, one dot, at most six decimals. A key press that would break it
// is ignored, so the box never holds text that cannot be a rate.
final _rateFormatter = TextInputFormatter.withFunction(
  (oldValue, newValue) => RegExp(r'^[0-9]*\.?[0-9]{0,6}$').hasMatch(newValue.text) ? newValue : oldValue,
);

class _CurrencySectionState extends State<CurrencySection> {
  late final _rateController = TextEditingController(text: _rateText(widget.exchangeRate));

  static String _rateText(double? rate) {
    if (rate == null) return '';
    return rate == rate.roundToDouble() ? rate.toInt().toString() : rate.toString();
  }

  @override
  void didUpdateWidget(covariant CurrencySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A rate that arrives from outside (the bank rate after switching currency) replaces the box,
    // but what the user is typing is never rewritten, so "12." is not turned into "12".
    if (double.tryParse(_rateController.text) != widget.exchangeRate) {
      _rateController.text = _rateText(widget.exchangeRate);
    }
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currency = widget.currency;
    final problem = rateProblem(currency, widget.exchangeRate);
    final notes = <String>[
      if (widget.locked) widget.lockedNote,
      if (widget.repriceNote) 'The prices below are still the numbers you had. Check them in ${currency.code}.',
      if (currency != Currency.rwf && problem == null)
        '${widget.rateHint == null ? '' : '${widget.rateHint} '}'
            'The rate is saved with this document and used to show it in RWF in your reports.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The field only reads initialValue when it is built, so the currency in its key makes it
        // rebuild whenever the currency changes from outside (a reference invoice fixes it).
        KeyedSubtree(
          key: const Key('document-editor-currency'),
          child: DropdownButtonFormField<Currency>(
            key: ValueKey(currency),
            initialValue: currency,
            // Names like "Tanzanian shilling" are wider than a narrow phone leaves for the field.
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Currency'),
            items: [
              for (final option in Currency.values)
                DropdownMenuItem(
                  value: option,
                  child: Text('${option.code} (${option.label})', overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: widget.locked
                ? null
                : (value) {
                    if (value != null && value != currency) widget.onCurrencyChanged(value);
                  },
          ),
        ),
        if (currency != Currency.rwf) ...[
          const SizedBox(height: 12),
          TextField(
            key: const Key('document-editor-rate'),
            controller: _rateController,
            enabled: !widget.locked,
            decoration: InputDecoration(labelText: '1 ${currency.code} = RWF', errorText: problem),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [_rateFormatter],
            onChanged: (value) => widget.onRateChanged(double.tryParse(value)),
          ),
        ],
        for (final note in notes) ...[
          const SizedBox(height: 4),
          Text(note, style: textTheme.bodySmall),
        ],
      ],
    );
  }
}
