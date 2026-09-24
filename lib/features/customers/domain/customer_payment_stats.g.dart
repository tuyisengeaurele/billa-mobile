// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_payment_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomerPaymentStatsImpl _$$CustomerPaymentStatsImplFromJson(
        Map<String, dynamic> json) =>
    _$CustomerPaymentStatsImpl(
      paidInvoiceCount: (json['paidInvoiceCount'] as num).toInt(),
      averageDaysToPay: (json['averageDaysToPay'] as num?)?.toInt(),
      onTimeRate: (json['onTimeRate'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$CustomerPaymentStatsImplToJson(
        _$CustomerPaymentStatsImpl instance) =>
    <String, dynamic>{
      'paidInvoiceCount': instance.paidInvoiceCount,
      'averageDaysToPay': instance.averageDaysToPay,
      'onTimeRate': instance.onTimeRate,
    };
