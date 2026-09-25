import 'package:freezed_annotation/freezed_annotation.dart';

part 'revenue_summary.freezed.dart';
part 'revenue_summary.g.dart';

@freezed
class MonthlyRevenue with _$MonthlyRevenue {
  const factory MonthlyRevenue({
    required String month,
    required int invoiced,
    required int credited,
    required int net,
  }) = _MonthlyRevenue;

  factory MonthlyRevenue.fromJson(Map<String, dynamic> json) => _$MonthlyRevenueFromJson(json);
}

@freezed
class TopCustomer with _$TopCustomer {
  const factory TopCustomer({
    required String customerId,
    required String name,
    required int total,
  }) = _TopCustomer;

  factory TopCustomer.fromJson(Map<String, dynamic> json) => _$TopCustomerFromJson(json);
}

@freezed
class RevenueSummary with _$RevenueSummary {
  const RevenueSummary._();

  const factory RevenueSummary({
    required int invoicedThisMonth,
    required int invoicedLastMonth,
    required int invoicedYearToDate,
    required int creditedYearToDate,
    required int netYearToDate,
    required int totalCollected,
    required int totalOutstanding,
    int? daysSalesOutstanding,
    required List<MonthlyRevenue> monthlyRevenue,
    required List<TopCustomer> topCustomers,
  }) = _RevenueSummary;

  factory RevenueSummary.fromJson(Map<String, dynamic> json) => _$RevenueSummaryFromJson(json);

  /// Signed whole-number change against last month, or null when last month
  /// had nothing to compare against (a percentage of zero means nothing).
  int? get monthOverMonthPercent {
    if (invoicedLastMonth == 0) return null;
    return (((invoicedThisMonth - invoicedLastMonth) / invoicedLastMonth) * 100).round();
  }
}
