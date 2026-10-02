import 'pending_invite.dart';
import 'team_member.dart';

abstract class TeamRepository {
  Future<List<TeamMember>> members();
  Future<void> removeMember(String userId);
  Future<List<PendingInvite>> invites();
  Future<void> invite(String email);
  Future<void> resendInvite(String inviteId);
  Future<void> revokeInvite(String inviteId);
}
