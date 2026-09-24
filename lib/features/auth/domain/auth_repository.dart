import 'auth_status.dart';

abstract class AuthRepository {
  Future<AuthStatus> exchangeSession({required String idToken, String? businessName});
  Future<AuthStatus> me();
  Future<AuthStatus> submitTwoFactorChallenge({required String challengeId, required String code});
  Future<void> logout();
}
