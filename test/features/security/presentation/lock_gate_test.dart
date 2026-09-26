import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/privacy/privacy_settings.dart';
import 'package:billa_mobile/core/security/app_lock.dart';
import 'package:billa_mobile/features/auth/domain/auth_status.dart';
import 'package:billa_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:billa_mobile/features/security/presentation/lock_gate.dart';
import '../../account/support.dart';

class _FakeAuthenticator implements Authenticator {
  bool accepts = true;
  int prompts = 0;

  @override
  Future<bool> get isSupported async => true;

  @override
  Future<bool> authenticate(String reason) async {
    prompts++;
    return accepts;
  }
}

void main() {
  late _FakeAuthenticator authenticator;

  setUp(() {
    authenticator = _FakeAuthenticator();
  });

  Widget host({bool locked = true, bool signedIn = true}) {
    return ProviderScope(
      overrides: [
        authenticatorProvider.overrideWithValue(authenticator),
        privacySettingsStoreProvider.overrideWithValue(InMemoryPrivacySettingsStore(PrivacySettings(appLock: locked))),
        if (signedIn) authControllerProvider.overrideWith(FakeAuthController.new) else authControllerProvider.overrideWith(_SignedOutController.new),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const LockGate(child: Scaffold(body: Text('secret content'))),
      ),
    );
  }

  testWidgets('covers the app with the lock screen when locked and signed in', (tester) async {
    authenticator.accepts = false;
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('lock-screen')), findsOneWidget);
    expect(find.text('Billa is locked'), findsOneWidget);
  });

  testWidgets('asks to unlock as soon as it appears', (tester) async {
    authenticator.accepts = false;
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(authenticator.prompts, 1);
  });

  testWidgets('a successful unlock reveals the app', (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('lock-screen')), findsNothing);
    expect(find.text('secret content'), findsOneWidget);
  });

  testWidgets('a refused unlock says so and Unlock tries again', (tester) async {
    authenticator.accepts = false;
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(find.text("Couldn't confirm it's you. Try again"), findsOneWidget);

    authenticator.accepts = true;
    await tester.tap(find.byKey(const Key('lock-unlock')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('lock-screen')), findsNothing);
  });

  testWidgets('nothing is hidden when the lock is off', (tester) async {
    await tester.pumpWidget(host(locked: false));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('lock-screen')), findsNothing);
    expect(authenticator.prompts, 0);
  });

  testWidgets('signed out there is nothing to protect, so no lock screen shows', (tester) async {
    await tester.pumpWidget(host(signedIn: false));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('lock-screen')), findsNothing);
  });
}

class _SignedOutController extends FakeAuthController {
  @override
  Future<AuthStatus> build() async => const AuthStatus.unauthenticated();
}
