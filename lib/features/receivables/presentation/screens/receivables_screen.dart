import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../../core/widgets/pull_to_refresh.dart';
import '../../../../core/widgets/swipe_row.dart';
import '../../../documents/presentation/providers/document_contact.dart';
import '../../../documents/presentation/providers/record_payment_flow.dart';
import '../../domain/outstanding_invoice.dart';
import '../providers/receivables_repository_provider.dart';
import '../widgets/aging_pill.dart';

class ReceivablesScreen extends ConsumerStatefulWidget {
  const ReceivablesScreen({super.key});

  @override
  ConsumerState<ReceivablesScreen> createState() => _ReceivablesScreenState();
}

class _ReceivablesScreenState extends ConsumerState<ReceivablesScreen> {
  late Future<List<OutstandingInvoice>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<OutstandingInvoice>> _load() => ref.read(receivablesRepositoryProvider).list();

  Future<bool> _refresh() async {
    try {
      final fresh = await _load();
      if (!mounted) return true;
      setState(() {
        _future = Future.value(fresh);
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: PullToRefresh(
        onRefresh: _refresh,
        child: FutureBuilder<List<OutstandingInvoice>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ScrollableFill(
              child: ErrorState(
                message: "Couldn't load receivables",
                onRetry: () => setState(() {
                  _future = _load();
                }),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Column(children: [LoadingSkeleton(height: 64), SizedBox(height: 12), LoadingSkeleton(height: 64)]),
            );
          }
          final invoices = snapshot.data!;
          if (invoices.isEmpty) {
            return const ScrollableFill(
              child: EmptyState(
                icon: Icons.check_circle_outline,
                message: 'Nothing outstanding. All invoices are paid up',
              ),
            );
          }
          final owed = invoices.fold<int>(0, (sum, invoice) => sum + invoice.amountOwed);
          final overdue = invoices.where((invoice) => invoice.daysOverdue > 0).length;
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            itemCount: invoices.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return _SummaryCard(owed: owed, count: invoices.length, overdue: overdue);
              final invoice = invoices[index - 1];
              return SwipeRow(
                startActions: [
                  SwipeAction(
                    key: Key('receivable-swipe-contact-${invoice.id}'),
                    label: 'Contact',
                    icon: Icons.chat_outlined,
                    onPressed: () => startDocumentContact(context, ref, documentId: invoice.id),
                  ),
                ],
                endActions: [
                  SwipeAction(
                    key: Key('receivable-swipe-pay-${invoice.id}'),
                    label: 'Record payment',
                    icon: Icons.payments_outlined,
                    onPressed: () => recordPaymentFor(context, ref, invoiceId: invoice.id),
                  ),
                ],
                child: ListTile(
                title: Text(invoice.customerName),
                subtitle: Text(
                  invoice.dueDate == null
                      ? (invoice.number ?? 'Draft')
                      : '${invoice.number ?? 'Draft'} · Due ${invoice.dueDate}',
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [MoneyText(invoice.amountOwed), const SizedBox(height: 4), AgingPill(bucket: invoice.agingBucket)],
                ),
                onTap: () => context.push('/documents/${invoice.id}'),
                ),
              );
            },
          );
        },
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.owed, required this.count, required this.overdue});

  final int owed;
  final int count;
  final int overdue;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      key: const Key('payments-summary'),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: colors.warningBg, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total outstanding', style: textTheme.labelLarge?.copyWith(color: colors.neutral700)),
          const SizedBox(height: 4),
          MoneyText(owed, style: textTheme.headlineMedium?.copyWith(color: colors.neutral900)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(count == 1 ? '1 invoice' : '$count invoices', style: textTheme.bodyMedium?.copyWith(color: colors.neutral700)),
              const SizedBox(width: 12),
              Icon(
                overdue > 0 ? Icons.schedule : Icons.check_circle_outline,
                size: 16,
                color: overdue > 0 ? colors.error : colors.success,
              ),
              const SizedBox(width: 4),
              Text(
                overdue > 0 ? '$overdue overdue' : 'None overdue',
                style: textTheme.bodyMedium?.copyWith(color: overdue > 0 ? colors.error : colors.success),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
