import 'package:flutter/material.dart';
import '../errors/action_errors.dart';

/// Confirms a reversible action after the fact and offers to take it back, the
/// way mail apps do, instead of asking "are you sure" before every change.
void showUndoSnackBar(BuildContext context, {required String message, required Future<void> Function() onUndo}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 6),
        // A snackbar with an action stays until dismissed unless told otherwise;
        // the chance to undo should pass, not linger over the screen.
        persist: false,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            try {
              await onUndo();
            } catch (e) {
              messenger.showSnackBar(SnackBar(content: Text(describeActionError(e))));
            }
          },
        ),
      ),
    );
}
