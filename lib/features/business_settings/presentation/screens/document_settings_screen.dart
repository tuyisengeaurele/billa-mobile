import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/widgets/action_error_banner.dart';
import '../../domain/business_settings.dart';
import '../../domain/document_template.dart';
import '../providers/business_settings_provider.dart';
import '../providers/business_settings_repository_provider.dart';
import '../widgets/settings_section_scaffold.dart';

class DocumentSettingsScreen extends StatelessWidget {
  const DocumentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSectionScaffold(
      title: 'Documents',
      builder: (settings) => _DocumentSettingsForm(initial: settings),
    );
  }
}

class _DocumentSettingsForm extends ConsumerStatefulWidget {
  const _DocumentSettingsForm({required this.initial});

  final BusinessSettings initial;

  @override
  ConsumerState<_DocumentSettingsForm> createState() => _DocumentSettingsFormState();
}

class _DocumentSettingsFormState extends ConsumerState<_DocumentSettingsForm> {
  late DocumentTemplate _template = widget.initial.defaultTemplate;
  late bool _requireApproval = widget.initial.requireApprovalToFinalize;
  late bool _reminders = widget.initial.remindersEnabled;
  late final _cadence = TextEditingController(text: '${widget.initial.reminderCadenceDays}');
  bool _actionInProgress = false;
  String? _actionError;
  Future<void> Function()? _lastAction;

  @override
  void dispose() {
    _cadence.dispose();
    super.dispose();
  }

  int? get _cadenceDays {
    final days = int.tryParse(_cadence.text.trim());
    return (days != null && days >= 1 && days <= 90) ? days : null;
  }

  Future<void> _runAction(Future<void> Function() action) async {
    _lastAction = action;
    setState(() {
      _actionInProgress = true;
      _actionError = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => _actionError = describeActionError(e));
    } finally {
      if (mounted) setState(() => _actionInProgress = false);
    }
  }

  Future<void> _save() => _runAction(() async {
        await ref.read(businessSettingsRepositoryProvider).updateDocumentSettings(
              defaultTemplate: _template,
              requireApprovalToFinalize: _requireApproval,
              remindersEnabled: _reminders,
              reminderCadenceDays: _cadenceDays!,
            );
        ref.invalidate(businessSettingsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document settings saved')));
        }
      });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Default template', style: Theme.of(context).textTheme.titleSmall),
        for (final template in DocumentTemplate.values)
          ListTile(
            key: Key('ds-template-${template.name}'),
            contentPadding: EdgeInsets.zero,
            title: Text(documentTemplateLabel(template)),
            trailing: template == _template ? const Icon(Icons.check) : null,
            onTap: () => setState(() => _template = template),
          ),
        const Divider(),
        SwitchListTile(
          key: const Key('ds-approval'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Require approval to finalize'),
          subtitle: const Text('Only the owner can finalize documents'),
          value: _requireApproval,
          onChanged: (value) => setState(() => _requireApproval = value),
        ),
        SwitchListTile(
          key: const Key('ds-reminders'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Payment reminders'),
          value: _reminders,
          onChanged: (value) => setState(() => _reminders = value),
        ),
        const SizedBox(height: 8),
        TextField(
          key: const Key('ds-cadence'),
          controller: _cadence,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Reminder every (days)',
            helperText: 'Used when reminders are on',
            errorText: _cadenceDays == null ? 'Enter a number from 1 to 90' : null,
          ),
          onChanged: (_) => setState(() {}),
        ),
        if (_actionError != null) ...[
          const SizedBox(height: 16),
          ActionErrorBanner(
            message: _actionError!,
            onRetry: _lastAction == null || _actionInProgress ? null : () => _runAction(_lastAction!),
          ),
        ],
        const SizedBox(height: 24),
        FilledButton(
          key: const Key('ds-save'),
          onPressed: (_actionInProgress || _cadenceDays == null) ? null : _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
