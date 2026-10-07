sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error']);
}

class SessionExpiredException extends AppException {
  const SessionExpiredException([super.message = 'Session expired']);
}

class ApiException extends AppException {
  const ApiException(this.statusCode, this.body, [super.message = 'Request failed']);

  final int statusCode;
  final Object? body;
}

class UnknownException extends AppException {
  const UnknownException([super.message = 'Something went wrong']);
}
