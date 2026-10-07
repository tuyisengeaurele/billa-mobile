import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:billa_mobile/core/privacy/privacy_settings.dart';

void main() {
  test('everything is off by default', () {
    const settings = PrivacySettings();

    expect(settings.appLock, isFalse);
    expect(settings.hideAmounts, isFalse);
    expect(settings.secureWindow, isFalse);
    expect(settings.lockDelay, LockDelay.immediately);
  });

  test('each setter changes only its own value and is written to the store', () async {
    final store = InMemoryPrivacySettingsStore();
    final container = ProviderContainer(overrides: [privacySettingsStoreProvider.overrideWithValue(store)]);
    addTearDown(container.dispose);
    final notifier = container.read(privacySettingsProvider.notifier);

    notifier.setAppLock(true);
    notifier.setLockDelay(LockDelay.fiveMinutes);
    notifier.setHideAmounts(true);
    notifier.setSecureWindow(true);

    const expected = PrivacySettings(appLock: true, lockDelay: LockDelay.fiveMinutes, hideAmounts: true, secureWindow: true);
    expect(container.read(privacySettingsProvider), expected);
    expect(store.read(), expected);
  });

  test('starts from what the store holds', () {
    final store = InMemoryPrivacySettingsStore(const PrivacySettings(hideAmounts: true));
    final container = ProviderContainer(overrides: [privacySettingsStoreProvider.overrideWithValue(store)]);
    addTearDown(container.dispose);

    expect(container.read(privacySettingsProvider).hideAmounts, isTrue);
  });

  test('delays have durations and labels a person can read', () {
    expect(LockDelay.immediately.duration, Duration.zero);
    expect(LockDelay.oneMinute.duration, const Duration(minutes: 1));
    expect(LockDelay.fiveMinutes.label, 'After 5 minutes');
  });

  group('preferences store', () {
    test('round-trips every value', () async {
      SharedPreferences.setMockInitialValues({});
      final store = SharedPreferencesPrivacySettingsStore(await SharedPreferences.getInstance());
      const settings = PrivacySettings(appLock: true, lockDelay: LockDelay.oneMinute, hideAmounts: true, secureWindow: true);

      await store.write(settings);

      expect(store.read(), settings);
    });

    test('falls back to defaults for missing or unknown values', () async {
      SharedPreferences.setMockInitialValues({'privacy_lock_delay': 'someday'});
      final store = SharedPreferencesPrivacySettingsStore(await SharedPreferences.getInstance());

      expect(store.read(), const PrivacySettings());
    });
  });
}
