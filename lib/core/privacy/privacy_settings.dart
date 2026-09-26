import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// How long the app may be out of sight before it asks to be unlocked again.
enum LockDelay {
  immediately(Duration.zero, 'Immediately'),
  oneMinute(Duration(minutes: 1), 'After 1 minute'),
  fiveMinutes(Duration(minutes: 5), 'After 5 minutes');

  const LockDelay(this.duration, this.label);

  final Duration duration;
  final String label;
}

/// The three privacy choices of this phone. They are local to the device on
/// purpose: a lock on a shared tablet should not lock the owner's phone.
class PrivacySettings {
  const PrivacySettings({
    this.appLock = false,
    this.lockDelay = LockDelay.immediately,
    this.hideAmounts = false,
    this.secureWindow = false,
  });

  final bool appLock;
  final LockDelay lockDelay;
  final bool hideAmounts;

  /// Hides the app in the recent apps list and blocks screenshots.
  final bool secureWindow;

  PrivacySettings copyWith({bool? appLock, LockDelay? lockDelay, bool? hideAmounts, bool? secureWindow}) => PrivacySettings(
        appLock: appLock ?? this.appLock,
        lockDelay: lockDelay ?? this.lockDelay,
        hideAmounts: hideAmounts ?? this.hideAmounts,
        secureWindow: secureWindow ?? this.secureWindow,
      );

  @override
  bool operator ==(Object other) =>
      other is PrivacySettings &&
      other.appLock == appLock &&
      other.lockDelay == lockDelay &&
      other.hideAmounts == hideAmounts &&
      other.secureWindow == secureWindow;

  @override
  int get hashCode => Object.hash(appLock, lockDelay, hideAmounts, secureWindow);
}

abstract class PrivacySettingsStore {
  PrivacySettings read();
  Future<void> write(PrivacySettings settings);
}

class InMemoryPrivacySettingsStore implements PrivacySettingsStore {
  InMemoryPrivacySettingsStore([this._value = const PrivacySettings()]);

  PrivacySettings _value;

  @override
  PrivacySettings read() => _value;

  @override
  Future<void> write(PrivacySettings settings) async => _value = settings;
}

class SharedPreferencesPrivacySettingsStore implements PrivacySettingsStore {
  SharedPreferencesPrivacySettingsStore(this._preferences);

  static const _lock = 'privacy_app_lock';
  static const _delay = 'privacy_lock_delay';
  static const _hide = 'privacy_hide_amounts';
  static const _secure = 'privacy_secure_window';

  final SharedPreferences _preferences;

  @override
  PrivacySettings read() {
    final delayName = _preferences.getString(_delay);
    return PrivacySettings(
      appLock: _preferences.getBool(_lock) ?? false,
      lockDelay: LockDelay.values.where((d) => d.name == delayName).firstOrNull ?? LockDelay.immediately,
      hideAmounts: _preferences.getBool(_hide) ?? false,
      secureWindow: _preferences.getBool(_secure) ?? false,
    );
  }

  @override
  Future<void> write(PrivacySettings settings) async {
    await _preferences.setBool(_lock, settings.appLock);
    await _preferences.setString(_delay, settings.lockDelay.name);
    await _preferences.setBool(_hide, settings.hideAmounts);
    await _preferences.setBool(_secure, settings.secureWindow);
  }
}

final privacySettingsStoreProvider = Provider<PrivacySettingsStore>((ref) => InMemoryPrivacySettingsStore());

class PrivacySettingsNotifier extends Notifier<PrivacySettings> {
  @override
  PrivacySettings build() => ref.read(privacySettingsStoreProvider).read();

  void _update(PrivacySettings next) {
    state = next;
    ref.read(privacySettingsStoreProvider).write(next);
  }

  void setAppLock(bool value) => _update(state.copyWith(appLock: value));
  void setLockDelay(LockDelay value) => _update(state.copyWith(lockDelay: value));
  void setHideAmounts(bool value) => _update(state.copyWith(hideAmounts: value));
  void setSecureWindow(bool value) => _update(state.copyWith(secureWindow: value));
}

final privacySettingsProvider = NotifierProvider<PrivacySettingsNotifier, PrivacySettings>(PrivacySettingsNotifier.new);
