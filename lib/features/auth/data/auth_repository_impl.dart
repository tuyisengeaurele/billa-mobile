import 'package:dio/dio.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/network/refresh_session.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_status.dart';
import '../domain/auth_user.dart';
import '../../onboarding/domain/business.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dio);

  final Dio _dio;

  // An admin-only account has no business, and the app is built around one.
  // By the time this reply arrives the server has already set the session
  // cookies, so they are ended here or the next launch would restore a
  // session the app cannot show.
  Future<AuthStatus> _statusFromSessionResponse(Map<String, dynamic> data) async {
    if (data['twoFactorRequired'] == true) {
      return AuthStatus.twoFactorRequired(data['challengeId'] as String);
    }
    final business = data['business'];
    if (business == null) {
      try {
        await _dio.post<void>('/auth/logout');
      } catch (_) {
        // Refusing the sign-in matters more than ending the cookies cleanly.
      }
      throw const AdminOnlyAccountException();
    }
    return AuthStatus.authenticated(
      AuthUser.fromJson(data['user'] as Map<String, dynamic>),
      Business.fromJson(business as Map<String, dynamic>),
    );
  }

  @override
  Future<AuthStatus> exchangeSession({required String idToken, String? businessName}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/session',
      data: businessName == null ? {'idToken': idToken} : {'idToken': idToken, 'businessName': businessName},
    );
    return await _statusFromSessionResponse(response.data!);
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
    try {
      return await _statusFromSessionResponse(response.data!);
    } on AdminOnlyAccountException {
      return const AuthStatus.unauthenticated();
    }
  }

  @override
  Future<bool> refreshSession() => refreshOnce(_dio);

  @override
  Future<AuthStatus> submitTwoFactorChallenge({required String challengeId, required String code}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/2fa/challenge',
      data: {'challengeId': challengeId, 'code': code},
    );
    return await _statusFromSessionResponse(response.data!);
  }

  @override
  Future<void> logout() async {
    await _dio.post<void>('/auth/logout');
  }
}
