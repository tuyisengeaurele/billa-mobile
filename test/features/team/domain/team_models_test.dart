import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/team/domain/pending_invite.dart';
import 'package:billa_mobile/features/team/domain/team_member.dart';
import 'package:billa_mobile/features/team/domain/team_role.dart';

void main() {
  test('roles are lowercase in responses', () {
    expect(teamRoleFromJson('owner'), TeamRole.owner);
    expect(teamRoleFromJson('member'), TeamRole.member);
    expect(teamRoleToJson(TeamRole.member), 'member');
    expect(teamRoleToJson(TeamRole.owner), 'owner');
  });

  test('a retired or unknown role reads as a plain member instead of failing the whole team list', () {
    expect(teamRoleFromJson('accountant'), TeamRole.member);
    expect(teamRoleFromJson('admin'), TeamRole.member);
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
      'role': 'member',
      'expiresAt': '2026-02-01T00:00:00.000Z',
      'createdAt': '2026-01-25T00:00:00.000Z',
      'link': 'https://app.example.com/invite/tok123',
    });

    expect(invite.role, TeamRole.member);
    expect(invite.link, endsWith('/invite/tok123'));
  });
}
