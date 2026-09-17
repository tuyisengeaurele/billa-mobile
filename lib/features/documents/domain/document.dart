import 'package:freezed_annotation/freezed_annotation.dart';
import 'document_enums.dart';

part 'document.freezed.dart';
part 'document.g.dart';

double _decimalFromJson(dynamic value) => double.parse(value as String);
String _decimalToJson(double value) => value.toStringAsFixed(2);

double? _nullableDecimalFromJson(dynamic value) {
  if (value == null) return null;
  return double.parse(value as String);
}

String? _nullableDecimalToJson(double? value) => value?.toStringAsFixed(2);

@freezed
class DocumentRef with _$DocumentRef {
  const factory DocumentRef({
    required String id,
    String? number,
    @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson) required DocumentType type,
  }) = _DocumentRef;

  factory DocumentRef.fromJson(Map<String, dynamic> json) => _$DocumentRefFromJson(json);
}

@freezed
class DocumentCustomerRef with _$DocumentCustomerRef {
  const factory DocumentCustomerRef({
    required String name,
    String? email,
  }) = _DocumentCustomerRef;

  factory DocumentCustomerRef.fromJson(Map<String, dynamic> json) => _$DocumentCustomerRefFromJson(json);
}

@freezed
class DocumentLine with _$DocumentLine {
  const factory DocumentLine({
    required String id,
    String? itemId,
    required String description,
    @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) required double quantity,
    required int unitPrice,
    @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) required double taxRate,
    @JsonKey(fromJson: discountTypeFromJson, toJson: discountTypeToJson) DiscountType? discountType,
    @JsonKey(fromJson: _nullableDecimalFromJson, toJson: _nullableDecimalToJson) double? discountValue,
    required int lineTotal,
    required int sortOrder,
  }) = _DocumentLine;

  factory DocumentLine.fromJson(Map<String, dynamic> json) => _$DocumentLineFromJson(json);
}

@freezed
class Document with _$Document {
  const factory Document({
    required String id,
    @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson) required DocumentType type,
    String? number,
    @JsonKey(fromJson: documentStatusFromJson, toJson: documentStatusToJson) required DocumentStatus status,
    required String customerId,
    required DocumentCustomerRef customer,
    required String issueDate,
    String? dueDate,
    String? notes,
    String? customerReference,
    required int subtotal,
    required int taxTotal,
    required int total,
    String? sentAt,
    required int amountPaid,
    @JsonKey(fromJson: paymentStatusFromJson, toJson: paymentStatusToJson) PaymentStatus? paymentStatus,
    String? writtenOffAt,
    String? writeOffReason,
    required String createdAt,
    required String updatedAt,
    String? convertedFromId,
    String? referencedDocumentId,
    @Default(<DocumentLine>[]) List<DocumentLine> lines,
    DocumentRef? convertedFrom,
    DocumentRef? convertedTo,
    DocumentRef? referencedDocument,
  }) = _Document;

  factory Document.fromJson(Map<String, dynamic> json) => _$DocumentFromJson(json);
}
