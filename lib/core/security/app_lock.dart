import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../privacy/privacy_settings.dart';

/// Asks the phone to prove the person holding it is its owner, with a
/// fingerprint or face where set up and the screen PIN or pattern otherwise.
abstract class Authenticator {
  Future<bool> get isSupported;
  Future<bool> authenticate(String reason);
}

class LocalAuthAuthenticator implements Authenticator {
  LocalAuthAuthenticator([LocalAuthentication? auth]) : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> get isSupported => _auth.isDeviceSupported();

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(localizedReason: reason);
    } on PlatformException {
      // A cancelled, locked-out, or unavailable prompt all mean "not proven".
      return false;
    }
  }
}

final authenticatorProvider = Provider<Authenticator>((ref) => LocalAuthAuthenticator());

final appLockClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// True while the app should be hidden behind the lock screen.
class AppLockController extends Notifier<bool> {
  DateTime? _pausedAt;
  bool _authenticating = false;

  @override
  bool build() {
    ref.listen(privacySettingsProvider.select((s) => s.appLock), (previous, next) {
      // Turning the lock on must not lock the person who just did it, and
      // turning it off must never leave the app covered.
      if (!next) state = false;
    });
    // A cold start counts as coming back after any delay.
    return ref.read(privacySettingsProvider).appLock;
  }

  void onPaused() {
    // The system prompt itself pauses the app; that is not the user leaving.
    if (_authenticating) return;
    _pausedAt = ref.read(appLockClockProvider)();
  }

  void onResumed() {
    if (_authenticating) return;
    final settings = ref.read(privacySettingsProvider);
    final pausedAt = _pausedAt;
    _pausedAt = null;
    if (!settings.appLock || pausedAt == null) return;
    if (ref.read(appLockClockProvider)().difference(pausedAt) >= settings.lockDelay.duration) state = true;
  }

  Future<bool> unlock() async {
    _authenticating = true;
    try {
      final proven = await ref.read(authenticatorProvider).authenticate('Unlock Billa');
      if (proven) state = false;
      return proven;
    } finally {
      _authenticating = false;
      _pausedAt = null;
    }
  }

  Future<bool> canEnable() => ref.read(authenticatorProvider).isSupported;

  /// Used by the settings screen after it has already proven the person, so
  /// turning the lock on does not ask twice.
  void unlockWithoutPrompt() => state = false;
}

final appLockProvider = NotifierProvider<AppLockController, bool>(AppLockController.new);
