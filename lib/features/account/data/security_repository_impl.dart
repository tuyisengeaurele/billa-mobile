import 'package:dio/dio.dart';
import '../domain/security_repository.dart';
import '../domain/session_info.dart';
import '../domain/two_factor_setup.dart';

class SecurityRepositoryImpl implements SecurityRepository {
  SecurityRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<TwoFactorSetup> setUpTwoFactor() async {
    final response = await _dio.post<Map<String, dynamic>>('/auth/2fa/setup');
    return TwoFactorSetup.fromJson(response.data!);
  }

  @override
  Future<List<String>> verifyTwoFactor(String code) async {
    final response = await _dio.post<Map<String, dynamic>>('/auth/2fa/verify', data: {'code': code});
    return (response.data!['backupCodes'] as List).cast<String>();
  }

  @override
  Future<void> disableTwoFactor(String code) async {
    await _dio.post<Map<String, dynamic>>('/auth/2fa/disable', data: {'code': code});
  }

  @override
  Future<List<SessionInfo>> sessions() async {
    final response = await _dio.get<Map<String, dynamic>>('/profile/sessions');
    return (response.data!['results'] as List)
        .map((json) => SessionInfo.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> revokeSession(String id) async {
    await _dio.post<Map<String, dynamic>>('/profile/sessions/$id/revoke');
  }

  @override
  Future<void> revokeOtherSessions() async {
    await _dio.post<Map<String, dynamic>>('/profile/sessions/revoke-others');
  }

  @override
  Future<void> deleteAccount() async {
    await _dio.delete<Map<String, dynamic>>('/auth/me');
  }
}
