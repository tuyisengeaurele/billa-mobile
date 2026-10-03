import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/action_errors.dart';
import '../providers/document_repository_provider.dart';

/// Lets one invoice opt out of automatic reminders, for a customer who has promised to pay. The switch moves
/// at once and goes back with the reason if the server does not agree, so it never shows a state that is not real.
class DocumentRemindersSwitch extends ConsumerStatefulWidget {
  const DocumentRemindersSwitch({super.key, required this.documentId, required this.initial});

  final String documentId;
  final bool initial;

  @override
  ConsumerState<DocumentRemindersSwitch> createState() => _DocumentRemindersSwitchState();
}

class _DocumentRemindersSwitchState extends ConsumerState<DocumentRemindersSwitch> {
  late bool _enabled = widget.initial;
  bool _busy = false;
  String? _error;

  Future<void> _change(bool enabled) async {
    setState(() {
      _enabled = enabled;
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(documentRepositoryProvider).setReminders(widget.documentId, enabled: enabled);
    } catch (e) {
      if (mounted) {
        setState(() {
          _enabled = !enabled;
          _error = describeActionError(e);
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          key: const Key('document-reminders'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Payment reminders'),
          subtitle: const Text('Automatic reminders for this invoice'),
          value: _enabled,
          onChanged: _busy ? null : _change,
        ),
        if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ],
    );
  }
}
