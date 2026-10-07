import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/pagination/paginated_result.dart';
import 'package:billa_mobile/features/customers/domain/customer.dart';
import 'package:billa_mobile/features/customers/domain/customer_repository.dart';
import 'package:billa_mobile/features/customers/presentation/providers/customer_repository_provider.dart';
import 'package:billa_mobile/features/customers/presentation/screens/customer_list_screen.dart';
import 'package:billa_mobile/features/documents/domain/document.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/domain/document_repository.dart';
import 'package:billa_mobile/features/documents/presentation/providers/document_repository_provider.dart';
import 'package:billa_mobile/features/documents/presentation/screens/document_list_screen.dart';
import 'package:billa_mobile/features/items/domain/item.dart';
import 'package:billa_mobile/features/items/domain/item_repository.dart';
import 'package:billa_mobile/features/items/presentation/providers/item_repository_provider.dart';
import 'package:billa_mobile/features/items/presentation/screens/item_list_screen.dart';

class _MockCustomerRepository extends Mock implements CustomerRepository {}

class _MockItemRepository extends Mock implements ItemRepository {}

class _MockDocumentRepository extends Mock implements DocumentRepository {}

// The list controllers outlive their screens, so what was typed or toggled on
// an earlier visit stays applied while a reopened screen starts out blank.
// Each test types a search, leaves, comes back, and expects the default list.
void main() {
  Widget host(ProviderContainer container, Widget screen) => UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: screen),
      );

  Future<void> searchThenReopen(
    WidgetTester tester,
    ProviderContainer container,
    Widget Function() screen,
    Key searchKey,
  ) async {
    await tester.pumpWidget(host(container, screen()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(searchKey), 'zzz');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(host(container, screen()));
    await tester.pumpAndSettle();
  }

  String searchText(WidgetTester tester, Key key) => tester.widget<TextField>(find.byKey(key)).controller?.text ?? '';

  testWidgets('customers: reopening clears a search left from an earlier visit', (tester) async {
    final repository = _MockCustomerRepository();
    when(() => repository.list(search: null, includeInactive: false, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(
        results: [Customer(id: 'c1', name: 'Default Customer', isActive: true, createdAt: '2026-01-01T00:00:00.000Z')],
        total: 1,
        page: 1,
        pageSize: 20,
      ),
    );
    when(() => repository.list(search: 'zzz', includeInactive: false, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: <Customer>[], total: 0, page: 1, pageSize: 20),
    );
    final container = ProviderContainer(overrides: [customerRepositoryProvider.overrideWithValue(repository)]);
    addTearDown(container.dispose);

    await searchThenReopen(tester, container, () => const CustomerListScreen(), const Key('customer-search'));

    expect(searchText(tester, const Key('customer-search')), '');
    expect(find.text('Default Customer'), findsOneWidget);
  });

  testWidgets('items: reopening clears a search left from an earlier visit', (tester) async {
    final repository = _MockItemRepository();
    when(() => repository.list(search: null, category: null, includeInactive: false, page: 1, pageSize: 20))
        .thenAnswer(
      (_) async => const PaginatedResult(
        results: [Item(id: 'i1', description: 'Default Item', unitPrice: 100, unit: 'pc', taxRate: 18, isActive: true)],
        total: 1,
        page: 1,
        pageSize: 20,
      ),
    );
    when(() => repository.list(search: 'zzz', category: null, includeInactive: false, page: 1, pageSize: 20))
        .thenAnswer((_) async => const PaginatedResult(results: <Item>[], total: 0, page: 1, pageSize: 20));
    final container = ProviderContainer(overrides: [itemRepositoryProvider.overrideWithValue(repository)]);
    addTearDown(container.dispose);

    await searchThenReopen(tester, container, () => const ItemListScreen(), const Key('item-search'));

    expect(searchText(tester, const Key('item-search')), '');
    expect(find.text('Default Item'), findsOneWidget);
  });

  testWidgets('documents: reopening clears a search left from an earlier visit', (tester) async {
    final repository = _MockDocumentRepository();
    const document = Document(
      id: 'd1',
      type: DocumentType.invoice,
      number: 'INV-DEFAULT',
      status: DocumentStatus.finalized,
      customerId: 'c1',
      customer: DocumentCustomerRef(name: 'Acme'),
      issueDate: '2026-01-01T00:00:00.000Z',
      subtotal: 100,
      taxTotal: 18,
      total: 118,
      amountPaid: 0,
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
    );
    when(() => repository.list(types: null, status: null, search: null, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: [document], total: 1, page: 1, pageSize: 20),
    );
    when(() => repository.list(types: null, status: null, search: 'zzz', page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: <Document>[], total: 0, page: 1, pageSize: 20),
    );
    final container = ProviderContainer(overrides: [documentRepositoryProvider.overrideWithValue(repository)]);
    addTearDown(container.dispose);

    await searchThenReopen(tester, container, () => const DocumentListScreen(), const Key('document-search'));

    expect(searchText(tester, const Key('document-search')), '');
    expect(find.text('INV-DEFAULT'), findsOneWidget);
  });

  testWidgets('customers: reopening also clears an inactive toggle left on', (tester) async {
    final repository = _MockCustomerRepository();
    when(() => repository.list(search: null, includeInactive: false, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(
        results: [Customer(id: 'c1', name: 'Active Customer', isActive: true, createdAt: '2026-01-01T00:00:00.000Z')],
        total: 1,
        page: 1,
        pageSize: 20,
      ),
    );
    when(() => repository.list(search: null, includeInactive: true, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(
        results: [Customer(id: 'c2', name: 'Inactive Customer', isActive: false, createdAt: '2026-01-01T00:00:00.000Z')],
        total: 1,
        page: 1,
        pageSize: 20,
      ),
    );
    final container = ProviderContainer(overrides: [customerRepositoryProvider.overrideWithValue(repository)]);
    addTearDown(container.dispose);

    await tester.pumpWidget(host(container, const CustomerListScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilterChip));
    await tester.pumpAndSettle();
    expect(find.text('Inactive Customer'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(host(container, const CustomerListScreen()));
    await tester.pumpAndSettle();

    expect(tester.widget<FilterChip>(find.byType(FilterChip)).selected, isFalse);
    expect(find.text('Active Customer'), findsOneWidget);
  });
}
