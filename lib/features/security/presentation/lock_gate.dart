import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/security/app_lock.dart';
import '../../auth/domain/auth_status.dart';
import '../../auth/presentation/providers/auth_controller.dart';
import 'lock_screen.dart';

/// Puts the lock screen above everything the app shows, sheets included,
/// because it sits outside the router. Signed out there is nothing to protect.
class LockGate extends ConsumerWidget {
  const LockGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locked = ref.watch(appLockProvider);
    final signedIn = ref.watch(authControllerProvider).valueOrNull is Authenticated;

    return Stack(
      children: [
        child,
        if (locked && signedIn) const Positioned.fill(child: LockScreen()),
      ],
    );
  }
}
