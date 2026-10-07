import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:billa_mobile/core/storage/secure_storage.dart';
import 'package:billa_mobile/features/auth/data/session_snapshot_store.dart';
import 'package:billa_mobile/features/auth/domain/auth_repository.dart';
import 'package:billa_mobile/features/auth/domain/auth_status.dart';
import 'package:billa_mobile/features/auth/domain/auth_user.dart';
import 'package:billa_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:billa_mobile/features/onboarding/domain/business.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

const _user = AuthUser(id: 'u1', email: 'a@b.com', totpEnabled: false, isAdmin: false);
const _business = Business(id: 'b1', name: 'Acme');
const _signedIn = Authenticated(_user, _business);

void main() {
  late _MockAuthRepository repository;
  late InMemorySessionSnapshotStore store;

  ProviderContainer makeContainer() {
    final container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(repository),
      sessionSnapshotStoreProvider.overrideWithValue(store),
    ]);
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    repository = _MockAuthRepository();
    store = InMemorySessionSnapshotStore();
  });

  test('a remembered session opens straight away without waiting for the server', () async {
    await store.write(_signedIn);
    final pending = Completer<AuthStatus>();
    when(() => repository.me()).thenAnswer((_) => pending.future);

    final container = makeContainer();
    final status = await container.read(authControllerProvider.future);

    expect(status, _signedIn);
    expect(pending.isCompleted, isFalse);
  });

  test('the server answer replaces the remembered one in the background', () async {
    await store.write(_signedIn);
    const renamed = Authenticated(_user, Business(id: 'b1', name: 'Acme Renamed'));
    when(() => repository.me()).thenAnswer((_) async => renamed);

    final container = makeContainer();
    await container.read(authControllerProvider.future);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(authControllerProvider).value, renamed);
    expect(store.read(), renamed);
  });

  test('a rejected session signs out and forgets the snapshot', () async {
    await store.write(_signedIn);
    when(() => repository.me()).thenAnswer((_) async => const AuthStatus.unauthenticated());

    final container = makeContainer();
    await container.read(authControllerProvider.future);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(authControllerProvider).value, const AuthStatus.unauthenticated());
    expect(store.read(), isNull);
  });

  test('being offline keeps the user signed in', () async {
    await store.write(_signedIn);
    when(() => repository.me()).thenAnswer(
      (_) async => throw DioException(requestOptions: RequestOptions(path: '/auth/me'), type: DioExceptionType.connectionError),
    );

    final container = makeContainer();
    await container.read(authControllerProvider.future);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(authControllerProvider).value, _signedIn);
    expect(store.read(), _signedIn);
  });

  test('a business switch made while the check is out is not overwritten by it', () async {
    await store.write(_signedIn);
    final pending = Completer<AuthStatus>();
    when(() => repository.me()).thenAnswer((_) => pending.future);

    final container = makeContainer();
    await container.read(authControllerProvider.future);
    const other = Business(id: 'b2', name: 'Other');
    container.read(authControllerProvider.notifier).setBusiness(other);
    pending.complete(_signedIn);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(authControllerProvider).value, const Authenticated(_user, other));
  });

  test('with nothing remembered it still asks the server and remembers a signed-in answer', () async {
    when(() => repository.me()).thenAnswer((_) async => _signedIn);

    final container = makeContainer();
    final status = await container.read(authControllerProvider.future);

    expect(status, _signedIn);
    expect(store.read(), _signedIn);
  });

  test('signing out forgets the snapshot', () async {
    await store.write(_signedIn);
    when(() => repository.me()).thenAnswer((_) async => _signedIn);
    when(() => repository.logout()).thenAnswer((_) async {});

    final container = makeContainer();
    await container.read(authControllerProvider.future);
    await container.read(authControllerProvider.notifier).logout();

    expect(store.read(), isNull);
  });

  group('secure snapshot store', () {
    late _FakeSecureStorage secure;
    late SharedPreferences preferences;

    setUp(() async {
      secure = _FakeSecureStorage();
      SharedPreferences.setMockInitialValues({});
      preferences = await SharedPreferences.getInstance();
    });

    test('a written snapshot is restored by the next load', () async {
      final first = await SecureSessionSnapshotStore.load(secure, preferences);
      await first.write(_signedIn);

      final second = await SecureSessionSnapshotStore.load(secure, preferences);

      expect(second.read(), _signedIn);
    });

    test('clear forgets it in memory and in storage', () async {
      final store = await SecureSessionSnapshotStore.load(secure, preferences);
      await store.write(_signedIn);
      await store.clear();

      expect(store.read(), isNull);
      expect((await SecureSessionSnapshotStore.load(secure, preferences)).read(), isNull);
    });

    test('an unreadable stored value is ignored', () async {
      await secure.write('session_snapshot', 'not json');

      expect((await SecureSessionSnapshotStore.load(secure, preferences)).read(), isNull);
    });

    test('the old plain preference copy is removed', () async {
      await preferences.setString('session_snapshot', '{"user":{},"business":{}}');

      await SecureSessionSnapshotStore.load(secure, preferences);

      expect(preferences.containsKey('session_snapshot'), isFalse);
    });
  });
}

class _FakeSecureStorage extends SecureStorage {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}
