// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revenue_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MonthlyRevenueImpl _$$MonthlyRevenueImplFromJson(Map<String, dynamic> json) =>
    _$MonthlyRevenueImpl(
      month: json['month'] as String,
      invoiced: (json['invoiced'] as num).toInt(),
      credited: (json['credited'] as num).toInt(),
      net: (json['net'] as num).toInt(),
    );

Map<String, dynamic> _$$MonthlyRevenueImplToJson(
        _$MonthlyRevenueImpl instance) =>
    <String, dynamic>{
      'month': instance.month,
      'invoiced': instance.invoiced,
      'credited': instance.credited,
      'net': instance.net,
    };

_$TopCustomerImpl _$$TopCustomerImplFromJson(Map<String, dynamic> json) =>
    _$TopCustomerImpl(
      customerId: json['customerId'] as String,
      name: json['name'] as String,
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$$TopCustomerImplToJson(_$TopCustomerImpl instance) =>
    <String, dynamic>{
      'customerId': instance.customerId,
      'name': instance.name,
      'total': instance.total,
    };

_$RevenueSummaryImpl _$$RevenueSummaryImplFromJson(Map<String, dynamic> json) =>
    _$RevenueSummaryImpl(
      invoicedThisMonth: (json['invoicedThisMonth'] as num).toInt(),
      invoicedLastMonth: (json['invoicedLastMonth'] as num).toInt(),
      invoicedYearToDate: (json['invoicedYearToDate'] as num).toInt(),
      creditedYearToDate: (json['creditedYearToDate'] as num).toInt(),
      netYearToDate: (json['netYearToDate'] as num).toInt(),
      totalCollected: (json['totalCollected'] as num).toInt(),
      totalOutstanding: (json['totalOutstanding'] as num).toInt(),
      daysSalesOutstanding: (json['daysSalesOutstanding'] as num?)?.toInt(),
      monthlyRevenue: (json['monthlyRevenue'] as List<dynamic>)
          .map((e) => MonthlyRevenue.fromJson(e as Map<String, dynamic>))
          .toList(),
      topCustomers: (json['topCustomers'] as List<dynamic>)
          .map((e) => TopCustomer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$RevenueSummaryImplToJson(
        _$RevenueSummaryImpl instance) =>
    <String, dynamic>{
      'invoicedThisMonth': instance.invoicedThisMonth,
      'invoicedLastMonth': instance.invoicedLastMonth,
      'invoicedYearToDate': instance.invoicedYearToDate,
      'creditedYearToDate': instance.creditedYearToDate,
      'netYearToDate': instance.netYearToDate,
      'totalCollected': instance.totalCollected,
      'totalOutstanding': instance.totalOutstanding,
      'daysSalesOutstanding': instance.daysSalesOutstanding,
      'monthlyRevenue': instance.monthlyRevenue,
      'topCustomers': instance.topCustomers,
    };
