import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/errors/action_errors.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/glass_surface.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/money_text.dart';
import '../../features/documents/domain/document_enums.dart';
import '../../features/documents/presentation/providers/document_repository_provider.dart';
import '../../features/documents/presentation/widgets/document_list_tile.dart';
import '../../features/receivables/domain/outstanding_invoice.dart';
import '../../features/receivables/presentation/providers/receivables_repository_provider.dart';
import '../theme/app_colors.dart';

sealed class _QuickAction {
  const _QuickAction();
}

class _NewDocument extends _QuickAction {
  const _NewDocument(this.type);
  final DocumentType type;
}

class _NewCustomer extends _QuickAction {
  const _NewCustomer();
}

class _RecordPayment extends _QuickAction {
  const _RecordPayment();
}

/// A glass circle docked beside the tab bar: the one place anything new starts.
class QuickCreateButton extends ConsumerWidget {
  const QuickCreateButton({super.key});

  static const size = 64.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return SizedBox(
      width: size,
      height: size,
      child: Semantics(
        button: true,
        label: 'Create new',
        excludeSemantics: true,
        child: GestureDetector(
          key: const Key('quick-create'),
          onTap: () => showQuickCreate(context, ref),
          child: GlassSurface(
            child: Center(child: Icon(Icons.add, size: 30, color: colors.primary500)),
          ),
        ),
      ),
    );
  }
}

Future<void> showQuickCreate(BuildContext context, WidgetRef ref) async {
  final action = await showAppSheet<_QuickAction>(
    context,
    builder: (context) => AppSheetContent(
      title: 'Create',
      children: [
        for (final type in DocumentType.values)
          ListTile(
            key: Key('quick-create-${type.name}'),
            contentPadding: EdgeInsets.zero,
            leading: Icon(documentTypeIcon(type)),
            title: Text('New ${documentTypeLabel(type).toLowerCase()}'),
            onTap: () => Navigator.of(context).pop(_NewDocument(type)),
          ),
        const Divider(),
        ListTile(
          key: const Key('quick-create-customer'),
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.person_add_alt_outlined),
          title: const Text('New customer'),
          onTap: () => Navigator.of(context).pop(const _NewCustomer()),
        ),
        ListTile(
          key: const Key('quick-create-payment'),
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.payments_outlined),
          title: const Text('Record a payment'),
          onTap: () => Navigator.of(context).pop(const _RecordPayment()),
        ),
      ],
    ),
  );
  if (action == null || !context.mounted) return;

  switch (action) {
    case _NewDocument(:final type):
      context.push('/documents/new', extra: type);
    case _NewCustomer():
      context.push('/customers/new');
    case _RecordPayment():
      await startRecordPayment(context, ref);
  }
}

/// Recording a payment needs an invoice first, so the flow starts by asking
/// which one the customer is paying, then opens the regular payment screen.
Future<void> startRecordPayment(BuildContext context, WidgetRef ref) async {
  final invoice = await showAppSheet<OutstandingInvoice>(context, builder: (context) => const _InvoicePicker());
  if (invoice == null || !context.mounted) return;

  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    final document = await ref.read(documentRepositoryProvider).get(invoice.id);
    if (context.mounted) context.push('/documents/${document.id}/payments/new', extra: document);
  } catch (e) {
    messenger?.showSnackBar(SnackBar(content: Text(describeActionError(e))));
  }
}

class _InvoicePicker extends ConsumerStatefulWidget {
  const _InvoicePicker();

  @override
  ConsumerState<_InvoicePicker> createState() => _InvoicePickerState();
}

class _InvoicePickerState extends ConsumerState<_InvoicePicker> {
  late Future<List<OutstandingInvoice>> _future = ref.read(receivablesRepositoryProvider).list();

  void _reload() {
    setState(() {
      _future = ref.read(receivablesRepositoryProvider).list();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppSheetContent(
      title: 'Record a payment',
      message: 'Choose the invoice the customer is paying.',
      children: [
        FutureBuilder<List<OutstandingInvoice>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return ErrorState(message: "Couldn't load your invoices", onRetry: _reload);
            }
            if (!snapshot.hasData) {
              return const Column(children: [LoadingSkeleton(height: 56), SizedBox(height: 8), LoadingSkeleton(height: 56)]);
            }
            final invoices = snapshot.data!;
            if (invoices.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('Nothing is outstanding, so there is no invoice to record a payment on.'),
              );
            }
            return Column(
              children: [
                for (final invoice in invoices)
                  ListTile(
                    key: Key('payment-invoice-${invoice.id}'),
                    contentPadding: EdgeInsets.zero,
                    title: Text(invoice.customerName),
                    subtitle: Text(invoice.dueDate == null
                        ? (invoice.number ?? 'Draft')
                        : '${invoice.number ?? 'Draft'} · Due ${invoice.dueDate}'),
                    trailing: MoneyText(invoice.amountOwed),
                    onTap: () => Navigator.of(context).pop(invoice),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
