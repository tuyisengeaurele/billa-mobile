// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OutstandingTotalImpl _$$OutstandingTotalImplFromJson(
        Map<String, dynamic> json) =>
    _$OutstandingTotalImpl(
      currency: currencyFromJson(json['currency']),
      amount: (json['amount'] as num).toInt(),
    );

Map<String, dynamic> _$$OutstandingTotalImplToJson(
        _$OutstandingTotalImpl instance) =>
    <String, dynamic>{
      'currency': currencyToJson(instance.currency),
      'amount': instance.amount,
    };

_$CustomerImpl _$$CustomerImplFromJson(Map<String, dynamic> json) =>
    _$CustomerImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      tin: json['tin'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: json['createdAt'] as String,
      creditLimit: (json['creditLimit'] as num?)?.toInt(),
      portalToken: json['portalToken'] as String?,
      outstandingBalance: (json['outstandingBalance'] as num?)?.toInt() ?? 0,
      outstandingTotals: (json['outstandingTotals'] as List<dynamic>?)
              ?.map((e) => OutstandingTotal.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <OutstandingTotal>[],
    );

Map<String, dynamic> _$$CustomerImplToJson(_$CustomerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'tin': instance.tin,
      'address': instance.address,
      'phone': instance.phone,
      'email': instance.email,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt,
      'creditLimit': instance.creditLimit,
      'portalToken': instance.portalToken,
      'outstandingBalance': instance.outstandingBalance,
      'outstandingTotals': instance.outstandingTotals,
    };
