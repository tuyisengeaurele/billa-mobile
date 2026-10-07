import 'package:freezed_annotation/freezed_annotation.dart';
import 'document_enums.dart';

part 'payment.freezed.dart';
part 'payment.g.dart';

@freezed
class Payment with _$Payment {
  const factory Payment({
    required String id,
    required int amount,
    @JsonKey(fromJson: paymentMethodFromJson, toJson: paymentMethodToJson) required PaymentMethod method,
    required String paidOn,
    String? notes,
    String? referenceNumber,
    String? payerName,
    String? receiptImageUrl,
    String? receiptDocumentId,
    String? voidedAt,
    String? voidReason,
    required String createdAt,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);
}
