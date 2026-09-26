import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/platform/secure_window.dart';
import '../core/privacy/privacy_mode.dart';
import '../core/privacy/privacy_scope.dart';
import '../core/privacy/privacy_settings.dart';
import '../features/security/presentation/lock_gate.dart';

/// Everything that protects what is on screen, wrapped around the whole app:
/// hidden amounts, the secure window flag, and the lock screen on top.
class AppPrivacyLayer extends ConsumerStatefulWidget {
  const AppPrivacyLayer({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppPrivacyLayer> createState() => _AppPrivacyLayerState();
}

class _AppPrivacyLayerState extends ConsumerState<AppPrivacyLayer> {
  @override
  void initState() {
    super.initState();
    ref.listenManual<bool>(
      privacySettingsProvider.select((s) => s.secureWindow),
      (_, secure) => ref.read(secureWindowProvider).setSecure(secure),
      fireImmediately: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PrivacyScope(
      hidden: ref.watch(amountsHiddenProvider),
      child: LockGate(child: widget.child),
    );
  }
}
