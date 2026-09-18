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
        _$DocumentLineInputImpl instance) =>
    <String, dynamic>{
      'itemId': instance.itemId,
      'description': instance.description,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'taxRate': instance.taxRate,
      'discountType': discountTypeToJson(instance.discountType),
      'discountValue': instance.discountValue,
    };

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
      lines: (json['lines'] as List<dynamic>?)
              ?.map(
                  (e) => DocumentLineInput.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <DocumentLineInput>[],
    );

Map<String, dynamic> _$$DocumentDraftInputImplToJson(
        _$DocumentDraftInputImpl instance) =>
    <String, dynamic>{
      'type': documentTypeToJson(instance.type),
      'customerId': instance.customerId,
      'issueDate': instance.issueDate,
      'dueDate': instance.dueDate,
      'notes': instance.notes,
      'customerReference': instance.customerReference,
      'referencedDocumentId': instance.referencedDocumentId,
      'language': documentLanguageToJson(instance.language),
      'lines': instance.lines.map((e) => e.toJson()).toList(),
    };
