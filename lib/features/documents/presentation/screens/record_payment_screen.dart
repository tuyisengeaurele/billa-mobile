import '../../../../core/widgets/app_sheet.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/widgets/success_check.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/document.dart';
import '../../domain/document_enums.dart';
import '../../domain/payment_input.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/widgets/action_error_banner.dart';
import '../providers/document_repository_provider.dart';

String paymentMethodLabel(PaymentMethod method) => switch (method) {
      PaymentMethod.cash => 'Cash',
      PaymentMethod.bankTransfer => 'Bank transfer',
      PaymentMethod.mobileMoney => 'Mobile Money',
      PaymentMethod.cheque => 'Cheque',
      PaymentMethod.other => 'Other',
    };

String _formatDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

class RecordPaymentScreen extends ConsumerStatefulWidget {
  const RecordPaymentScreen({super.key, required this.document});

  final Document document;

  @override
  ConsumerState<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends ConsumerState<RecordPaymentScreen> {
  late final _amountController =
      TextEditingController(text: (widget.document.total - widget.document.amountPaid).toString());
  final _notesController = TextEditingController();
  final _referenceController = TextEditingController();
  final _payerController = TextEditingController();
  PaymentMethod _method = PaymentMethod.cash;
  DateTime _paidOn = DateTime.now();
  bool _generateReceipt = false;
  String? _receiptImageUrl;
  bool _uploadingReceipt = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _saveError;

  Future<void> _pickReceipt() async {
    final source = await showAppSheet<ImageSource>(
      context,
      builder: (context) => AppSheetContent(
        title: 'Add a receipt photo',
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text('Camera'),
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Gallery'),
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
        ],
      ),
    );
    if (source == null) return;
    final picked = await ImagePicker().pickImage(source: source);
    if (picked == null) return;
    setState(() => _uploadingReceipt = true);
    try {
      final bytes = await File(picked.path).readAsBytes();
      final url = await ref.read(documentRepositoryProvider).uploadPaymentReceipt(bytes, picked.name);
      if (mounted) setState(() => _receiptImageUrl = url);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = describeActionError(e));
    } finally {
      if (mounted) setState(() => _uploadingReceipt = false);
    }
  }

  Future<void> _save() async {
    final amount = int.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = 'Enter an amount greater than zero');
      return;
    }
    setState(() {
      _errorMessage = null;
      _saveError = null;
      _isSaving = true;
    });
    try {
      await ref.read(documentRepositoryProvider).recordPayment(
            widget.document.id,
            PaymentInput(
              amount: amount,
              method: _method,
              paidOn: _formatDate(_paidOn),
              notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
              referenceNumber: _referenceController.text.trim().isEmpty ? null : _referenceController.text.trim(),
              payerName: _payerController.text.trim().isEmpty ? null : _payerController.text.trim(),
              receiptImageUrl: _receiptImageUrl,
              generateReceipt: _generateReceipt,
            ),
          );
      if (!mounted) return;
      await showSuccessCheck(context);
      if (mounted) context.pop(true);
    } catch (e) {
      if (mounted) setState(() => _saveError = describeActionError(e));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const Key('payment-amount'),
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<PaymentMethod>(
              initialValue: _method,
              decoration: const InputDecoration(labelText: 'Method'),
              items: [
                for (final method in PaymentMethod.values)
                  DropdownMenuItem(value: method, child: Text(paymentMethodLabel(method))),
              ],
              onChanged: (value) => setState(() => _method = value!),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Paid on ${_formatDate(_paidOn)}'),
              trailing: const Icon(Icons.calendar_today, size: 20),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _paidOn,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _paidOn = picked);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _referenceController,
              decoration: const InputDecoration(labelText: 'Reference number (optional)'),
            ),
            const SizedBox(height: 12),
            TextField(controller: _payerController, decoration: const InputDecoration(labelText: 'Payer name (optional)')),
            const SizedBox(height: 12),
            TextField(controller: _notesController, decoration: const InputDecoration(labelText: 'Notes (optional)'), maxLines: 3),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_receiptImageUrl == null ? 'Add receipt photo' : 'Receipt photo attached'),
              trailing: _uploadingReceipt
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(_receiptImageUrl == null ? Icons.add_a_photo : Icons.check),
              onTap: _uploadingReceipt ? null : _pickReceipt,
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Generate a receipt document'),
              value: _generateReceipt,
              onChanged: (value) => setState(() => _generateReceipt = value ?? false),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(_errorMessage!),
            ],
            if (_saveError != null) ...[
              const SizedBox(height: 8),
              ActionErrorBanner(message: _saveError!, onRetry: _isSaving ? null : _save),
            ],
            const SizedBox(height: 16),
            AppButton(
              key: const Key('payment-submit'),
              label: 'Record Payment',
              isLoading: _isSaving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
