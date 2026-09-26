import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/pagination/paginated_result.dart';
import 'package:billa_mobile/features/customers/domain/customer.dart';
import 'package:billa_mobile/features/customers/domain/customer_repository.dart';
import 'package:billa_mobile/features/customers/presentation/providers/customer_repository_provider.dart';
import 'package:billa_mobile/features/documents/domain/document.dart';
import 'package:billa_mobile/features/documents/domain/document_draft_input.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/domain/document_repository.dart';
import 'package:billa_mobile/features/documents/presentation/providers/document_repository_provider.dart';
import 'package:billa_mobile/features/documents/presentation/screens/document_editor_screen.dart';
import 'package:billa_mobile/features/documents/presentation/widgets/item_search_field.dart';
import 'package:billa_mobile/features/items/domain/item.dart';
import 'package:billa_mobile/features/items/domain/item_repository.dart';
import 'package:billa_mobile/features/auth/presentation/providers/active_business_provider.dart';
import 'package:billa_mobile/features/items/presentation/providers/item_repository_provider.dart';
import 'package:billa_mobile/features/items/presentation/providers/recent_items_provider.dart';
import '../../../../support/tall_screen.dart';

class _MockDocumentRepository extends Mock implements DocumentRepository {}
class _MockCustomerRepository extends Mock implements CustomerRepository {}
class _MockItemRepository extends Mock implements ItemRepository {}
class _FakeDocumentDraftInput extends Fake implements DocumentDraftInput {}

const _customer = Customer(id: 'c1', name: 'Acme', isActive: true, createdAt: '2026-01-01T00:00:00.000Z');
const _item = Item(id: 'i1', description: 'Printing', unitPrice: 5000, unit: 'unit', taxRate: 18, isActive: true);
const _documentCustomer = DocumentCustomerRef(name: 'Acme');
Document _savedDocument() => Document(
      id: 'd1',
      type: DocumentType.invoice,
      status: DocumentStatus.draft,
      customerId: 'c1',
      customer: _documentCustomer,
      issueDate: '2026-01-01T00:00:00.000Z',
      subtotal: 0,
      taxTotal: 0,
      total: 0,
      amountPaid: 0,
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
    );

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeDocumentDraftInput());
  });

  late _MockDocumentRepository documentRepository;
  late _MockCustomerRepository customerRepository;
  late _MockItemRepository itemRepository;

  setUp(() {
    documentRepository = _MockDocumentRepository();
    customerRepository = _MockCustomerRepository();
    itemRepository = _MockItemRepository();
    when(() => customerRepository.list(search: any(named: 'search'))).thenAnswer(
      (_) async => const PaginatedResult(results: [_customer], total: 1, page: 1, pageSize: 20),
    );
    when(() => itemRepository.list(search: any(named: 'search'))).thenAnswer(
      (_) async => const PaginatedResult(results: [_item], total: 1, page: 1, pageSize: 20),
    );
  });

  Widget buildApp(Widget screen) {
    return ProviderScope(
      overrides: [
        documentRepositoryProvider.overrideWithValue(documentRepository),
        customerRepositoryProvider.overrideWithValue(customerRepository),
        itemRepositoryProvider.overrideWithValue(itemRepository),
      ],
      child: MaterialApp(theme: AppTheme.light, home: screen),
    );
  }

  testWidgets('picking a customer triggers an autosave', (tester) async {
    when(() => documentRepository.create(any())).thenAnswer((_) async => _savedDocument());

    await tester.pumpWidget(buildApp(DocumentEditorScreen.create(type: DocumentType.invoice)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Choose a customer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Acme'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    verify(() => documentRepository.create(any())).called(1);
  });

  testWidgets('choosing an item from the type-ahead fills the line description, price, and tax', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(buildApp(DocumentEditorScreen.create(type: DocumentType.invoice)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add line'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ItemSearchField));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('item-option-i1')));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    final fields = tester.widgetList<TextField>(find.byType(TextField)).map((f) => f.controller?.text).toList();
    expect(fields, containsAll(['Printing', '5000', '18.0']));
  });

  testWidgets('typing a custom description keeps the line free of any item', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(buildApp(DocumentEditorScreen.create(type: DocumentType.invoice)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add line'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(ItemSearchField), 'Delivery to Huye');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('Use "Delivery to Huye" as the description'), findsOneWidget);
    expect(find.text('Enter a description'), findsNothing);
  });

  testWidgets('a credit note cannot autosave without a chosen reference invoice', (tester) async {
    await tester.pumpWidget(buildApp(DocumentEditorScreen.create(type: DocumentType.creditNote)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Choose a customer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Acme'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    verifyNever(() => documentRepository.create(any()));
  });

  testWidgets('a failed autosave says why, keeps the draft on screen, and Retry saves it', (tester) async {
    var failing = true;
    when(() => documentRepository.create(any())).thenAnswer((_) async {
      if (failing) throw DioException(requestOptions: RequestOptions(path: '/documents'), type: DioExceptionType.connectionError);
      return _savedDocument();
    });

    useTallScreen(tester);
    await tester.pumpWidget(buildApp(DocumentEditorScreen.create(type: DocumentType.invoice)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose a customer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Acme'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(find.text('Check your connection and try again'), findsOneWidget);
    expect(find.text('Acme'), findsWidgets);

    failing = false;
    await tester.tap(find.byKey(const Key('editor-save-retry')));
    await tester.pumpAndSettle();

    expect(find.text('Check your connection and try again'), findsNothing);
    verify(() => documentRepository.create(any())).called(2);
  });

  group('recent items', () {
    Widget buildWithRecents(Widget screen, InMemoryRecentItemsStore store) => ProviderScope(
          overrides: [
            documentRepositoryProvider.overrideWithValue(documentRepository),
            customerRepositoryProvider.overrideWithValue(customerRepository),
            itemRepositoryProvider.overrideWithValue(itemRepository),
            recentItemsStoreProvider.overrideWithValue(store),
            activeBusinessIdProvider.overrideWith((ref) => 'b1'),
          ],
          child: MaterialApp(theme: AppTheme.light, home: screen),
        );

    testWidgets('an empty line offers the recently used items and a tap fills it', (tester) async {
      final store = InMemoryRecentItemsStore();
      await store.write('b1', [_item]);
      when(() => documentRepository.create(any())).thenAnswer((_) async => _savedDocument());

      useTallScreen(tester);
      await tester.pumpWidget(buildWithRecents(DocumentEditorScreen.create(type: DocumentType.invoice), store));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add line'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('recent-item-i1')));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, 'Printing'), findsOneWidget);
      expect(find.byKey(const Key('recent-item-i1')), findsNothing);
    });

    testWidgets('an item chosen from the search is remembered for next time', (tester) async {
      final store = InMemoryRecentItemsStore();
      when(() => documentRepository.create(any())).thenAnswer((_) async => _savedDocument());

      useTallScreen(tester);
      await tester.pumpWidget(buildWithRecents(DocumentEditorScreen.create(type: DocumentType.invoice), store));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add line'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('line-description-0')), 'Prin');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Printing').last);
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(store.read('b1').map((i) => i.id), ['i1']);
    });
  });
}
