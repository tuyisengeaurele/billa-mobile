import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/errors/action_errors.dart';
import '../../domain/duplicate_draft.dart';
import 'document_repository_provider.dart';

/// Repeats a document as a new draft and opens it for editing, so a regular
/// customer's next invoice starts from the last one instead of from blank.
Future<void> duplicateDocument(BuildContext context, WidgetRef ref, {required String documentId}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final repository = ref.read(documentRepositoryProvider);
  try {
    final source = await repository.get(documentId);
    final copy = await repository.create(draftFromDocument(source));
    if (context.mounted) context.push('/documents/${copy.id}/edit');
  } catch (e) {
    messenger?.showSnackBar(SnackBar(content: Text(describeActionError(e))));
  }
}
