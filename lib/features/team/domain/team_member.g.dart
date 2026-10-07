// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TeamMemberImpl _$$TeamMemberImplFromJson(Map<String, dynamic> json) =>
    _$TeamMemberImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      role: teamRoleFromJson(json['role'] as String),
      joinedAt: json['joinedAt'] as String,
    );

Map<String, dynamic> _$$TeamMemberImplToJson(_$TeamMemberImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'role': teamRoleToJson(instance.role),
      'joinedAt': instance.joinedAt,
    };
