// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DocumentRefImpl _$$DocumentRefImplFromJson(Map<String, dynamic> json) =>
    _$DocumentRefImpl(
      id: json['id'] as String,
      number: json['number'] as String?,
      type: documentTypeFromJson(json['type'] as String),
    );

Map<String, dynamic> _$$DocumentRefImplToJson(_$DocumentRefImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'type': documentTypeToJson(instance.type),
    };

_$DocumentCustomerRefImpl _$$DocumentCustomerRefImplFromJson(
        Map<String, dynamic> json) =>
    _$DocumentCustomerRefImpl(
      name: json['name'] as String,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$$DocumentCustomerRefImplToJson(
        _$DocumentCustomerRefImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
    };

_$DocumentLineImpl _$$DocumentLineImplFromJson(Map<String, dynamic> json) =>
    _$DocumentLineImpl(
      id: json['id'] as String,
      itemId: json['itemId'] as String?,
      description: json['description'] as String,
      quantity: _decimalFromJson(json['quantity']),
      unitPrice: (json['unitPrice'] as num).toInt(),
      taxRate: _decimalFromJson(json['taxRate']),
      discountType: discountTypeFromJson(json['discountType'] as String?),
      discountValue: _nullableDecimalFromJson(json['discountValue']),
      lineTotal: (json['lineTotal'] as num).toInt(),
      sortOrder: (json['sortOrder'] as num).toInt(),
    );

Map<String, dynamic> _$$DocumentLineImplToJson(_$DocumentLineImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'itemId': instance.itemId,
      'description': instance.description,
      'quantity': _decimalToJson(instance.quantity),
      'unitPrice': instance.unitPrice,
      'taxRate': _decimalToJson(instance.taxRate),
      'discountType': discountTypeToJson(instance.discountType),
      'discountValue': _nullableDecimalToJson(instance.discountValue),
      'lineTotal': instance.lineTotal,
      'sortOrder': instance.sortOrder,
    };

_$DocumentImpl _$$DocumentImplFromJson(Map<String, dynamic> json) =>
    _$DocumentImpl(
      id: json['id'] as String,
      type: documentTypeFromJson(json['type'] as String),
      number: json['number'] as String?,
      status: documentStatusFromJson(json['status'] as String),
      customerId: json['customerId'] as String,
      customer: DocumentCustomerRef.fromJson(
          json['customer'] as Map<String, dynamic>),
      issueDate: json['issueDate'] as String,
      dueDate: json['dueDate'] as String?,
      notes: json['notes'] as String?,
      customerReference: json['customerReference'] as String?,
      subtotal: (json['subtotal'] as num).toInt(),
      taxTotal: (json['taxTotal'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      language: json['language'] == null
          ? DocumentLanguage.en
          : documentLanguageFromJson(json['language'] as String),
      sentAt: json['sentAt'] as String?,
      amountPaid: (json['amountPaid'] as num).toInt(),
      paymentStatus: paymentStatusFromJson(json['paymentStatus'] as String?),
      writtenOffAt: json['writtenOffAt'] as String?,
      writeOffReason: json['writeOffReason'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      convertedFromId: json['convertedFromId'] as String?,
      referencedDocumentId: json['referencedDocumentId'] as String?,
      lines: (json['lines'] as List<dynamic>?)
              ?.map((e) => DocumentLine.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <DocumentLine>[],
      convertedFrom: json['convertedFrom'] == null
          ? null
          : DocumentRef.fromJson(json['convertedFrom'] as Map<String, dynamic>),
      convertedTo: json['convertedTo'] == null
          ? null
          : DocumentRef.fromJson(json['convertedTo'] as Map<String, dynamic>),
      referencedDocument: json['referencedDocument'] == null
          ? null
          : DocumentRef.fromJson(
              json['referencedDocument'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$DocumentImplToJson(_$DocumentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': documentTypeToJson(instance.type),
      'number': instance.number,
      'status': documentStatusToJson(instance.status),
      'customerId': instance.customerId,
      'customer': instance.customer,
      'issueDate': instance.issueDate,
      'dueDate': instance.dueDate,
      'notes': instance.notes,
      'customerReference': instance.customerReference,
      'subtotal': instance.subtotal,
      'taxTotal': instance.taxTotal,
      'total': instance.total,
      'language': documentLanguageToJson(instance.language),
      'sentAt': instance.sentAt,
      'amountPaid': instance.amountPaid,
      'paymentStatus': paymentStatusToJson(instance.paymentStatus),
      'writtenOffAt': instance.writtenOffAt,
      'writeOffReason': instance.writeOffReason,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'convertedFromId': instance.convertedFromId,
      'referencedDocumentId': instance.referencedDocumentId,
      'lines': instance.lines,
      'convertedFrom': instance.convertedFrom,
      'convertedTo': instance.convertedTo,
      'referencedDocument': instance.referencedDocument,
    };
