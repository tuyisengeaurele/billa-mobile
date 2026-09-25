import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/language_picker_sheet.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/money_text.dart';
import '../../domain/document.dart';
import '../../domain/document_enums.dart';
import '../../domain/payment.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/success_check.dart';
import '../../../../core/widgets/text_prompt_dialog.dart';
import '../providers/document_list_controller.dart';
import '../providers/document_repository_provider.dart';
import '../widgets/document_status_pill.dart';
import 'record_payment_screen.dart' show paymentMethodLabel;

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
  late Future<List<Payment>> _paymentsFuture;
  bool _actionInProgress = false;
  String? _actionError;
  Future<void> Function()? _lastAction;

  @override
  void initState() {
    super.initState();
    _future = _load();
    _paymentsFuture = _loadPayments();
  }

  Future<Document> _load() => ref.read(documentRepositoryProvider).get(widget.documentId);

  // Fetching payments unconditionally (regardless of document type) is
  // deliberate: the backend's GET /:id/payments has no type restriction
  // (only the mutating POST does), so it simply returns an empty list for
  // a non-invoice document, no special-casing needed here.
  Future<List<Payment>> _loadPayments() => ref.read(documentRepositoryProvider).listPayments(widget.documentId);

  void _reload() => setState(() {
        _future = _load();
      });

  void _reloadAll() => setState(() {
        _future = _load();
        _paymentsFuture = _loadPayments();
      });

  Future<String?> _promptText(String title, String label, String confirmLabel) =>
      showTextPromptDialog(context, title: title, label: label, confirmLabel: confirmLabel);

  Future<void> _runAction(Future<void> Function() action) async {
    _lastAction = action;
    setState(() {
      _actionInProgress = true;
      _actionError = null;
    });
    try {
      await action();
    } catch (e) {
      setState(() => _actionError = describeActionError(e));
    } finally {
      if (mounted) setState(() => _actionInProgress = false);
    }
  }

  Future<bool> _confirm(String title, String? content, String confirmLabel) =>
      showConfirmDialog(context, title: title, content: content, confirmLabel: confirmLabel);

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
      if (mounted) unawaited(showSuccessCheck(context));
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

  Future<void> _send(Document document, String email) async {
    final language = await showLanguagePicker(context, initial: document.language);
    if (language == null || !mounted) return;
    if (!await _confirm('Send to $email?', 'The PDF will be in ${documentLanguageLabel(language)}.', 'Send')) return;
    await _runAction(() async {
      await ref.read(documentRepositoryProvider).send(widget.documentId, language: language);
      _reload();
    });
  }

  Future<void> _sharePdf(Document document) async {
    final language = await showLanguagePicker(context, initial: document.language);
    if (language == null) return;
    await _runAction(() async {
      final bytes = await ref.read(documentRepositoryProvider).fetchPdfBytes(widget.documentId, language: language);
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

  Future<void> _voidPayment(String paymentId) async {
    final reason = await _promptText('Void this payment?', 'Reason', 'Void');
    if (reason == null) return;
    await _runAction(() async {
      await ref.read(documentRepositoryProvider).voidPayment(widget.documentId, paymentId, reason);
      _reloadAll();
    });
  }

  Future<void> _openRecordPayment(Document document) async {
    final recorded = await context.push<bool>('/documents/${document.id}/payments/new', extra: document);
    if (recorded == true) _reloadAll();
  }

  Future<void> _writeOff() async {
    final reason = await _promptText('Write off this invoice?', 'Reason', 'Write off');
    if (reason == null) return;
    await _runAction(() async {
      await ref.read(documentRepositoryProvider).writeOff(widget.documentId, reason);
      _reload();
    });
  }

  Future<void> _reactivate() async {
    if (!await _confirm('Reactivate this invoice?', 'This clears the write-off.', 'Reactivate')) return;
    await _runAction(() async {
      await ref.read(documentRepositoryProvider).reactivate(widget.documentId);
      _reload();
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
        final isInvoice = document.type == DocumentType.invoice;
        // Deliberately excludes writtenOff as well as paid, showing
        // Write-off and Reactivate at once for the same invoice would be
        // a contradictory pair of actions on screen at the same time.
        final hasOutstandingBalance =
            document.paymentStatus == PaymentStatus.unpaid || document.paymentStatus == PaymentStatus.partiallyPaid;
        final canRecordPayment = isFinalized && isInvoice && hasOutstandingBalance;
        final canWriteOff = isFinalized && isInvoice && hasOutstandingBalance;
        final canReactivate = document.paymentStatus == PaymentStatus.writtenOff;
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
                if (isInvoice) ...[
                  const SizedBox(height: 24),
                  Text('Payments', style: Theme.of(context).textTheme.titleMedium),
                  FutureBuilder<List<Payment>>(
                    future: _paymentsFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: LoadingSkeleton(height: 40));
                      }
                      final payments = snapshot.data!;
                      if (payments.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('No payments recorded yet'),
                        );
                      }
                      return Column(
                        children: [
                          for (final payment in payments)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: MoneyText(payment.amount),
                              subtitle: Text(
                                '${paymentMethodLabel(payment.method)} · ${payment.paidOn.split('T').first}'
                                '${payment.voidedAt != null ? ' · Voided' : ''}',
                              ),
                              trailing: payment.voidedAt == null
                                  ? TextButton(onPressed: () => _voidPayment(payment.id), child: const Text('Void'))
                                  : null,
                            ),
                        ],
                      );
                    },
                  ),
                  if (canRecordPayment)
                    AppButton(
                      label: 'Record Payment',
                      isLoading: _actionInProgress,
                      onPressed: () => _openRecordPayment(document),
                    ),
                ],
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
                          onPressed: _actionInProgress ? null : () => _sharePdf(document),
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
                                : () => _send(document, document.customer.email!),
                            child: const Text('Send'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (canWriteOff) ...[
                  const SizedBox(height: 8),
                  AppButton(label: 'Write off', isLoading: _actionInProgress, onPressed: _writeOff),
                ],
                if (canReactivate) ...[
                  const SizedBox(height: 8),
                  AppButton(label: 'Reactivate', isLoading: _actionInProgress, onPressed: _reactivate),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
