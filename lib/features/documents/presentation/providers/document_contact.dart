import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/contact_actions.dart';
import '../../../customers/presentation/providers/customer_repository_provider.dart';
import '../../domain/document_enums.dart';
import '../../domain/share_message.dart';
import '../widgets/document_list_tile.dart';
import 'document_repository_provider.dart';

/// Opens the call, SMS and WhatsApp sheet for the customer of a document.
/// A list row only knows the invoice id, and a document carries the customer's
/// name but not their phone, so both are loaded here on demand.
Future<void> startDocumentContact(BuildContext context, WidgetRef ref, {required String documentId}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    final document = await ref.read(documentRepositoryProvider).get(documentId);
    final token = document.publicToken;
    if (document.status != DocumentStatus.finalized || token == null) {
      messenger?.showSnackBar(const SnackBar(content: Text('Finalize this document first to share it')));
      return;
    }
    final customer = await ref.read(customerRepositoryProvider).get(document.customerId);
    final link = publicDocumentUrl(apiBaseUrl, token);
    final owed = document.total - document.amountPaid;
    final isChase = document.type == DocumentType.invoice && owed > 0;

    if (!context.mounted) return;
    await showContactActions(
      context,
      ref,
      title: customer.name,
      phone: customer.phone,
      message: isChase
          ? reminderMessage(customer: customer.name, number: document.number, amountOwed: owed, link: link)
          : shareMessage(
              customer: customer.name,
              typeLabel: documentTypeLabel(document.type).toLowerCase(),
              number: document.number,
              total: document.total,
              link: link,
            ),
    );
  } catch (e) {
    messenger?.showSnackBar(SnackBar(content: Text(describeActionError(e))));
  }
}
