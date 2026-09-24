// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentInputImpl _$$PaymentInputImplFromJson(Map<String, dynamic> json) =>
    _$PaymentInputImpl(
      amount: (json['amount'] as num).toInt(),
      method: paymentMethodFromJson(json['method'] as String),
      paidOn: json['paidOn'] as String,
      notes: json['notes'] as String?,
      referenceNumber: json['referenceNumber'] as String?,
      payerName: json['payerName'] as String?,
      receiptImageUrl: json['receiptImageUrl'] as String?,
      generateReceipt: json['generateReceipt'] as bool? ?? false,
    );

Map<String, dynamic> _$$PaymentInputImplToJson(_$PaymentInputImpl instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'method': paymentMethodToJson(instance.method),
      'paidOn': instance.paidOn,
      'notes': instance.notes,
      'referenceNumber': instance.referenceNumber,
      'payerName': instance.payerName,
      'receiptImageUrl': instance.receiptImageUrl,
      'generateReceipt': instance.generateReceipt,
    };
