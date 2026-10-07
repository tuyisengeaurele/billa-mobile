import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/shell/quick_create.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/fade_switcher.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../documents/domain/document_enums.dart';
import '../../domain/revenue_summary.dart';
import '../providers/dashboard_provider.dart';
import 'monthly_bars.dart';

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
            ? _HeroCard(top: _HeroFailed(onRetry: () => ref.invalidate(revenueProvider)))
            : const _HeroCard(top: _HeroSkeleton());

    return FadeSwitcher(child: KeyedSubtree(key: ValueKey(asyncViewKind(revenue)), child: view));
  }
}

/// The hero always carries the three create actions, so starting work never
/// waits on the figures loading or failing.
class _HeroCard extends ConsumerWidget {
  const _HeroCard({required this.top});

  final Widget top;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A fixed brand gradient with white text in both themes: it is a brand
    // moment rather than a surface, so it should not invert in dark mode.
    const brand = AppColors.light;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [brand.primary700, brand.primary500],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          top,
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _HeroAction(
                  key: const Key('home-action-invoice'),
                  icon: Icons.receipt_long_outlined,
                  label: 'New invoice',
                  onTap: () => context.push('/documents/new', extra: DocumentType.invoice),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HeroAction(
                  key: const Key('home-action-payment'),
                  icon: Icons.payments_outlined,
                  label: 'Record payment',
                  onTap: () => startRecordPayment(context, ref),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HeroAction(
                  key: const Key('home-action-customer'),
                  icon: Icons.person_add_alt_outlined,
                  label: 'Add customer',
                  onTap: () => context.push('/customers/new'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroAction extends StatelessWidget {
  const _HeroAction({super.key, required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LoadingSkeleton(width: 120, height: 14),
        SizedBox(height: 12),
        LoadingSkeleton(width: 220, height: 40),
        SizedBox(height: 12),
        LoadingSkeleton(width: 160, height: 24),
      ],
    );
  }
}

class _HeroFailed extends StatelessWidget {
  const _HeroFailed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Couldn't load your revenue", style: textTheme.titleMedium?.copyWith(color: Colors.white)),
        const SizedBox(height: 4),
        TextButton(
          onPressed: onRetry,
          style: TextButton.styleFrom(foregroundColor: Colors.white, padding: EdgeInsets.zero),
          child: const Text('Retry'),
        ),
      ],
    );
  }
}

class _RevenueContent extends StatelessWidget {
  const _RevenueContent({required this.revenue});

  final RevenueSummary revenue;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final percent = revenue.monthOverMonthPercent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroCard(
          top: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Invoiced this month', style: textTheme.labelLarge?.copyWith(color: Colors.white70)),
              const SizedBox(height: 4),
              MoneyText(
                revenue.invoicedThisMonth,
                key: const Key('home-invoiced-this-month'),
                style: textTheme.displaySmall?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (percent != null && percent != 0) ...[
                    Icon(percent > 0 ? Icons.trending_up : Icons.trending_down, size: 18, color: Colors.white),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(revenueDeltaText(revenue), style: textTheme.bodyMedium?.copyWith(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _Figure(label: 'Collected', amount: revenue.totalCollected, tint: colors.successBg, dot: colors.success),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Figure(label: 'Outstanding', amount: revenue.totalOutstanding, tint: colors.warningBg, dot: colors.warning),
            ),
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
  const _Figure({required this.label, required this.amount, required this.tint, required this.dot});

  final String label;
  final int amount;
  final Color tint;
  final Color dot;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: colors.neutral700)),
            ],
          ),
          const SizedBox(height: 6),
          MoneyText(amount, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colors.neutral900)),
        ],
      ),
    );
  }
}
