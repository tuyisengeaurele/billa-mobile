import 'package:dio/dio.dart';
import '../domain/pending_invite.dart';
import '../domain/team_member.dart';
import '../domain/team_repository.dart';
import '../domain/team_role.dart';

class TeamRepositoryImpl implements TeamRepository {
  TeamRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<TeamMember>> members() async {
    final response = await _dio.get<Map<String, dynamic>>('/business/members');
    return (response.data!['members'] as List)
        .map((json) => TeamMember.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> updateRole(String userId, TeamRole role) async {
    await _dio.patch<Map<String, dynamic>>('/business/members/$userId/role', data: {'role': teamRoleToRequest(role)});
  }

  @override
  Future<void> removeMember(String userId) async {
    await _dio.delete<Map<String, dynamic>>('/business/members/$userId');
  }

  @override
  Future<List<PendingInvite>> invites() async {
    final response = await _dio.get<Map<String, dynamic>>('/business/invites');
    return (response.data!['invites'] as List)
        .map((json) => PendingInvite.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> invite(String email, TeamRole role) async {
    await _dio.post<Map<String, dynamic>>('/business/invites', data: {'email': email, 'role': teamRoleToRequest(role)});
  }

  @override
  Future<void> resendInvite(String inviteId) async {
    await _dio.post<Map<String, dynamic>>('/business/invites/$inviteId/resend');
  }

  @override
  Future<void> revokeInvite(String inviteId) async {
    await _dio.delete<Map<String, dynamic>>('/business/invites/$inviteId');
  }
}
