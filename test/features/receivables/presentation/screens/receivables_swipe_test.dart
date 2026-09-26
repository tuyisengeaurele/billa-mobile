import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/customers/domain/customer.dart';
import 'package:billa_mobile/features/customers/domain/customer_repository.dart';
import 'package:billa_mobile/features/customers/presentation/providers/customer_repository_provider.dart';
import 'package:billa_mobile/features/documents/domain/document.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/domain/document_repository.dart';
import 'package:billa_mobile/features/documents/presentation/providers/document_repository_provider.dart';
import 'package:billa_mobile/features/receivables/domain/outstanding_invoice.dart';
import 'package:billa_mobile/features/receivables/domain/receivables_repository.dart';
import 'package:billa_mobile/features/receivables/presentation/providers/receivables_repository_provider.dart';
import 'package:billa_mobile/features/receivables/presentation/screens/receivables_screen.dart';
import '../../../../support/tall_screen.dart';

class _MockReceivablesRepository extends Mock implements ReceivablesRepository {}

class _MockDocumentRepository extends Mock implements DocumentRepository {}

class _MockCustomerRepository extends Mock implements CustomerRepository {}

const _invoice = OutstandingInvoice(
  id: 'd1',
  number: 'INV-0001',
  customerName: 'Acme',
  total: 10000,
  amountOwed: 4000,
  dueDate: '2026-01-01',
  daysOverdue: 12,
  agingBucket: '0-30',
);

const _document = Document(
  id: 'd1',
  type: DocumentType.invoice,
  number: 'INV-0001',
  status: DocumentStatus.finalized,
  customerId: 'c1',
  customer: DocumentCustomerRef(name: 'Acme'),
  issueDate: '2026-01-01T00:00:00.000Z',
  subtotal: 10000,
  taxTotal: 0,
  total: 10000,
  amountPaid: 6000,
  publicToken: 'tok',
  createdAt: '2026-01-01T00:00:00.000Z',
  updatedAt: '2026-01-01T00:00:00.000Z',
);

void main() {
  late _MockReceivablesRepository receivables;
  late _MockDocumentRepository documents;
  late _MockCustomerRepository customers;

  setUp(() {
    receivables = _MockReceivablesRepository();
    documents = _MockDocumentRepository();
    customers = _MockCustomerRepository();
    when(() => receivables.list()).thenAnswer((_) async => [_invoice]);
    when(() => documents.get('d1')).thenAnswer((_) async => _document);
    when(() => customers.get('c1')).thenAnswer(
      (_) async => const Customer(id: 'c1', name: 'Acme', phone: '0788123456', isActive: true, createdAt: '2026-01-01T00:00:00.000Z'),
    );
  });

  Future<void> pump(WidgetTester tester) async {
    useTallScreen(tester);
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => const ReceivablesScreen()),
      GoRoute(path: '/documents/:id', builder: (context, state) => const Scaffold(body: Text('detail screen'))),
      GoRoute(
        path: '/documents/:id/payments/new',
        builder: (context, state) => Scaffold(body: Text('payment for ${(state.extra as Document).number}')),
      ),
    ]);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        receivablesRepositoryProvider.overrideWithValue(receivables),
        documentRepositoryProvider.overrideWithValue(documents),
        customerRepositoryProvider.overrideWithValue(customers),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('swiping left records a payment for that invoice', (tester) async {
    await pump(tester);

    await tester.drag(find.text('Acme'), const Offset(-400, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('receivable-swipe-pay-d1')));
    await tester.pumpAndSettle();

    expect(find.text('payment for INV-0001'), findsOneWidget);
  });

  testWidgets('swiping right opens the reminder with the amount owed', (tester) async {
    await pump(tester);

    await tester.drag(find.text('Acme'), const Offset(400, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('receivable-swipe-contact-d1')));
    await tester.pumpAndSettle();

    expect(find.textContaining('RWF 4,000 outstanding'), findsOneWidget);
    expect(find.byKey(const Key('contact-whatsapp')), findsOneWidget);
  });

  testWidgets('tapping the row still opens the invoice', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Acme'));
    await tester.pumpAndSettle();

    expect(find.text('detail screen'), findsOneWidget);
  });
}
