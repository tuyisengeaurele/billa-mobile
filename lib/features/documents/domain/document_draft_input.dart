import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/formatting/currency.dart';
import 'document_enums.dart';

part 'document_draft_input.freezed.dart';
part 'document_draft_input.g.dart';

// The API treats an absent optional field as "not set" but rejects an explicit
// null for most of them, so empty fields are left out of the request.
@freezed
class DocumentLineInput with _$DocumentLineInput {
  @JsonSerializable(includeIfNull: false)
  const factory DocumentLineInput({
    String? itemId,
    required String description,
    required double quantity,
    required int unitPrice,
    required double taxRate,
    @JsonKey(fromJson: discountTypeFromJson, toJson: discountTypeToJson) DiscountType? discountType,
    double? discountValue,
  }) = _DocumentLineInput;

  factory DocumentLineInput.fromJson(Map<String, dynamic> json) => _$DocumentLineInputFromJson(json);
}

@freezed
class InstallmentInput with _$InstallmentInput {
  @JsonSerializable(includeIfNull: false)
  const factory InstallmentInput({String? label, required int amount, required String dueDate}) = _InstallmentInput;

  factory InstallmentInput.fromJson(Map<String, dynamic> json) => _$InstallmentInputFromJson(json);
}

@freezed
class RecurrenceInput with _$RecurrenceInput {
  @JsonSerializable(includeIfNull: false)
  const factory RecurrenceInput({required String interval, String? endDate}) = _RecurrenceInput;

  factory RecurrenceInput.fromJson(Map<String, dynamic> json) => _$RecurrenceInputFromJson(json);
}

@freezed
class DocumentDraftInput with _$DocumentDraftInput {
  // Without this, toJson() leaves nested DocumentLineInput objects
  // unconverted (relying on dart:convert's jsonEncode to call their own
  // toJson() later), fine for Dio in practice, but it means toJson()'s
  // own return value can't be inspected as plain maps, which the tests do.
  @JsonSerializable(explicitToJson: true, includeIfNull: false)
  const factory DocumentDraftInput({
    @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson) required DocumentType type,
    required String customerId,
    required String issueDate,
    String? dueDate,
    String? notes,
    String? customerReference,
    String? referencedDocumentId,
    @JsonKey(fromJson: documentLanguageFromJson, toJson: documentLanguageToJson)
    @Default(DocumentLanguage.en)
    DocumentLanguage language,
    @JsonKey(fromJson: currencyFromJson, toJson: currencyToJson) @Default(Currency.rwf) Currency currency,
    double? exchangeRate,
    List<InstallmentInput>? installments,
    RecurrenceInput? recurrence,
    @Default(<DocumentLineInput>[]) List<DocumentLineInput> lines,
  }) = _DocumentDraftInput;

  factory DocumentDraftInput.fromJson(Map<String, dynamic> json) => _$DocumentDraftInputFromJson(json);
}
