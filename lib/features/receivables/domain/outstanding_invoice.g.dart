// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outstanding_invoice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OutstandingInvoiceImpl _$$OutstandingInvoiceImplFromJson(
        Map<String, dynamic> json) =>
    _$OutstandingInvoiceImpl(
      id: json['id'] as String,
      number: json['number'] as String?,
      customerName: json['customerName'] as String,
      total: (json['total'] as num).toInt(),
      amountOwed: (json['amountOwed'] as num).toInt(),
      dueDate: json['dueDate'] as String?,
      daysOverdue: (json['daysOverdue'] as num).toInt(),
      agingBucket: json['agingBucket'] as String,
    );

Map<String, dynamic> _$$OutstandingInvoiceImplToJson(
        _$OutstandingInvoiceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'customerName': instance.customerName,
      'total': instance.total,
      'amountOwed': instance.amountOwed,
      'dueDate': instance.dueDate,
      'daysOverdue': instance.daysOverdue,
      'agingBucket': instance.agingBucket,
    };
