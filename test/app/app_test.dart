import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:billa_mobile/app/app.dart';
import 'package:billa_mobile/core/platform/secure_window.dart';
import 'package:billa_mobile/core/privacy/privacy_settings.dart';
import 'package:billa_mobile/core/security/app_lock.dart';
import 'package:billa_mobile/features/auth/domain/auth_user.dart';
import 'package:billa_mobile/features/onboarding/domain/business.dart';
import 'package:billa_mobile/features/auth/domain/auth_status.dart';
import 'package:billa_mobile/features/auth/presentation/providers/auth_controller.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('an unauthenticated boot lands on the login screen', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(() => _FakeAuthController(const AuthStatus.unauthenticated())),
      ],
      child: const App(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Log in'), findsWidgets);
  });

  testWidgets('coming back to the app refreshes a stale session', (tester) async {
    final controller = _RecordingAuthController();
    await tester.pumpWidget(ProviderScope(
      overrides: [authControllerProvider.overrideWith(() => controller)],
      child: const App(),
    ));
    await tester.pumpAndSettle();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(controller.refreshChecks, 1);
  });

  testWidgets('leaving and returning locks a signed-in app when the lock is on', (tester) async {
    var now = DateTime(2026, 3, 1, 9);
    const business = Business(id: 'b1', name: 'Acme', onboardingCompletedAt: '2026-01-01T00:00:00.000Z');
    const user = AuthUser(id: 'u1', email: 'a@b.com', totpEnabled: false, isAdmin: false);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(() => _FakeAuthController(const AuthStatus.authenticated(user, business))),
        privacySettingsStoreProvider.overrideWithValue(InMemoryPrivacySettingsStore(const PrivacySettings(appLock: true))),
        authenticatorProvider.overrideWithValue(_NoPromptAuthenticator()),
        appLockClockProvider.overrideWithValue(() => now),
        secureWindowProvider.overrideWithValue(_NullSecureWindow()),
      ],
      child: const App(),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('lock-screen')), findsOneWidget);

    final container = ProviderScope.containerOf(tester.element(find.byType(App)));
    container.read(appLockProvider.notifier).unlockWithoutPrompt();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('lock-screen')), findsNothing);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    now = now.add(const Duration(seconds: 5));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(find.byKey(const Key('lock-screen')), findsOneWidget);
  });

  testWidgets('going to the background does not refresh anything', (tester) async {
    final controller = _RecordingAuthController();
    await tester.pumpWidget(ProviderScope(
      overrides: [authControllerProvider.overrideWith(() => controller)],
      child: const App(),
    ));
    await tester.pumpAndSettle();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();

    expect(controller.refreshChecks, 0);
  });
}

class _NoPromptAuthenticator implements Authenticator {
  @override
  Future<bool> get isSupported async => true;

  @override
  Future<bool> authenticate(String reason) async => false;
}

class _NullSecureWindow implements SecureWindow {
  @override
  Future<void> setSecure(bool secure) async {}
}

class _FakeAuthController extends AuthController {
  _FakeAuthController(this._status);
  final AuthStatus _status;

  @override
  Future<AuthStatus> build() async => _status;
}

class _RecordingAuthController extends AuthController {
  int refreshChecks = 0;

  @override
  Future<AuthStatus> build() async => const AuthStatus.unauthenticated();

  @override
  Future<void> refreshIfStale() async => refreshChecks++;
}
