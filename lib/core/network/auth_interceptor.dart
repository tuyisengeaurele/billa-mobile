import 'dart:async';
import 'package:dio/dio.dart';
import '../error/app_exception.dart';

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

  // The refresh token rotates on every use and the server revokes the whole
  // session family if a rotated token is presented twice, so every request
  // waiting on a 401 must await the *same* refresh call, never start its own.
  Completer<bool>? _refreshCompleter;

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

  Future<bool> _refresh() {
    final inFlight = _refreshCompleter;
    if (inFlight != null) return inFlight.future;

    final completer = Completer<bool>();
    _refreshCompleter = completer;

    _dio.post<void>('/auth/refresh').then((_) {
      completer.complete(true);
    }).catchError((_) {
      completer.complete(false);
    }).whenComplete(() {
      _refreshCompleter = null;
    });

    return completer.future;
  }
}
