// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentImpl _$$PaymentImplFromJson(Map<String, dynamic> json) =>
    _$PaymentImpl(
      id: json['id'] as String,
      amount: (json['amount'] as num).toInt(),
      method: paymentMethodFromJson(json['method'] as String),
      paidOn: json['paidOn'] as String,
      notes: json['notes'] as String?,
      referenceNumber: json['referenceNumber'] as String?,
      payerName: json['payerName'] as String?,
      receiptImageUrl: json['receiptImageUrl'] as String?,
      receiptDocumentId: json['receiptDocumentId'] as String?,
      voidedAt: json['voidedAt'] as String?,
      voidReason: json['voidReason'] as String?,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$$PaymentImplToJson(_$PaymentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'method': paymentMethodToJson(instance.method),
      'paidOn': instance.paidOn,
      'notes': instance.notes,
      'referenceNumber': instance.referenceNumber,
      'payerName': instance.payerName,
      'receiptImageUrl': instance.receiptImageUrl,
      'receiptDocumentId': instance.receiptDocumentId,
      'voidedAt': instance.voidedAt,
      'voidReason': instance.voidReason,
      'createdAt': instance.createdAt,
    };
