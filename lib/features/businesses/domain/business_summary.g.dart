// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BusinessSummaryImpl _$$BusinessSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$BusinessSummaryImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      isOwner: json['isOwner'] as bool,
    );

Map<String, dynamic> _$$BusinessSummaryImplToJson(
        _$BusinessSummaryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'isOwner': instance.isOwner,
    };
