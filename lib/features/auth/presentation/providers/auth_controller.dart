import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository_impl.dart';
import '../../domain/auth_repository.dart';
import '../../domain/auth_status.dart';
import '../../domain/auth_user.dart';
import '../../../onboarding/domain/business.dart';
import '../../../../core/network/api_client_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(apiClientProvider).dio);
});

class AuthController extends AsyncNotifier<AuthStatus> {
  @override
  Future<AuthStatus> build() {
    return ref.read(authRepositoryProvider).me();
  }

  Future<void> exchangeSession({required String idToken, String? businessName}) async {
    final repository = ref.read(authRepositoryProvider);
    state = AsyncData(await repository.exchangeSession(idToken: idToken, businessName: businessName));
  }

  Future<void> submitTwoFactorChallenge({required String challengeId, required String code}) async {
    final repository = ref.read(authRepositoryProvider);
    state = AsyncData(await repository.submitTwoFactorChallenge(challengeId: challengeId, code: code));
  }

  // Switch, create, join, and leave each re-issue the session server-side, so
  // the only client state to update is which business the session points at.
  void setBusiness(Business business) {
    final current = state.valueOrNull;
    if (current is Authenticated) {
      state = AsyncData(AuthStatus.authenticated(current.user, business));
    }
  }

  // Profile edits and 2FA changes happen server-side without re-issuing the
  // session, so the signed-in user is patched locally instead of refetched.
  void updateUser(AuthUser Function(AuthUser current) change) {
    final current = state.valueOrNull;
    if (current is Authenticated) {
      state = AsyncData(AuthStatus.authenticated(change(current.user), current.business));
    }
  }

  // After account deletion the server has already cleared the cookies, so a
  // logout request would only 401.
  void clearSession() => state = const AsyncData(AuthStatus.unauthenticated());

  Future<void> logout() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();
    state = const AsyncData(AuthStatus.unauthenticated());
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthStatus>(AuthController.new);
