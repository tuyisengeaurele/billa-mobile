import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/money_text.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receivables')),
      body: FutureBuilder<List<OutstandingInvoice>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorState(
              message: "Couldn't load receivables",
              onRetry: () => setState(() {
                _future = _load();
              }),
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
            return const EmptyState(
              icon: Icons.check_circle_outline,
              message: 'Nothing outstanding — all invoices are paid up',
            );
          }
          return ListView.builder(
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              return ListTile(
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
              );
            },
          );
        },
      ),
    );
  }
}
