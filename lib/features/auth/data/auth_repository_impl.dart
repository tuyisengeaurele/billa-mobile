import 'package:dio/dio.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_status.dart';
import '../domain/auth_user.dart';
import '../../onboarding/domain/business.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dio);

  final Dio _dio;

  AuthStatus _statusFromSessionResponse(Map<String, dynamic> data) {
    if (data['twoFactorRequired'] == true) {
      return AuthStatus.twoFactorRequired(data['challengeId'] as String);
    }
    return AuthStatus.authenticated(
      AuthUser.fromJson(data['user'] as Map<String, dynamic>),
      Business.fromJson(data['business'] as Map<String, dynamic>),
    );
  }

  @override
  Future<AuthStatus> exchangeSession({required String idToken, String? businessName}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/session',
      data: businessName == null ? {'idToken': idToken} : {'idToken': idToken, 'businessName': businessName},
    );
    return _statusFromSessionResponse(response.data!);
  }

  @override
  Future<AuthStatus> me() async {
    try {
      return await _fetchMe();
    } on DioException catch (e) {
      if (e.response?.statusCode != 401) rethrow;
    }
    // The access token only lives 15 minutes, so a 401 here usually means it
    // lapsed while the app was closed, not that the user signed out. The
    // refresh token (valid for weeks) decides that.
    if (!await refreshSession()) return const AuthStatus.unauthenticated();
    try {
      return await _fetchMe();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return const AuthStatus.unauthenticated();
      rethrow;
    }
  }

  Future<AuthStatus> _fetchMe() async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/me');
    return _statusFromSessionResponse(response.data!);
  }

  @override
  Future<bool> refreshSession() async {
    try {
      await _dio.post<void>('/auth/refresh');
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return false;
      rethrow;
    }
  }

  @override
  Future<AuthStatus> submitTwoFactorChallenge({required String challengeId, required String code}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/2fa/challenge',
      data: {'challengeId': challengeId, 'code': code},
    );
    return _statusFromSessionResponse(response.data!);
  }

  @override
  Future<void> logout() async {
    await _dio.post<void>('/auth/logout');
  }
}
