import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/documents/domain/document.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/domain/document_repository.dart';
import 'package:billa_mobile/features/documents/domain/payment.dart';
import 'package:billa_mobile/features/documents/presentation/providers/document_repository_provider.dart';
import 'package:billa_mobile/features/documents/presentation/screens/document_detail_screen.dart';

class _MockDocumentRepository extends Mock implements DocumentRepository {}

const _customer = DocumentCustomerRef(name: 'Acme', email: 'acme@example.com');
const _line = DocumentLine(
  id: 'l1',
  description: 'Printing',
  quantity: 2.0,
  unitPrice: 5000,
  taxRate: 18.0,
  discountType: DiscountType.percent,
  discountValue: 10.0,
  lineTotal: 9000,
  sortOrder: 0,
);
const _document = Document(
  id: 'd1',
  type: DocumentType.invoice,
  number: 'INV-0001',
  status: DocumentStatus.finalized,
  customerId: 'c1',
  customer: _customer,
  issueDate: '2026-01-01T00:00:00.000Z',
  subtotal: 9000,
  taxTotal: 1620,
  total: 10620,
  amountPaid: 0,
  createdAt: '2026-01-01T00:00:00.000Z',
  updatedAt: '2026-01-01T00:00:00.000Z',
  lines: [_line],
  convertedFrom: DocumentRef(id: 'p1', number: 'PRO-0001', type: DocumentType.proforma),
);

