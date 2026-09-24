import 'package:freezed_annotation/freezed_annotation.dart';
import 'team_role.dart';

part 'pending_invite.freezed.dart';
part 'pending_invite.g.dart';

@freezed
class PendingInvite with _$PendingInvite {
  const factory PendingInvite({
    required String id,
    required String email,
    @JsonKey(fromJson: teamRoleFromJson, toJson: teamRoleToJson) required TeamRole role,
    required String expiresAt,
    required String createdAt,
    required String link,
  }) = _PendingInvite;

  factory PendingInvite.fromJson(Map<String, dynamic> json) => _$PendingInviteFromJson(json);
}
