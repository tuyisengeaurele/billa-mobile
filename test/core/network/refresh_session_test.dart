import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/core/network/refresh_session.dart';
import 'package:billa_mobile/features/auth/data/auth_repository_impl.dart';

class _MockDio extends Mock implements Dio {}

DioException _status(int code) {
  final options = RequestOptions(path: '/auth/refresh');
  return DioException(requestOptions: options, response: Response(statusCode: code, requestOptions: options));
}

Response<void> _ok() => Response(statusCode: 200, requestOptions: RequestOptions(path: '/auth/refresh'));

void main() {
  late _MockDio dio;

  setUp(() {
    dio = _MockDio();
  });

  test('callers that arrive while a refresh is running share it instead of sending the token twice', () async {
    when(() => dio.post<void>('/auth/refresh')).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return _ok();
    });

    final results = await Future.wait([refreshOnce(dio), refreshOnce(dio), refreshOnce(dio)]);

    expect(results, [true, true, true]);
    verify(() => dio.post<void>('/auth/refresh')).called(1);
  });

  test('the resume check and a request that hit a 401 share one refresh', () async {
    when(() => dio.post<void>('/auth/refresh')).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return _ok();
    });
    final repository = AuthRepositoryImpl(dio);

    final results = await Future.wait([repository.refreshSession(), refreshOnce(dio), repository.refreshSession()]);

    expect(results, [true, true, true]);
    verify(() => dio.post<void>('/auth/refresh')).called(1);
  });

  test('a rejected token ends every waiter the same way', () async {
    when(() => dio.post<void>('/auth/refresh')).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      throw _status(401);
    });

    final results = await Future.wait([refreshOnce(dio), refreshOnce(dio)]);

    expect(results, [false, false]);
    verify(() => dio.post<void>('/auth/refresh')).called(1);
  });

  test('a dropped connection reaches every waiter, and the next call tries again', () async {
    var calls = 0;
    when(() => dio.post<void>('/auth/refresh')).thenAnswer((_) async {
      calls++;
      await Future<void>.delayed(const Duration(milliseconds: 20));
      if (calls == 1) {
        throw DioException(requestOptions: RequestOptions(path: '/auth/refresh'), type: DioExceptionType.connectionError);
      }
      return _ok();
    });

    final failed = await Future.wait(
      [refreshOnce(dio).then((_) => 'ok', onError: (_) => 'failed'), refreshOnce(dio).then((_) => 'ok', onError: (_) => 'failed')],
    );
    final retried = await refreshOnce(dio);

    expect(failed, ['failed', 'failed']);
    expect(retried, isTrue);
    expect(calls, 2);
  });
}
