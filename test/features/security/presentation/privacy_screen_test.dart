import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/platform/secure_window.dart';
import 'package:billa_mobile/core/privacy/privacy_settings.dart';
import 'package:billa_mobile/core/security/app_lock.dart';
import 'package:billa_mobile/features/security/presentation/privacy_screen.dart';
import '../../../support/tall_screen.dart';

class _FakeAuthenticator implements Authenticator {
  bool supported = true;
  bool accepts = true;
  int prompts = 0;

  @override
  Future<bool> get isSupported async => supported;

  @override
  Future<bool> authenticate(String reason) async {
    prompts++;
    return accepts;
  }
}

class _FakeSecureWindow implements SecureWindow {
  final calls = <bool>[];

  @override
  Future<void> setSecure(bool secure) async => calls.add(secure);
}

void main() {
  late _FakeAuthenticator authenticator;
  late InMemoryPrivacySettingsStore store;
  late ProviderContainer container;

  Future<void> pump(WidgetTester tester) async {
    useTallScreen(tester);
    container = ProviderContainer(overrides: [
      authenticatorProvider.overrideWithValue(authenticator),
      privacySettingsStoreProvider.overrideWithValue(store),
      secureWindowProvider.overrideWithValue(_FakeSecureWindow()),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(theme: AppTheme.light, home: const PrivacyScreen()),
    ));
    await tester.pumpAndSettle();
  }

  setUp(() {
    authenticator = _FakeAuthenticator();
    store = InMemoryPrivacySettingsStore();
  });

  testWidgets('shows every switch off by default and hides the delay until the lock is on', (tester) async {
    await pump(tester);

    expect(tester.widget<SwitchListTile>(find.byKey(const Key('privacy-lock'))).value, isFalse);
    expect(tester.widget<SwitchListTile>(find.byKey(const Key('privacy-hide-amounts'))).value, isFalse);
    expect(tester.widget<SwitchListTile>(find.byKey(const Key('privacy-secure-window'))).value, isFalse);
    expect(find.byKey(const Key('privacy-delay-immediately')), findsNothing);
  });

  testWidgets('turning the lock on proves the owner first, then reveals the delay choices', (tester) async {
    await pump(tester);

    await tester.tap(find.byKey(const Key('privacy-lock')));
    await tester.pumpAndSettle();

    expect(authenticator.prompts, 1);
    expect(container.read(privacySettingsProvider).appLock, isTrue);
    expect(find.byKey(const Key('privacy-delay-immediately')), findsOneWidget);
  });

  testWidgets('a refused check leaves the lock off and says so', (tester) async {
    authenticator.accepts = false;
    await pump(tester);

    await tester.tap(find.byKey(const Key('privacy-lock')));
    await tester.pumpAndSettle();

    expect(container.read(privacySettingsProvider).appLock, isFalse);
    expect(find.text("Couldn't confirm it's you, so the lock stays off"), findsOneWidget);
  });

  testWidgets('a phone with no screen lock explains what to set up instead of failing', (tester) async {
    authenticator.supported = false;
    await pump(tester);

    await tester.tap(find.byKey(const Key('privacy-lock')));
    await tester.pumpAndSettle();

    expect(container.read(privacySettingsProvider).appLock, isFalse);
    expect(find.text('Set up a screen lock, fingerprint or face on this phone first'), findsOneWidget);
    expect(authenticator.prompts, 0);
  });

  testWidgets('the lock delay can be changed', (tester) async {
    store = InMemoryPrivacySettingsStore(const PrivacySettings(appLock: true));
    await pump(tester);

    await tester.tap(find.byKey(const Key('privacy-delay-fiveMinutes')));
    await tester.pumpAndSettle();

    expect(container.read(privacySettingsProvider).lockDelay, LockDelay.fiveMinutes);
  });

  testWidgets('turning the lock off needs no check', (tester) async {
    store = InMemoryPrivacySettingsStore(const PrivacySettings(appLock: true));
    await pump(tester);

    await tester.tap(find.byKey(const Key('privacy-lock')));
    await tester.pumpAndSettle();

    expect(container.read(privacySettingsProvider).appLock, isFalse);
    expect(authenticator.prompts, 0);
  });

  testWidgets('hiding amounts and the secure window are plain switches', (tester) async {
    await pump(tester);

    await tester.tap(find.byKey(const Key('privacy-hide-amounts')));
    await tester.tap(find.byKey(const Key('privacy-secure-window')));
    await tester.pumpAndSettle();

    expect(container.read(privacySettingsProvider).hideAmounts, isTrue);
    expect(container.read(privacySettingsProvider).secureWindow, isTrue);
  });
}
