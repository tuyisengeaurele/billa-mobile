import 'pending_invite.dart';
import 'team_member.dart';
import 'team_role.dart';

abstract class TeamRepository {
  Future<List<TeamMember>> members();
  Future<void> updateRole(String userId, TeamRole role);
  Future<void> removeMember(String userId);
  Future<List<PendingInvite>> invites();
  Future<void> invite(String email, TeamRole role);
  Future<void> resendInvite(String inviteId);
  Future<void> revokeInvite(String inviteId);
}
