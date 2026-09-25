import 'auth_status.dart';

abstract class AuthRepository {
  Future<AuthStatus> exchangeSession({required String idToken, String? businessName});
  Future<AuthStatus> me();
  Future<AuthStatus> submitTwoFactorChallenge({required String challengeId, required String code});
  Future<void> logout();

  /// Trades the refresh cookie for a fresh access token. False means the
  /// refresh token itself was rejected (the session is truly over); other
  /// failures, such as no connection, are thrown so callers can tell them apart.
  Future<bool> refreshSession();
}
