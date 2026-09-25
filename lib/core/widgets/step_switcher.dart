import 'package:flutter/material.dart';

/// Swaps between steps of one flow with a short fade and a small horizontal
/// drift, enough to show that the content changed without drawing attention.
/// The child must carry a key that changes with the step, or nothing animates.
class StepSwitcher extends StatelessWidget {
  const StepSwitcher({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(begin: const Offset(0.04, 0), end: Offset.zero).animate(animation),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
