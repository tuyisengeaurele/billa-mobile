import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// The one way to ask the user for a decision or a small piece of input:
/// a sheet that slides up from the bottom, in reach of a thumb, instead of a
/// dialog floating mid-screen. Content moves up with the keyboard.
Future<T?> showAppSheet<T>(BuildContext context, {required WidgetBuilder builder, bool scrollable = true}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    // A little longer in than out: the entrance is what the eye follows, and
    // dismissing should never feel like waiting.
    sheetAnimationStyle: const AnimationStyle(
      duration: Duration(milliseconds: 300),
      reverseDuration: Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      // A picker that owns a long list scrolls it itself; wrapping that in a
      // second scroll view would give it unbounded height.
      child: scrollable ? SingleChildScrollView(child: builder(context)) : builder(context),
    ),
  );
}

/// Standard layout for a sheet: heading, optional message, content, actions.
class AppSheetContent extends StatelessWidget {
  const AppSheetContent({super.key, required this.title, this.message, this.children = const [], this.actions});

  final String title;
  final String? message;
  final List<Widget> children;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: textTheme.titleLarge),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(message!, style: textTheme.bodyMedium?.copyWith(color: colors.neutral600)),
          ],
          if (children.isNotEmpty) ...[const SizedBox(height: 16), ...children],
          if (actions != null) ...[const SizedBox(height: 24), actions!],
        ],
      ),
    );
  }
}

/// Cancel on the left, the decision on the right. A null [onConfirm] shows the
/// button disabled, which is how a sheet says "not valid yet".
class SheetActions extends StatelessWidget {
  const SheetActions({
    super.key,
    required this.confirmLabel,
    required this.onConfirm,
    required this.onCancel,
    this.cancelLabel = 'Cancel',
    this.destructive = false,
    this.confirmKey,
  });

  final String confirmLabel;
  final VoidCallback? onConfirm;
  final VoidCallback onCancel;
  final String cancelLabel;
  final bool destructive;
  final Key? confirmKey;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Row(
      children: [
        Expanded(child: OutlinedButton(onPressed: onCancel, child: Text(cancelLabel))),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            key: confirmKey,
            onPressed: onConfirm,
            style: destructive ? FilledButton.styleFrom(backgroundColor: colors.error, foregroundColor: Colors.white) : null,
            child: Text(confirmLabel),
          ),
        ),
      ],
    );
  }
}
