import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../../core/widgets/swipe_row.dart';
import '../../domain/document.dart';
import '../../domain/document_enums.dart';
import 'document_status_pill.dart';

String documentTypeLabel(DocumentType type) => switch (type) {
      DocumentType.invoice => 'Invoice',
      DocumentType.proforma => 'Proforma',
      DocumentType.deliveryNote => 'Delivery note',
      DocumentType.quote => 'Quote',
      DocumentType.receipt => 'Receipt',
      DocumentType.creditNote => 'Credit note',
    };

IconData documentTypeIcon(DocumentType type) => switch (type) {
      DocumentType.invoice => Icons.receipt_long_outlined,
      DocumentType.proforma => Icons.description_outlined,
      DocumentType.deliveryNote => Icons.local_shipping_outlined,
      DocumentType.quote => Icons.request_quote_outlined,
      DocumentType.receipt => Icons.payments_outlined,
      DocumentType.creditNote => Icons.assignment_return_outlined,
    };

class DocumentListTile extends StatelessWidget {
  const DocumentListTile({
    super.key,
    required this.document,
    required this.onTap,
    this.onDuplicate,
    this.onContact,
    this.onDelete,
  });

  final Document document;
  final VoidCallback onTap;
  final VoidCallback? onDuplicate;
  final VoidCallback? onContact;

  /// Only a draft can be deleted, so the list passes this for drafts alone.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final tile = ListTile(
      onTap: onTap,
      title: Text(document.number ?? 'Draft ${documentTypeLabel(document.type)}'),
      // The status sits under the text rather than beside the amount: a tile's
      // trailing slot has a fixed height that a large system font overflows.
      isThreeLine: true,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${documentTypeLabel(document.type)} · ${document.customer.name}'),
          const SizedBox(height: 4),
          Row(
            children: [
              DocumentStatusPill(status: document.status, paymentStatus: document.paymentStatus),
              // Once it is paid the customer opening it again no longer matters.
              if (document.lastViewedAt != null && document.paymentStatus != PaymentStatus.paid) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).extension<AppColors>()!.neutral100,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('Opened', style: Theme.of(context).textTheme.labelSmall),
                ),
              ],
            ],
          ),
        ],
      ),
      trailing: MoneyText(document.total, currency: document.currency),
    );

    if (onDuplicate == null && onContact == null && onDelete == null) return tile;
    return SwipeRow(
      startActions: [
        if (onDuplicate != null)
          SwipeAction(
            key: Key('document-swipe-duplicate-${document.id}'),
            label: 'Duplicate',
            icon: Icons.copy_outlined,
            onPressed: onDuplicate!,
          ),
      ],
      endActions: [
        if (onContact != null)
          SwipeAction(
            key: Key('document-swipe-contact-${document.id}'),
            label: 'Contact',
            icon: Icons.chat_outlined,
            onPressed: onContact!,
          ),
        if (onDelete != null)
          SwipeAction(
            key: Key('document-swipe-delete-${document.id}'),
            label: 'Delete',
            icon: Icons.delete_outline,
            onPressed: onDelete!,
          ),
      ],
      child: tile,
    );
  }
}
