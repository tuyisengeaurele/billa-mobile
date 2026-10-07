// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SessionInfoImpl _$$SessionInfoImplFromJson(Map<String, dynamic> json) =>
    _$SessionInfoImpl(
      id: json['id'] as String,
      deviceName: json['deviceName'] as String?,
      lastUsedAt: json['lastUsedAt'] as String?,
      createdAt: json['createdAt'] as String,
      expiresAt: json['expiresAt'] as String,
      isCurrent: json['isCurrent'] as bool,
    );

Map<String, dynamic> _$$SessionInfoImplToJson(_$SessionInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deviceName': instance.deviceName,
      'lastUsedAt': instance.lastUsedAt,
      'createdAt': instance.createdAt,
      'expiresAt': instance.expiresAt,
      'isCurrent': instance.isCurrent,
    };
