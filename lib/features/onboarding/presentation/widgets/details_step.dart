import 'package:flutter/material.dart';
import '../../../../core/widgets/app_button.dart';

class DetailsStep extends StatefulWidget {
  const DetailsStep({super.key, required this.onSaved, required this.onSkip});

  final Future<void> Function(
    String name,
    String? tin,
    String? industry,
    String? phone,
    String? email,
    String? address,
    String? rraEbmNumber,
  ) onSaved;
  final VoidCallback onSkip;

  @override
  State<DetailsStep> createState() => _DetailsStepState();
}

class _DetailsStepState extends State<DetailsStep> {
  final _nameController = TextEditingController(text: 'My Business');
  final _tinController = TextEditingController();
  final _industryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _rraEbmNumberController = TextEditingController();
  bool _isSaving = false;

  String? _orNull(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await widget.onSaved(
      _nameController.text.trim(),
      _orNull(_tinController),
      _orNull(_industryController),
      _orNull(_phoneController),
      _orNull(_emailController),
      _orNull(_addressController),
      _orNull(_rraEbmNumberController),
    );
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Tell us about your business', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        TextField(key: const Key('onboarding-business-name'), controller: _nameController, textCapitalization: TextCapitalization.words, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'Business name')),
        const SizedBox(height: 12),
        TextField(key: const Key('onboarding-tin'), controller: _tinController, keyboardType: TextInputType.number, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'TIN (optional)')),
        const SizedBox(height: 12),
        TextField(controller: _industryController, textCapitalization: TextCapitalization.sentences, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'Industry (optional)')),
        const SizedBox(height: 12),
        TextField(key: const Key('onboarding-phone'), controller: _phoneController, keyboardType: TextInputType.phone, textInputAction: TextInputAction.next, autofillHints: const [AutofillHints.telephoneNumber], decoration: const InputDecoration(labelText: 'Phone (optional)')),
        const SizedBox(height: 12),
        TextField(key: const Key('onboarding-email'), controller: _emailController, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next, autofillHints: const [AutofillHints.email], decoration: const InputDecoration(labelText: 'Email (optional)')),
        const SizedBox(height: 12),
        TextField(controller: _addressController, textCapitalization: TextCapitalization.sentences, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'Address (optional)')),
        const SizedBox(height: 12),
        TextField(controller: _rraEbmNumberController, keyboardType: TextInputType.number, textInputAction: TextInputAction.done, decoration: const InputDecoration(labelText: 'RRA EBM number (optional)')),
        const SizedBox(height: 16),
        AppButton(key: const Key('onboarding-details-continue'), label: 'Continue', onPressed: _save, isLoading: _isSaving),
        TextButton(key: const Key('onboarding-details-skip'), onPressed: widget.onSkip, child: const Text('Skip this step')),
      ],
    );
  }
}
