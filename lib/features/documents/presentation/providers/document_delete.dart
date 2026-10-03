import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/document.dart';
import 'document_list_controller.dart';
import 'document_repository_provider.dart';

/// Deletes a draft from the list after asking, with a message either way. A failure leaves the draft where
/// it is and offers a retry, so a dropped connection never costs the user the document or a dead end.
Future<void> deleteDraft(BuildContext context, WidgetRef ref, {required Document document}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final repository = ref.read(documentRepositoryProvider);
  final list = ref.read(documentListControllerProvider.notifier);

  final confirmed = await showConfirmDialog(
    context,
    title: 'Delete this draft?',
    content: "This can't be undone.",
    confirmLabel: 'Delete',
    destructive: true,
  );
  if (!confirmed) return;

  Future<void> attempt() async {
    try {
      await repository.delete(document.id);
      await list.refresh();
      messenger?.showSnackBar(const SnackBar(content: Text('Draft deleted')));
    } catch (e) {
      messenger?.showSnackBar(SnackBar(
        content: Text(describeActionError(e)),
        action: SnackBarAction(label: 'Retry', onPressed: attempt),
      ));
    }
  }

  await attempt();
}
