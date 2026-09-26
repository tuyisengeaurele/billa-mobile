import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository_impl.dart';
import '../../data/session_snapshot_store.dart';
import '../../domain/auth_repository.dart';
import '../../domain/auth_status.dart';
import '../../domain/auth_user.dart';
import '../../../onboarding/domain/business.dart';
import '../../../../core/network/api_client_provider.dart';
import '../../../../core/network/response_cache.dart';

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
    final store = ref.read(sessionSnapshotStoreProvider);
    final snapshot = store.read();
    if (snapshot != null) {
      // Open straight into the app on what was true last time, then let the
      // server confirm or correct it in the background.
      _lastRefreshAt = ref.read(authClockProvider)();
      ref.read(cacheScopeProvider).businessId = snapshot.business.id;
      Future.microtask(() => _revalidate(snapshot));
      return snapshot;
    }
    final status = await ref.read(authRepositoryProvider).me();
    _lastRefreshAt = ref.read(authClockProvider)();
    _remember(status);
    return status;
  }

  Future<void> _revalidate(Authenticated snapshot) async {
    try {
      final fresh = await ref.read(authRepositoryProvider).me();
      // Someone acted while the check was out (signed out, switched business),
      // and their change is newer than this answer.
      if (state.valueOrNull != snapshot) return;
      _set(fresh);
    } catch (_) {
      // Offline or the server is waking up: staying signed in is right, and
      // the next request will find out if it is not.
    }
  }

  void _remember(AuthStatus status) {
    final store = ref.read(sessionSnapshotStoreProvider);
    final scope = ref.read(cacheScopeProvider);
    if (status is Authenticated) {
      store.write(status);
      scope.businessId = status.business.id;
    } else if (status is Unauthenticated) {
      store.clear();
      // Saved copies belong to the person who was signed in, so they go with
      // the session; the next user on this phone must never see them.
      scope.businessId = '';
      scope.stale.value = false;
      ref.read(responseCacheProvider).clear();
    }
  }

  void _set(AuthStatus status) {
    state = AsyncData(status);
    _remember(status);
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
        _set(const AuthStatus.unauthenticated());
      }
    } catch (_) {
      // Offline or the server is down: the next request will retry.
    }
  }

  Future<void> exchangeSession({required String idToken, String? businessName}) async {
    final repository = ref.read(authRepositoryProvider);
    _set(await repository.exchangeSession(idToken: idToken, businessName: businessName));
    _lastRefreshAt = ref.read(authClockProvider)();
  }

  Future<void> submitTwoFactorChallenge({required String challengeId, required String code}) async {
    final repository = ref.read(authRepositoryProvider);
    _set(await repository.submitTwoFactorChallenge(challengeId: challengeId, code: code));
    _lastRefreshAt = ref.read(authClockProvider)();
  }

  // Switch, create, join, and leave each re-issue the session server-side, so
  // the only client state to update is which business the session points at.
  void setBusiness(Business business) {
    final current = state.valueOrNull;
    if (current is Authenticated) {
      _set(AuthStatus.authenticated(current.user, business));
    }
  }

  // Profile edits and 2FA changes happen server-side without re-issuing the
  // session, so the signed-in user is patched locally instead of refetched.
  void updateUser(AuthUser Function(AuthUser current) change) {
    final current = state.valueOrNull;
    if (current is Authenticated) {
      _set(AuthStatus.authenticated(change(current.user), current.business));
    }
  }

  // After account deletion the server has already cleared the cookies, so a
  // logout request would only 401.
  void clearSession() => _set(const AuthStatus.unauthenticated());

  Future<void> logout() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();
    _set(const AuthStatus.unauthenticated());
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthStatus>(AuthController.new);
