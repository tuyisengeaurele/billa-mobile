import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// For switches between unrelated top-level screens (splash, login, home):
/// there is no "deeper" to move into, so a fade-through fits better than the
/// shared-axis slide used for pushes within a flow.
CustomTransitionPage<void> fadeThroughPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeThroughTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      fillColor: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    ),
  );
}
