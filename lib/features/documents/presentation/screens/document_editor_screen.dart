import '../widgets/item_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../../core/widgets/search_picker_sheet.dart';
import '../../../customers/presentation/providers/customer_repository_provider.dart';
import '../../../items/presentation/providers/item_repository_provider.dart';
import '../../domain/document.dart';
import '../../domain/document_enums.dart';
import '../../domain/document_totals.dart';
import '../providers/document_editor_controller.dart';
import '../providers/document_repository_provider.dart';
import '../widgets/document_list_tile.dart' show documentTypeLabel;

String _formatDisplayDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

class DocumentEditorScreen extends ConsumerStatefulWidget {
  // Not const: the initializer calls DocumentEditorArgs.create(type), and a
  // const constructor can't invoke another const constructor with one of
  // its own formal parameters as the argument.
  DocumentEditorScreen.create({super.key, required DocumentType type}) : args = DocumentEditorArgs.create(type);
  DocumentEditorScreen.edit({super.key, required String documentId}) : args = DocumentEditorArgs.edit(documentId);

  final DocumentEditorArgs args;

  @override
  ConsumerState<DocumentEditorScreen> createState() => _DocumentEditorScreenState();
}

class _DocumentEditorScreenState extends ConsumerState<DocumentEditorScreen> {
  bool _popping = false;

  Future<void> _handlePop(bool didPop) async {
    if (didPop || _popping) return;
    _popping = true;
    await ref.read(documentEditorControllerProvider(widget.args).notifier).flushPendingSave();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(documentEditorControllerProvider(widget.args));
    final type = widget.args.type ?? async.value?.type;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => _handlePop(didPop),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.args.documentId == null
              ? 'New ${type != null ? documentTypeLabel(type) : ''}'
              : 'Edit document'),
          actions: [
            if (async.value != null) _AutosaveIndicator(state: async.value!, args: widget.args),
          ],
        ),
        body: switch (async) {
          AsyncData(value: final state) => _DocumentEditorForm(args: widget.args, state: state),
          AsyncError() => ErrorState(
              message: "Couldn't load this document",
              onRetry: () => ref.invalidate(documentEditorControllerProvider(widget.args)),
            ),
          _ => const Padding(
              padding: EdgeInsets.all(16),
              child: Column(children: [LoadingSkeleton(height: 24), SizedBox(height: 12), LoadingSkeleton(height: 200)]),
            ),
        },
      ),
    );
  }
}

class _AutosaveIndicator extends ConsumerWidget {
  const _AutosaveIndicator({required this.state, required this.args});

  final DocumentEditorState state;
  final DocumentEditorArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (state.autosaveStatus) {
      AutosaveStatus.idle => const SizedBox.shrink(),
      AutosaveStatus.saving => const Padding(
          padding: EdgeInsets.only(right: 16),
          child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
        ),
      AutosaveStatus.saved => const Padding(
          padding: EdgeInsets.only(right: 16),
          child: Center(child: Icon(Icons.check, size: 20)),
        ),
      AutosaveStatus.error => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: TextButton(
            onPressed: () => ref.read(documentEditorControllerProvider(args).notifier).retrySave(),
            child: const Text('Retry'),
          ),
        ),
    };
  }
}

class _DocumentEditorForm extends ConsumerWidget {
  const _DocumentEditorForm({required this.args, required this.state});

