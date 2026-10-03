import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/document_enums.dart';
import '../../domain/recurrence.dart';
import '../providers/document_editor_controller.dart';

/// Makes an invoice repeat on its own: weekly, monthly, every quarter or yearly, until an optional end date.
/// It excludes a payment plan, as the server does, and says so instead of simply being missing.
class RepeatSection extends ConsumerWidget {
  const RepeatSection({super.key, required this.args, required this.state});

  final DocumentEditorArgs args;
  final DocumentEditorState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.type != DocumentType.invoice) return const SizedBox.shrink();
    final controller = ref.read(documentEditorControllerProvider(args).notifier);
    final textTheme = Theme.of(context).textTheme;
    final current = state.recurrence;
    final end = current?.endDate;
    final enabled = state.canRepeat;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Repeat', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  key: const Key('repeat-none'),
                  label: const Text('Does not repeat'),
                  selected: current == null,
                  onSelected: enabled ? (_) => controller.clearRecurrence() : null,
                ),
                for (final option in recurrenceOptions)
                  ChoiceChip(
                    key: Key('repeat-${option.interval}'),
                    label: Text(option.label),
                    selected: current?.interval == option.interval,
                    onSelected: enabled ? (_) => controller.setRecurrence(option.interval) : null,
                  ),
              ],
            ),
            if (!enabled)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'A repeating invoice cannot be paid in instalments. Pay in full to repeat it.',
                  style: textTheme.bodyMedium,
                ),
              ),
            if (current != null)
              ListTile(
                key: const Key('repeat-end'),
                contentPadding: EdgeInsets.zero,
                title: Text(end == null ? 'Add an end date (optional)' : 'Stops after $end'),
                trailing: end == null
                    ? const Icon(Icons.calendar_today, size: 20)
                    : IconButton(icon: const Icon(Icons.close), onPressed: () => controller.setRecurrenceEnd(null)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.tryParse(end ?? '') ?? DateTime.now().add(const Duration(days: 365)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) controller.setRecurrenceEnd(picked);
                },
              ),
          ],
        ),
      ),
    );
  }
}
