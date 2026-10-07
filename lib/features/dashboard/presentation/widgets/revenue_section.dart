import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/fade_switcher.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/money_text.dart';
import '../../domain/revenue_summary.dart';
import '../providers/dashboard_provider.dart';
import 'monthly_bars.dart';
import 'section_error.dart';

String revenueDeltaText(RevenueSummary revenue) {
  final percent = revenue.monthOverMonthPercent;
  if (percent == null) {
    return revenue.invoicedThisMonth == 0 ? 'No invoices this month yet' : 'First month of invoices';
  }
  if (percent > 0) return '$percent% more than last month';
  if (percent < 0) return '${-percent}% less than last month';
  return 'Same as last month';
}

class RevenueSection extends ConsumerWidget {
  const RevenueSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenue = ref.watch(revenueProvider);
    final value = revenue.valueOrNull;

    final Widget view = value != null
        ? _RevenueContent(revenue: value)
        : revenue.hasError
            ? SectionError(
                message: "Couldn't load your revenue",
                onRetry: () => ref.invalidate(revenueProvider),
              )
            : const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LoadingSkeleton(width: 120, height: 14),
                  SizedBox(height: 12),
                  LoadingSkeleton(width: 220, height: 40),
                  SizedBox(height: 12),
                  LoadingSkeleton(height: 96),
                ],
              );

    return FadeSwitcher(child: KeyedSubtree(key: ValueKey(asyncViewKind(revenue)), child: view));
  }
}

class _RevenueContent extends StatelessWidget {
  const _RevenueContent({required this.revenue});

  final RevenueSummary revenue;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Invoiced this month', style: textTheme.labelLarge?.copyWith(color: colors.neutral500)),
        const SizedBox(height: 4),
        MoneyText(revenue.invoicedThisMonth, key: const Key('home-invoiced-this-month'), style: textTheme.displaySmall),
        const SizedBox(height: 4),
        Text(revenueDeltaText(revenue), style: textTheme.bodyMedium?.copyWith(color: colors.neutral600)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _Figure(label: 'Collected', amount: revenue.totalCollected)),
            Expanded(child: _Figure(label: 'Outstanding', amount: revenue.totalOutstanding)),
          ],
        ),
        const SizedBox(height: 24),
        Text('Last six months', style: textTheme.titleSmall),
        const SizedBox(height: 12),
        MonthlyBars(months: revenue.monthlyRevenue),
      ],
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.amount});

  final String label;
  final int amount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: colors.neutral500)),
        const SizedBox(height: 2),
        MoneyText(amount, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
