import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A short cross-fade for content that replaces a placeholder (skeleton to
/// list, list to empty state). The child must be keyed by what it shows.
class FadeSwitcher extends StatelessWidget {
  const FadeSwitcher({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: child);
  }
}

/// Which of the four views an async list is showing, for keying a
/// [FadeSwitcher]. Kept coarse on purpose: paging in more rows must not
/// re-trigger the fade, only a change of view should.
String asyncViewKind<T>(AsyncValue<T> value, {bool Function(T data)? isEmpty}) {
  if (value.hasError && !value.hasValue) return 'error';
  final data = value.valueOrNull;
  if (data == null) return 'loading';
  return (isEmpty?.call(data) ?? false) ? 'empty' : 'data';
}
