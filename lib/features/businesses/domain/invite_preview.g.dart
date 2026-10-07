// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_preview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InvitePreviewImpl _$$InvitePreviewImplFromJson(Map<String, dynamic> json) =>
    _$InvitePreviewImpl(
      email: json['email'] as String,
      businessName: json['businessName'] as String,
      expired: json['expired'] as bool,
      alreadyAccepted: json['alreadyAccepted'] as bool,
    );

Map<String, dynamic> _$$InvitePreviewImplToJson(_$InvitePreviewImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
      'businessName': instance.businessName,
      'expired': instance.expired,
      'alreadyAccepted': instance.alreadyAccepted,
    };
