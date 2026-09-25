import 'package:flutter/material.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/widgets/action_error_banner.dart';
import '../../../documents/domain/document_enums.dart';
import '../../../documents/presentation/widgets/document_list_tile.dart' show documentTypeLabel;
import '../../domain/document_sequence.dart';

class _Row {
  _Row(DocumentSequence sequence)
      : type = sequence.type,
        prefix = TextEditingController(text: sequence.prefix),
        next = TextEditingController(text: '${sequence.nextNumber}'),
        resetYearly = sequence.resetYearly;

  final DocumentType type;
  final TextEditingController prefix;
  final TextEditingController next;
  bool resetYearly;

  String? get prefixError {
    final text = prefix.text.trim();
    if (text.isEmpty) return 'Enter a prefix';
    if (text.length > 10) return 'At most 10 characters';
    return null;
  }

  int? get nextNumber {
    final number = int.tryParse(next.text.trim());
    return (number != null && number >= 1) ? number : null;
  }

  DocumentSequence toSequence() => DocumentSequence(
        type: type,
        prefix: prefix.text.trim(),
        nextNumber: nextNumber!,
        resetYearly: resetYearly,
      );

  void dispose() {
    prefix.dispose();
    next.dispose();
  }
}

/// The six per-type numbering cards with their validation. Saving is the
/// caller's business ([onSave]), so settings and onboarding can share the
/// form while doing different things afterwards; a thrown error is shown here
/// with a Retry that repeats the same save.
class NumberingForm extends StatefulWidget {
  const NumberingForm({
    super.key,
    required this.initial,
    required this.onSave,
    this.saveLabel = 'Save',
    this.embedded = false,
  });

  final List<DocumentSequence> initial;
  final Future<void> Function(List<DocumentSequence> sequences) onSave;
  final String saveLabel;

  /// True when the form sits inside another scroll view (the onboarding
  /// wizard) and must size itself instead of scrolling.
  final bool embedded;

  @override
  State<NumberingForm> createState() => _NumberingFormState();
}

class _NumberingFormState extends State<NumberingForm> {
  late final List<_Row> _rows = widget.initial.map(_Row.new).toList();
  bool _actionInProgress = false;
  String? _actionError;
  Future<void> Function()? _lastAction;

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  bool get _valid => _rows.every((row) => row.prefixError == null && row.nextNumber != null);

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

  Future<void> _save() => _runAction(() => widget.onSave(_rows.map((row) => row.toSequence()).toList()));

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
        const Text('The next document of each type is numbered from these settings.'),
        const SizedBox(height: 16),
        for (final row in _rows)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(documentTypeLabel(row.type), style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: Key('num-prefix-${documentTypeToJson(row.type)}'),
                          controller: row.prefix,
                          decoration: InputDecoration(labelText: 'Prefix', errorText: row.prefixError),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          key: Key('num-next-${documentTypeToJson(row.type)}'),
                          controller: row.next,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Next number',
                            errorText: row.nextNumber == null ? 'At least 1' : null,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  SwitchListTile(
                    key: Key('num-yearly-${documentTypeToJson(row.type)}'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Restart every year'),
                    value: row.resetYearly,
                    onChanged: (value) => setState(() => row.resetYearly = value),
                  ),
                ],
              ),
            ),
          ),
        if (_actionError != null) ...[
          ActionErrorBanner(
            message: _actionError!,
            onRetry: _lastAction == null || _actionInProgress ? null : () => _runAction(_lastAction!),
          ),
          const SizedBox(height: 12),
        ],
        FilledButton(
          key: const Key('num-save'),
          onPressed: (_actionInProgress || !_valid) ? null : _save,
          child: Text(widget.saveLabel),
        ),
    ];

    return widget.embedded
        ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children)
        : ListView(padding: const EdgeInsets.all(24), children: children);
  }
}
