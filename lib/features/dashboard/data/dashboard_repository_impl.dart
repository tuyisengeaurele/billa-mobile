import 'package:dio/dio.dart';
import '../domain/dashboard_repository.dart';
import '../domain/dashboard_summary.dart';
import '../domain/revenue_summary.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<DashboardSummary> summary() async {
    final response = await _dio.get<Map<String, dynamic>>('/dashboard/summary');
    return DashboardSummary.fromJson(response.data!);
  }

  @override
  Future<RevenueSummary> revenue() async {
    final response = await _dio.get<Map<String, dynamic>>('/dashboard/revenue');
    return RevenueSummary.fromJson(response.data!);
  }
}
