// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_invite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PendingInviteImpl _$$PendingInviteImplFromJson(Map<String, dynamic> json) =>
    _$PendingInviteImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      role: teamRoleFromJson(json['role'] as String),
      expiresAt: json['expiresAt'] as String,
      createdAt: json['createdAt'] as String,
      link: json['link'] as String,
    );

Map<String, dynamic> _$$PendingInviteImplToJson(_$PendingInviteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'role': teamRoleToJson(instance.role),
      'expiresAt': instance.expiresAt,
      'createdAt': instance.createdAt,
      'link': instance.link,
    };