  final DocumentEditorArgs args;
  final DocumentEditorState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(documentEditorControllerProvider(args).notifier);
    final totals = state.totals;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(state.customerName ?? 'Choose a customer'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final customer = await showSearchPickerSheet(
                context: context,
                title: 'Choose a customer',
                fetch: (search) async =>
                    (await ref.read(customerRepositoryProvider).list(search: search)).results,
                itemBuilder: (customer) => ListTile(title: Text(customer.name)),
              );
              if (customer != null) controller.setCustomer(customer.id, customer.name);
            },
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Issued ${_formatDisplayDate(state.issueDate)}'),
            trailing: const Icon(Icons.calendar_today, size: 20),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: state.issueDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) controller.setIssueDate(picked);
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(state.dueDate == null ? 'Add a due date' : 'Due ${_formatDisplayDate(state.dueDate!)}'),
            trailing: state.dueDate == null
                ? const Icon(Icons.calendar_today, size: 20)
                : IconButton(icon: const Icon(Icons.close), onPressed: () => controller.setDueDate(null)),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: state.dueDate ?? state.issueDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) controller.setDueDate(picked);
            },
          ),
          if (state.referencedDocumentAllowed) ...[
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              enabled: state.customerId != null,
              title: Text(state.referencedDocument?.number ?? 'Choose the invoice this document is for'),
              trailing: const Icon(Icons.chevron_right),
              onTap: state.customerId == null
                  ? null
                  : () async {
                      final reference = await showSearchPickerSheet(
                        context: context,
                        title: 'Choose the invoice this document is for',
                        fetch: (search) async => (await ref.read(documentRepositoryProvider).list(
                              types: [DocumentType.invoice],
                              status: DocumentStatus.finalized,
                              customerId: state.customerId,
                              search: search,
                            ))
                                .results,
                        itemBuilder: (document) => ListTile(title: Text(document.number ?? document.id)),
                      );
                      if (reference != null) {
                        controller.setReferencedDocument(
                          DocumentRef(id: reference.id, number: reference.number, type: reference.type),
                        );
                      }
                    },
            ),
          ],
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('document-editor-customer-reference'),
            initialValue: state.customerReference,
            decoration: const InputDecoration(labelText: 'Customer reference (optional)'),
            onChanged: controller.setCustomerReference,
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const Key('document-editor-notes'),
            initialValue: state.notes,
            decoration: const InputDecoration(labelText: 'Notes (optional)'),
            maxLines: 3,
            onChanged: controller.setNotes,
          ),
          const SizedBox(height: 12),
          SegmentedButton<DocumentLanguage>(
            segments: const [
              ButtonSegment(value: DocumentLanguage.en, label: Text('EN')),
              ButtonSegment(value: DocumentLanguage.fr, label: Text('FR')),
            ],
            selected: {state.language},
            onSelectionChanged: (selection) => controller.setLanguage(selection.first),
          ),
          const SizedBox(height: 16),
          Text('Line items', style: Theme.of(context).textTheme.titleMedium),
          for (var i = 0; i < state.lines.length; i++)
            // calculateDocumentTotals preserves list order, so index i's
            // LineTotals always matches index i's line, computed once here
            // rather than re-derived per card, so a card's total can never
            // drift from what the footer's subtotal actually sums.
            _LineCard(args: args, line: state.lines[i], lineTotal: totals.lines[i]),
          TextButton(onPressed: controller.addLine, child: const Text('Add line')),
          const Divider(height: 32),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Subtotal'), MoneyText(totals.subtotal)]),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Tax'), MoneyText(totals.taxTotal)]),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: Theme.of(context).textTheme.titleMedium),
              MoneyText(totals.total, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ],
      ),
    );
  }
}

// A line's description/unit price/tax rate can change from OUTSIDE this
// widget's own typing (picking an item overwrites all three at once), so
// plain `TextFormField(initialValue: ...)` isn't enough, Flutter only
// applies `initialValue` on first build, not on later rebuilds carrying a
// new value in from the controller. This owns real TextEditingControllers
// and re-syncs them in didUpdateWidget whenever the incoming value differs
// from what's currently displayed.
class _LineCard extends ConsumerStatefulWidget {
  const _LineCard({required this.args, required this.line, required this.lineTotal});

  final DocumentEditorArgs args;
  final DocumentLineDraft line;
  final LineTotals lineTotal;

  @override
  ConsumerState<_LineCard> createState() => _LineCardState();
}

