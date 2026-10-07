// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BusinessSettingsImpl _$$BusinessSettingsImplFromJson(
        Map<String, dynamic> json) =>
    _$BusinessSettingsImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      tin: json['tin'] as String?,
      industry: json['industry'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      rraEbmNumber: json['rraEbmNumber'] as String?,
      bankName: json['bankName'] as String?,
      bankAccountNumber: json['bankAccountNumber'] as String?,
      signatoryName: json['signatoryName'] as String?,
      signatoryTitle: json['signatoryTitle'] as String?,
      signatureUrl: json['signatureUrl'] as String?,
      logoUrl: json['logoUrl'] as String?,
      primaryColor: json['primaryColor'] as String?,
      accentColors: (json['accentColors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      remindersEnabled: json['remindersEnabled'] as bool? ?? true,
      reminderCadenceDays: (json['reminderCadenceDays'] as num?)?.toInt() ?? 7,
      requireApprovalToFinalize:
          json['requireApprovalToFinalize'] as bool? ?? false,
      defaultTemplate: json['defaultTemplate'] == null
          ? DocumentTemplate.minimal
          : documentTemplateFromJson(json['defaultTemplate'] as String),
    );

Map<String, dynamic> _$$BusinessSettingsImplToJson(
        _$BusinessSettingsImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'tin': instance.tin,
      'industry': instance.industry,
      'phone': instance.phone,
      'email': instance.email,
      'address': instance.address,
      'rraEbmNumber': instance.rraEbmNumber,
      'bankName': instance.bankName,
      'bankAccountNumber': instance.bankAccountNumber,
      'signatoryName': instance.signatoryName,
      'signatoryTitle': instance.signatoryTitle,
      'signatureUrl': instance.signatureUrl,
      'logoUrl': instance.logoUrl,
      'primaryColor': instance.primaryColor,
      'accentColors': instance.accentColors,
      'remindersEnabled': instance.remindersEnabled,
      'reminderCadenceDays': instance.reminderCadenceDays,
      'requireApprovalToFinalize': instance.requireApprovalToFinalize,
      'defaultTemplate': documentTemplateToJson(instance.defaultTemplate),
    };
