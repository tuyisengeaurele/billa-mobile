// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppNotificationImpl _$$AppNotificationImplFromJson(
        Map<String, dynamic> json) =>
    _$AppNotificationImpl(
      id: json['id'] as String,
      type: _typeFromJson(json['type'] as String?),
      title: json['title'] as String,
      body: json['body'] as String?,
      link: json['link'] as String?,
      readAt: json['readAt'] as String?,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$$AppNotificationImplToJson(
        _$AppNotificationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _typeToJson(instance.type),
      'title': instance.title,
      'body': instance.body,
      'link': instance.link,
      'readAt': instance.readAt,
      'createdAt': instance.createdAt,
    };
