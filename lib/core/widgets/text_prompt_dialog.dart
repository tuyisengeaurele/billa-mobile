import 'package:flutter/material.dart';
import 'app_sheet.dart';

/// Asks for one required line of text in a slide-up sheet; confirm stays
/// disabled while it's empty, so an empty submission is impossible rather than
/// silently ignored.
Future<String?> showTextPromptDialog(
  BuildContext context, {
  required String title,
  required String label,
  required String confirmLabel,
}) {
  return showAppSheet<String>(
    context,
    builder: (context) => _TextPromptSheet(title: title, label: label, confirmLabel: confirmLabel),
  );
}

class _TextPromptSheet extends StatefulWidget {
  const _TextPromptSheet({required this.title, required this.label, required this.confirmLabel});

  final String title;
  final String label;
  final String confirmLabel;

  @override
  State<_TextPromptSheet> createState() => _TextPromptSheetState();
}

class _TextPromptSheetState extends State<_TextPromptSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = _controller.text.trim();
    return AppSheetContent(
      title: widget.title,
      actions: SheetActions(
        confirmLabel: widget.confirmLabel,
        onCancel: () => Navigator.pop(context),
        onConfirm: text.isEmpty ? null : () => Navigator.pop(context, text),
      ),
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(labelText: widget.label),
          autofocus: true,
          textInputAction: TextInputAction.done,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) {
            if (text.isNotEmpty) Navigator.pop(context, text);
          },
        ),
      ],
    );
  }
}
