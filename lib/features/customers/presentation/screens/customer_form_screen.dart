import 'package:flutter/material.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/widgets/action_error_banner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/platform/contact_picker.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/customer.dart';
import '../providers/customer_repository_provider.dart';

class CustomerFormScreen extends ConsumerStatefulWidget {
  const CustomerFormScreen({super.key, this.existing});

  final Customer? existing;

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  late final _nameController = TextEditingController(text: widget.existing?.name ?? '');
  late final _tinController = TextEditingController(text: widget.existing?.tin ?? '');
  late final _addressController = TextEditingController(text: widget.existing?.address ?? '');
  late final _phoneController = TextEditingController(text: widget.existing?.phone ?? '');
  late final _emailController = TextEditingController(text: widget.existing?.email ?? '');
  String? _errorMessage;
  String? _saveError;
  String? _pickError;
  bool _isSaving = false;

  String? _orNull(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _importFromContacts() async {
    try {
      final picked = await ref.read(contactPickerProvider).pick();
      if (picked == null || !mounted) return;
      setState(() {
        _pickError = null;
        // A name someone already typed is more likely the business name than
        // the contact's, so only an empty name is filled.
        if (_nameController.text.trim().isEmpty) _nameController.text = picked.name;
        _phoneController.text = picked.phone;
      });
    } on ContactPickerUnavailable {
      if (mounted) setState(() => _pickError = 'This phone has no contacts app. Type the details instead');
    } catch (e) {
      if (mounted) setState(() => _pickError = describeActionError(e));
    }
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Enter a customer name');
      return;
    }
    setState(() {
      _errorMessage = null;
      _saveError = null;
      _isSaving = true;
    });
    try {
      final repository = ref.read(customerRepositoryProvider);
      if (widget.existing == null) {
        await repository.create(
          name: _nameController.text.trim(),
          tin: _orNull(_tinController),
          address: _orNull(_addressController),
          phone: _orNull(_phoneController),
          email: _orNull(_emailController),
        );
      } else {
        await repository.update(
          widget.existing!.id,
          name: _nameController.text.trim(),
          tin: _orNull(_tinController),
          address: _orNull(_addressController),
          phone: _orNull(_phoneController),
          email: _orNull(_emailController),
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
      appBar: AppBar(title: Text(widget.existing == null ? 'Add customer' : 'Edit customer')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.existing == null) ...[
                OutlinedButton.icon(
                  key: const Key('customer-form-import'),
                  onPressed: _isSaving ? null : _importFromContacts,
                  icon: const Icon(Icons.contacts_outlined),
                  label: const Text('From contacts'),
                ),
                if (_pickError != null) ...[
                  const SizedBox(height: 8),
                  Text(_pickError!),
                ],
                const SizedBox(height: 16),
              ],
              TextField(key: const Key('customer-form-name'), controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 12),
              TextField(controller: _tinController, decoration: const InputDecoration(labelText: 'TIN (optional)')),
              const SizedBox(height: 12),
              TextField(controller: _addressController, decoration: const InputDecoration(labelText: 'Address (optional)')),
              const SizedBox(height: 12),
              TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone (optional)')),
              const SizedBox(height: 12),
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email (optional)')),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(_errorMessage!),
              ],
              if (_saveError != null) ...[
                const SizedBox(height: 8),
                ActionErrorBanner(message: _saveError!, onRetry: _isSaving ? null : _save),
              ],
              const SizedBox(height: 16),
              AppButton(key: const Key('customer-form-save'), label: 'Save', onPressed: _save, isLoading: _isSaving),
            ],
          ),
        ),
      ),
    );
  }
}
