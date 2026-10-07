import 'package:freezed_annotation/freezed_annotation.dart';
import 'team_role.dart';

part 'team_member.freezed.dart';
part 'team_member.g.dart';

@freezed
class TeamMember with _$TeamMember {
  const factory TeamMember({
    required String id,
    required String email,
    @JsonKey(fromJson: teamRoleFromJson, toJson: teamRoleToJson) required TeamRole role,
    required String joinedAt,
  }) = _TeamMember;

  factory TeamMember.fromJson(Map<String, dynamic> json) => _$TeamMemberFromJson(json);
}
