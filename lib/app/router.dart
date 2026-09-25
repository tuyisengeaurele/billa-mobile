import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/account/presentation/screens/appearance_screen.dart';
import '../features/account/presentation/screens/notification_preferences_screen.dart';
import '../features/account/presentation/screens/profile_screen.dart';
import '../features/account/presentation/screens/security_screen.dart';
import '../features/account/presentation/screens/sessions_screen.dart';
import '../features/account/presentation/screens/settings_screen.dart';
import '../features/account/presentation/screens/two_factor_setup_screen.dart';
import '../features/auth/domain/auth_status.dart';
import '../features/business_settings/presentation/screens/business_details_screen.dart';
import '../features/business_settings/presentation/screens/business_settings_screen.dart';
import '../features/business_settings/presentation/screens/document_settings_screen.dart';
import '../features/business_settings/presentation/screens/logo_screen.dart';
import '../features/business_settings/presentation/screens/numbering_screen.dart';
import '../features/business_settings/presentation/screens/payments_screen.dart';
import '../features/auth/presentation/providers/auth_controller.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/businesses/presentation/providers/my_businesses_provider.dart';
import '../features/businesses/presentation/screens/businesses_screen.dart';
import '../features/businesses/presentation/screens/join_business_screen.dart';
import '../features/customers/domain/customer.dart';
import '../features/customers/presentation/screens/customer_detail_screen.dart';
import '../features/customers/presentation/screens/customer_form_screen.dart';
import '../features/customers/presentation/screens/customer_list_screen.dart';
import '../features/documents/domain/document.dart';
import '../features/documents/domain/document_enums.dart';
import '../features/documents/presentation/screens/document_detail_screen.dart';
import '../features/documents/presentation/screens/document_editor_screen.dart';
import '../features/documents/presentation/screens/document_list_screen.dart';
import '../features/documents/presentation/screens/record_payment_screen.dart';
import '../features/items/domain/item.dart';
import '../features/items/presentation/screens/item_form_screen.dart';
import '../features/items/presentation/screens/item_list_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/receivables/presentation/screens/receivables_screen.dart';
import '../features/team/presentation/screens/team_screen.dart';
import 'theme/bootstrap_screen.dart';

