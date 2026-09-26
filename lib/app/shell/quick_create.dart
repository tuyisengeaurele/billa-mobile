import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/glass_surface.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/money_text.dart';
import '../../features/documents/domain/document_enums.dart';
import '../../features/documents/presentation/providers/record_payment_flow.dart';
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

class _NewItem extends _QuickAction {
  const _NewItem();
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
        const _SectionLabel('Documents'),
        _TileGrid(children: [
          for (final type in DocumentType.values)
            _CreateTile(
              key: Key('quick-create-${type.name}'),
              icon: documentTypeIcon(type),
              label: documentTypeLabel(type),
              onTap: () => Navigator.of(context).pop(_NewDocument(type)),
            ),
        ]),
        const SizedBox(height: 20),
        const _SectionLabel('More'),
        _TileGrid(children: [
          _CreateTile(
            key: const Key('quick-create-customer'),
            icon: Icons.person_add_alt_outlined,
            label: 'Customer',
            onTap: () => Navigator.of(context).pop(const _NewCustomer()),
          ),
          _CreateTile(
            key: const Key('quick-create-item'),
            icon: Icons.inventory_2_outlined,
            label: 'Item',
            onTap: () => Navigator.of(context).pop(const _NewItem()),
          ),
          _CreateTile(
            key: const Key('quick-create-payment'),
            icon: Icons.payments_outlined,
            label: 'Payment',
            onTap: () => Navigator.of(context).pop(const _RecordPayment()),
          ),
        ]),
      ],
    ),
  );
  if (action == null || !context.mounted) return;

  switch (action) {
    case _NewDocument(:final type):
      context.push('/documents/new', extra: type);
    case _NewCustomer():
      context.push('/customers/new');
    case _NewItem():
      context.push('/items/new');
    case _RecordPayment():
      await startRecordPayment(context, ref);
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text.toUpperCase(), style: Theme.of(context).textTheme.labelMedium?.copyWith(color: colors.neutral500)),
    );
  }
}

/// Three tiles to a row, whatever the screen width.
class _TileGrid extends StatelessWidget {
  const _TileGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    const gap = 12.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - gap * 2) / 3;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [for (final child in children) SizedBox(width: width, child: child)],
        );
      },
    );
  }
}

class _CreateTile extends StatelessWidget {
  const _CreateTile({super.key, required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Material(
      color: colors.neutral50,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: colors.primary100, shape: BoxShape.circle),
                child: Icon(icon, color: colors.primary700, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Recording a payment needs an invoice first, so the flow starts by asking
/// which one the customer is paying, then opens the regular payment screen.
Future<void> startRecordPayment(BuildContext context, WidgetRef ref) async {
  final invoice = await showAppSheet<OutstandingInvoice>(context, builder: (context) => const _InvoicePicker());
  if (invoice == null || !context.mounted) return;
  await recordPaymentFor(context, ref, invoiceId: invoice.id);
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
