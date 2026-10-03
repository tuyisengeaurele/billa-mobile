import 'dart:async';
import 'package:dio/dio.dart';
import '../error/app_exception.dart';
import 'refresh_session.dart';

// Matches the server's own exempt list in apiClient.ts: a 401 from any of
// these is a normal, expected outcome, not "the session died".
const _exemptPaths = <String>{
  '/auth/session',
  '/auth/refresh',
  '/auth/me',
  '/auth/2fa/challenge',
};

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._dio);

  final Dio _dio;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;
    final alreadyRetried = err.requestOptions.extra['retried'] == true;

    if (statusCode != 401 || _exemptPaths.contains(path) || alreadyRetried) {
      handler.next(err);
      return;
    }

    final refreshed = await _refresh();
    if (!refreshed) {
      handler.next(DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        error: const SessionExpiredException(),
        type: DioExceptionType.badResponse,
      ));
      return;
    }

    try {
      final retryOptions = err.requestOptions;
      retryOptions.extra['retried'] = true;
      final retryResponse = await _dio.fetch(retryOptions);
      handler.resolve(retryResponse);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<bool> _refresh() async {
    try {
      return await refreshOnce(_dio);
    } catch (_) {
      return false;
    }
  }
}
