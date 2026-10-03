import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/formatting/currency.dart';

part 'outstanding_invoice.freezed.dart';
part 'outstanding_invoice.g.dart';

@freezed
class OutstandingInvoice with _$OutstandingInvoice {
  const factory OutstandingInvoice({
    required String id,
    String? number,
    required String customerName,
    required int total,
    required int amountOwed,
    @JsonKey(fromJson: currencyFromJson, toJson: currencyToJson) @Default(Currency.rwf) Currency currency,
    @Default(0) int amountOwedRwf,
    String? dueDate,
    // What is payable today when the invoice is on an instalment plan, and which instalment that is.
    int? amountDue,
    String? nextInstallmentLabel,
    required int daysOverdue,
    required String agingBucket,
  }) = _OutstandingInvoice;

  factory OutstandingInvoice.fromJson(Map<String, dynamic> json) => _$OutstandingInvoiceFromJson(json);
}
