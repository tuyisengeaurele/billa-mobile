import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/auth/domain/auth_repository.dart';
import 'package:billa_mobile/features/auth/domain/auth_status.dart';
import 'package:billa_mobile/features/auth/domain/auth_user.dart';
import 'package:billa_mobile/features/auth/presentation/providers/active_business_provider.dart';
import 'package:billa_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:billa_mobile/features/onboarding/domain/business.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

const _user = AuthUser(id: 'u1', email: 'a@b.com', totpEnabled: false, isAdmin: false);

void main() {
  test('is null until authenticated, then follows the business', () async {
    final repository = _MockAuthRepository();
    when(() => repository.me()).thenAnswer(
      (_) async => const AuthStatus.authenticated(_user, Business(id: 'b1', name: 'Acme')),
    );
    final container = ProviderContainer(overrides: [authRepositoryProvider.overrideWithValue(repository)]);
    addTearDown(container.dispose);

    expect(container.read(activeBusinessIdProvider), isNull);
    await container.read(authControllerProvider.future);
    expect(container.read(activeBusinessIdProvider), 'b1');

    container.read(authControllerProvider.notifier).setBusiness(const Business(id: 'b2', name: 'Other'));
    expect(container.read(activeBusinessIdProvider), 'b2');
  });

  test('is null, not a crash, when the auth provider itself failed to build', () {
    // Screen and controller tests that never override auth leave it errored;
    // reading the id must stay safe there.
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(activeBusinessIdProvider), isNull);
  });
}
