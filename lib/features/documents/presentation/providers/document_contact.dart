import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/formatting/currency.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/contact_actions.dart';
import '../../../auth/domain/auth_status.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
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
    // A reminder only makes sense once the invoice has gone out; the first message is the invoice itself.
    final isChase = document.type == DocumentType.invoice && owed > 0 && document.sentAt != null;
    final status = ref.read(authControllerProvider).valueOrNull;
    final business = status is Authenticated ? status.business.name : '';
    final payable = document.business?.momoEnabled == true && document.currency == Currency.rwf;
    final next = document.nextInstallment;
    // Only a plan with something already covered has a smaller amount due now than the whole balance.
    final instalment = next != null && next.remaining < owed ? (label: next.label, amount: next.remaining) : null;

    if (!context.mounted) return;
    await showContactActions(
      context,
      ref,
      title: customer.name,
      phone: customer.phone,
      // Only a first share is recorded; a reminder to pay is not the document going out.
      onWhatsAppOpened: isChase ? null : () => ref.read(documentRepositoryProvider).markShared(document.id),
      message: isChase
          ? reminderMessage(
              customer: customer.name,
              business: business,
              number: document.number,
              amountOwed: owed,
              dueDate: document.dueDate,
              link: link,
              currency: document.currency,
              payable: payable,
              instalment: instalment,
            )
          : shareMessage(
              customer: customer.name,
              business: business,
              type: document.type,
              typeLabel: documentTypeLabel(document.type).toLowerCase(),
              number: document.number,
              total: document.total,
              dueDate: document.dueDate,
              link: link,
              currency: document.currency,
              payable: payable,
            ),
    );
  } catch (e) {
    messenger?.showSnackBar(SnackBar(content: Text(describeActionError(e))));
  }
}
