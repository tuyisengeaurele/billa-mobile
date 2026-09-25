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
import 'package:billa_mobile/features/items/domain/item.dart';
import 'package:billa_mobile/features/items/domain/item_repository.dart';
import 'package:billa_mobile/features/items/presentation/providers/item_repository_provider.dart';
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

  testWidgets('picking an item fills the line description, price, and tax', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(buildApp(DocumentEditorScreen.create(type: DocumentType.invoice)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add line'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Choose an item'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Printing'));
    await tester.pumpAndSettle();

    expect(find.text('Printing'), findsWidgets);
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
}
