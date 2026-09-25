import 'package:animations/animations.dart';
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
import 'package:billa_mobile/features/receivables/domain/receivables_repository.dart';
import 'package:billa_mobile/features/receivables/presentation/providers/receivables_repository_provider.dart';
import 'package:billa_mobile/features/businesses/domain/business_summary.dart';
import 'package:billa_mobile/features/businesses/domain/businesses_repository.dart';
import 'package:billa_mobile/features/businesses/presentation/providers/businesses_repository_provider.dart';
import 'package:billa_mobile/features/team/domain/team_repository.dart';
import 'package:billa_mobile/features/team/presentation/providers/team_repository_provider.dart';
import 'package:billa_mobile/features/account/domain/profile_repository.dart';
import 'package:billa_mobile/features/account/domain/security_repository.dart';
import 'package:billa_mobile/features/account/presentation/providers/profile_repository_provider.dart';
import 'package:billa_mobile/features/account/presentation/providers/security_repository_provider.dart';
import 'package:billa_mobile/features/business_settings/domain/business_settings.dart';
import 'package:billa_mobile/features/business_settings/domain/business_settings_repository.dart';
import 'package:billa_mobile/features/business_settings/domain/subscription_status.dart';
import 'package:billa_mobile/features/business_settings/presentation/providers/business_settings_repository_provider.dart';

const _user = AuthUser(id: 'u1', email: 'a@b.com', totpEnabled: false, isAdmin: false);

class _MockCustomerRepository extends Mock implements CustomerRepository {}
class _MockItemRepository extends Mock implements ItemRepository {}
class _MockDocumentRepository extends Mock implements DocumentRepository {}
class _MockReceivablesRepository extends Mock implements ReceivablesRepository {}
class _MockBusinessesRepository extends Mock implements BusinessesRepository {}

class _MockTeamRepository extends Mock implements TeamRepository {}
class _MockProfileRepository extends Mock implements ProfileRepository {}
class _MockSecurityRepository extends Mock implements SecurityRepository {}
class _MockBusinessSettingsRepository extends Mock implements BusinessSettingsRepository {}

