// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationsPageImpl _$$NotificationsPageImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationsPageImpl(
      results: (json['results'] as List<dynamic>)
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList(),
      unreadCount: (json['unreadCount'] as num).toInt(),
    );

Map<String, dynamic> _$$NotificationsPageImplToJson(
        _$NotificationsPageImpl instance) =>
    <String, dynamic>{
      'results': instance.results,
      'unreadCount': instance.unreadCount,
    };
