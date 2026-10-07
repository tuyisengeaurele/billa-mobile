import 'package:dio/dio.dart';
import '../../onboarding/domain/business.dart';
import '../domain/business_summary.dart';
import '../domain/businesses_repository.dart';
import '../domain/invite_preview.dart';
import '../domain/leave_result.dart';

class BusinessesRepositoryImpl implements BusinessesRepository {
  BusinessesRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<BusinessSummary>> list() async {
    final response = await _dio.get<Map<String, dynamic>>('/businesses');
    return (response.data!['businesses'] as List)
        .map((json) => BusinessSummary.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Business> create(String name) async {
    final response = await _dio.post<Map<String, dynamic>>('/businesses', data: {'name': name});
    return Business.fromJson(response.data!['business'] as Map<String, dynamic>);
  }

  @override
  Future<Business> switchTo(String businessId) async {
    final response = await _dio.post<Map<String, dynamic>>('/auth/switch-business', data: {'businessId': businessId});
    return Business.fromJson(response.data!['business'] as Map<String, dynamic>);
  }

  @override
  Future<InvitePreview> previewInvite(String token) async {
    final response = await _dio.get<Map<String, dynamic>>('/invites/${Uri.encodeComponent(token)}');
    return InvitePreview.fromJson(response.data!);
  }

  @override
  Future<Business> acceptInvite(String token) async {
    final response = await _dio.post<Map<String, dynamic>>('/invites/${Uri.encodeComponent(token)}/accept');
    return Business.fromJson(response.data!['business'] as Map<String, dynamic>);
  }

  @override
  Future<LeaveResult> leaveCurrent() async {
    final response = await _dio.post<Map<String, dynamic>>('/business/leave');
    return LeaveResult.fromJson(response.data!);
  }
}
