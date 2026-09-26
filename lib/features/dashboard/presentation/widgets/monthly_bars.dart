import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/money_text.dart';
import '../../domain/revenue_summary.dart';

const _monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String monthLabel(String month) {
  final index = int.tryParse(month.split('-').last);
  return (index != null && index >= 1 && index <= 12) ? _monthNames[index - 1] : month;
}

/// Net revenue per month as plain bars: six values don't justify a charting
/// dependency, and the semantics label carries the same numbers for screen
/// readers, which a painted chart would not.
class MonthlyBars extends StatelessWidget {
  const MonthlyBars({super.key, required this.months});

  final List<MonthlyRevenue> months;

  static const _maxBarHeight = 96.0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final peak = months.fold<int>(1, (max, month) => month.net > max ? month.net : max);
    // The month and amount labels grow with the system font; a fixed chart
    // height would clip them for anyone who has raised it.
    final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    final summary = months.map((m) => '${monthLabel(m.month)} RWF ${m.net}').join(', ');

    return Semantics(
      label: 'Net revenue by month: $summary',
      child: ExcludeSemantics(
        child: SizedBox(
          height: _maxBarHeight + 44 * textScale,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final month in months)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (month.net > 0)
                        DefaultTextStyle.merge(
                          style: Theme.of(context).textTheme.labelSmall!.copyWith(color: colors.neutral500),
                          child: MoneyText(month.net, currencySymbol: ''),
                        ),
                      const SizedBox(height: 4),
                      Container(
                        height: month.net > 0 ? (_maxBarHeight * month.net / peak).clamp(4.0, _maxBarHeight) : 2,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: month.net > 0 ? colors.primary500 : colors.neutral200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        monthLabel(month.month),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.neutral500),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
