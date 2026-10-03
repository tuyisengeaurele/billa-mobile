// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActivityActorImpl _$$ActivityActorImplFromJson(Map<String, dynamic> json) =>
    _$ActivityActorImpl(
      name: json['name'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$$ActivityActorImplToJson(_$ActivityActorImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
    };

_$ActivityEntryImpl _$$ActivityEntryImplFromJson(Map<String, dynamic> json) =>
    _$ActivityEntryImpl(
      id: json['id'] as String,
      action: json['action'] as String,
      entityType: json['entityType'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] as String,
      actor: json['actor'] == null
          ? null
          : ActivityActor.fromJson(json['actor'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ActivityEntryImplToJson(_$ActivityEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'action': instance.action,
      'entityType': instance.entityType,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt,
      'actor': instance.actor,
    };
