import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/account/domain/security_repository.dart';
import 'package:billa_mobile/features/account/domain/session_info.dart';
import 'package:billa_mobile/features/account/presentation/providers/security_repository_provider.dart';
import 'package:billa_mobile/features/account/presentation/screens/sessions_screen.dart';
import 'package:billa_mobile/features/auth/presentation/providers/auth_controller.dart';
import '../../support.dart';

class _MockSecurityRepository extends Mock implements SecurityRepository {}

const _current = SessionInfo(
  id: 's1',
  createdAt: '2026-01-01T00:00:00.000Z',
  expiresAt: '2026-02-01T00:00:00.000Z',
  isCurrent: true,
);
const _other = SessionInfo(
  id: 's2',
  createdAt: '2026-01-02T00:00:00.000Z',
  expiresAt: '2026-02-02T00:00:00.000Z',
  isCurrent: false,
);

void main() {
  late _MockSecurityRepository repository;

  setUp(() {
    repository = _MockSecurityRepository();
  });

  Widget buildApp() => accountApp(
        screen: const SessionsScreen(),
        path: '/settings/security/sessions',
        overrides: [
          authControllerProvider.overrideWith(FakeAuthController.new),
          securityRepositoryProvider.overrideWithValue(repository),
        ],
      );

  testWidgets('labels this device and only offers to sign out the others', (tester) async {
    when(() => repository.sessions()).thenAnswer((_) async => [_current, _other]);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('This device'), findsOneWidget);
    expect(find.byKey(const Key('session-revoke-s1')), findsNothing);
    expect(find.byKey(const Key('session-revoke-s2')), findsOneWidget);
  });

  testWidgets('revoking a device confirms first, then reloads', (tester) async {
    when(() => repository.sessions()).thenAnswer((_) async => [_current, _other]);
    when(() => repository.revokeSession('s2')).thenAnswer((_) async {});

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('session-revoke-s2')));
    await tester.pumpAndSettle();
    verifyNever(() => repository.revokeSession('s2'));

    await tester.tap(find.text('Sign out').last);
    await tester.pumpAndSettle();

    verify(() => repository.revokeSession('s2')).called(1);
    verify(() => repository.sessions()).called(2);
  });

  testWidgets('signing out other devices is offered only with more than one session', (tester) async {
    when(() => repository.sessions()).thenAnswer((_) async => [_current]);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('sessions-revoke-others')), findsNothing);
  });

  testWidgets('sign out other devices confirms and calls the endpoint', (tester) async {
    when(() => repository.sessions()).thenAnswer((_) async => [_current, _other]);
    when(() => repository.revokeOtherSessions()).thenAnswer((_) async {});

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sessions-revoke-others')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out others'));
    await tester.pumpAndSettle();

    verify(() => repository.revokeOtherSessions()).called(1);
  });

  testWidgets('a failed revoke shows its message with a retry', (tester) async {
    when(() => repository.sessions()).thenAnswer((_) async => [_current, _other]);
    when(() => repository.revokeSession('s2')).thenThrow(apiError('not_found'));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('session-revoke-s2')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out').last);
    await tester.pumpAndSettle();

    expect(find.text("We couldn't find that. It may have been removed"), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('a failed load offers a retry', (tester) async {
    when(() => repository.sessions()).thenAnswer((_) async => throw apiError('not_found'));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Retry'), findsOneWidget);
  });
}
