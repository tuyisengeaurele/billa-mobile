import 'package:flutter/material.dart';
import '../../../../core/widgets/money_text.dart';
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

class DocumentListTile extends StatelessWidget {
  const DocumentListTile({super.key, required this.document, required this.onTap});

  final Document document;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(document.number ?? 'Draft ${documentTypeLabel(document.type)}'),
      subtitle: Text('${documentTypeLabel(document.type)} · ${document.customer.name}'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          MoneyText(document.total),
          const SizedBox(height: 4),
          DocumentStatusPill(status: document.status, paymentStatus: document.paymentStatus),
        ],
      ),
    );
  }
}
