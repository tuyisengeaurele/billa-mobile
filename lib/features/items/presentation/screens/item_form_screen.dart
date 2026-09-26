import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/widgets/action_error_banner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/item.dart';
import '../providers/item_repository_provider.dart';

class ItemFormScreen extends ConsumerStatefulWidget {
  const ItemFormScreen({super.key, this.existing});

  final Item? existing;

  @override
  ConsumerState<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends ConsumerState<ItemFormScreen> {
  late final _descriptionController = TextEditingController(text: widget.existing?.description ?? '');
  late final _unitPriceController = TextEditingController(text: widget.existing?.unitPrice.toString() ?? '');
  late final _unitController = TextEditingController(text: widget.existing?.unit ?? '');
  late final _taxRateController = TextEditingController(text: (widget.existing?.taxRate ?? 18).toString());
  late final _categoryController = TextEditingController(text: widget.existing?.category ?? '');
  String? _errorMessage;
  String? _saveError;
  bool _isSaving = false;

  String? _orNull(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _save() async {
    final unitPrice = int.tryParse(_unitPriceController.text.trim());
    final taxRate = double.tryParse(_taxRateController.text.trim());
    final hasValidFields = _descriptionController.text.trim().isNotEmpty &&
        unitPrice != null &&
        unitPrice > 0 &&
        _unitController.text.trim().isNotEmpty &&
        taxRate != null;
    if (!hasValidFields) {
      setState(() => _errorMessage = 'Check the highlighted fields');
      return;
    }
    setState(() {
      _errorMessage = null;
      _saveError = null;
      _isSaving = true;
    });
    try {
      final repository = ref.read(itemRepositoryProvider);
      if (widget.existing == null) {
        await repository.create(
          description: _descriptionController.text.trim(),
          unitPrice: unitPrice,
          unit: _unitController.text.trim(),
          taxRate: taxRate,
          category: _orNull(_categoryController),
        );
      } else {
        await repository.update(
          widget.existing!.id,
          description: _descriptionController.text.trim(),
          unitPrice: unitPrice,
          unit: _unitController.text.trim(),
          taxRate: taxRate,
          category: _orNull(_categoryController),
        );
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) setState(() => _saveError = describeActionError(e));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? 'Add item' : 'Edit item')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(key: const Key('item-form-description'), controller: _descriptionController, textCapitalization: TextCapitalization.sentences, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 12),
              TextField(
                key: const Key('item-form-unit-price'),
                controller: _unitPriceController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Unit price (RWF)'),
              ),
              const SizedBox(height: 12),
              TextField(key: const Key('item-form-unit'), controller: _unitController, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'Unit (e.g. piece, hour)')),
              const SizedBox(height: 12),
              TextField(
                key: const Key('item-form-tax-rate'),
                controller: _taxRateController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Tax rate (%)'),
              ),
              const SizedBox(height: 12),
              TextField(controller: _categoryController, textCapitalization: TextCapitalization.words, textInputAction: TextInputAction.done, decoration: const InputDecoration(labelText: 'Category (optional)')),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(_errorMessage!),
              ],
              if (_saveError != null) ...[
                const SizedBox(height: 8),
                ActionErrorBanner(message: _saveError!, onRetry: _isSaving ? null : _save),
              ],
              const SizedBox(height: 16),
              AppButton(key: const Key('item-form-save'), label: 'Save', onPressed: _save, isLoading: _isSaving),
            ],
          ),
        ),
      ),
    );
  }
}
