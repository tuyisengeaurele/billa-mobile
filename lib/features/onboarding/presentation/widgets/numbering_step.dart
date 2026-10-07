import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../business_settings/domain/document_sequence.dart';
import '../../../business_settings/presentation/providers/business_settings_provider.dart';
import '../../../business_settings/presentation/widgets/numbering_form.dart';

class NumberingStep extends ConsumerWidget {
  const NumberingStep({super.key, required this.onSaved, required this.onSkip});

  final Future<void> Function(List<DocumentSequence> sequences) onSaved;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sequences = ref.watch(sequencesProvider);
    final value = sequences.valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Number your documents', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        if (value != null)
          NumberingForm(initial: value, onSave: onSaved, saveLabel: 'Finish', embedded: true)
        else if (sequences.hasError)
          ErrorState(
            message: "Couldn't load your numbering settings",
            onRetry: () => ref.invalidate(sequencesProvider),
          )
        else
          const LoadingSkeleton(height: 220),
        TextButton(
          key: const Key('onboarding-numbering-skip'),
          onPressed: onSkip,
          child: const Text('Skip this step'),
        ),
      ],
    );
  }
}
