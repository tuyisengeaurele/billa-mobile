import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/account/domain/security_repository.dart';
import 'package:billa_mobile/features/account/presentation/providers/current_user_provider.dart';
import 'package:billa_mobile/features/account/presentation/providers/security_repository_provider.dart';
import 'package:billa_mobile/features/account/presentation/screens/security_screen.dart';
import 'package:billa_mobile/features/auth/domain/auth_user.dart';
import 'package:billa_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../support.dart';

class _MockSecurityRepository extends Mock implements SecurityRepository {}

void main() {
  late _MockSecurityRepository repository;
  late FakeAuthController auth;

  setUp(() {
    repository = _MockSecurityRepository();
  });

  Widget buildApp({AuthUser user = testUser}) {
    auth = FakeAuthController(user);
    return accountApp(
      screen: const SecurityScreen(),
      path: '/settings/security',
      overrides: [
        authControllerProvider.overrideWith(() => auth),
        securityRepositoryProvider.overrideWithValue(repository),
      ],
    );
  }

  ProviderContainer container(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(SecurityScreen)));

  testWidgets('offers Turn on when two-factor is off and opens the setup screen', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Turn on'), findsOneWidget);
    await tester.tap(find.byKey(const Key('security-two-factor')));
    await tester.pumpAndSettle();

    expect(find.text('stub /settings/security/two-factor'), findsOneWidget);
  });

  testWidgets('turning off two-factor asks for a code and updates the user', (tester) async {
    when(() => repository.disableTwoFactor('123456')).thenAnswer((_) async {});

    await tester.pumpWidget(buildApp(user: testUser.copyWith(totpEnabled: true)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('security-two-factor')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '123456');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Turn off').last);
    await tester.pumpAndSettle();

    verify(() => repository.disableTwoFactor('123456')).called(1);
    expect(container(tester).read(currentUserProvider)!.totpEnabled, isFalse);
  });

  testWidgets('a wrong code when turning off shows the specific message', (tester) async {
    when(() => repository.disableTwoFactor('000000')).thenThrow(apiError('invalid_code'));

    await tester.pumpWidget(buildApp(user: testUser.copyWith(totpEnabled: true)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('security-two-factor')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '000000');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Turn off').last);
    await tester.pumpAndSettle();

    expect(find.text("That code isn't right — try again"), findsOneWidget);
    expect(container(tester).read(currentUserProvider)!.totpEnabled, isTrue);
  });

  testWidgets('signed-in devices opens the sessions screen', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('security-sessions')));
    await tester.pumpAndSettle();

    expect(find.text('stub /settings/security/sessions'), findsOneWidget);
  });

  testWidgets('deleting the account needs the typed email, then signs out locally', (tester) async {
    when(() => repository.deleteAccount()).thenAnswer((_) async {});

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('security-delete')));
    await tester.pumpAndSettle();

    expect(tester.widget<TextButton>(find.byKey(const Key('delete-confirm'))).onPressed, isNull);
    await tester.enterText(find.byKey(const Key('delete-email')), 'wrong@example.com');
    await tester.pumpAndSettle();
    expect(tester.widget<TextButton>(find.byKey(const Key('delete-confirm'))).onPressed, isNull);

    await tester.enterText(find.byKey(const Key('delete-email')), 'ada@example.com');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('delete-confirm')));
    await tester.pumpAndSettle();

    verify(() => repository.deleteAccount()).called(1);
    expect(container(tester).read(currentUserProvider), isNull);
  });

  testWidgets('an account with administrator history shows why it cannot be deleted', (tester) async {
    when(() => repository.deleteAccount()).thenThrow(apiError('has_admin_history'));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('security-delete')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('delete-email')), 'ada@example.com');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('delete-confirm')));
    await tester.pumpAndSettle();

    expect(find.text("This account can't be deleted because it has administrator history"), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