class _LineCardState extends ConsumerState<_LineCard> {
  late final _descriptionController = TextEditingController(text: widget.line.description);
  late final _quantityController = TextEditingController(text: widget.line.quantity.toString());
  late final _unitPriceController = TextEditingController(text: widget.line.unitPrice.toString());
  late final _taxRateController = TextEditingController(text: widget.line.taxRate.toString());
  late final _discountValueController = TextEditingController(text: (widget.line.discountValue ?? 0).toString());

  @override
  void didUpdateWidget(covariant _LineCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only reachable from picking an item, never from typing in these exact
    // fields, so this can't clobber text the user is mid-way through typing.
    if (widget.line.description != _descriptionController.text) {
      _descriptionController.text = widget.line.description;
    }
    if (widget.line.unitPrice.toString() != _unitPriceController.text) {
      _unitPriceController.text = widget.line.unitPrice.toString();
    }
    if (widget.line.taxRate.toString() != _taxRateController.text) {
      _taxRateController.text = widget.line.taxRate.toString();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _taxRateController.dispose();
    _discountValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(documentEditorControllerProvider(widget.args).notifier);
    final line = widget.line;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ItemSearchField(
                    fieldKey: ValueKey('line-description-${line.localId}'),
                    controller: _descriptionController,
                    errorText: line.description.trim().isEmpty ? 'Enter a description' : null,
                    searchItems: (query) async => (await ref.read(itemRepositoryProvider).list(search: query)).results,
                    // Typing here decouples the line from any linked item,
                    // matching the production web editor's ItemPicker.
                    onTextChanged: (value) => controller.setLineDescription(line.localId, value),
                    onItemSelected: (item) => controller.selectLineItem(
                      line.localId,
                      itemId: item.id,
                      description: item.description,
                      unitPrice: item.unitPrice,
                      taxRate: item.taxRate,
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => controller.removeLine(line.localId)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    key: ValueKey('line-quantity-${line.localId}'),
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: 'Qty',
                      errorText: line.quantity > 0 ? null : 'Enter a quantity greater than zero',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final parsed = double.tryParse(value);
                      if (parsed != null) controller.setLineQuantity(line.localId, parsed);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    key: ValueKey('line-unit-price-${line.localId}'),
                    controller: _unitPriceController,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      errorText: line.unitPrice >= 0 ? null : "Price can't be negative",
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed != null) controller.setLineUnitPrice(line.localId, parsed);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    key: ValueKey('line-tax-rate-${line.localId}'),
                    controller: _taxRateController,
                    decoration: InputDecoration(
                      labelText: 'Tax %',
                      errorText: line.taxRate >= 0 && line.taxRate <= 100 ? null : 'Must be between 0 and 100',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final parsed = double.tryParse(value);
                      if (parsed != null) controller.setLineTaxRate(line.localId, parsed);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                DropdownButton<DiscountType?>(
                  value: line.discountType,
                  hint: const Text('No discount'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('No discount')),
                    DropdownMenuItem(value: DiscountType.percent, child: Text('% off')),
                    DropdownMenuItem(value: DiscountType.flat, child: Text('RWF off')),
                  ],
                  onChanged: (type) =>
                      controller.setLineDiscount(line.localId, type, type == null ? null : (line.discountValue ?? 0)),
                ),
                if (line.discountType != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      key: ValueKey('line-discount-value-${line.localId}'),
                      controller: _discountValueController,
                      decoration: InputDecoration(
                        labelText: 'Discount',
                        errorText: (line.discountValue ?? 0) >= 0 &&
                                (line.discountType != DiscountType.percent || (line.discountValue ?? 0) <= 100)
                            ? null
                            : (line.discountType == DiscountType.percent ? "Can't exceed 100%" : "Can't be negative"),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final parsed = double.tryParse(value);
                        if (parsed != null) controller.setLineDiscount(line.localId, line.discountType, parsed);
                      },
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: MoneyText(widget.lineTotal.lineTotal),
            ),
          ],
        ),
      ),
    );
  }
}
