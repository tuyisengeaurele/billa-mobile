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
      currency: json['currency'] == null
          ? Currency.rwf
          : currencyFromJson(json['currency']),
      amountOwedRwf: (json['amountOwedRwf'] as num?)?.toInt() ?? 0,
      dueDate: json['dueDate'] as String?,
      amountDue: (json['amountDue'] as num?)?.toInt(),
      nextInstallmentLabel: json['nextInstallmentLabel'] as String?,
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
      'currency': currencyToJson(instance.currency),
      'amountOwedRwf': instance.amountOwedRwf,
      'dueDate': instance.dueDate,
      'amountDue': instance.amountDue,
      'nextInstallmentLabel': instance.nextInstallmentLabel,
      'daysOverdue': instance.daysOverdue,
      'agingBucket': instance.agingBucket,
    };
