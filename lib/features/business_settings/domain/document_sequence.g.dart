// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_sequence.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DocumentSequenceImpl _$$DocumentSequenceImplFromJson(
        Map<String, dynamic> json) =>
    _$DocumentSequenceImpl(
      type: documentTypeFromJson(json['type'] as String),
      prefix: json['prefix'] as String,
      nextNumber: (json['nextNumber'] as num).toInt(),
      resetYearly: json['resetYearly'] as bool,
    );

Map<String, dynamic> _$$DocumentSequenceImplToJson(
        _$DocumentSequenceImpl instance) =>
    <String, dynamic>{
      'type': documentTypeToJson(instance.type),
      'prefix': instance.prefix,
      'nextNumber': instance.nextNumber,
      'resetYearly': instance.resetYearly,
    };
