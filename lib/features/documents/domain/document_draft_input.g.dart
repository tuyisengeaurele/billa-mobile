// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_draft_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DocumentLineInputImpl _$$DocumentLineInputImplFromJson(
        Map<String, dynamic> json) =>
    _$DocumentLineInputImpl(
      itemId: json['itemId'] as String?,
      description: json['description'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toInt(),
      taxRate: (json['taxRate'] as num).toDouble(),
      discountType: discountTypeFromJson(json['discountType'] as String?),
      discountValue: (json['discountValue'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$DocumentLineInputImplToJson(
    _$DocumentLineInputImpl instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('itemId', instance.itemId);
  val['description'] = instance.description;
  val['quantity'] = instance.quantity;
  val['unitPrice'] = instance.unitPrice;
  val['taxRate'] = instance.taxRate;
  writeNotNull('discountType', discountTypeToJson(instance.discountType));
  writeNotNull('discountValue', instance.discountValue);
  return val;
}

_$InstallmentInputImpl _$$InstallmentInputImplFromJson(
        Map<String, dynamic> json) =>
    _$InstallmentInputImpl(
      label: json['label'] as String?,
      amount: (json['amount'] as num).toInt(),
      dueDate: json['dueDate'] as String,
    );

Map<String, dynamic> _$$InstallmentInputImplToJson(
    _$InstallmentInputImpl instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('label', instance.label);
  val['amount'] = instance.amount;
  val['dueDate'] = instance.dueDate;
  return val;
}

_$RecurrenceInputImpl _$$RecurrenceInputImplFromJson(
        Map<String, dynamic> json) =>
    _$RecurrenceInputImpl(
      interval: json['interval'] as String,
      endDate: json['endDate'] as String?,
    );

Map<String, dynamic> _$$RecurrenceInputImplToJson(
    _$RecurrenceInputImpl instance) {
  final val = <String, dynamic>{
    'interval': instance.interval,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('endDate', instance.endDate);
  return val;
}

_$DocumentDraftInputImpl _$$DocumentDraftInputImplFromJson(
        Map<String, dynamic> json) =>
    _$DocumentDraftInputImpl(
      type: documentTypeFromJson(json['type'] as String),
      customerId: json['customerId'] as String,
      issueDate: json['issueDate'] as String,
      dueDate: json['dueDate'] as String?,
      notes: json['notes'] as String?,
      customerReference: json['customerReference'] as String?,
      referencedDocumentId: json['referencedDocumentId'] as String?,
      language: json['language'] == null
          ? DocumentLanguage.en
          : documentLanguageFromJson(json['language'] as String),
      currency: json['currency'] == null
          ? Currency.rwf
          : currencyFromJson(json['currency']),
      exchangeRate: (json['exchangeRate'] as num?)?.toDouble(),
      installments: (json['installments'] as List<dynamic>?)
          ?.map((e) => InstallmentInput.fromJson(e as Map<String, dynamic>))
          .toList(),
      recurrence: json['recurrence'] == null
          ? null
          : RecurrenceInput.fromJson(
              json['recurrence'] as Map<String, dynamic>),
      lines: (json['lines'] as List<dynamic>?)
              ?.map(
                  (e) => DocumentLineInput.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <DocumentLineInput>[],
    );

Map<String, dynamic> _$$DocumentDraftInputImplToJson(
    _$DocumentDraftInputImpl instance) {
  final val = <String, dynamic>{
    'type': documentTypeToJson(instance.type),
    'customerId': instance.customerId,
    'issueDate': instance.issueDate,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('dueDate', instance.dueDate);
  writeNotNull('notes', instance.notes);
  writeNotNull('customerReference', instance.customerReference);
  writeNotNull('referencedDocumentId', instance.referencedDocumentId);
  val['language'] = documentLanguageToJson(instance.language);
  val['currency'] = currencyToJson(instance.currency);
  writeNotNull('exchangeRate', instance.exchangeRate);
  writeNotNull(
      'installments', instance.installments?.map((e) => e.toJson()).toList());
  writeNotNull('recurrence', instance.recurrence?.toJson());
  val['lines'] = instance.lines.map((e) => e.toJson()).toList();
  return val;
}
