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

/// Injectable so tests can move time; the app uses the real clock.
final authClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

class AuthController extends AsyncNotifier<AuthStatus> {
  static const _staleAfter = Duration(minutes: 10);

  DateTime? _lastRefreshAt;

  @override
  Future<AuthStatus> build() async {
    final status = await ref.read(authRepositoryProvider).me();
    _lastRefreshAt = ref.read(authClockProvider)();
    return status;
  }

  /// Keeps an idle session alive: when the app comes back after a while, the
  /// access token has usually lapsed, and refreshing here means the user never
  /// meets a 401 in the middle of doing something. Only a refresh token that
  /// is actually rejected signs them out; being offline changes nothing.
  Future<void> refreshIfStale() async {
    if (state.valueOrNull is! Authenticated) return;
    final now = ref.read(authClockProvider)();
    final last = _lastRefreshAt;
    if (last != null && now.difference(last) < _staleAfter) return;
    try {
      final refreshed = await ref.read(authRepositoryProvider).refreshSession();
      if (refreshed) {
        _lastRefreshAt = now;
      } else {
        state = const AsyncData(AuthStatus.unauthenticated());
      }
    } catch (_) {
      // Offline or the server is down: the next request will retry.
    }
  }

  Future<void> exchangeSession({required String idToken, String? businessName}) async {
    final repository = ref.read(authRepositoryProvider);
    state = AsyncData(await repository.exchangeSession(idToken: idToken, businessName: businessName));
    _lastRefreshAt = ref.read(authClockProvider)();
  }

  Future<void> submitTwoFactorChallenge({required String challengeId, required String code}) async {
    final repository = ref.read(authRepositoryProvider);
    state = AsyncData(await repository.submitTwoFactorChallenge(challengeId: challengeId, code: code));
    _lastRefreshAt = ref.read(authClockProvider)();
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
