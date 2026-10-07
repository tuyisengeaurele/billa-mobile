// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'two_factor_setup.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TwoFactorSetupImpl _$$TwoFactorSetupImplFromJson(Map<String, dynamic> json) =>
    _$TwoFactorSetupImpl(
      secret: json['secret'] as String,
      otpauthUrl: json['otpauthUrl'] as String,
      qrCodeDataUri: json['qrCodeDataUri'] as String,
    );

Map<String, dynamic> _$$TwoFactorSetupImplToJson(
        _$TwoFactorSetupImpl instance) =>
    <String, dynamic>{
      'secret': instance.secret,
      'otpauthUrl': instance.otpauthUrl,
      'qrCodeDataUri': instance.qrCodeDataUri,
    };