const _authRoutes = {'/login', '/register'};

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshNotifier(ref),
    redirect: (context, state) {
      final status = ref.read(authControllerProvider).value;
      final path = state.uri.path;
      if (status == null) return path == '/bootstrap' ? null : '/bootstrap';

      return status.when(
        unauthenticated: () => _authRoutes.contains(path) ? null : '/login',
        // Handled inline by login_screen.dart — never a route-level redirect.
        twoFactorRequired: (challengeId) => null,
        authenticated: (user, business) {
          final needsOnboarding = business.onboardingCompletedAt == null;
          if (needsOnboarding) return path == '/onboarding' ? null : '/onboarding';
          return (_authRoutes.contains(path) || path == '/onboarding') ? '/' : null;
        },
      );
    },
    routes: [
      GoRoute(path: '/bootstrap', builder: (context, state) => const BootstrapScreen()),
      GoRoute(path: '/', builder: (context, state) => const _PlaceholderHomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/customers', builder: (context, state) => const CustomerListScreen()),
      GoRoute(path: '/customers/new', builder: (context, state) => const CustomerFormScreen()),
      GoRoute(
        path: '/customers/:id/edit',
        builder: (context, state) => CustomerFormScreen(existing: state.extra as Customer?),
      ),
      GoRoute(
        path: '/customers/:id',
        builder: (context, state) => CustomerDetailScreen(customerId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/items', builder: (context, state) => const ItemListScreen()),
      GoRoute(path: '/items/new', builder: (context, state) => const ItemFormScreen()),
      GoRoute(
        path: '/items/:id/edit',
        builder: (context, state) => ItemFormScreen(existing: state.extra as Item?),
      ),
      GoRoute(
        path: '/documents',
        builder: (context, state) {
          final status = switch (state.uri.queryParameters['status']) {
            'draft' => DocumentStatus.draft,
            'finalized' => DocumentStatus.finalized,
            _ => null,
          };
          final types = state.uri.queryParameters['types']
              ?.split(',')
              .map((name) => DocumentType.values.where((type) => type.name == name).firstOrNull)
              .whereType<DocumentType>()
              .toList();
          return DocumentListScreen(initialStatus: status, initialTypes: (types?.isEmpty ?? true) ? null : types);
        },
      ),
      GoRoute(
        path: '/documents/new',
        builder: (context, state) => DocumentEditorScreen.create(type: state.extra as DocumentType),
      ),
      GoRoute(
        path: '/documents/:id/edit',
        builder: (context, state) => DocumentEditorScreen.edit(documentId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/documents/:id',
        builder: (context, state) => DocumentDetailScreen(documentId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/documents/:id/payments/new',
        builder: (context, state) => RecordPaymentScreen(document: state.extra as Document),
      ),
      GoRoute(path: '/receivables', builder: (context, state) => const ReceivablesScreen()),
      GoRoute(path: '/businesses', builder: (context, state) => const BusinessesScreen()),
      GoRoute(path: '/businesses/join', builder: (context, state) => const JoinBusinessScreen()),
      GoRoute(path: '/team', builder: (context, state) => const TeamScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      GoRoute(path: '/settings/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/settings/security', builder: (context, state) => const SecurityScreen()),
      GoRoute(path: '/settings/security/two-factor', builder: (context, state) => const TwoFactorSetupScreen()),
      GoRoute(path: '/settings/security/sessions', builder: (context, state) => const SessionsScreen()),
      GoRoute(path: '/settings/notifications', builder: (context, state) => const NotificationPreferencesScreen()),
      GoRoute(path: '/settings/appearance', builder: (context, state) => const AppearanceScreen()),
      GoRoute(path: '/settings/business', builder: (context, state) => const BusinessSettingsScreen()),
      GoRoute(path: '/settings/business/details', builder: (context, state) => const BusinessDetailsScreen()),
      GoRoute(path: '/settings/business/payments', builder: (context, state) => const PaymentsScreen()),
      GoRoute(path: '/settings/business/documents', builder: (context, state) => const DocumentSettingsScreen()),
      GoRoute(path: '/settings/business/numbering', builder: (context, state) => const NumberingScreen()),
      GoRoute(path: '/settings/business/logo', builder: (context, state) => const LogoScreen()),
    ],
  );
});

class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(Ref ref) {
    ref.listen(authControllerProvider, (_, _) => notifyListeners());
  }
}

class _PlaceholderHomeScreen extends ConsumerWidget {
  const _PlaceholderHomeScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider).valueOrNull;
    final businessName = auth is Authenticated ? auth.business.name : null;
    final isOwner = ref.watch(isOwnerOfActiveBusinessProvider);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            key: const Key('home-account'),
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Account',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Billa', style: Theme.of(context).textTheme.displayMedium),
            if (businessName != null)
              TextButton.icon(
                key: const Key('home-business-switcher'),
                onPressed: () => context.push('/businesses'),
                icon: const Icon(Icons.swap_horiz),
                label: Text(businessName),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              key: const Key('home-nav-customers'),
              onPressed: () => context.push('/customers'),
              child: const Text('Customers'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              key: const Key('home-nav-items'),
              onPressed: () => context.push('/items'),
              child: const Text('Items'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              key: const Key('home-nav-documents'),
              onPressed: () => context.push('/documents'),
              child: const Text('Documents'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              key: const Key('home-nav-receivables'),
              onPressed: () => context.push('/receivables'),
              child: const Text('Receivables'),
            ),
            if (isOwner) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                key: const Key('home-nav-team'),
                onPressed: () => context.push('/team'),
                child: const Text('Team'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
