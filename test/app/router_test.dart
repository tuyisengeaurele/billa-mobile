import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/router.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/pagination/paginated_result.dart';
import 'package:billa_mobile/features/auth/domain/auth_status.dart';
import 'package:billa_mobile/features/auth/domain/auth_user.dart';
import 'package:billa_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:billa_mobile/features/customers/domain/customer_repository.dart';
import 'package:billa_mobile/features/customers/presentation/providers/customer_repository_provider.dart';
import 'package:billa_mobile/features/documents/domain/document_repository.dart';
import 'package:billa_mobile/features/documents/presentation/providers/document_repository_provider.dart';
import 'package:billa_mobile/features/items/domain/item_repository.dart';
import 'package:billa_mobile/features/items/presentation/providers/item_repository_provider.dart';
import 'package:billa_mobile/features/onboarding/domain/business.dart';

const _user = AuthUser(id: 'u1', email: 'a@b.com', totpEnabled: false, isAdmin: false);

class _MockCustomerRepository extends Mock implements CustomerRepository {}
class _MockItemRepository extends Mock implements ItemRepository {}
class _MockDocumentRepository extends Mock implements DocumentRepository {}

Future<GoRouter> _pumpRouter(WidgetTester tester, ProviderContainer container) async {
  final router = container.read(appRouterProvider);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
  ));
  await tester.pumpAndSettle();
  return router;
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('unauthenticated is redirected from home to /login', (tester) async {
    final container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(() => _FakeAuthController(const AuthStatus.unauthenticated())),
    ]);
    addTearDown(container.dispose);

    final router = await _pumpRouter(tester, container);

    expect(router.routerDelegate.currentConfiguration.uri.toString(), '/login');
  });

  testWidgets('authenticated without onboarding completed goes to /onboarding', (tester) async {
    const business = Business(id: 'b1', name: 'Acme', onboardingCompletedAt: null);
    final container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(() => _FakeAuthController(const AuthStatus.authenticated(_user, business))),
    ]);
    addTearDown(container.dispose);

    final router = await _pumpRouter(tester, container);

    expect(router.routerDelegate.currentConfiguration.uri.toString(), '/onboarding');
  });

  testWidgets('authenticated with onboarding completed reaches home, not the auth screens', (tester) async {
    const business = Business(id: 'b1', name: 'Acme', onboardingCompletedAt: '2026-01-01T00:00:00.000Z');
    final container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(() => _FakeAuthController(const AuthStatus.authenticated(_user, business))),
    ]);
    addTearDown(container.dispose);

    final router = await _pumpRouter(tester, container);
    router.go('/login');
    await tester.pumpAndSettle();

    expect(router.routerDelegate.currentConfiguration.uri.toString(), '/');
  });

  testWidgets('home screen navigates to the customers list', (tester) async {
    final customerRepository = _MockCustomerRepository();
    when(() => customerRepository.list(search: null, includeInactive: false, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: [], total: 0, page: 1, pageSize: 20),
    );
    const business = Business(id: 'b1', name: 'Acme', onboardingCompletedAt: '2026-01-01T00:00:00.000Z');
    final container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(() => _FakeAuthController(const AuthStatus.authenticated(_user, business))),
      customerRepositoryProvider.overrideWithValue(customerRepository),
    ]);
    addTearDown(container.dispose);

    await _pumpRouter(tester, container);
    await tester.tap(find.byKey(const Key('home-nav-customers')));
    await tester.pumpAndSettle();

    expect(find.text('No customers yet'), findsOneWidget);
  });

  testWidgets('home screen navigates to the items list', (tester) async {
    final itemRepository = _MockItemRepository();
    when(() => itemRepository.list(search: null, category: null, includeInactive: false, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: [], total: 0, page: 1, pageSize: 20),
    );
    const business = Business(id: 'b1', name: 'Acme', onboardingCompletedAt: '2026-01-01T00:00:00.000Z');
    final container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(() => _FakeAuthController(const AuthStatus.authenticated(_user, business))),
      itemRepositoryProvider.overrideWithValue(itemRepository),
    ]);
    addTearDown(container.dispose);

    await _pumpRouter(tester, container);
    await tester.tap(find.byKey(const Key('home-nav-items')));
    await tester.pumpAndSettle();

    expect(find.text('No items yet'), findsOneWidget);
  });

  testWidgets('home screen navigates to the documents list', (tester) async {
    final documentRepository = _MockDocumentRepository();
    when(() => documentRepository.list(types: null, status: null, search: null, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: [], total: 0, page: 1, pageSize: 20),
    );
    const business = Business(id: 'b1', name: 'Acme', onboardingCompletedAt: '2026-01-01T00:00:00.000Z');
    final container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(() => _FakeAuthController(const AuthStatus.authenticated(_user, business))),
      documentRepositoryProvider.overrideWithValue(documentRepository),
    ]);
    addTearDown(container.dispose);

    await _pumpRouter(tester, container);
    await tester.tap(find.byKey(const Key('home-nav-documents')));
    await tester.pumpAndSettle();

    expect(find.text('No documents yet'), findsOneWidget);
  });

  testWidgets('the documents list FAB reaches the real document editor screen', (tester) async {
    final documentRepository = _MockDocumentRepository();
    when(() => documentRepository.list(types: null, status: null, search: null, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: [], total: 0, page: 1, pageSize: 20),
    );
    const business = Business(id: 'b1', name: 'Acme', onboardingCompletedAt: '2026-01-01T00:00:00.000Z');
    final container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(() => _FakeAuthController(const AuthStatus.authenticated(_user, business))),
      documentRepositoryProvider.overrideWithValue(documentRepository),
    ]);
    addTearDown(container.dispose);

    await _pumpRouter(tester, container);
    await tester.tap(find.byKey(const Key('home-nav-documents')));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Invoice').last);
    await tester.pumpAndSettle();

    expect(find.text('New Invoice'), findsOneWidget);
    expect(find.text('Choose a customer'), findsOneWidget);
  });
}

class _FakeAuthController extends AuthController {
  _FakeAuthController(this._status);
  final AuthStatus _status;

  @override
  Future<AuthStatus> build() async => _status;
}
