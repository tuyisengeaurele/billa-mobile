import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/money_text.dart';
import '../../domain/document.dart';
import '../../domain/document_enums.dart';
import '../document_action_errors.dart';
import '../providers/document_list_controller.dart';
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
  bool _actionInProgress = false;
  String? _actionError;
  Future<void> Function()? _lastAction;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Document> _load() => ref.read(documentRepositoryProvider).get(widget.documentId);

  void _reload() => setState(() {
        _future = _load();
      });

  Future<void> _runAction(Future<void> Function() action) async {
    _lastAction = action;
    setState(() {
      _actionInProgress = true;
      _actionError = null;
    });
    try {
      await action();
    } catch (e) {
      setState(() => _actionError = describeDocumentActionError(e));
    } finally {
      if (mounted) setState(() => _actionInProgress = false);
    }
  }

  Future<bool> _confirm(String title, String? content, String confirmLabel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: content == null ? null : Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(confirmLabel)),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _finalize() async {
    if (!await _confirm(
      'Finalize this document?',
      'It will get a permanent number and can no longer be edited.',
      'Finalize',
    )) {
      return;
    }
    await _runAction(() async {
      await ref.read(documentRepositoryProvider).finalize(widget.documentId);
      _reload();
    });
  }

  Future<void> _convert() async {
    if (!await _confirm('Convert to invoice?', 'Creates a new draft invoice with the same lines.', 'Convert')) {
      return;
    }
    await _runAction(() async {
      final invoice = await ref.read(documentRepositoryProvider).convert(widget.documentId);
      if (mounted) context.push('/documents/${invoice.id}');
    });
  }

  Future<void> _send(String email) async {
    if (!await _confirm('Send to $email?', null, 'Send')) return;
    await _runAction(() async {
      await ref.read(documentRepositoryProvider).send(widget.documentId);
      _reload();
    });
  }

  Future<void> _sharePdf() async {
    await _runAction(() async {
      final bytes = await ref.read(documentRepositoryProvider).fetchPdfBytes(widget.documentId);
      final dir = await getTemporaryDirectory();
      final file = await File('${dir.path}/${widget.documentId}.pdf').writeAsBytes(bytes);
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
    });
  }

  Future<void> _delete() async {
    if (!await _confirm("Delete this draft?", "This can't be undone.", 'Delete')) return;
    await _runAction(() async {
      await ref.read(documentRepositoryProvider).delete(widget.documentId);
      ref.invalidate(documentListControllerProvider);
      if (mounted) context.pop();
    });
  }

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
        final isDraft = document.status == DocumentStatus.draft;
        final isFinalized = document.status == DocumentStatus.finalized;
        final isConvertible = isFinalized &&
            (document.type == DocumentType.proforma || document.type == DocumentType.quote) &&
            document.convertedTo == null;
        final colors = Theme.of(context).extension<AppColors>()!;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Document'),
            actions: [
              if (isDraft)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => context.push('/documents/${document.id}/edit'),
                ),
              if (isDraft)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') _delete();
                  },
                  itemBuilder: (context) => [const PopupMenuItem(value: 'delete', child: Text('Delete'))],
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
                if (_actionError != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: colors.errorBg, borderRadius: BorderRadius.circular(AppRadii.small)),
                    child: Row(
                      children: [
                        Expanded(child: Text(_actionError!, style: TextStyle(color: colors.error))),
                        TextButton(
                          onPressed: _lastAction == null ? null : () => _runAction(_lastAction!),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (isDraft) AppButton(label: 'Finalize', isLoading: _actionInProgress, onPressed: _finalize),
                if (isConvertible) ...[
                  const SizedBox(height: 8),
                  AppButton(label: 'Convert to Invoice', isLoading: _actionInProgress, onPressed: _convert),
                ],
                if (isFinalized) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          key: const Key('document-share-pdf'),
                          onPressed: _actionInProgress ? null : _sharePdf,
                          child: const Text('Share PDF'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Tooltip(
                          message: document.customer.email == null ? 'Add an email for this customer first' : '',
                          child: OutlinedButton(
                            key: const Key('document-send'),
                            onPressed: (_actionInProgress || document.customer.email == null)
                                ? null
                                : () => _send(document.customer.email!),
                            child: const Text('Send'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
