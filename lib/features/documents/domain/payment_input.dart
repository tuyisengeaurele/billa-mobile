import 'package:freezed_annotation/freezed_annotation.dart';
import 'document_enums.dart';

part 'payment_input.freezed.dart';
part 'payment_input.g.dart';

// Empty optional fields are left out: the API rejects an explicit null for them.
@freezed
class PaymentInput with _$PaymentInput {
  @JsonSerializable(includeIfNull: false)
  const factory PaymentInput({
    required int amount,
    @JsonKey(fromJson: paymentMethodFromJson, toJson: paymentMethodToJson) required PaymentMethod method,
    required String paidOn,
    String? notes,
    String? referenceNumber,
    String? payerName,
    String? receiptImageUrl,
    @Default(false) bool generateReceipt,
  }) = _PaymentInput;

  factory PaymentInput.fromJson(Map<String, dynamic> json) => _$PaymentInputFromJson(json);
}
