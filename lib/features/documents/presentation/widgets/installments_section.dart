import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/formatting/currency.dart';
import '../../domain/document_draft_input.dart';
import '../../domain/document_enums.dart';
import '../../domain/installment_plan.dart';
import '../providers/document_editor_controller.dart';

/// Paying an invoice in steps. A phone does not get the web's table: a plan starts from a preset (equal parts,
/// or a deposit and the balance) and each row can then be renamed, re-dated or re-valued. The last row is always
/// the balance, so the plan stays equal to the invoice however its lines change.
class InstallmentsSection extends ConsumerWidget {
  const InstallmentsSection({super.key, required this.args, required this.state});

  final DocumentEditorArgs args;
  final DocumentEditorState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.type == DocumentType.invoice && state.recurrence != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            'A repeating invoice cannot be paid in instalments. Turn off repeating to use a plan.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }
    if (!state.canHavePlan) return const SizedBox.shrink();
    final controller = ref.read(documentEditorControllerProvider(args).notifier);
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).extension<AppColors>()!;
    final rows = state.plannedInstallments;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Payment plan', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            if (rows.isEmpty) ...[
              Text('Paid in full, or split the total into instalments.', style: textTheme.bodyMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    key: const Key('plan-preset-two'),
                    onPressed: () => controller.startPlan(PlanPreset.twoParts),
                    child: const Text('2 equal parts'),
                  ),
                  OutlinedButton(
                    key: const Key('plan-preset-three'),
                    onPressed: () => controller.startPlan(PlanPreset.threeParts),
                    child: const Text('3 equal parts'),
                  ),
                  OutlinedButton(
                    key: const Key('plan-preset-deposit'),
                    onPressed: () => controller.startPlan(PlanPreset.deposit),
                    child: const Text('Deposit, then balance'),
                  ),
                ],
              ),
            ] else ...[
              for (var i = 0; i < rows.length; i++)
                _InstallmentRow(
                  key: ValueKey('installment-row-$i'),
                  args: args,
                  index: i,
                  row: rows[i],
                  isBalance: i == rows.length - 1,
                  canRemove: rows.length > 2,
                  currency: state.currency,
                ),
              if (rows.length < maxInstallments)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    key: const Key('installment-add'),
                    onPressed: controller.addInstallment,
                    icon: const Icon(Icons.add),
                    label: const Text('Add instalment'),
                  ),
                ),
              if (state.installmentProblem != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(state.installmentProblem!, style: textTheme.bodyMedium?.copyWith(color: colors.error)),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  key: const Key('plan-clear'),
                  onPressed: controller.clearPlan,
                  child: const Text('Pay in full instead'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InstallmentRow extends ConsumerStatefulWidget {
  const _InstallmentRow({
    super.key,
    required this.args,
    required this.index,
    required this.row,
    required this.isBalance,
    required this.canRemove,
    required this.currency,
  });

  final DocumentEditorArgs args;
  final int index;
  final InstallmentInput row;
  final bool isBalance;
  final bool canRemove;
  final Currency currency;

  @override
  ConsumerState<_InstallmentRow> createState() => _InstallmentRowState();
}

class _InstallmentRowState extends ConsumerState<_InstallmentRow> {
  late final _labelController = TextEditingController(text: widget.row.label ?? '');
  late final _amountController =
      TextEditingController(text: minorToMajorText(widget.row.amount, widget.currency));

  @override
  void didUpdateWidget(covariant _InstallmentRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The balance moves whenever the lines or another row change, so it always follows the state. The other
    // fields only follow it when it differs from what is typed, so typing "12." is not rewritten to "12".
    if (widget.isBalance || parseMajorAmount(_amountController.text, widget.currency) != widget.row.amount) {
      _amountController.text = minorToMajorText(widget.row.amount, widget.currency);
    }
    if ((widget.row.label ?? '') != _labelController.text.trim() && widget.row.label != null) {
      _labelController.text = widget.row.label!;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final current = DateTime.tryParse(widget.row.dueDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      ref.read(documentEditorControllerProvider(widget.args).notifier).setInstallmentDate(widget.index, picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(documentEditorControllerProvider(widget.args).notifier);
    final decimals = widget.currency.decimals > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: Key('installment-label-${widget.index}'),
                  controller: _labelController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(labelText: 'Name (optional)', hintText: 'Instalment ${widget.index + 1}'),
                  onChanged: (value) => controller.setInstallmentLabel(widget.index, value),
                ),
              ),
              IconButton(
                key: Key('installment-remove-${widget.index}'),
                tooltip: 'Remove this instalment',
                icon: const Icon(Icons.close),
                onPressed: widget.canRemove ? () => controller.removeInstallment(widget.index) : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  key: Key('installment-amount-${widget.index}'),
                  controller: _amountController,
                  readOnly: widget.isBalance,
                  keyboardType: TextInputType.numberWithOptions(decimal: decimals),
                  inputFormatters: [FilteringTextInputFormatter.allow(decimals ? RegExp(r'[0-9.,]') : RegExp(r'[0-9]'))],
                  decoration: InputDecoration(
                    labelText: 'Amount (${widget.currency.code})',
                    helperText: widget.isBalance ? 'Balance' : null,
                  ),
                  onChanged: (value) {
                    final parsed = parseMajorAmount(value, widget.currency);
                    if (parsed != null) controller.setInstallmentAmount(widget.index, parsed);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  key: Key('installment-date-${widget.index}'),
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Due', suffixIcon: Icon(Icons.calendar_today, size: 20)),
                    child: Text(widget.row.dueDate),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
