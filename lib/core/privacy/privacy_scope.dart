import 'package:flutter/widgets.dart';

/// Tells every amount below it whether to hide itself. It is an inherited
/// widget rather than a provider so a plain amount in any widget test or
/// preview needs no app state around it.
class PrivacyScope extends InheritedWidget {
  const PrivacyScope({super.key, required this.hidden, required super.child});

  final bool hidden;

  static bool hiddenOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PrivacyScope>()?.hidden ?? false;
  }

  @override
  bool updateShouldNotify(PrivacyScope oldWidget) => oldWidget.hidden != hidden;
}
