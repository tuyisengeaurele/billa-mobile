import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/team/domain/pending_invite.dart';
import 'package:billa_mobile/features/team/domain/team_member.dart';
import 'package:billa_mobile/features/team/domain/team_role.dart';

void main() {
  test('roles are lowercase in responses and uppercase in requests', () {
    expect(teamRoleFromJson('accountant'), TeamRole.accountant);
    expect(teamRoleToJson(TeamRole.member), 'member');
    expect(teamRoleToRequest(TeamRole.member), 'MEMBER');
    expect(teamRoleToRequest(TeamRole.accountant), 'ACCOUNTANT');
  });

  test('an owner can never be assigned or invited', () {
    expect(() => teamRoleToRequest(TeamRole.owner), throwsArgumentError);
  });

  test('an unknown role is rejected', () {
    expect(() => teamRoleFromJson('admin'), throwsArgumentError);
  });

  test('TeamMember.fromJson parses the owner row', () {
    final member = TeamMember.fromJson({
      'id': 'u1',
      'email': 'owner@example.com',
      'role': 'owner',
      'joinedAt': '2026-01-01T00:00:00.000Z',
    });

    expect(member.role, TeamRole.owner);
    expect(member.email, 'owner@example.com');
  });

  test('PendingInvite.fromJson parses an invite with its link', () {
    final invite = PendingInvite.fromJson({
      'id': 'i1',
      'email': 'new@example.com',
      'role': 'accountant',
      'expiresAt': '2026-02-01T00:00:00.000Z',
      'createdAt': '2026-01-25T00:00:00.000Z',
      'link': 'https://app.example.com/invite/tok123',
    });

    expect(invite.role, TeamRole.accountant);
    expect(invite.link, endsWith('/invite/tok123'));
  });
}
