import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/network/cache_interceptor.dart';
import 'package:billa_mobile/core/network/response_cache.dart';

/// Answers from a script: each call pops the next behaviour, so a test can say
/// "succeed, then lose the connection".
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.script);

  final List<Object> script;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    calls++;
    final next = script.removeAt(0);
    if (next is DioExceptionType) {
      throw DioException(requestOptions: options, type: next);
    }
    final status = next as int;
    return ResponseBody.fromString(
      status == 200 ? '{"n": $calls}' : '{"error":"x"}',
      status,
      headers: {Headers.contentTypeHeader: ['application/json']},
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late InMemoryResponseCache cache;
  late CacheScope scope;

  Dio buildDio(List<Object> script) {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test', validateStatus: (s) => s != null && s < 400));
    dio.httpClientAdapter = _ScriptedAdapter(script);
    dio.interceptors.add(CacheInterceptor(cache: cache, scope: scope));
    return dio;
  }

  setUp(() {
    cache = InMemoryResponseCache();
    scope = CacheScope()..businessId = 'b1';
  });

  test('a successful read is passed through and marks data fresh', () async {
    final dio = buildDio([200]);

    final response = await dio.get<Map<String, dynamic>>('/items');

    expect(response.data, {'n': 1});
    expect(response.extra['fromCache'], isNot(true));
    expect(scope.stale.value, isFalse);
  });

  for (final failure in [DioExceptionType.connectionError, DioExceptionType.connectionTimeout, DioExceptionType.receiveTimeout]) {
    test('a $failure after a good read returns the saved copy and marks it stale', () async {
      final dio = buildDio([200, failure]);
      await dio.get<Map<String, dynamic>>('/items');

      final response = await dio.get<Map<String, dynamic>>('/items');

      expect(response.data, {'n': 1});
      expect(response.extra['fromCache'], isTrue);
      expect(scope.stale.value, isTrue);
    });
  }

  test('a server that is still waking (503) falls back to the saved copy', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
    dio.httpClientAdapter = _ScriptedAdapter([200, 503]);
    dio.interceptors.add(CacheInterceptor(cache: cache, scope: scope));
    await dio.get<Map<String, dynamic>>('/items');

    final response = await dio.get<Map<String, dynamic>>('/items');

    expect(response.extra['fromCache'], isTrue);
  });

  test('a real error such as a 404 is never replaced by saved data', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
    dio.httpClientAdapter = _ScriptedAdapter([200, 404]);
    dio.interceptors.add(CacheInterceptor(cache: cache, scope: scope));
    await dio.get<Map<String, dynamic>>('/items');

    expect(() => dio.get<Map<String, dynamic>>('/items'), throwsA(isA<DioException>()));
  });

  test('with nothing saved the failure is reported as it was', () async {
    final dio = buildDio([DioExceptionType.connectionError]);

    expect(
      () => dio.get<Map<String, dynamic>>('/items'),
      throwsA(isA<DioException>().having((e) => e.type, 'type', DioExceptionType.connectionError)),
    );
  });

  test('writes are never cached or answered from the cache', () async {
    final dio = buildDio([200, DioExceptionType.connectionError]);
    await dio.post<Map<String, dynamic>>('/items', data: {'a': 1});

    expect(() => dio.post<Map<String, dynamic>>('/items', data: {'a': 1}), throwsA(isA<DioException>()));
  });

  test('sign-in and upload paths are never cached', () async {
    for (final path in ['/auth/me', '/uploads/b1/logo.png']) {
      final dio = buildDio([200, DioExceptionType.connectionError]);
      await dio.get<Map<String, dynamic>>(path);

      expect(() => dio.get<Map<String, dynamic>>(path), throwsA(isA<DioException>()), reason: path);
    }
  });

  test('another business never sees this business\'s saved data', () async {
    final dio = buildDio([200, DioExceptionType.connectionError]);
    await dio.get<Map<String, dynamic>>('/items');
    scope.businessId = 'b2';

    expect(() => dio.get<Map<String, dynamic>>('/items'), throwsA(isA<DioException>()));
  });

  test('different query strings are saved separately', () async {
    final dio = buildDio([200, 200, DioExceptionType.connectionError]);
    await dio.get<Map<String, dynamic>>('/items', queryParameters: {'page': 1});
    await dio.get<Map<String, dynamic>>('/items', queryParameters: {'page': 2});

    final response = await dio.get<Map<String, dynamic>>('/items', queryParameters: {'page': 1});

    expect(response.data, {'n': 1});
  });

  test('clearing the cache removes everything', () async {
    final dio = buildDio([200, DioExceptionType.connectionError]);
    await dio.get<Map<String, dynamic>>('/items');
    await cache.clear();

    expect(() => dio.get<Map<String, dynamic>>('/items'), throwsA(isA<DioException>()));
  });

  test('a fresh read after a stale one clears the stale flag', () async {
    final dio = buildDio([200, DioExceptionType.connectionError, 200]);
    await dio.get<Map<String, dynamic>>('/items');
    await dio.get<Map<String, dynamic>>('/items');
    expect(scope.stale.value, isTrue);

    await dio.get<Map<String, dynamic>>('/items');

    expect(scope.stale.value, isFalse);
  });

  group('file cache', () {
    late Directory dir;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('billa_cache_test');
    });

    tearDown(() {
      if (dir.existsSync()) dir.deleteSync(recursive: true);
    });

    test('survives a restart', () async {
      final saved = CachedResponse(statusCode: 200, data: {'a': 1}, savedAt: DateTime(2026, 1, 1));
      await FileResponseCache(dir).write('k', saved);

      final loaded = await FileResponseCache(dir).read('k');

      expect(loaded?.data, {'a': 1});
      expect(loaded?.savedAt, DateTime(2026, 1, 1));
    });

    test('an unreadable file is treated as a miss', () async {
      final cache = FileResponseCache(dir);
      await cache.write('k', CachedResponse(statusCode: 200, data: 1, savedAt: DateTime(2026)));
      for (final file in dir.listSync().whereType<File>()) {
        file.writeAsStringSync('not json');
      }

      expect(await cache.read('k'), isNull);
    });

    test('clear empties the folder', () async {
      final cache = FileResponseCache(dir);
      await cache.write('k', CachedResponse(statusCode: 200, data: 1, savedAt: DateTime(2026)));

      await cache.clear();

      expect(await cache.read('k'), isNull);
    });
  });
}
