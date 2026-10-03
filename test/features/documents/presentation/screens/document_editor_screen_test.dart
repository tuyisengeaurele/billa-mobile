import 'package:billa_mobile/features/documents/domain/exchange_rates.dart';
import 'package:billa_mobile/core/formatting/currency.dart';
import 'package:billa_mobile/core/privacy/privacy_scope.dart';
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

  testWidgets('a draft with a payment plan no longer says the plan can only be changed on the web', (tester) async {
    when(() => documentRepository.get('d1')).thenAnswer((_) async => _savedDocument().copyWith(
          installments: const [
            DocumentInstallment(amount: 4000, dueDate: '2026-10-01T00:00:00.000Z'),
            DocumentInstallment(amount: 7800, dueDate: '2026-11-01T00:00:00.000Z'),
          ],
        ));

    await tester.pumpWidget(buildApp(DocumentEditorScreen.edit(documentId: 'd1')));
    await tester.pumpAndSettle();

    expect(find.textContaining('set up on the web'), findsNothing);
  });

  testWidgets('choosing USD shows the bank rate, and a price is typed in dollars and cents', (tester) async {
    when(() => documentRepository.rates()).thenAnswer(
      (_) async => const ExchangeRates({Currency.usd: RateQuote(rate: 1400, source: 'BNR', date: '2026-09-29')}),
    );
    when(() => documentRepository.create(any())).thenAnswer((_) async => _savedDocument());
    useTallScreen(tester);

    await tester.pumpWidget(buildApp(DocumentEditorScreen.create(type: DocumentType.invoice)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('document-editor-currency')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('USD (US dollar)').last);
    await tester.pumpAndSettle();

    expect(find.text('1400'), findsOneWidget);
    expect(find.textContaining('National Bank of Rwanda reference rate, 29 Sep 2026.'), findsOneWidget);

    await tester.tap(find.text('Add line'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('line-unit-price-0')), '12.50');
    await tester.pumpAndSettle();

    expect(find.text('USD 12.50'), findsWidgets);
  });

  testWidgets('switching a discount from percent to a flat amount starts the amount at zero, not at the percent', (tester) async {
    when(() => documentRepository.rates()).thenAnswer(
      (_) async => const ExchangeRates({Currency.usd: RateQuote(rate: 1400, source: 'BNR', date: '2026-09-29')}),
    );
    useTallScreen(tester);

    await tester.pumpWidget(buildApp(DocumentEditorScreen.create(type: DocumentType.invoice)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('document-editor-currency')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('USD (US dollar)').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add line'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButton<DiscountType?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('% off').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('line-discount-value-0')), '10');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButton<DiscountType?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('USD off').last);
    await tester.pumpAndSettle();

    final box = tester.widget<TextField>(
      find.descendant(of: find.byKey(const ValueKey('line-discount-value-0')), matching: find.byType(TextField)),
    );
    expect(box.controller!.text, '0');
  });

  testWidgets('amounts stay readable while a document is being written, even with privacy mode on', (tester) async {
    useTallScreen(tester);

    await tester.pumpWidget(
      PrivacyScope(hidden: true, child: buildApp(DocumentEditorScreen.create(type: DocumentType.invoice))),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add line'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('line-unit-price-0')), '5000');
    await tester.pumpAndSettle();

    expect(find.text('RWF 5,900'), findsOneWidget);
    expect(find.textContaining('•'), findsNothing);
  });

  testWidgets('picking a payment term fills the due date and marks the term', (tester) async {
    useTallScreen(tester);

    await tester.pumpWidget(buildApp(DocumentEditorScreen.create(type: DocumentType.invoice)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('payment-term-14')));
    await tester.pumpAndSettle();

    final due = DateTime.now().add(const Duration(days: 14));
    final expected =
        '${due.year.toString().padLeft(4, '0')}-${due.month.toString().padLeft(2, '0')}-${due.day.toString().padLeft(2, '0')}';
    expect(find.text('Due $expected'), findsOneWidget);
    expect(tester.widget<ChoiceChip>(find.byKey(const Key('payment-term-14'))).selected, isTrue);
    expect(tester.widget<ChoiceChip>(find.byKey(const Key('payment-term-30'))).selected, isFalse);
  });

  testWidgets('an invoice that would pass the customer credit limit says so, a quote does not', (tester) async {
    when(() => customerRepository.get('c1')).thenAnswer(
      (_) async => const Customer(
        id: 'c1',
        name: 'Acme',
        isActive: true,
        createdAt: '2026-01-01T00:00:00.000Z',
        creditLimit: 100,
        outstandingBalance: 0,
      ),
    );
    when(() => documentRepository.create(any())).thenAnswer((_) async => _savedDocument());
    useTallScreen(tester);

    await tester.pumpWidget(buildApp(DocumentEditorScreen.create(type: DocumentType.invoice)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose a customer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Acme'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add line'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('line-unit-price-0')), '5000');
    await tester.pumpAndSettle();

    expect(
      find.text('Acme already owes RWF 0. With this invoice they would owe RWF 5,900, which is over their RWF 100 limit.'),
      findsOneWidget,
    );
  });

  testWidgets('a quote is not held to the credit limit', (tester) async {
    when(() => customerRepository.get('c1')).thenAnswer(
      (_) async => const Customer(
        id: 'c1',
        name: 'Acme',
        isActive: true,
        createdAt: '2026-01-01T00:00:00.000Z',
        creditLimit: 100,
      ),
    );
    when(() => documentRepository.create(any())).thenAnswer((_) async => _savedDocument());
    useTallScreen(tester);

    await tester.pumpWidget(buildApp(DocumentEditorScreen.create(type: DocumentType.quote)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose a customer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Acme'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add line'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('line-unit-price-0')), '5000');
    await tester.pumpAndSettle();

    expect(find.textContaining('over their'), findsNothing);
  });

  Future<void> typeLine(WidgetTester tester, {required String description, required String price}) async {
    await tester.tap(find.text('Add line'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(ItemSearchField), description);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('line-unit-price-0')), price);
    await tester.pumpAndSettle();
  }

  testWidgets('a line with no text cannot be saved as an item, and a line picked from the catalog needs no saving',
      (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(buildApp(DocumentEditorScreen.create(type: DocumentType.invoice)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add line'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('line-save-item-0')), findsNothing);

    await tester.enterText(find.byType(ItemSearchField), 'Printing');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('line-save-item-0')), findsOneWidget);
  });

  testWidgets('saving a typed line adds it to the catalog at the same RWF price and links the line', (tester) async {
    when(() => itemRepository.create(description: 'Banner', unitPrice: 5000, unit: 'unit', taxRate: 18.0))
        .thenAnswer((_) async => const Item(
              id: 'i7',
              description: 'Banner',
              unitPrice: 5000,
              unit: 'unit',
              taxRate: 18,
              isActive: true,
            ));
    useTallScreen(tester);
    await tester.pumpWidget(buildApp(DocumentEditorScreen.create(type: DocumentType.invoice)));
    await tester.pumpAndSettle();
    await typeLine(tester, description: 'Banner', price: '5000');

    await tester.tap(find.byKey(const Key('line-save-item-0')));
    await tester.pumpAndSettle();

    verify(() => itemRepository.create(description: 'Banner', unitPrice: 5000, unit: 'unit', taxRate: 18.0)).called(1);
    expect(find.byKey(const Key('line-save-item-0')), findsNothing);
    expect(find.text('Saved to your items'), findsOneWidget);
  });

  testWidgets('a dollar line is saved to the catalog in francs at the draft rate', (tester) async {
    when(() => documentRepository.rates()).thenAnswer(
      (_) async => const ExchangeRates({Currency.usd: RateQuote(rate: 1400, source: 'BNR', date: '2026-09-29')}),
    );
    when(() => itemRepository.create(description: 'Banner', unitPrice: 14000, unit: 'unit', taxRate: 18.0))
        .thenAnswer((_) async => const Item(
              id: 'i7',
              description: 'Banner',
              unitPrice: 14000,
              unit: 'unit',
              taxRate: 18,
              isActive: true,
            ));
    useTallScreen(tester);
    await tester.pumpWidget(buildApp(DocumentEditorScreen.create(type: DocumentType.invoice)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('document-editor-currency')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('USD (US dollar)').last);
    await tester.pumpAndSettle();
    await typeLine(tester, description: 'Banner', price: '10');

    await tester.tap(find.byKey(const Key('line-save-item-0')));
    await tester.pumpAndSettle();

    verify(() => itemRepository.create(description: 'Banner', unitPrice: 14000, unit: 'unit', taxRate: 18.0)).called(1);
  });

  testWidgets('a dollar line with no rate explains why it cannot be saved as an item yet', (tester) async {
    when(() => documentRepository.rates()).thenAnswer((_) async => const ExchangeRates({}));
    useTallScreen(tester);
    await tester.pumpWidget(buildApp(DocumentEditorScreen.create(type: DocumentType.invoice)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('document-editor-currency')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('USD (US dollar)').last);
    await tester.pumpAndSettle();
    await typeLine(tester, description: 'Banner', price: '10');

    await tester.tap(find.byKey(const Key('line-save-item-0')));
    await tester.pumpAndSettle();

    expect(find.text('Enter the exchange rate first, so the price can be saved in RWF'), findsOneWidget);
    verifyNever(() => itemRepository.create(
          description: any(named: 'description'),
          unitPrice: any(named: 'unitPrice'),
          unit: any(named: 'unit'),
          taxRate: any(named: 'taxRate'),
        ));
  });

  testWidgets('a failed save keeps the line, says why, and Retry saves it', (tester) async {
    var failing = true;
    when(() => itemRepository.create(description: 'Banner', unitPrice: 5000, unit: 'unit', taxRate: 18.0))
        .thenAnswer((_) async {
      if (failing) {
        throw DioException(requestOptions: RequestOptions(path: '/items'), type: DioExceptionType.connectionError);
      }
      return const Item(id: 'i7', description: 'Banner', unitPrice: 5000, unit: 'unit', taxRate: 18, isActive: true);
    });
    useTallScreen(tester);
    await tester.pumpWidget(buildApp(DocumentEditorScreen.create(type: DocumentType.invoice)));
    await tester.pumpAndSettle();
    await typeLine(tester, description: 'Banner', price: '5000');

    await tester.tap(find.byKey(const Key('line-save-item-0')));
    await tester.pumpAndSettle();
    expect(find.text('Check your connection and try again'), findsOneWidget);
    expect(find.byKey(const Key('line-save-item-0')), findsOneWidget);

    failing = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Saved to your items'), findsOneWidget);
    verify(() => itemRepository.create(description: 'Banner', unitPrice: 5000, unit: 'unit', taxRate: 18.0)).called(2);
  });

  Future<void> openInvoiceWithTotal(WidgetTester tester, {DocumentType type = DocumentType.invoice}) async {
    useTallScreen(tester);
    await tester.pumpWidget(buildApp(DocumentEditorScreen.create(type: type)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add line'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('line-unit-price-0')), '10000');
    await tester.pumpAndSettle();
  }

  TextField field(WidgetTester tester, String key) => tester.widget<TextField>(find.byKey(Key(key)));

  testWidgets('an invoice offers a payment plan, a quote does not', (tester) async {
    await openInvoiceWithTotal(tester);
    expect(find.text('Payment plan'), findsOneWidget);
    expect(find.byKey(const Key('plan-preset-two')), findsOneWidget);
    expect(find.byKey(const Key('plan-preset-three')), findsOneWidget);
    expect(find.byKey(const Key('plan-preset-deposit')), findsOneWidget);

    await openInvoiceWithTotal(tester, type: DocumentType.quote);
    expect(find.text('Payment plan'), findsNothing);
  });

  testWidgets('choosing two parts shows two instalments, the last one being the balance', (tester) async {
    await openInvoiceWithTotal(tester);

    await tester.tap(find.byKey(const Key('plan-preset-two')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('installment-row-0')), findsOneWidget);
    expect(find.byKey(const Key('installment-row-1')), findsOneWidget);
    expect(field(tester, 'installment-amount-0').controller!.text, '5900');
    expect(field(tester, 'installment-amount-1').controller!.text, '5900');
    expect(field(tester, 'installment-amount-1').readOnly, isTrue);
    expect(find.text('Balance'), findsOneWidget);
    expect(find.byKey(const Key('plan-preset-two')), findsNothing);
  });

  testWidgets('changing an earlier amount moves the balance', (tester) async {
    await openInvoiceWithTotal(tester);
    await tester.tap(find.byKey(const Key('plan-preset-two')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('installment-amount-0')), '2000');
    await tester.pumpAndSettle();

    expect(field(tester, 'installment-amount-1').controller!.text, '9800');
  });

  testWidgets('instalments that add up to the whole total say what to do', (tester) async {
    await openInvoiceWithTotal(tester);
    await tester.tap(find.byKey(const Key('plan-preset-two')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('installment-amount-0')), '20000');
    await tester.pumpAndSettle();

    expect(
      find.text('The earlier instalments already add up to the whole total. Lower them so the balance is more than zero.'),
      findsOneWidget,
    );
  });

  testWidgets('a row can be added before the balance and removed again, never below two', (tester) async {
    await openInvoiceWithTotal(tester);
    await tester.tap(find.byKey(const Key('plan-preset-two')));
    await tester.pumpAndSettle();
    expect(tester.widget<IconButton>(find.byKey(const Key('installment-remove-0'))).onPressed, isNull);

    await tester.tap(find.byKey(const Key('installment-add')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('installment-row-2')), findsOneWidget);

    await tester.tap(find.byKey(const Key('installment-remove-0')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('installment-row-2')), findsNothing);
  });

  testWidgets('a name can be given to an instalment', (tester) async {
    await openInvoiceWithTotal(tester);
    await tester.tap(find.byKey(const Key('plan-preset-two')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('installment-label-0')), 'First half');
    await tester.pumpAndSettle();

    expect(field(tester, 'installment-label-0').controller!.text, 'First half');
  });

  testWidgets('paying in full again removes the plan and brings back the due date and terms', (tester) async {
    await openInvoiceWithTotal(tester);
    await tester.tap(find.byKey(const Key('plan-preset-two')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('payment-term-30')), findsNothing);

    await tester.tap(find.byKey(const Key('plan-clear')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('plan-preset-two')), findsOneWidget);
    expect(find.byKey(const Key('payment-term-30')), findsOneWidget);
  });
}
