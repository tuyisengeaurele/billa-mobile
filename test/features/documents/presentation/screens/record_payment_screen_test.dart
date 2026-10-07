import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/formatting/currency.dart';
import 'package:billa_mobile/features/documents/domain/document.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/domain/document_repository.dart';
import 'package:billa_mobile/features/documents/domain/payment_input.dart';
import 'package:billa_mobile/features/documents/presentation/providers/document_repository_provider.dart';
import 'package:billa_mobile/features/documents/presentation/screens/record_payment_screen.dart';
import '../../../../support/tall_screen.dart';

class _MockDocumentRepository extends Mock implements DocumentRepository {}
class _FakePaymentInput extends Fake implements PaymentInput {}

const _customer = DocumentCustomerRef(name: 'Acme');
const _invoice = Document(
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
  amountPaid: 4000,
  paymentStatus: PaymentStatus.partiallyPaid,
  createdAt: '2026-01-01T00:00:00.000Z',
  updatedAt: '2026-01-01T00:00:00.000Z',
);

const _usdInvoice = Document(
  id: 'd1',
  type: DocumentType.invoice,
  number: 'INV-0002',
  status: DocumentStatus.finalized,
  customerId: 'c1',
  customer: _customer,
  issueDate: '2026-01-01T00:00:00.000Z',
  subtotal: 125050,
  taxTotal: 0,
  total: 125050,
  currency: Currency.usd,
  exchangeRate: 1450,
  amountPaid: 25050,
  paymentStatus: PaymentStatus.partiallyPaid,
  createdAt: '2026-01-01T00:00:00.000Z',
  updatedAt: '2026-01-01T00:00:00.000Z',
);

void main() {
  setUpAll(() {
    registerFallbackValue(_FakePaymentInput());
  });

  late _MockDocumentRepository repository;
  late GoRouter router;

  setUp(() {
    repository = _MockDocumentRepository();
  });

  Widget buildApp({Document document = _invoice}) {
    router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => const Scaffold(body: Text('detail screen'))),
      GoRoute(path: '/payment', builder: (context, state) => RecordPaymentScreen(document: document)),
    ]);
    return ProviderScope(
      overrides: [documentRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  testWidgets('defaults the amount to the outstanding balance', (tester) async {
    await tester.pumpWidget(buildApp());
    router.push('/payment');
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byKey(const Key('payment-amount')));
    expect(field.controller!.text, '6620'); // total 10620 - amountPaid 4000
  });

  testWidgets('records a payment and pops back on success', (tester) async {
    when(() => repository.recordPayment('d1', any())).thenAnswer((_) async => _invoice);

    await tester.pumpWidget(buildApp());
    router.push('/payment');
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('payment-submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('payment-submit')));
    await tester.pumpAndSettle();

    verify(() => repository.recordPayment('d1', any())).called(1);
    expect(find.text('detail screen'), findsOneWidget);
  });

  testWidgets('the generate-receipt checkbox defaults unchecked', (tester) async {
    await tester.pumpWidget(buildApp());
    router.push('/payment');
    await tester.pumpAndSettle();

    final checkbox = tester.widget<CheckboxListTile>(find.byType(CheckboxListTile));
    expect(checkbox.value, false);
  });

  testWidgets('picking a receipt photo opens a camera/gallery choice', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(buildApp());
    router.push('/payment');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add receipt photo'));
    await tester.pumpAndSettle();

    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
  });

  testWidgets('a failed payment keeps the amount, says why, and Retry records it', (tester) async {
    var failing = true;
    when(() => repository.recordPayment('d1', any())).thenAnswer((_) async {
      if (failing) throw DioException(requestOptions: RequestOptions(path: '/documents/d1/payments'), type: DioExceptionType.connectionTimeout);
      return _invoice;
    });

    useTallScreen(tester);
    await tester.pumpWidget(buildApp());
    router.push('/payment');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('payment-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Check your connection and try again'), findsOneWidget);
    expect(tester.widget<TextField>(find.byKey(const Key('payment-amount'))).controller!.text, '6620');

    failing = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('detail screen'), findsOneWidget);
  });

  testWidgets('a foreign invoice defaults the amount to the balance in whole units and labels the currency', (tester) async {
    await tester.pumpWidget(buildApp(document: _usdInvoice));
    router.push('/payment');
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byKey(const Key('payment-amount')));
    expect(field.controller!.text, '1000'); // total 1250.50 - paid 250.50, in dollars
    expect(find.text('Amount (USD)'), findsOneWidget);
  });

  testWidgets('a foreign amount typed with a decimal is saved in the smallest unit', (tester) async {
    useTallScreen(tester);
    when(() => repository.recordPayment('d1', any())).thenAnswer((_) async => _usdInvoice);
    await tester.pumpWidget(buildApp(document: _usdInvoice));
    router.push('/payment');
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('payment-amount')), '10.5');
    await tester.ensureVisible(find.byKey(const Key('payment-submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('payment-submit')));
    await tester.pumpAndSettle();

    final input = verify(() => repository.recordPayment('d1', captureAny())).captured.single as PaymentInput;
    expect(input.amount, 1050);
  });

  testWidgets('an amount that is not a number asks for a valid one and sends nothing', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(buildApp(document: _usdInvoice));
    router.push('/payment');
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('payment-amount')), '1.2.3');
    await tester.ensureVisible(find.byKey(const Key('payment-submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('payment-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Enter an amount greater than zero'), findsOneWidget);
    verifyNever(() => repository.recordPayment(any(), any()));
  });
}
