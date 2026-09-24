import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/account/presentation/screens/settings_screen.dart';
import 'package:billa_mobile/features/auth/presentation/providers/auth_controller.dart';
import '../../support.dart';

void main() {
  late FakeAuthController auth;

  setUp(() {
    auth = FakeAuthController();
  });

  Widget buildApp() => accountApp(
        screen: const SettingsScreen(),
        path: '/settings',
        overrides: [authControllerProvider.overrideWith(() => auth)],
      );

  testWidgets('shows the signed-in name and email', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('ada@example.com'), findsOneWidget);
  });

  testWidgets('each row opens its screen', (tester) async {
    for (final (key, route) in [
      ('settings-profile', '/settings/profile'),
      ('settings-security', '/settings/security'),
      ('settings-notifications', '/settings/notifications'),
      ('settings-appearance', '/settings/appearance'),
    ]) {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key(key)));
      await tester.pumpAndSettle();

      expect(find.text('stub $route'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('sign out asks first, then signs out', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-sign-out')));
    await tester.pumpAndSettle();
    expect(auth.loggedOut, isFalse);

    await tester.tap(find.text('Sign out').last);
    await tester.pumpAndSettle();

    expect(auth.loggedOut, isTrue);
  });

  testWidgets('cancelling the sign out confirmation keeps the session', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-sign-out')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(auth.loggedOut, isFalse);
  });
}
