import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/pagination/paginated_result.dart';
import 'package:billa_mobile/features/customers/domain/customer.dart';
import 'package:billa_mobile/features/customers/domain/customer_repository.dart';
import 'package:billa_mobile/features/customers/presentation/providers/customer_list_controller.dart';
import 'package:billa_mobile/features/customers/presentation/providers/customer_repository_provider.dart';
import 'package:billa_mobile/features/customers/presentation/screens/customer_list_screen.dart';
import 'package:billa_mobile/features/receivables/domain/outstanding_invoice.dart';
import 'package:billa_mobile/features/receivables/domain/receivables_repository.dart';
import 'package:billa_mobile/features/receivables/presentation/providers/receivables_repository_provider.dart';
import 'package:billa_mobile/features/receivables/presentation/screens/receivables_screen.dart';

class _MockCustomerRepository extends Mock implements CustomerRepository {}

class _MockReceivablesRepository extends Mock implements ReceivablesRepository {}

Customer _customer(String id, String name) =>
    Customer(id: id, name: name, isActive: true, createdAt: '2026-01-01T00:00:00.000Z');

PaginatedResult<Customer> _page(List<Customer> customers) =>
    PaginatedResult(results: customers, total: customers.length, page: 1, pageSize: 20);

DioException _offline() =>
    DioException(requestOptions: RequestOptions(path: '/x'), type: DioExceptionType.connectionError);

void main() {
  late _MockCustomerRepository customers;

  setUp(() {
    customers = _MockCustomerRepository();
  });

  Widget host(ProviderContainer container, Widget screen) => UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: screen),
      );

  ProviderContainer containerWith(List<Override> overrides) {
    final container = ProviderContainer(overrides: overrides);
    addTearDown(container.dispose);
    return container;
  }

  Future<void> pullDown(WidgetTester tester, Finder scrollable) async {
    await tester.fling(scrollable, const Offset(0, 400), 1000);
    await tester.pumpAndSettle();
  }

  group('controller', () {
    test('pullToRefresh keeps the list on screen while it refetches and swaps in the new data', () async {
      when(() => customers.list(search: null, includeInactive: false, page: 1, pageSize: 20))
          .thenAnswer((_) async => _page([_customer('c1', 'Old')]));
      final container = containerWith([customerRepositoryProvider.overrideWithValue(customers)]);
      await container.read(customerListControllerProvider.future);

      when(() => customers.list(search: null, includeInactive: false, page: 1, pageSize: 20))
          .thenAnswer((_) async => _page([_customer('c2', 'New')]));
      final states = <bool>[];
      container.listen(customerListControllerProvider, (_, next) => states.add(next.isLoading));

      final ok = await container.read(customerListControllerProvider.notifier).pullToRefresh();

      expect(ok, isTrue);
      expect(states.contains(true), isFalse);
      expect(container.read(customerListControllerProvider).value!.items.single.name, 'New');
    });

    test('a failed pullToRefresh keeps the old list and reports failure', () async {
      when(() => customers.list(search: null, includeInactive: false, page: 1, pageSize: 20))
          .thenAnswer((_) async => _page([_customer('c1', 'Old')]));
      final container = containerWith([customerRepositoryProvider.overrideWithValue(customers)]);
      await container.read(customerListControllerProvider.future);

      when(() => customers.list(search: null, includeInactive: false, page: 1, pageSize: 20))
          .thenAnswer((_) async => throw _offline());
      final ok = await container.read(customerListControllerProvider.notifier).pullToRefresh();

      expect(ok, isFalse);
      expect(container.read(customerListControllerProvider).value!.items.single.name, 'Old');
    });
  });

  group('customers screen', () {
    testWidgets('pulling down refetches and shows the new rows', (tester) async {
      when(() => customers.list(search: null, includeInactive: false, page: 1, pageSize: 20))
          .thenAnswer((_) async => _page([_customer('c1', 'Old')]));
      final container = containerWith([customerRepositoryProvider.overrideWithValue(customers)]);

      await tester.pumpWidget(host(container, const CustomerListScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Old'), findsOneWidget);

      when(() => customers.list(search: null, includeInactive: false, page: 1, pageSize: 20))
          .thenAnswer((_) async => _page([_customer('c2', 'New')]));
      await pullDown(tester, find.byType(ListView).last);

      expect(find.text('New'), findsOneWidget);
      expect(find.text('Old'), findsNothing);
    });

    testWidgets('a failed refresh keeps the rows and says so with a way to retry', (tester) async {
      when(() => customers.list(search: null, includeInactive: false, page: 1, pageSize: 20))
          .thenAnswer((_) async => _page([_customer('c1', 'Old')]));
      final container = containerWith([customerRepositoryProvider.overrideWithValue(customers)]);

      await tester.pumpWidget(host(container, const CustomerListScreen()));
      await tester.pumpAndSettle();
      when(() => customers.list(search: null, includeInactive: false, page: 1, pageSize: 20))
          .thenAnswer((_) async => throw _offline());
      await pullDown(tester, find.byType(ListView).last);

      expect(find.text('Old'), findsOneWidget);
      expect(find.text("Couldn't refresh. Check your connection and try again"), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('an empty list can be pulled down to refetch', (tester) async {
      when(() => customers.list(search: null, includeInactive: false, page: 1, pageSize: 20))
          .thenAnswer((_) async => _page([]));
      final container = containerWith([customerRepositoryProvider.overrideWithValue(customers)]);

      await tester.pumpWidget(host(container, const CustomerListScreen()));
      await tester.pumpAndSettle();
      expect(find.text('No customers yet'), findsOneWidget);

      when(() => customers.list(search: null, includeInactive: false, page: 1, pageSize: 20))
          .thenAnswer((_) async => _page([_customer('c1', 'First customer')]));
      await pullDown(tester, find.byType(SingleChildScrollView).last);

      expect(find.text('First customer'), findsOneWidget);
    });

    testWidgets('an error state can be pulled down to try again', (tester) async {
      var failing = true;
      when(() => customers.list(search: null, includeInactive: false, page: 1, pageSize: 20)).thenAnswer((_) async {
        if (failing) throw _offline();
        return _page([_customer('c1', 'Back again')]);
      });
      final container = containerWith([customerRepositoryProvider.overrideWithValue(customers)]);

      await tester.pumpWidget(host(container, const CustomerListScreen()));
      await tester.pumpAndSettle();
      expect(find.text("Couldn't load your customers"), findsOneWidget);

      failing = false;
      await pullDown(tester, find.byType(SingleChildScrollView).last);

      expect(find.text('Back again'), findsOneWidget);
    });
  });

  group('receivables screen', () {
    testWidgets('pulling down reloads the outstanding invoices', (tester) async {
      final repository = _MockReceivablesRepository();
      var calls = 0;
      when(() => repository.list()).thenAnswer((_) async {
        calls++;
        return [
          OutstandingInvoice(
            id: 'd$calls',
            number: 'INV-$calls',
            customerName: 'Customer $calls',
            amountOwed: 1000 * calls,
            total: 1000 * calls,
            daysOverdue: 0,
            agingBucket: 'current',
          ),
        ];
      });
      final container = containerWith([receivablesRepositoryProvider.overrideWithValue(repository)]);

      await tester.pumpWidget(host(container, const ReceivablesScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Customer 1'), findsOneWidget);

      await pullDown(tester, find.byType(ListView).last);

      expect(find.text('Customer 2'), findsOneWidget);
      expect(calls, 2);
    });
  });
}
