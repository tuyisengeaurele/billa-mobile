import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/formatting/currency.dart';

part 'customer.freezed.dart';
part 'customer.g.dart';

/// What a customer owes in one currency, from their unpaid finalized invoices.
@freezed
class OutstandingTotal with _$OutstandingTotal {
  const factory OutstandingTotal({
    @JsonKey(fromJson: currencyFromJson, toJson: currencyToJson) required Currency currency,
    required int amount,
  }) = _OutstandingTotal;

  factory OutstandingTotal.fromJson(Map<String, dynamic> json) => _$OutstandingTotalFromJson(json);
}

@freezed
class Customer with _$Customer {
  const factory Customer({
    required String id,
    required String name,
    String? tin,
    String? address,
    String? phone,
    String? email,
    required bool isActive,
    required String createdAt,
    // Whole RWF; only a warning on new invoices, never a block.
    int? creditLimit,
    String? portalToken,
    // Only the single-customer response carries these two.
    @Default(0) int outstandingBalance,
    @Default(<OutstandingTotal>[]) List<OutstandingTotal> outstandingTotals,
  }) = _Customer;

  factory Customer.fromJson(Map<String, dynamic> json) => _$CustomerFromJson(json);
}