void main() {
  late _MockDocumentRepository repository;

  setUp(() {
    repository = _MockDocumentRepository();
    when(() => repository.get('d1')).thenAnswer((_) async => _document);
    when(() => repository.listPayments('d1')).thenAnswer((_) async => []);
  });

  Widget buildApp() {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => const DocumentDetailScreen(documentId: 'd1')),
      GoRoute(path: '/documents/:id', builder: (context, state) => const Scaffold(body: Text('converted-from screen'))),
    ]);
    return ProviderScope(
      overrides: [documentRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  testWidgets('shows line items, the discount, and the totals', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Printing'), findsOneWidget);
    expect(find.textContaining('10% off'), findsOneWidget);
    expect(find.text('RWF 10,620'), findsOneWidget);
  });

  testWidgets('tapping the converted-from link navigates to that document', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Converted from'));
    await tester.pumpAndSettle();

    expect(find.text('converted-from screen'), findsOneWidget);
  });

  testWidgets('a draft document shows an Edit action that opens the editor', (tester) async {
    const draft = Document(
      id: 'd1',
      type: DocumentType.invoice,
      status: DocumentStatus.draft,
      customerId: 'c1',
      customer: _customer,
      issueDate: '2026-01-01T00:00:00.000Z',
      subtotal: 0,
      taxTotal: 0,
      total: 0,
      amountPaid: 0,
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
    );
    when(() => repository.get('d1')).thenAnswer((_) async => draft);
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => const DocumentDetailScreen(documentId: 'd1')),
      GoRoute(path: '/documents/:id/edit', builder: (context, state) => const Scaffold(body: Text('editor screen'))),
    ]);

    await tester.pumpWidget(ProviderScope(
      overrides: [documentRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    expect(find.text('editor screen'), findsOneWidget);
  });

  testWidgets('a finalized document shows no Edit action', (tester) async {
    when(() => repository.get('d1')).thenAnswer((_) async => _document);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.edit), findsNothing);
  });

  testWidgets('Finalize appears for a draft and reloads on success', (tester) async {
    const draft = Document(
      id: 'd1',
      type: DocumentType.invoice,
      status: DocumentStatus.draft,
      customerId: 'c1',
      customer: _customer,
      issueDate: '2026-01-01T00:00:00.000Z',
      subtotal: 0,
      taxTotal: 0,
      total: 0,
      amountPaid: 0,
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
      lines: [_line],
    );
    when(() => repository.get('d1')).thenAnswer((_) async => draft);
    when(() => repository.finalize('d1')).thenAnswer(
      (_) async => draft.copyWith(status: DocumentStatus.finalized, number: 'INV-0001'),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Finalize'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finalize').last);
    await tester.pumpAndSettle();

    verify(() => repository.finalize('d1')).called(1);
    verify(() => repository.get('d1')).called(2); // initial load + reload after finalize
  });

  testWidgets('Convert to Invoice appears for a finalized proforma with no convertedTo, and navigates on success', (tester) async {
    const proforma = Document(
      id: 'd1',
      type: DocumentType.proforma,
      number: 'PRO-0001',
      status: DocumentStatus.finalized,
      customerId: 'c1',
      customer: _customer,
      issueDate: '2026-01-01T00:00:00.000Z',
      subtotal: 0,
      taxTotal: 0,
      total: 0,
      amountPaid: 0,
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
    );
    const newInvoice = Document(
      id: 'd2',
      type: DocumentType.invoice,
      status: DocumentStatus.draft,
      customerId: 'c1',
      customer: _customer,
      issueDate: '2026-01-01T00:00:00.000Z',
      subtotal: 0,
      taxTotal: 0,
      total: 0,
      amountPaid: 0,
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
    );
    when(() => repository.get('d1')).thenAnswer((_) async => proforma);
    when(() => repository.convert('d1')).thenAnswer((_) async => newInvoice);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Convert to Invoice'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Convert').last);
    await tester.pumpAndSettle();

    expect(find.text('converted-from screen'), findsOneWidget);
  });

  testWidgets('Send is disabled when the customer has no email', (tester) async {
    const noEmailCustomer = DocumentCustomerRef(name: 'Acme');
    const finalized = Document(
      id: 'd1',
      type: DocumentType.invoice,
      number: 'INV-0001',
      status: DocumentStatus.finalized,
      customerId: 'c1',
      customer: noEmailCustomer,
      issueDate: '2026-01-01T00:00:00.000Z',
      subtotal: 0,
      taxTotal: 0,
      total: 0,
      amountPaid: 0,
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
    );
    when(() => repository.get('d1')).thenAnswer((_) async => finalized);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final sendButton = tester.widget<OutlinedButton>(find.byKey(const Key('document-send')));
    expect(sendButton.onPressed, isNull);
  });

  testWidgets('Send confirms and reloads on success when the customer has an email', (tester) async {
    when(() => repository.get('d1')).thenAnswer((_) async => _document);
    when(() => repository.send('d1', language: DocumentLanguage.en)).thenAnswer((_) async => '2026-01-02T00:00:00.000Z');

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('document-send')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('language-en')));
    await tester.pumpAndSettle();
    expect(find.text('The PDF will be in English.'), findsOneWidget);
    await tester.tap(find.text('Send').last);
    await tester.pumpAndSettle();

    verify(() => repository.send('d1', language: DocumentLanguage.en)).called(1);
    verify(() => repository.get('d1')).called(2);
  });

  testWidgets('Share PDF fetches the document bytes', (tester) async {
    when(() => repository.get('d1')).thenAnswer((_) async => _document);
    when(() => repository.fetchPdfBytes('d1', language: DocumentLanguage.en)).thenAnswer((_) async => [1, 2, 3]);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('document-share-pdf')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('language-en')));
    await tester.pumpAndSettle();

    verify(() => repository.fetchPdfBytes('d1', language: DocumentLanguage.en)).called(1);
  });

  testWidgets('the language picker opens on the document language and shares in the one chosen', (tester) async {
    when(() => repository.get('d1')).thenAnswer((_) async => _document.copyWith(language: DocumentLanguage.fr));
    when(() => repository.fetchPdfBytes('d1', language: DocumentLanguage.en)).thenAnswer((_) async => [1, 2, 3]);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('document-share-pdf')));
    await tester.pumpAndSettle();

    expect(find.descendant(of: find.byKey(const Key('language-fr')), matching: find.byIcon(Icons.check)), findsOneWidget);
    expect(find.descendant(of: find.byKey(const Key('language-en')), matching: find.byIcon(Icons.check)), findsNothing);

    await tester.tap(find.byKey(const Key('language-en')));
    await tester.pumpAndSettle();

    verify(() => repository.fetchPdfBytes('d1', language: DocumentLanguage.en)).called(1);
  });

  testWidgets('dismissing the language picker shares nothing', (tester) async {
    when(() => repository.get('d1')).thenAnswer((_) async => _document);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('document-share-pdf')));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    verifyNever(() => repository.fetchPdfBytes(any(), language: any(named: 'language')));
  });

  testWidgets('dismissing the language picker before sending sends nothing', (tester) async {
    when(() => repository.get('d1')).thenAnswer((_) async => _document);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('document-send')));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    verifyNever(() => repository.send(any(), language: any(named: 'language')));
  });

  testWidgets('the overflow Delete action appears only for drafts, confirms, and pops back to the list', (tester) async {
    const draft = Document(
      id: 'd1',
      type: DocumentType.invoice,
      status: DocumentStatus.draft,
      customerId: 'c1',
      customer: _customer,
      issueDate: '2026-01-01T00:00:00.000Z',
      subtotal: 0,
      taxTotal: 0,
      total: 0,
      amountPaid: 0,
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
    );
    when(() => repository.get('d1')).thenAnswer((_) async => draft);
    when(() => repository.delete('d1')).thenAnswer((_) async {});
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => const Scaffold(body: Text('list screen'))),
      GoRoute(path: '/documents/d1', builder: (context, state) => const DocumentDetailScreen(documentId: 'd1')),
    ]);

    await tester.pumpWidget(ProviderScope(
      overrides: [documentRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ));
    await tester.pumpAndSettle();
    router.push('/documents/d1');
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('list screen'), findsOneWidget);
    verify(() => repository.delete('d1')).called(1);
  });

  testWidgets('the Payments section lists recorded payments with a Void action', (tester) async {
    when(() => repository.get('d1')).thenAnswer((_) async => _document);
    when(() => repository.listPayments('d1')).thenAnswer((_) async => [
          const Payment(
            id: 'pay1',
            amount: 5000,
            method: PaymentMethod.cash,
            paidOn: '2026-01-05T00:00:00.000Z',
            createdAt: '2026-01-05T00:00:00.000Z',
          ),
        ]);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('RWF 5,000'), findsOneWidget);
    expect(find.text('Void'), findsOneWidget);
  });

  testWidgets('voiding a payment confirms with a reason and reloads', (tester) async {
    when(() => repository.get('d1')).thenAnswer((_) async => _document);
    when(() => repository.listPayments('d1')).thenAnswer((_) async => [
          const Payment(
            id: 'pay1',
            amount: 5000,
            method: PaymentMethod.cash,
            paidOn: '2026-01-05T00:00:00.000Z',
            createdAt: '2026-01-05T00:00:00.000Z',
          ),
        ]);
    when(() => repository.voidPayment('d1', 'pay1', 'Mistake')).thenAnswer((_) async => _document);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Void'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Mistake');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Void').last);
    await tester.pumpAndSettle();

    verify(() => repository.voidPayment('d1', 'pay1', 'Mistake')).called(1);
  });

  testWidgets('Record Payment appears for an unpaid finalized invoice and opens the record screen', (tester) async {
    const unpaidInvoice = Document(
      id: 'd1',
      type: DocumentType.invoice,
      number: 'INV-0001',
      status: DocumentStatus.finalized,
      customerId: 'c1',
      customer: _customer,
      issueDate: '2026-01-01T00:00:00.000Z',
      subtotal: 9000,
      taxTotal: 1620,
      total: 10620,
      amountPaid: 0,
      paymentStatus: PaymentStatus.unpaid,
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
    );
    when(() => repository.get('d1')).thenAnswer((_) async => unpaidInvoice);
    when(() => repository.listPayments('d1')).thenAnswer((_) async => []);
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => const DocumentDetailScreen(documentId: 'd1')),
      GoRoute(
        path: '/documents/:id/payments/new',
        builder: (context, state) => const Scaffold(body: Text('record payment screen')),
      ),
    ]);

    await tester.pumpWidget(ProviderScope(
      overrides: [documentRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Record Payment'));
    await tester.pumpAndSettle();

    expect(find.text('record payment screen'), findsOneWidget);
  });

  testWidgets('Write off appears for an unpaid finalized invoice and succeeds with a reason', (tester) async {
    const unpaidInvoice = Document(
      id: 'd1',
      type: DocumentType.invoice,
      number: 'INV-0001',
      status: DocumentStatus.finalized,
      customerId: 'c1',
      customer: _customer,
      issueDate: '2026-01-01T00:00:00.000Z',
      subtotal: 9000,
      taxTotal: 1620,
      total: 10620,
      amountPaid: 0,
      paymentStatus: PaymentStatus.unpaid,
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
    );
    when(() => repository.get('d1')).thenAnswer((_) async => unpaidInvoice);
    when(() => repository.writeOff('d1', 'Bad debt')).thenAnswer(
      (_) async => unpaidInvoice.copyWith(paymentStatus: PaymentStatus.writtenOff),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Write off'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Bad debt');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Write off').last);
    await tester.pumpAndSettle();

    verify(() => repository.writeOff('d1', 'Bad debt')).called(1);
  });

  testWidgets('Reactivate appears for a written-off invoice and succeeds', (tester) async {
    const writtenOffInvoice = Document(
      id: 'd1',
      type: DocumentType.invoice,
      number: 'INV-0001',
      status: DocumentStatus.finalized,
      customerId: 'c1',
      customer: _customer,
      issueDate: '2026-01-01T00:00:00.000Z',
      subtotal: 9000,
      taxTotal: 1620,
      total: 10620,
      amountPaid: 0,
      paymentStatus: PaymentStatus.writtenOff,
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
    );
    when(() => repository.get('d1')).thenAnswer((_) async => writtenOffInvoice);
    when(() => repository.reactivate('d1')).thenAnswer(
      (_) async => writtenOffInvoice.copyWith(paymentStatus: PaymentStatus.unpaid),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reactivate'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reactivate').last);
    await tester.pumpAndSettle();

    verify(() => repository.reactivate('d1')).called(1);
  });
}
