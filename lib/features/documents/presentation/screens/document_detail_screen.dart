import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/money_text.dart';
import '../../domain/document.dart';
import '../../domain/document_enums.dart';
import '../providers/document_repository_provider.dart';
import '../widgets/document_status_pill.dart';

String _lineDiscountLabel(DocumentLine line) {
  if (line.discountType == null || line.discountValue == null) return '';
  return line.discountType == DiscountType.percent
      ? '${line.discountValue!.toStringAsFixed(0)}% off'
      : 'RWF ${line.discountValue!.toStringAsFixed(0)} off';
}

class DocumentDetailScreen extends ConsumerStatefulWidget {
  const DocumentDetailScreen({super.key, required this.documentId});

  final String documentId;

  @override
  ConsumerState<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends ConsumerState<DocumentDetailScreen> {
  late Future<Document> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Document> _load() => ref.read(documentRepositoryProvider).get(widget.documentId);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Document>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Document')),
            body: ErrorState(
              message: "Couldn't load this document",
              onRetry: () => setState(() {
                _future = _load();
              }),
            ),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Document')),
            body: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(children: [LoadingSkeleton(height: 24), SizedBox(height: 12), LoadingSkeleton(height: 200)]),
            ),
          );
        }
        final document = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Document'),
            actions: [
              if (document.status == DocumentStatus.draft)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => context.push('/documents/${document.id}/edit'),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(document.number ?? 'Draft', style: Theme.of(context).textTheme.headlineSmall),
                    DocumentStatusPill(status: document.status, paymentStatus: document.paymentStatus),
                  ],
                ),
                const SizedBox(height: 8),
                Text(document.customer.name),
                if (document.customer.email != null) Text(document.customer.email!),
                const SizedBox(height: 16),
                Text('Issued ${document.issueDate.split('T').first}'),
                if (document.dueDate != null) Text('Due ${document.dueDate!.split('T').first}'),
                if (document.notes != null) ...[
                  const SizedBox(height: 16),
                  Text(document.notes!),
                ],
                const SizedBox(height: 24),
                for (final line in document.lines)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(line.description),
                              Text(
                                '${line.quantity.toStringAsFixed(2)} × RWF ${line.unitPrice}'
                                '${_lineDiscountLabel(line).isEmpty ? '' : ' · ${_lineDiscountLabel(line)}'}',
                              ),
                            ],
                          ),
                        ),
                        MoneyText(line.lineTotal),
                      ],
                    ),
                  ),
                const Divider(height: 32),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Subtotal'), MoneyText(document.subtotal)]),
                const SizedBox(height: 4),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Tax'), MoneyText(document.taxTotal)]),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: Theme.of(context).textTheme.titleMedium),
                    MoneyText(document.total, style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                if (document.convertedFrom != null) ...[
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => context.push('/documents/${document.convertedFrom!.id}'),
                    child: Text('Converted from ${document.convertedFrom!.number ?? document.convertedFrom!.id}'),
                  ),
                ],
                if (document.convertedTo != null)
                  TextButton(
                    onPressed: () => context.push('/documents/${document.convertedTo!.id}'),
                    child: Text('Converted to ${document.convertedTo!.number ?? document.convertedTo!.id}'),
                  ),
                if (document.referencedDocument != null)
                  TextButton(
                    onPressed: () => context.push('/documents/${document.referencedDocument!.id}'),
                    child: Text('References ${document.referencedDocument!.number ?? document.referencedDocument!.id}'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
