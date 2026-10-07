// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BusinessImpl _$$BusinessImplFromJson(Map<String, dynamic> json) =>
    _$BusinessImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      tin: json['tin'] as String?,
      industry: json['industry'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      rraEbmNumber: json['rraEbmNumber'] as String?,
      logoUrl: json['logoUrl'] as String?,
      primaryColor: json['primaryColor'] as String?,
      accentColors: (json['accentColors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      onboardingCompletedAt: json['onboardingCompletedAt'] as String?,
    );

Map<String, dynamic> _$$BusinessImplToJson(_$BusinessImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'tin': instance.tin,
      'industry': instance.industry,
      'phone': instance.phone,
      'email': instance.email,
      'address': instance.address,
      'rraEbmNumber': instance.rraEbmNumber,
      'logoUrl': instance.logoUrl,
      'primaryColor': instance.primaryColor,
      'accentColors': instance.accentColors,
      'onboardingCompletedAt': instance.onboardingCompletedAt,
    };
