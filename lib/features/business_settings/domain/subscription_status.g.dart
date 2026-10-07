// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubscriptionStatusImpl _$$SubscriptionStatusImplFromJson(
        Map<String, dynamic> json) =>
    _$SubscriptionStatusImpl(
      plan: json['plan'] as String?,
      trialEndsAt: json['trialEndsAt'] as String?,
      currentPeriodEnd: json['currentPeriodEnd'] as String?,
      activeUntil: json['activeUntil'] as String?,
    );

Map<String, dynamic> _$$SubscriptionStatusImplToJson(
        _$SubscriptionStatusImpl instance) =>
    <String, dynamic>{
      'plan': instance.plan,
      'trialEndsAt': instance.trialEndsAt,
      'currentPeriodEnd': instance.currentPeriodEnd,
      'activeUntil': instance.activeUntil,
    };
