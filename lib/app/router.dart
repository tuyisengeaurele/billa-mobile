import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/providers/auth_controller.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
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
      GoRoute(path: '/documents', builder: (context, state) => const DocumentListScreen()),
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
    ],
  );
});

class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(Ref ref) {
    ref.listen(authControllerProvider, (_, _) => notifyListeners());
  }
}

class _PlaceholderHomeScreen extends StatelessWidget {
  const _PlaceholderHomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Billa', style: Theme.of(context).textTheme.displayMedium),
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
          ],
        ),
      ),
    );
  }
}
