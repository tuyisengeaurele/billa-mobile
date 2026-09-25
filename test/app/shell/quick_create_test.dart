import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/shell/quick_create.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/documents/domain/document.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/domain/document_repository.dart';
import 'package:billa_mobile/features/documents/presentation/providers/document_repository_provider.dart';
import 'package:billa_mobile/features/receivables/domain/outstanding_invoice.dart';
import 'package:billa_mobile/features/receivables/domain/receivables_repository.dart';
import 'package:billa_mobile/features/receivables/presentation/providers/receivables_repository_provider.dart';
import '../../support/tall_screen.dart';

class _MockReceivablesRepository extends Mock implements ReceivablesRepository {}

class _MockDocumentRepository extends Mock implements DocumentRepository {}

const _invoice = OutstandingInvoice(
  id: 'd1',
  number: 'INV-1',
  customerName: 'Acme Ltd',
  total: 10000,
  amountOwed: 4000,
  dueDate: '2026-02-01',
  daysOverdue: 0,
  agingBucket: 'current',
);

const _document = Document(
  id: 'd1',
  type: DocumentType.invoice,
  number: 'INV-1',
  status: DocumentStatus.finalized,
  customerId: 'c1',
  customer: DocumentCustomerRef(name: 'Acme Ltd'),
  issueDate: '2026-01-01T00:00:00.000Z',
  subtotal: 10000,
  taxTotal: 0,
  total: 10000,
  amountPaid: 6000,
  createdAt: '2026-01-01T00:00:00.000Z',
  updatedAt: '2026-01-01T00:00:00.000Z',
);

void main() {
  late _MockReceivablesRepository receivables;
  late _MockDocumentRepository documents;

  setUp(() {
    receivables = _MockReceivablesRepository();
    documents = _MockDocumentRepository();
    when(() => receivables.list()).thenAnswer((_) async => [_invoice]);
    when(() => documents.get('d1')).thenAnswer((_) async => _document);
  });

  Widget buildApp() {
    Widget stub(String label) => Scaffold(body: Text(label));
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => const Scaffold(body: Center(child: QuickCreateButton()))),
      GoRoute(path: '/documents/new', builder: (context, state) => stub('new document ${(state.extra as DocumentType).name}')),
      GoRoute(path: '/customers/new', builder: (context, state) => stub('new customer')),
      GoRoute(
        path: '/documents/:id/payments/new',
        builder: (context, state) => stub('payment for ${(state.extra as Document).number}'),
      ),
    ]);
    return ProviderScope(
      overrides: [
        receivablesRepositoryProvider.overrideWithValue(receivables),
        documentRepositoryProvider.overrideWithValue(documents),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  Future<void> open(WidgetTester tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quick-create')));
    await tester.pumpAndSettle();
  }

  testWidgets('offers every document type, a new customer, and recording a payment', (tester) async {
    await open(tester);

    for (final type in DocumentType.values) {
      expect(find.byKey(Key('quick-create-${type.name}')), findsOneWidget);
    }
    expect(find.byKey(const Key('quick-create-customer')), findsOneWidget);
    expect(find.byKey(const Key('quick-create-payment')), findsOneWidget);
  });

  testWidgets('a document type opens the editor for that type', (tester) async {
    await open(tester);
    await tester.tap(find.byKey(const Key('quick-create-quote')));
    await tester.pumpAndSettle();

    expect(find.text('new document quote'), findsOneWidget);
  });

  testWidgets('new customer opens the customer form', (tester) async {
    await open(tester);
    await tester.tap(find.byKey(const Key('quick-create-customer')));
    await tester.pumpAndSettle();

    expect(find.text('new customer'), findsOneWidget);
  });

  testWidgets('recording a payment asks which invoice, then opens the payment screen for it', (tester) async {
    await open(tester);
    await tester.tap(find.byKey(const Key('quick-create-payment')));
    await tester.pumpAndSettle();

    expect(find.text('Choose the invoice the customer is paying.'), findsOneWidget);
    expect(find.text('Acme Ltd'), findsOneWidget);
    expect(find.text('RWF 4,000'), findsOneWidget);

    await tester.tap(find.byKey(const Key('payment-invoice-d1')));
    await tester.pumpAndSettle();

    expect(find.text('payment for INV-1'), findsOneWidget);
  });

  testWidgets('with nothing outstanding the picker says so instead of showing an empty list', (tester) async {
    when(() => receivables.list()).thenAnswer((_) async => []);

    await open(tester);
    await tester.tap(find.byKey(const Key('quick-create-payment')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Nothing is outstanding'), findsOneWidget);
  });

  testWidgets('a failed invoice load shows a message and Retry reloads it', (tester) async {
    var failing = true;
    when(() => receivables.list()).thenAnswer((_) async {
      if (failing) throw DioException(requestOptions: RequestOptions(path: '/x'), type: DioExceptionType.connectionError);
      return [_invoice];
    });

    await open(tester);
    await tester.tap(find.byKey(const Key('quick-create-payment')));
    await tester.pumpAndSettle();
    expect(find.text("Couldn't load your invoices"), findsOneWidget);

    failing = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('payment-invoice-d1')), findsOneWidget);
  });

  testWidgets('a failure loading the chosen invoice shows a message instead of doing nothing', (tester) async {
    when(() => documents.get('d1')).thenAnswer(
      (_) async => throw DioException(requestOptions: RequestOptions(path: '/x'), type: DioExceptionType.connectionError),
    );

    await open(tester);
    await tester.tap(find.byKey(const Key('quick-create-payment')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('payment-invoice-d1')));
    await tester.pumpAndSettle();

    expect(find.text('Check your connection and try again'), findsOneWidget);
  });

  testWidgets('dismissing the sheet starts nothing', (tester) async {
    await open(tester);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('quick-create-invoice')), findsNothing);
    expect(find.byKey(const Key('quick-create')), findsOneWidget);
  });
}
