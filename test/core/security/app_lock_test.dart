import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/privacy/privacy_settings.dart';
import 'package:billa_mobile/core/security/app_lock.dart';

class _FakeAuthenticator implements Authenticator {
  bool supported = true;
  bool accepts = true;
  int prompts = 0;
  void Function()? duringPrompt;

  @override
  Future<bool> get isSupported async => supported;

  @override
  Future<bool> authenticate(String reason) async {
    prompts++;
    duringPrompt?.call();
    return accepts;
  }
}

void main() {
  late _FakeAuthenticator authenticator;
  late DateTime now;
  late InMemoryPrivacySettingsStore store;

  ProviderContainer make() {
    final container = ProviderContainer(overrides: [
      authenticatorProvider.overrideWithValue(authenticator),
      appLockClockProvider.overrideWithValue(() => now),
      privacySettingsStoreProvider.overrideWithValue(store),
    ]);
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    authenticator = _FakeAuthenticator();
    now = DateTime(2026, 3, 1, 9);
    store = InMemoryPrivacySettingsStore();
  });

  test('a phone with the lock off is never locked', () {
    final container = make();
    final lock = container.read(appLockProvider.notifier);

    lock.onPaused();
    now = now.add(const Duration(hours: 5));
    lock.onResumed();

    expect(container.read(appLockProvider), isFalse);
  });

  test('a fresh start is locked when the lock is on', () {
    store = InMemoryPrivacySettingsStore(const PrivacySettings(appLock: true));

    expect(make().read(appLockProvider), isTrue);
  });

  test('the immediate delay locks on any return to the app', () {
    store = InMemoryPrivacySettingsStore(const PrivacySettings(appLock: true));
    final container = make();
    final lock = container.read(appLockProvider.notifier);
    lock.unlockWithoutPrompt();

    lock.onPaused();
    lock.onResumed();

    expect(container.read(appLockProvider), isTrue);
  });

  test('a one minute delay waits a minute before locking', () {
    store = InMemoryPrivacySettingsStore(const PrivacySettings(appLock: true, lockDelay: LockDelay.oneMinute));
    final container = make();
    final lock = container.read(appLockProvider.notifier);
    lock.unlockWithoutPrompt();

    lock.onPaused();
    now = now.add(const Duration(seconds: 30));
    lock.onResumed();
    expect(container.read(appLockProvider), isFalse);

    lock.onPaused();
    now = now.add(const Duration(seconds: 61));
    lock.onResumed();
    expect(container.read(appLockProvider), isTrue);
  });

  test('a successful unlock opens the app, a refusal keeps it locked', () async {
    store = InMemoryPrivacySettingsStore(const PrivacySettings(appLock: true));
    final container = make();
    final lock = container.read(appLockProvider.notifier);

    authenticator.accepts = false;
    expect(await lock.unlock(), isFalse);
    expect(container.read(appLockProvider), isTrue);

    authenticator.accepts = true;
    expect(await lock.unlock(), isTrue);
    expect(container.read(appLockProvider), isFalse);
  });

  test('the system prompt pausing the app does not lock it again straight after unlocking', () async {
    store = InMemoryPrivacySettingsStore(const PrivacySettings(appLock: true));
    final container = make();
    final lock = container.read(appLockProvider.notifier);
    authenticator.duringPrompt = () {
      lock.onPaused();
    };

    await lock.unlock();
    lock.onResumed();

    expect(container.read(appLockProvider), isFalse);
  });

  test('turning the lock off unlocks immediately', () {
    store = InMemoryPrivacySettingsStore(const PrivacySettings(appLock: true));
    final container = make();
    expect(container.read(appLockProvider), isTrue);

    container.read(privacySettingsProvider.notifier).setAppLock(false);

    expect(container.read(appLockProvider), isFalse);
  });

  test('turning the lock on does not lock the person who just turned it on', () {
    final container = make();
    container.read(appLockProvider);

    container.read(privacySettingsProvider.notifier).setAppLock(true);

    expect(container.read(appLockProvider), isFalse);
  });

  test('the lock can only be enabled when the phone has a screen lock or biometrics', () async {
    final container = make();
    final lock = container.read(appLockProvider.notifier);

    authenticator.supported = false;
    expect(await lock.canEnable(), isFalse);

    authenticator.supported = true;
    expect(await lock.canEnable(), isTrue);
  });
}
