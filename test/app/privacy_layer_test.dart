import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/privacy_layer.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/platform/secure_window.dart';
import 'package:billa_mobile/core/privacy/privacy_mode.dart';
import 'package:billa_mobile/core/privacy/privacy_settings.dart';
import 'package:billa_mobile/core/security/app_lock.dart';
import 'package:billa_mobile/core/widgets/money_text.dart';
import 'package:billa_mobile/features/auth/presentation/providers/auth_controller.dart';
import '../features/account/support.dart';

class _FakeSecureWindow implements SecureWindow {
  final calls = <bool>[];

  @override
  Future<void> setSecure(bool secure) async => calls.add(secure);
}

class _NoPrompt implements Authenticator {
  @override
  Future<bool> get isSupported async => true;

  @override
  Future<bool> authenticate(String reason) async => true;
}

void main() {
  late _FakeSecureWindow window;
  late ProviderContainer container;

  Future<void> pump(WidgetTester tester, PrivacySettings settings) async {
    window = _FakeSecureWindow();
    container = ProviderContainer(overrides: [
      secureWindowProvider.overrideWithValue(window),
      privacySettingsStoreProvider.overrideWithValue(InMemoryPrivacySettingsStore(settings)),
      authenticatorProvider.overrideWithValue(_NoPrompt()),
      authControllerProvider.overrideWith(FakeAuthController.new),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light,
        home: const AppPrivacyLayer(child: Scaffold(body: MoneyText(5000))),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('amounts show normally when privacy mode is off', (tester) async {
    await pump(tester, const PrivacySettings());

    expect(find.text('RWF 5,000'), findsOneWidget);
  });

  testWidgets('amounts turn to dots when privacy mode is on, and back when revealed', (tester) async {
    await pump(tester, const PrivacySettings(hideAmounts: true));
    expect(find.text('RWF 5,000'), findsNothing);

    container.read(amountsRevealedProvider.notifier).state = true;
    await tester.pumpAndSettle();

    expect(find.text('RWF 5,000'), findsOneWidget);
  });

  testWidgets('the secure window follows the setting, including at launch', (tester) async {
    await pump(tester, const PrivacySettings(secureWindow: true));
    expect(window.calls, [true]);

    container.read(privacySettingsProvider.notifier).setSecureWindow(false);
    await tester.pumpAndSettle();

    expect(window.calls, [true, false]);
  });

  testWidgets('the lock covers the content while locked', (tester) async {
    await pump(tester, const PrivacySettings(appLock: true));
    container.read(appLockProvider.notifier).state = true;
    await tester.pump();

    expect(find.byKey(const Key('lock-screen')), findsOneWidget);
  });
}
