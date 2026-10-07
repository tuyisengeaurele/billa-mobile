import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  bool _isSaving = false;

  String? _orNull(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Enter a customer name');
      return;
    }
    setState(() {
      _errorMessage = null;
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
    } catch (_) {
      setState(() => _errorMessage = "Couldn't save this customer");
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
              const SizedBox(height: 16),
              AppButton(key: const Key('customer-form-save'), label: 'Save', onPressed: _save, isLoading: _isSaving),
            ],
          ),
        ),
      ),
    );
  }
}
