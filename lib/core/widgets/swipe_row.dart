import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../app/theme/app_colors.dart';

class SwipeAction {
  const SwipeAction({required this.key, required this.label, required this.icon, required this.onPressed});

  final Key key;
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
}

/// A list row that reveals quick actions when dragged sideways. Swiping is a
/// shortcut, never the only way: every action is also offered to screen
/// readers as a custom action, and should exist on the row's detail screen.
class SwipeRow extends StatelessWidget {
  const SwipeRow({super.key, required this.child, this.startActions = const [], this.endActions = const []});

  final Widget child;
  final List<SwipeAction> startActions;
  final List<SwipeAction> endActions;

  ActionPane? _pane(List<SwipeAction> actions, Color background, Color foreground) {
    if (actions.isEmpty) return null;
    return ActionPane(
      motion: const DrawerMotion(),
      extentRatio: 0.28 * actions.length,
      children: [
        for (final action in actions)
          SlidableAction(
            key: action.key,
            onPressed: (_) => action.onPressed(),
            icon: action.icon,
            label: action.label,
            backgroundColor: background,
            foregroundColor: foreground,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final all = [...startActions, ...endActions];
    if (all.isEmpty) return child;

    return Semantics(
      customSemanticsActions: {
        for (final action in all) CustomSemanticsAction(label: action.label): action.onPressed,
      },
      child: Slidable(
        startActionPane: _pane(startActions, colors.primary100, colors.primary700),
        endActionPane: _pane(endActions, colors.successBg, colors.success),
        child: child,
      ),
    );
  }
}
