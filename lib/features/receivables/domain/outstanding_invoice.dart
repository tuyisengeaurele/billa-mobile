import 'package:freezed_annotation/freezed_annotation.dart';

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
    String? dueDate,
    required int daysOverdue,
    required String agingBucket,
  }) = _OutstandingInvoice;

  factory OutstandingInvoice.fromJson(Map<String, dynamic> json) => _$OutstandingInvoiceFromJson(json);
}