ProviderContainer _homeContainer(
  List<BusinessSummary> summaries, {
  TeamRepository? teamRepository,
  List<Override> extraOverrides = const [],
}) {
  final businessesRepository = _MockBusinessesRepository();
  when(() => businessesRepository.list()).thenAnswer((_) async => summaries);
  const business = Business(id: 'b1', name: 'Acme', onboardingCompletedAt: '2026-01-01T00:00:00.000Z');
  return ProviderContainer(overrides: [
    authControllerProvider.overrideWith(() => _FakeAuthController(const AuthStatus.authenticated(_user, business))),
    businessesRepositoryProvider.overrideWithValue(businessesRepository),
    if (teamRepository != null) teamRepositoryProvider.overrideWithValue(teamRepository),
    ...extraOverrides,
  ]);
}

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

  testWidgets('home screen navigates to receivables', (tester) async {
    final receivablesRepository = _MockReceivablesRepository();
    when(() => receivablesRepository.list()).thenAnswer((_) async => []);
    const business = Business(id: 'b1', name: 'Acme', onboardingCompletedAt: '2026-01-01T00:00:00.000Z');
    final container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(() => _FakeAuthController(const AuthStatus.authenticated(_user, business))),
      receivablesRepositoryProvider.overrideWithValue(receivablesRepository),
    ]);
    addTearDown(container.dispose);

    await _pumpRouter(tester, container);
    await tester.tap(find.byKey(const Key('home-nav-receivables')));
    await tester.pumpAndSettle();

    expect(find.text('Nothing outstanding. All invoices are paid up'), findsOneWidget);
  });

  testWidgets('home shows the business name and an owner-only Team button', (tester) async {
    final container = _homeContainer([const BusinessSummary(id: 'b1', name: 'Acme', isOwner: true)]);
    addTearDown(container.dispose);

    await _pumpRouter(tester, container);

    expect(find.text('Acme'), findsOneWidget);
    expect(find.byKey(const Key('home-nav-team')), findsOneWidget);
  });

  testWidgets('home hides the Team button for a non-owner', (tester) async {
    final container = _homeContainer([const BusinessSummary(id: 'b1', name: 'Acme', isOwner: false)]);
    addTearDown(container.dispose);

    await _pumpRouter(tester, container);

    expect(find.byKey(const Key('home-nav-team')), findsNothing);
  });

  testWidgets('the business switcher opens the businesses screen', (tester) async {
    final container = _homeContainer([
      const BusinessSummary(id: 'b1', name: 'Acme', isOwner: true),
      const BusinessSummary(id: 'b2', name: 'Other Co', isOwner: false),
    ]);
    addTearDown(container.dispose);

    await _pumpRouter(tester, container);
    await tester.tap(find.byKey(const Key('home-business-switcher')));
    await tester.pumpAndSettle();

    expect(find.text('Other Co'), findsOneWidget);
    expect(find.text('Join a business'), findsOneWidget);
  });

  testWidgets('the Team button opens the team screen for an owner', (tester) async {
    final teamRepository = _MockTeamRepository();
    when(() => teamRepository.members()).thenAnswer((_) async => []);
    when(() => teamRepository.invites()).thenAnswer((_) async => []);
    final container = _homeContainer(
      [const BusinessSummary(id: 'b1', name: 'Acme', isOwner: true)],
      teamRepository: teamRepository,
    );
    addTearDown(container.dispose);

    await _pumpRouter(tester, container);
    await tester.tap(find.byKey(const Key('home-nav-team')));
    await tester.pumpAndSettle();

    expect(find.text('No pending invites'), findsOneWidget);
  });

  testWidgets('the account icon opens settings with the signed-in email', (tester) async {
    final container = _homeContainer([const BusinessSummary(id: 'b1', name: 'Acme', isOwner: true)]);
    addTearDown(container.dispose);

    await _pumpRouter(tester, container);
    await tester.tap(find.byKey(const Key('home-account')));
    await tester.pumpAndSettle();

    expect(find.text('a@b.com'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
  });

  testWidgets('settings rows open profile, security, notifications, and appearance', (tester) async {
    final profileRepository = _MockProfileRepository();
    when(() => profileRepository.notificationPreferences()).thenAnswer((_) async => {});
    final securityRepository = _MockSecurityRepository();
    final businessesRepository = _MockBusinessesRepository();
    when(() => businessesRepository.list()).thenAnswer(
      (_) async => [const BusinessSummary(id: 'b1', name: 'Acme', isOwner: true)],
    );
    const business = Business(id: 'b1', name: 'Acme', onboardingCompletedAt: '2026-01-01T00:00:00.000Z');
    final container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(() => _FakeAuthController(const AuthStatus.authenticated(_user, business))),
      businessesRepositoryProvider.overrideWithValue(businessesRepository),
      profileRepositoryProvider.overrideWithValue(profileRepository),
      securityRepositoryProvider.overrideWithValue(securityRepository),
    ]);
    addTearDown(container.dispose);

    final router = await _pumpRouter(tester, container);
    for (final (key, marker) in [
      ('settings-profile', 'Change photo'),
      ('settings-security', 'Signed-in devices'),
      ('settings-notifications', 'Payment received'),
      ('settings-appearance', 'System default'),
    ]) {
      router.go('/settings');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key(key)));
      await tester.pumpAndSettle();

      expect(find.text(marker), findsOneWidget);
    }
  });

  testWidgets('an owner reaches every business settings section from settings', (tester) async {
    final settingsRepository = _MockBusinessSettingsRepository();
    when(() => settingsRepository.get()).thenAnswer((_) async => const BusinessSettings(id: 'b1', name: 'Acme'));
    when(() => settingsRepository.subscription()).thenAnswer(
      (_) async => const SubscriptionStatus(trialEndsAt: '2026-03-01T00:00:00.000Z'),
    );
    when(() => settingsRepository.sequences()).thenAnswer((_) async => []);
    final container = _homeContainer(
      [const BusinessSummary(id: 'b1', name: 'Acme', isOwner: true)],
      extraOverrides: [businessSettingsRepositoryProvider.overrideWithValue(settingsRepository)],
    );
    addTearDown(container.dispose);

    final router = await _pumpRouter(tester, container);
    router.go('/settings');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-business')));
    await tester.pumpAndSettle();

    expect(find.text('Free trial until 2026-03-01'), findsOneWidget);
    for (final (key, marker) in [
      ('bs-details', 'Business name'),
      ('bs-payments', 'Bank name (optional)'),
      ('bs-documents', 'Default template'),
      ('bs-numbering', 'The next document of each type is numbered from these settings.'),
      ('bs-logo', 'Current logo'),
    ]) {
      await tester.tap(find.byKey(Key(key)));
      await tester.pumpAndSettle();
      expect(find.text(marker), findsOneWidget, reason: key);
      router.pop();
      await tester.pumpAndSettle();
    }
  });


  testWidgets('top-level screens switch with a fade-through', (tester) async {
    final container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(() => _FakeAuthController(const AuthStatus.unauthenticated())),
    ]);
    addTearDown(container.dispose);

    final router = await _pumpRouter(tester, container);
    expect(find.byType(FadeThroughTransition), findsWidgets);

    router.go('/register');
    await tester.pumpAndSettle();
    expect(find.byType(FadeThroughTransition), findsWidgets);
    expect(router.routerDelegate.currentConfiguration.uri.toString(), '/register');
  });
}

class _FakeAuthController extends AuthController {
  _FakeAuthController(this._status);
  final AuthStatus _status;

  @override
  Future<AuthStatus> build() async => _status;
}
