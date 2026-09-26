import 'package:dio/dio.dart';
import 'response_cache.dart';

/// Keeps the last good copy of each read so the app still has something to
/// show when the phone is offline or the server is waking up. It never touches
/// writes, sign-in, or files, and never hides a real error such as a 404.
class CacheInterceptor extends Interceptor {
  CacheInterceptor({required this.cache, required this.scope});

  final ResponseCache cache;
  final CacheScope scope;

  static const _outageTypes = {
    DioExceptionType.connectionError,
    DioExceptionType.connectionTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.sendTimeout,
  };

  // Render answers these from its proxy while a sleeping service starts.
  static const _wakingStatuses = {502, 503, 504};

  bool _cacheable(RequestOptions options) {
    if (options.method != 'GET') return false;
    if (options.responseType != ResponseType.json) return false;
    final path = options.path;
    return !path.startsWith('/auth/') && !path.startsWith('/uploads');
  }

  String _key(RequestOptions options) {
    final query = options.queryParameters.entries.map((e) => '${e.key}=${e.value}').toList()..sort();
    return '${scope.businessId}|${options.path}?${query.join('&')}';
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;
    final status = response.statusCode ?? 0;
    if (_cacheable(options) && status >= 200 && status < 300 && (response.data is Map || response.data is List)) {
      cache.write(_key(options), CachedResponse(statusCode: status, data: response.data, savedAt: DateTime.now()));
      scope.stale.value = false;
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final outage = _outageTypes.contains(err.type) || _wakingStatuses.contains(err.response?.statusCode);
    if (!_cacheable(options) || !outage) {
      handler.next(err);
      return;
    }
    final saved = await cache.read(_key(options));
    if (saved == null) {
      handler.next(err);
      return;
    }
    scope.stale.value = true;
    handler.resolve(Response<dynamic>(
      requestOptions: options,
      data: saved.data,
      statusCode: saved.statusCode,
      extra: {'fromCache': true},
    ));
  }
}
