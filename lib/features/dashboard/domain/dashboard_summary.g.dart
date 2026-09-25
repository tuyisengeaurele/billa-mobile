// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecentDocumentImpl _$$RecentDocumentImplFromJson(Map<String, dynamic> json) =>
    _$RecentDocumentImpl(
      id: json['id'] as String,
      type: documentTypeFromJson(json['type'] as String),
      number: json['number'] as String?,
      status: documentStatusFromJson(json['status'] as String),
      customerName: json['customerName'] as String,
      issueDate: json['issueDate'] as String,
      paymentStatus: paymentStatusFromJson(json['paymentStatus'] as String?),
    );

Map<String, dynamic> _$$RecentDocumentImplToJson(
        _$RecentDocumentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': documentTypeToJson(instance.type),
      'number': instance.number,
      'status': documentStatusToJson(instance.status),
      'customerName': instance.customerName,
      'issueDate': instance.issueDate,
      'paymentStatus': paymentStatusToJson(instance.paymentStatus),
    };

_$DashboardSummaryImpl _$$DashboardSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$DashboardSummaryImpl(
      draftCount: (json['draftCount'] as num).toInt(),
      overdueInvoiceCount: (json['overdueInvoiceCount'] as num).toInt(),
      expiringQuoteCount: (json['expiringQuoteCount'] as num).toInt(),
      recentDocuments: (json['recentDocuments'] as List<dynamic>)
          .map((e) => RecentDocument.fromJson(e as Map<String, dynamic>))
          .toList(),
      documentsThisMonth: (json['documentsThisMonth'] as num).toInt(),
      documentsLastMonth: (json['documentsLastMonth'] as num).toInt(),
      customerCount: (json['customerCount'] as num).toInt(),
      hasLogo: json['hasLogo'] as bool? ?? false,
    );

Map<String, dynamic> _$$DashboardSummaryImplToJson(
        _$DashboardSummaryImpl instance) =>
    <String, dynamic>{
      'draftCount': instance.draftCount,
      'overdueInvoiceCount': instance.overdueInvoiceCount,
      'expiringQuoteCount': instance.expiringQuoteCount,
      'recentDocuments': instance.recentDocuments,
      'documentsThisMonth': instance.documentsThisMonth,
      'documentsLastMonth': instance.documentsLastMonth,
      'customerCount': instance.customerCount,
      'hasLogo': instance.hasLogo,
    };
