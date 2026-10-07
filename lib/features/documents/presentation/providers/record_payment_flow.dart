import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/errors/action_errors.dart';
import 'document_repository_provider.dart';

/// The payment screen needs the whole document, and a list row only has its id.
Future<void> recordPaymentFor(BuildContext context, WidgetRef ref, {required String invoiceId}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    final document = await ref.read(documentRepositoryProvider).get(invoiceId);
    if (context.mounted) context.push('/documents/${document.id}/payments/new', extra: document);
  } catch (e) {
    messenger?.showSnackBar(SnackBar(content: Text(describeActionError(e))));
  }
}
