// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ItemImpl _$$ItemImplFromJson(Map<String, dynamic> json) => _$ItemImpl(
      id: json['id'] as String,
      description: json['description'] as String,
      unitPrice: (json['unitPrice'] as num).toInt(),
      unit: json['unit'] as String,
      taxRate: (json['taxRate'] as num).toDouble(),
      category: json['category'] as String?,
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$$ItemImplToJson(_$ItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'unitPrice': instance.unitPrice,
      'unit': instance.unit,
      'taxRate': instance.taxRate,
      'category': instance.category,
      'isActive': instance.isActive,
    };
