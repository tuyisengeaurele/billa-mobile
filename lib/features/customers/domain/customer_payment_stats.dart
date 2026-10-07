import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_payment_stats.freezed.dart';
part 'customer_payment_stats.g.dart';

@freezed
class CustomerPaymentStats with _$CustomerPaymentStats {
  const factory CustomerPaymentStats({
    required int paidInvoiceCount,
    int? averageDaysToPay,
    int? onTimeRate,
  }) = _CustomerPaymentStats;

  factory CustomerPaymentStats.fromJson(Map<String, dynamic> json) => _$CustomerPaymentStatsFromJson(json);
}
