import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../providers/business_settings_provider.dart';
import '../providers/business_settings_repository_provider.dart';
import '../widgets/numbering_form.dart';

class NumberingScreen extends ConsumerWidget {
  const NumberingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sequences = ref.watch(sequencesProvider);
    final value = sequences.valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Numbering')),
      body: value != null
          ? NumberingForm(
              initial: value,
              onSave: (sequences) async {
                await ref.read(businessSettingsRepositoryProvider).saveSequences(sequences);
                ref.invalidate(sequencesProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Numbering saved')));
                }
              },
            )
          : sequences.hasError
              ? ErrorState(
                  message: "Couldn't load your numbering settings",
                  onRetry: () => ref.invalidate(sequencesProvider),
                )
              : const Padding(padding: EdgeInsets.all(16), child: LoadingSkeleton(height: 220)),
    );
  }
}
