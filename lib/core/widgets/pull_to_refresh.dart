import 'package:flutter/material.dart';

/// Pull-down refresh for a list screen. [onRefresh] reports whether it worked:
/// a failed refresh keeps the list on screen and says so in a snackbar with a
/// way to try again, rather than replacing good data with an error.
class PullToRefresh extends StatelessWidget {
  const PullToRefresh({super.key, required this.onRefresh, required this.child});

  final Future<bool> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        final messenger = ScaffoldMessenger.maybeOf(context);
        if (await onRefresh()) return;
        messenger?.showSnackBar(
          SnackBar(
            content: const Text("Couldn't refresh. Check your connection and try again"),
            action: SnackBarAction(label: 'Retry', onPressed: () => onRefresh()),
          ),
        );
      },
      child: child,
    );
  }
}

/// Lets a non-list view (empty state, error, skeleton) be pulled down too:
/// the gesture only works on something scrollable, and these fill the space
/// exactly, so they are wrapped in a scroll view at least as tall as the area.
class ScrollableFill extends StatelessWidget {
  const ScrollableFill({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(child: child),
        ),
      ),
    );
  }
}
