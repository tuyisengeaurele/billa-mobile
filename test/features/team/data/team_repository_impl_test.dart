import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/team/data/team_repository_impl.dart';
import 'package:billa_mobile/features/team/domain/team_role.dart';

class _MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _response(int status, Map<String, dynamic> data, String path) =>
    Response(statusCode: status, data: data, requestOptions: RequestOptions(path: path));

void main() {
  late _MockDio dio;
  late TeamRepositoryImpl repository;

  setUp(() {
    dio = _MockDio();
    repository = TeamRepositoryImpl(dio);
  });

  test('members maps the owner row and members', () async {
    when(() => dio.get<Map<String, dynamic>>('/business/members')).thenAnswer((_) async => _response(200, {
          'members': [
            {'id': 'u1', 'email': 'o@x.com', 'role': 'owner', 'joinedAt': '2026-01-01T00:00:00.000Z'},
            {'id': 'u2', 'email': 'm@x.com', 'role': 'member', 'joinedAt': '2026-01-02T00:00:00.000Z'},
          ],
        }, '/business/members'));

    final members = await repository.members();

    expect(members.map((m) => m.role), [TeamRole.owner, TeamRole.member]);
  });

  test('updateRole sends the uppercase role', () async {
    when(() => dio.patch<Map<String, dynamic>>('/business/members/u2/role', data: {'role': 'ACCOUNTANT'}))
        .thenAnswer((_) async => _response(200, {'ok': true}, '/business/members/u2/role'));

    await repository.updateRole('u2', TeamRole.accountant);

    verify(() => dio.patch<Map<String, dynamic>>('/business/members/u2/role', data: {'role': 'ACCOUNTANT'}))
        .called(1);
  });

  test('removeMember sends a DELETE', () async {
    when(() => dio.delete<Map<String, dynamic>>('/business/members/u2'))
        .thenAnswer((_) async => _response(200, {'ok': true}, '/business/members/u2'));

    await repository.removeMember('u2');

    verify(() => dio.delete<Map<String, dynamic>>('/business/members/u2')).called(1);
  });

  test('invites maps pending invites with their links', () async {
    when(() => dio.get<Map<String, dynamic>>('/business/invites')).thenAnswer((_) async => _response(200, {
          'invites': [
            {
              'id': 'i1',
              'email': 'n@x.com',
              'role': 'member',
              'expiresAt': '2026-02-01T00:00:00.000Z',
              'createdAt': '2026-01-25T00:00:00.000Z',
              'link': 'https://app.example.com/invite/tok',
            },
          ],
        }, '/business/invites'));

    final invites = await repository.invites();

    expect(invites.single.email, 'n@x.com');
  });

  test('invite posts the email and uppercase role', () async {
    when(() => dio.post<Map<String, dynamic>>('/business/invites', data: {'email': 'n@x.com', 'role': 'MEMBER'}))
        .thenAnswer((_) async => _response(201, {'invite': {'id': 'i1'}, 'link': 'l'}, '/business/invites'));

    await repository.invite('n@x.com', TeamRole.member);

    verify(() => dio.post<Map<String, dynamic>>('/business/invites', data: {'email': 'n@x.com', 'role': 'MEMBER'}))
        .called(1);
  });

  test('resendInvite and revokeInvite hit their endpoints', () async {
    when(() => dio.post<Map<String, dynamic>>('/business/invites/i1/resend'))
        .thenAnswer((_) async => _response(200, {'ok': true}, '/business/invites/i1/resend'));
    when(() => dio.delete<Map<String, dynamic>>('/business/invites/i1'))
        .thenAnswer((_) async => _response(200, {'ok': true}, '/business/invites/i1'));

    await repository.resendInvite('i1');
    await repository.revokeInvite('i1');

    verify(() => dio.post<Map<String, dynamic>>('/business/invites/i1/resend')).called(1);
    verify(() => dio.delete<Map<String, dynamic>>('/business/invites/i1')).called(1);
  });
}
