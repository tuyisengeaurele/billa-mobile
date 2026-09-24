// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LeaveResultImpl _$$LeaveResultImplFromJson(Map<String, dynamic> json) =>
    _$LeaveResultImpl(
      business: Business.fromJson(json['business'] as Map<String, dynamic>),
      createdReplacement: json['createdReplacement'] as bool,
    );

Map<String, dynamic> _$$LeaveResultImplToJson(_$LeaveResultImpl instance) =>
    <String, dynamic>{
      'business': instance.business,
      'createdReplacement': instance.createdReplacement,
    };
