import 'package:flutter/material.dart';
import 'app_sheet.dart';

/// Asks for a yes or no in a slide-up sheet. The name predates the sheet and
/// is kept so call sites and their meaning stay the same; [destructive] turns
/// the confirm button red for actions that cannot be undone.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  String? content,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final confirmed = await showAppSheet<bool>(
    context,
    builder: (context) => AppSheetContent(
      title: title,
      message: content,
      actions: SheetActions(
        confirmLabel: confirmLabel,
        destructive: destructive,
        onCancel: () => Navigator.pop(context, false),
        onConfirm: () => Navigator.pop(context, true),
      ),
    ),
  );
  return confirmed == true;
}
