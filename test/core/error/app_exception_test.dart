import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/error/app_exception.dart';

void main() {
  test('each subtype is an AppException and an Exception', () {
    expect(const NetworkException(), isA<AppException>());
    expect(const SessionExpiredException(), isA<Exception>());
    expect(const ApiException(404, {'error': 'not_found'}), isA<AppException>());
    expect(const UnknownException(), isA<AppException>());
  });

  test('ApiException carries the status code and body', () {
    const exception = ApiException(409, {'error': 'already_finalized'});
    expect(exception.statusCode, 409);
    expect(exception.body, {'error': 'already_finalized'});
  });

  test('default messages are human-readable', () {
    expect(const SessionExpiredException().message, 'Session expired');
    expect(const NetworkException().message, 'Network error');
  });
}
