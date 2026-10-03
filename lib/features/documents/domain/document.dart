import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/formatting/currency.dart';
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
class DocumentInstallment with _$DocumentInstallment {
  const factory DocumentInstallment({String? label, required int amount, required String dueDate}) =
      _DocumentInstallment;

  factory DocumentInstallment.fromJson(Map<String, dynamic> json) => _$DocumentInstallmentFromJson(json);
}

/// The step of a payment plan the customer should pay next, as the server works it out from what is paid.
@freezed
class DocumentNextInstallment with _$DocumentNextInstallment {
  const factory DocumentNextInstallment({String? label, required int remaining, required String dueDate, int? number}) =
      _DocumentNextInstallment;

  factory DocumentNextInstallment.fromJson(Map<String, dynamic> json) => _$DocumentNextInstallmentFromJson(json);
}

/// One step of a payment plan with how much of it the payments recorded so far have covered.
@freezed
class DocumentScheduleStep with _$DocumentScheduleStep {
  const factory DocumentScheduleStep({
    String? label,
    required int amount,
    required String dueDate,
    required int paid,
    required int remaining,
    // PAID, PARTIALLY_PAID, OVERDUE or UNPAID, as the server works it out.
    required String status,
    required int number,
  }) = _DocumentScheduleStep;

  factory DocumentScheduleStep.fromJson(Map<String, dynamic> json) => _$DocumentScheduleStepFromJson(json);
}

@freezed
class DocumentBusinessRef with _$DocumentBusinessRef {
  const factory DocumentBusinessRef({@Default(false) bool momoEnabled}) = _DocumentBusinessRef;

  factory DocumentBusinessRef.fromJson(Map<String, dynamic> json) => _$DocumentBusinessRefFromJson(json);
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
    @JsonKey(fromJson: currencyFromJson, toJson: currencyToJson) @Default(Currency.rwf) Currency currency,
    @JsonKey(fromJson: rateFromJson) double? exchangeRate,
    @Default(<DocumentInstallment>[]) List<DocumentInstallment> installments,
    String? recurrenceInterval,
    String? recurrenceEndDate,
    String? nextRecurrenceAt,
    DocumentNextInstallment? nextInstallment,
    @Default(<DocumentScheduleStep>[]) List<DocumentScheduleStep> schedule,
    DocumentBusinessRef? business,
    @JsonKey(fromJson: documentLanguageFromJson, toJson: documentLanguageToJson)
    @Default(DocumentLanguage.en)
    DocumentLanguage language,
    String? sentAt,
    // When the customer opened the public page: first, last, and how many times, as the server counts them.
    String? firstViewedAt,
    String? lastViewedAt,
    @Default(0) int viewCount,
    String? publicToken,
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
