import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/auth/data/auth_repository_impl.dart';
import 'package:billa_mobile/features/auth/domain/auth_status.dart';

class _MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _response(int statusCode, Map<String, dynamic> data, RequestOptions options) {
  return Response(statusCode: statusCode, data: data, requestOptions: options);
}

void main() {
  late _MockDio dio;
  late AuthRepositoryImpl repository;

  setUp(() {
    dio = _MockDio();
    repository = AuthRepositoryImpl(dio);
  });

  test('exchangeSession returns authenticated on a normal user/business response', () async {
    final options = RequestOptions(path: '/auth/session');
    when(() => dio.post<Map<String, dynamic>>('/auth/session', data: {'idToken': 'tok'})).thenAnswer(
      (_) async => _response(201, {
        'user': {'id': 'u1', 'email': 'a@b.com', 'totpEnabled': false, 'isAdmin': false},
        'business': {'id': 'b1', 'name': 'Acme', 'onboardingCompletedAt': null},
      }, options),
    );

    final status = await repository.exchangeSession(idToken: 'tok');

    expect(status, isA<Authenticated>());
    final authenticated = status as Authenticated;
    expect(authenticated.user.email, 'a@b.com');
    expect(authenticated.business.onboardingCompletedAt, isNull);
  });

  test('exchangeSession returns twoFactorRequired when the server asks for it', () async {
    final options = RequestOptions(path: '/auth/session');
    when(() => dio.post<Map<String, dynamic>>('/auth/session', data: {'idToken': 'tok'})).thenAnswer(
      (_) async => _response(200, {'twoFactorRequired': true, 'challengeId': 'c1'}, options),
    );

    final status = await repository.exchangeSession(idToken: 'tok');

    expect(status, const AuthStatus.twoFactorRequired('c1'));
  });

  test('exchangeSession passes businessName through for signup', () async {
    final options = RequestOptions(path: '/auth/session');
    when(() => dio.post<Map<String, dynamic>>(
      '/auth/session',
      data: {'idToken': 'tok', 'businessName': 'My Business'},
    )).thenAnswer(
      (_) async => _response(201, {
        'user': {'id': 'u1', 'email': 'a@b.com', 'totpEnabled': false, 'isAdmin': false},
        'business': {'id': 'b1', 'name': 'My Business', 'onboardingCompletedAt': null},
      }, options),
    );

    final status = await repository.exchangeSession(idToken: 'tok', businessName: 'My Business');

    expect(status, isA<Authenticated>());
  });

  DioException unauthorised(String path) {
    final options = RequestOptions(path: path);
    return DioException(requestOptions: options, response: Response(statusCode: 401, requestOptions: options));
  }

  const meJson = {
    'user': {'id': 'u1', 'email': 'a@b.com', 'totpEnabled': false, 'isAdmin': false},
    'business': {'id': 'b1', 'name': 'Acme', 'onboardingCompletedAt': '2026-01-01T00:00:00.000Z'},
  };

  test('me() refreshes an expired access token and retries instead of reporting a logout', () async {
    final options = RequestOptions(path: '/auth/me');
    var calls = 0;
    when(() => dio.get<Map<String, dynamic>>('/auth/me')).thenAnswer((_) async {
      calls++;
      if (calls == 1) throw unauthorised('/auth/me');
      return _response(200, meJson, options);
    });
    when(() => dio.post<void>('/auth/refresh')).thenAnswer(
      (_) async => Response(statusCode: 200, requestOptions: RequestOptions(path: '/auth/refresh')),
    );

    final status = await repository.me();

    expect(status, isA<Authenticated>());
    verify(() => dio.post<void>('/auth/refresh')).called(1);
    expect(calls, 2);
  });

  test('me() reports unauthenticated only when the refresh is rejected too', () async {
    when(() => dio.get<Map<String, dynamic>>('/auth/me')).thenAnswer((_) async => throw unauthorised('/auth/me'));
    when(() => dio.post<void>('/auth/refresh')).thenAnswer((_) async => throw unauthorised('/auth/refresh'));

    final status = await repository.me();

    expect(status, const AuthStatus.unauthenticated());
  });

  test('me() lets a network failure during the refresh surface instead of signing the user out', () async {
    when(() => dio.get<Map<String, dynamic>>('/auth/me')).thenAnswer((_) async => throw unauthorised('/auth/me'));
    when(() => dio.post<void>('/auth/refresh')).thenAnswer(
      (_) async => throw DioException(requestOptions: RequestOptions(path: '/auth/refresh'), type: DioExceptionType.connectionError),
    );

    expect(repository.me(), throwsA(isA<DioException>()));
  });

  test('me() refreshes at most once per call', () async {
    when(() => dio.get<Map<String, dynamic>>('/auth/me')).thenAnswer((_) async => throw unauthorised('/auth/me'));
    when(() => dio.post<void>('/auth/refresh')).thenAnswer(
      (_) async => Response(statusCode: 200, requestOptions: RequestOptions(path: '/auth/refresh')),
    );

    final status = await repository.me();

    expect(status, const AuthStatus.unauthenticated());
    verify(() => dio.post<void>('/auth/refresh')).called(1);
  });

  test('refreshSession returns true on success and false when the refresh token is rejected', () async {
    when(() => dio.post<void>('/auth/refresh')).thenAnswer(
      (_) async => Response(statusCode: 200, requestOptions: RequestOptions(path: '/auth/refresh')),
    );
    expect(await repository.refreshSession(), isTrue);

    when(() => dio.post<void>('/auth/refresh')).thenAnswer((_) async => throw unauthorised('/auth/refresh'));
    expect(await repository.refreshSession(), isFalse);
  });

  test('me() maps a valid session to authenticated', () async {
    final options = RequestOptions(path: '/auth/me');
    when(() => dio.get<Map<String, dynamic>>('/auth/me')).thenAnswer(
      (_) async => _response(200, {
        'user': {'id': 'u1', 'email': 'a@b.com', 'totpEnabled': false, 'isAdmin': false},
        'business': {'id': 'b1', 'name': 'Acme', 'onboardingCompletedAt': '2026-01-01T00:00:00.000Z'},
      }, options),
    );

    final status = await repository.me();

    expect(status, isA<Authenticated>());
  });

  test('submitTwoFactorChallenge posts the code and returns authenticated', () async {
    final options = RequestOptions(path: '/auth/2fa/challenge');
    when(() => dio.post<Map<String, dynamic>>(
      '/auth/2fa/challenge',
      data: {'challengeId': 'c1', 'code': '123456'},
    )).thenAnswer(
      (_) async => _response(200, {
        'user': {'id': 'u1', 'email': 'a@b.com', 'totpEnabled': true, 'isAdmin': false},
        'business': {'id': 'b1', 'name': 'Acme', 'onboardingCompletedAt': null},
      }, options),
    );

    final status = await repository.submitTwoFactorChallenge(challengeId: 'c1', code: '123456');

    expect(status, isA<Authenticated>());
  });

  test('logout posts to /auth/logout', () async {
    final options = RequestOptions(path: '/auth/logout');
    when(() => dio.post<void>('/auth/logout')).thenAnswer((_) async => _response(200, {}, options));

    await repository.logout();

    verify(() => dio.post<void>('/auth/logout')).called(1);
  });
}
