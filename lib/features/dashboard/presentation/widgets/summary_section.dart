import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../documents/presentation/widgets/document_list_tile.dart' show documentTypeLabel;
import '../../../documents/presentation/widgets/document_status_pill.dart';
import '../../domain/dashboard_summary.dart';
import '../providers/dashboard_provider.dart';
import 'section_error.dart';

/// Needs-attention counts, recent documents, and (for a business that has
/// done nothing yet) first steps. All three come from one endpoint, so they
/// share one load and one failure.
class SummarySection extends ConsumerWidget {
  const SummarySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);
    final value = summary.valueOrNull;

    if (value != null) return _SummaryContent(summary: value);
    if (summary.hasError) {
      return SectionError(
        message: "Couldn't load your activity",
        onRetry: () => ref.invalidate(dashboardSummaryProvider),
      );
    }
    return const Column(children: [
      LoadingSkeleton(height: 72),
      SizedBox(height: 12),
      LoadingSkeleton(height: 56),
      SizedBox(height: 8),
      LoadingSkeleton(height: 56),
    ]);
  }
}

class _SummaryContent extends StatelessWidget {
  const _SummaryContent({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    if (summary.isEmptyBusiness) return const _FirstSteps();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Needs attention', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _AttentionCard(
                key: const Key('home-attention-drafts'),
                count: summary.draftCount,
                label: 'Drafts',
                calm: 'No drafts',
                route: '/documents?status=draft',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _AttentionCard(
                key: const Key('home-attention-overdue'),
                count: summary.overdueInvoiceCount,
                label: 'Overdue',
                calm: 'None overdue',
                route: '/receivables',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _AttentionCard(
                key: const Key('home-attention-expiring'),
                count: summary.expiringQuoteCount,
                label: 'Expiring quotes',
                calm: 'None expiring',
                route: '/documents?types=quote,proforma',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: Text('Recent documents', style: Theme.of(context).textTheme.titleSmall)),
            TextButton(
              key: const Key('home-see-all-documents'),
              onPressed: () => context.push('/documents'),
              child: const Text('See all'),
            ),
          ],
        ),
        if (summary.recentDocuments.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('No documents yet. Create your first one from the Documents list.'),
          )
        else
          for (final document in summary.recentDocuments)
            ListTile(
              key: Key('home-recent-${document.id}'),
              contentPadding: EdgeInsets.zero,
              title: Text(document.number ?? 'Draft ${documentTypeLabel(document.type)}'),
              subtitle: Text('${documentTypeLabel(document.type)} · ${document.customerName}'),
              trailing: DocumentStatusPill(status: document.status, paymentStatus: document.paymentStatus),
              onTap: () => context.push('/documents/${document.id}'),
            ),
      ],
    );
  }
}

class _AttentionCard extends StatelessWidget {
  const _AttentionCard({
    super.key,
    required this.count,
    required this.label,
    required this.calm,
    required this.route,
  });

  final int count;
  final String label;
  final String calm;
  final String route;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.small),
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(color: colors.neutral200),
          borderRadius: BorderRadius.circular(AppRadii.small),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (count == 0) ...[
              Icon(Icons.check_circle_outline, size: 20, color: colors.success),
              const SizedBox(height: 8),
              Text(calm, style: textTheme.labelMedium?.copyWith(color: colors.neutral600)),
            ] else ...[
              Text('$count', style: textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(label, style: textTheme.labelMedium?.copyWith(color: colors.neutral600)),
            ],
          ],
        ),
      ),
    );
  }
}

class _FirstSteps extends StatelessWidget {
  const _FirstSteps();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primary100,
        borderRadius: BorderRadius.circular(AppRadii.large),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Start with your first customer', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Add who you bill, then create an invoice, quote, or any other document for them.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                key: const Key('home-first-customer'),
                onPressed: () => context.push('/customers/new'),
                child: const Text('Add a customer'),
              ),
              OutlinedButton(
                key: const Key('home-first-document'),
                onPressed: () => context.push('/documents'),
                child: const Text('Create a document'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
