import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository_impl.dart';
import '../../domain/auth_repository.dart';
import '../../domain/auth_status.dart';
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

  Future<void> logout() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();
    state = const AsyncData(AuthStatus.unauthenticated());
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthStatus>(AuthController.new);
