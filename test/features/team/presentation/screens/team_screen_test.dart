import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/team/domain/pending_invite.dart';
import 'package:billa_mobile/features/team/domain/team_member.dart';
import 'package:billa_mobile/features/team/domain/team_repository.dart';
import 'package:billa_mobile/features/team/domain/team_role.dart';
import 'package:billa_mobile/features/team/presentation/providers/team_repository_provider.dart';
import 'package:billa_mobile/features/team/presentation/screens/team_screen.dart';

class _MockTeamRepository extends Mock implements TeamRepository {}

const _owner = TeamMember(id: 'u1', email: 'owner@x.com', role: TeamRole.owner, joinedAt: '2026-01-01T00:00:00.000Z');
const _member = TeamMember(id: 'u2', email: 'member@x.com', role: TeamRole.member, joinedAt: '2026-01-02T00:00:00.000Z');
const _invite = PendingInvite(
  id: 'i1',
  email: 'new@x.com',
  role: TeamRole.accountant,
  expiresAt: '2026-02-01T00:00:00.000Z',
  createdAt: '2026-01-25T00:00:00.000Z',
  link: 'https://app.example.com/invite/tok',
);

DioException _error(String code) => DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response(requestOptions: RequestOptions(path: '/x'), data: {'error': code}),
    );

void main() {
  late _MockTeamRepository repository;

  setUp(() {
    repository = _MockTeamRepository();
    when(() => repository.members()).thenAnswer((_) async => [_owner, _member]);
    when(() => repository.invites()).thenAnswer((_) async => [_invite]);
  });

  Widget buildApp() => ProviderScope(
        overrides: [teamRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(theme: AppTheme.light, home: const TeamScreen()),
      );

  Future<void> sendInvite(WidgetTester tester, String email) async {
    await tester.tap(find.byKey(const Key('team-invite-button')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('invite-email')), email);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send invite'));
    await tester.pumpAndSettle();
  }

  testWidgets('lists members and pending invites, with no actions on the owner', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('owner@x.com'), findsOneWidget);
    expect(find.text('member@x.com'), findsOneWidget);
    expect(find.text('new@x.com'), findsOneWidget);
    expect(find.byIcon(Icons.person_remove), findsOneWidget);
  });

  testWidgets('changing a member role calls updateRole', (tester) async {
    when(() => repository.updateRole('u2', TeamRole.accountant)).thenAnswer((_) async {});

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButton<TeamRole>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Accountant').last);
    await tester.pumpAndSettle();

    verify(() => repository.updateRole('u2', TeamRole.accountant)).called(1);
  });

  testWidgets('removing a member confirms first', (tester) async {
    when(() => repository.removeMember('u2')).thenAnswer((_) async {});

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.person_remove));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove').last);
    await tester.pumpAndSettle();

    verify(() => repository.removeMember('u2')).called(1);
  });

  testWidgets('inviting someone sends the email and role, then reloads', (tester) async {
    when(() => repository.invite('friend@x.com', TeamRole.member)).thenAnswer((_) async {});

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await sendInvite(tester, 'friend@x.com');

    verify(() => repository.invite('friend@x.com', TeamRole.member)).called(1);
    verify(() => repository.invites()).called(2);
  });

  testWidgets('an already-member error shows its specific message with a retry', (tester) async {
    when(() => repository.invite('member@x.com', TeamRole.member)).thenThrow(_error('already_member'));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await sendInvite(tester, 'member@x.com');

    expect(find.text('That person is already on this team'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('revoking an invite confirms first', (tester) async {
    when(() => repository.revokeInvite('i1')).thenAnswer((_) async {});

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Revoke'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Revoke').last);
    await tester.pumpAndSettle();

    verify(() => repository.revokeInvite('i1')).called(1);
  });
}
