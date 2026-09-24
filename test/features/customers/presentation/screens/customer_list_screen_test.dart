import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/pagination/paginated_result.dart';
import 'package:billa_mobile/features/customers/domain/customer.dart';
import 'package:billa_mobile/features/customers/domain/customer_repository.dart';
import 'package:billa_mobile/features/customers/presentation/providers/customer_repository_provider.dart';
import 'package:billa_mobile/features/customers/presentation/screens/customer_list_screen.dart';

class _MockCustomerRepository extends Mock implements CustomerRepository {}

void main() {
  late _MockCustomerRepository repository;

  setUp(() {
    repository = _MockCustomerRepository();
  });

  Widget buildApp() {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => const CustomerListScreen()),
      GoRoute(path: '/customers/new', builder: (context, state) => const Scaffold(body: Text('new customer screen'))),
    ]);
    return ProviderScope(
      overrides: [customerRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  testWidgets('shows the empty state with a working add-customer action', (tester) async {
    when(() => repository.list(search: null, includeInactive: false, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: <Customer>[], total: 0, page: 1, pageSize: 20),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('No customers yet'), findsOneWidget);
    await tester.tap(find.text('Add customer'));
    await tester.pumpAndSettle();

    expect(find.text('new customer screen'), findsOneWidget);
  });

  testWidgets('typing in search debounces to a single repository call', (tester) async {
    when(() => repository.list(search: null, includeInactive: false, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: <Customer>[], total: 0, page: 1, pageSize: 20),
    );
    when(() => repository.list(search: 'acme', includeInactive: false, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(
        results: [Customer(id: 'c1', name: 'Acme', isActive: true, createdAt: '2026-01-01T00:00:00.000Z')],
        total: 1,
        page: 1,
        pageSize: 20,
      ),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('customer-search')), 'acme');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    verify(() => repository.list(search: 'acme', includeInactive: false, page: 1, pageSize: 20)).called(1);
  });
}
