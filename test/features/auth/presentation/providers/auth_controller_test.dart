import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/auth/domain/auth_repository.dart';
import 'package:billa_mobile/features/auth/domain/auth_status.dart';
import 'package:billa_mobile/features/auth/domain/auth_user.dart';
import 'package:billa_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:billa_mobile/features/onboarding/domain/business.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

const _user = AuthUser(id: 'u1', email: 'a@b.com', totpEnabled: false, isAdmin: false);
const _business = Business(id: 'b1', name: 'Acme');

void main() {
  late _MockAuthRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _MockAuthRepository();
    when(() => repository.me()).thenAnswer((_) async => const AuthStatus.unauthenticated());
    container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);
  });

  test('bootstraps by calling me() and exposes its result', () async {
    final status = await container.read(authControllerProvider.future);
    expect(status, const AuthStatus.unauthenticated());
  });

  test('exchangeSession updates state to the repository result', () async {
    await container.read(authControllerProvider.future); // let the bootstrap settle first
    when(() => repository.exchangeSession(idToken: 'tok', businessName: null))
        .thenAnswer((_) async => const AuthStatus.authenticated(_user, _business));

    await container.read(authControllerProvider.notifier).exchangeSession(idToken: 'tok');

    expect(container.read(authControllerProvider).value, const AuthStatus.authenticated(_user, _business));
  });

  test('logout calls the repository and resets to unauthenticated', () async {
    await container.read(authControllerProvider.future);
    when(() => repository.logout()).thenAnswer((_) async {});

    await container.read(authControllerProvider.notifier).logout();

    expect(container.read(authControllerProvider).value, const AuthStatus.unauthenticated());
    verify(() => repository.logout()).called(1);
  });
}
