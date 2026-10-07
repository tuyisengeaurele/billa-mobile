import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/account/data/security_repository_impl.dart';

class _MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _ok(Map<String, dynamic> data, String path) =>
    Response(statusCode: 200, data: data, requestOptions: RequestOptions(path: path));

void main() {
  late _MockDio dio;
  late SecurityRepositoryImpl repository;

  setUp(() {
    dio = _MockDio();
    repository = SecurityRepositoryImpl(dio);
  });

  test('setUpTwoFactor parses the secret and QR', () async {
    when(() => dio.post<Map<String, dynamic>>('/auth/2fa/setup')).thenAnswer(
      (_) async => _ok({
        'secret': 'ABC',
        'otpauthUrl': 'otpauth://x',
        'qrCodeDataUri': 'data:image/png;base64,AAAA',
      }, '/auth/2fa/setup'),
    );

    final setup = await repository.setUpTwoFactor();

    expect(setup.secret, 'ABC');
  });

  test('verifyTwoFactor sends the code and returns the backup codes', () async {
    when(() => dio.post<Map<String, dynamic>>('/auth/2fa/verify', data: {'code': '123456'})).thenAnswer(
      (_) async => _ok({'backupCodes': ['aaaaaaaaaa', 'bbbbbbbbbb']}, '/auth/2fa/verify'),
    );

    final codes = await repository.verifyTwoFactor('123456');

    expect(codes, ['aaaaaaaaaa', 'bbbbbbbbbb']);
  });

  test('disableTwoFactor posts the code', () async {
    when(() => dio.post<Map<String, dynamic>>('/auth/2fa/disable', data: {'code': '123456'}))
        .thenAnswer((_) async => _ok({'ok': true}, '/auth/2fa/disable'));

    await repository.disableTwoFactor('123456');

    verify(() => dio.post<Map<String, dynamic>>('/auth/2fa/disable', data: {'code': '123456'})).called(1);
  });

  test('sessions parses results with the current flag', () async {
    when(() => dio.get<Map<String, dynamic>>('/profile/sessions')).thenAnswer(
      (_) async => _ok({
        'results': [
          {
            'id': 's1',
            'createdAt': '2026-01-01T00:00:00.000Z',
            'expiresAt': '2026-02-01T00:00:00.000Z',
            'isCurrent': true,
          },
          {
            'id': 's2',
            'createdAt': '2026-01-02T00:00:00.000Z',
            'expiresAt': '2026-02-02T00:00:00.000Z',
            'isCurrent': false,
          },
        ],
      }, '/profile/sessions'),
    );

    final sessions = await repository.sessions();

    expect(sessions.map((s) => s.isCurrent), [true, false]);
  });

  test('revokeSession and revokeOtherSessions hit their endpoints', () async {
    when(() => dio.post<Map<String, dynamic>>('/profile/sessions/s2/revoke'))
        .thenAnswer((_) async => _ok({'ok': true}, '/profile/sessions/s2/revoke'));
    when(() => dio.post<Map<String, dynamic>>('/profile/sessions/revoke-others'))
        .thenAnswer((_) async => _ok({'ok': true}, '/profile/sessions/revoke-others'));

    await repository.revokeSession('s2');
    await repository.revokeOtherSessions();

    verify(() => dio.post<Map<String, dynamic>>('/profile/sessions/s2/revoke')).called(1);
    verify(() => dio.post<Map<String, dynamic>>('/profile/sessions/revoke-others')).called(1);
  });

  test('deleteAccount sends a DELETE to /auth/me', () async {
    when(() => dio.delete<Map<String, dynamic>>('/auth/me')).thenAnswer((_) async => _ok({'ok': true}, '/auth/me'));

    await repository.deleteAccount();

    verify(() => dio.delete<Map<String, dynamic>>('/auth/me')).called(1);
  });
}
