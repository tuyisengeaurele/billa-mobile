import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/businesses/presentation/providers/my_businesses_provider.dart';
import 'package:billa_mobile/features/account/presentation/screens/settings_screen.dart';
import 'package:billa_mobile/features/auth/presentation/providers/auth_controller.dart';
import '../../../../support/tall_screen.dart';
import '../../support.dart';

void main() {
  late FakeAuthController auth;

  setUp(() {
    auth = FakeAuthController();
  });

  Widget buildApp({bool owner = false}) => accountApp(
        screen: const SettingsScreen(),
        path: '/settings',
        overrides: [
          authControllerProvider.overrideWith(() => auth),
          isOwnerOfActiveBusinessProvider.overrideWith((ref) => owner),
        ],
      );

  testWidgets('shows the signed-in name and email', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('ada@example.com'), findsOneWidget);
  });

  testWidgets('each row opens its screen', (tester) async {
    useTallScreen(tester);
    for (final (key, route) in [
      ('settings-profile', '/settings/profile'),
      ('settings-items', '/items'),
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
    useTallScreen(tester);
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
    useTallScreen(tester);
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-sign-out')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(auth.loggedOut, isFalse);
  });

  testWidgets('business settings is offered to an owner and opens its hub', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(buildApp(owner: true));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-business')));
    await tester.pumpAndSettle();

    expect(find.text('stub /settings/business'), findsOneWidget);
  });

  testWidgets('business settings is hidden from a non-owner', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('settings-business')), findsNothing);
  });

  testWidgets('team is offered to an owner and opens the team screen', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(buildApp(owner: true));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-team')));
    await tester.pumpAndSettle();

    expect(find.text('stub /team'), findsOneWidget);
  });

  testWidgets('team is hidden from a non-owner', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('settings-team')), findsNothing);
  });

  testWidgets('shows the active business as the way to switch', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Acme'), findsOneWidget);
    expect(find.text('Switch business'), findsOneWidget);

    await tester.tap(find.byKey(const Key('settings-switch-business')));
    await tester.pumpAndSettle();
    expect(find.text('stub /businesses'), findsOneWidget);
  });
}
