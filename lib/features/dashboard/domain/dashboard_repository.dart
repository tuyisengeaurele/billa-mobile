import 'dashboard_summary.dart';
import 'revenue_summary.dart';

abstract class DashboardRepository {
  Future<DashboardSummary> summary();
  Future<RevenueSummary> revenue();
}
