import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/active_business_provider.dart';
import '../../domain/dashboard_summary.dart';
import '../../domain/revenue_summary.dart';
import 'dashboard_repository_provider.dart';

// Two providers rather than one combined load: the endpoints are independent,
// so a failure in one must not blank the other section of the home screen.
final dashboardSummaryProvider = FutureProvider.autoDispose<DashboardSummary>((ref) {
  ref.watch(activeBusinessIdProvider);
  return ref.watch(dashboardRepositoryProvider).summary();
});

final revenueProvider = FutureProvider.autoDispose<RevenueSummary>((ref) {
  ref.watch(activeBusinessIdProvider);
  return ref.watch(dashboardRepositoryProvider).revenue();
});
