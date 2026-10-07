import 'session_info.dart';
import 'two_factor_setup.dart';

abstract class SecurityRepository {
  Future<TwoFactorSetup> setUpTwoFactor();
  Future<List<String>> verifyTwoFactor(String code);
  Future<void> disableTwoFactor(String code);
  Future<List<SessionInfo>> sessions();
  Future<void> revokeSession(String id);
  Future<void> revokeOtherSessions();
  Future<void> deleteAccount();
}
