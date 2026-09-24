import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/error/app_exception.dart';
import 'package:billa_mobile/core/network/auth_interceptor.dart';

typedef Behavior = ResponseBody Function(RequestOptions options, int callIndexForPath);

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this.behavior);

  final Behavior behavior;
  final Map<String, int> callCounts = {};

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    // A small delay lets concurrent requests actually overlap in the test,
    // which is what proves the single-flight guard rather than luck.
    await Future.delayed(const Duration(milliseconds: 5));
    final count = (callCounts[options.path] ?? 0) + 1;
    callCounts[options.path] = count;
    return behavior(options, count);
  }
}

ResponseBody _json(int statusCode, Map<String, dynamic> body) {
  return ResponseBody.fromString(jsonEncode(body), statusCode, headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  });
}

Dio _buildDio(_RecordingAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://billa.test'));
  dio.httpClientAdapter = adapter;
  dio.interceptors.add(AuthInterceptor(dio));
  return dio;
}

void main() {
  test('a single 401 triggers exactly one refresh and one retry', () async {
    final adapter = _RecordingAdapter((options, count) {
      if (options.path == '/documents') {
        return count == 1 ? _json(401, {}) : _json(200, {'ok': true});
      }
      return _json(200, {'ok': true}); // /auth/refresh
    });
    final dio = _buildDio(adapter);

    final response = await dio.get('/documents');

    expect(response.statusCode, 200);
    expect(adapter.callCounts['/documents'], 2);
    expect(adapter.callCounts['/auth/refresh'], 1);
  });

  test('two concurrent 401s share a single refresh call', () async {
    final adapter = _RecordingAdapter((options, count) {
      if (options.path == '/documents') {
        return count <= 2 ? _json(401, {}) : _json(200, {'ok': true});
      }
      return _json(200, {'ok': true}); // /auth/refresh
    });
    final dio = _buildDio(adapter);

    final results = await Future.wait([dio.get('/documents'), dio.get('/documents')]);

    expect(results[0].statusCode, 200);
    expect(results[1].statusCode, 200);
    expect(adapter.callCounts['/auth/refresh'], 1);
  });

  test('a failed refresh surfaces SessionExpiredException and does not retry', () async {
    final adapter = _RecordingAdapter((options, count) {
      if (options.path == '/documents') return _json(401, {});
      return _json(401, {}); // /auth/refresh also fails
    });
    final dio = _buildDio(adapter);

    await expectLater(
      dio.get('/documents'),
      throwsA(isA<DioException>().having((e) => e.error, 'error', isA<SessionExpiredException>())),
    );
    expect(adapter.callCounts['/documents'], 1);
    expect(adapter.callCounts['/auth/refresh'], 1);
  });

  test('a 401 on an exempt path is left untouched, no refresh attempted', () async {
    final adapter = _RecordingAdapter((options, count) => _json(401, {}));
    final dio = _buildDio(adapter);

    await expectLater(
      dio.get('/auth/me'),
      throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'status', 401)),
    );
    expect(adapter.callCounts['/auth/refresh'], isNull);
  });
}
