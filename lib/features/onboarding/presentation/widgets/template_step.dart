import 'package:flutter/material.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../business_settings/domain/document_template.dart';

class TemplateStep extends StatefulWidget {
  const TemplateStep({super.key, required this.onSaved, required this.onSkip});

  final Future<void> Function(DocumentTemplate template) onSaved;
  final VoidCallback onSkip;

  @override
  State<TemplateStep> createState() => _TemplateStepState();
}

class _TemplateStepState extends State<TemplateStep> {
  // A new business already defaults to the minimal template, so that is what
  // Continue saves if the user just accepts the step.
  DocumentTemplate _selected = DocumentTemplate.minimal;
  bool _isSaving = false;

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await widget.onSaved(_selected);
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Choose a document style', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text('This is how your invoices, quotes, and other documents look. You can change it later in settings.'),
        const SizedBox(height: 16),
        for (final template in DocumentTemplate.values)
          ListTile(
            key: Key('onboarding-template-${template.name}'),
            contentPadding: EdgeInsets.zero,
            title: Text(documentTemplateLabel(template)),
            trailing: template == _selected ? const Icon(Icons.check) : null,
            onTap: () => setState(() => _selected = template),
          ),
        const SizedBox(height: 16),
        AppButton(
          key: const Key('onboarding-template-continue'),
          label: 'Continue',
          onPressed: _save,
          isLoading: _isSaving,
        ),
        TextButton(
          key: const Key('onboarding-template-skip'),
          onPressed: widget.onSkip,
          child: const Text('Skip this step'),
        ),
      ],
    );
  }
}
