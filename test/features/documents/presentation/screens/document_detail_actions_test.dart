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
import 'package:billa_mobile/features/documents/domain/document_draft_input.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/domain/document_repository.dart';
import 'package:billa_mobile/features/documents/presentation/providers/document_repository_provider.dart';
import 'package:billa_mobile/features/documents/presentation/screens/document_detail_screen.dart';
import '../../../../support/tall_screen.dart';

class _MockDocumentRepository extends Mock implements DocumentRepository {}

class _MockCustomerRepository extends Mock implements CustomerRepository {}

class _FakeInput extends Fake implements DocumentDraftInput {}

Document _doc({String id = 'd1', DocumentStatus status = DocumentStatus.finalized}) => Document(
      id: id,
      type: DocumentType.invoice,
      number: 'INV-0001',
      status: status,
      customerId: 'c1',
      customer: const DocumentCustomerRef(name: 'Acme', email: 'acme@example.com'),
      issueDate: '2026-01-01T00:00:00.000Z',
      subtotal: 10000,
      taxTotal: 0,
      total: 10000,
      amountPaid: 0,
      publicToken: 'tok',
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
    );

void main() {
  late _MockDocumentRepository documents;
  late _MockCustomerRepository customers;

  setUpAll(() => registerFallbackValue(_FakeInput()));

  setUp(() {
    documents = _MockDocumentRepository();
    customers = _MockCustomerRepository();
    when(() => documents.listPayments('d1')).thenAnswer((_) async => []);
    when(() => customers.get('c1')).thenAnswer(
      (_) async => const Customer(id: 'c1', name: 'Acme', phone: '0788123456', isActive: true, createdAt: '2026-01-01T00:00:00.000Z'),
    );
  });

  Future<void> pump(WidgetTester tester, Document document) async {
    when(() => documents.get('d1')).thenAnswer((_) async => document);
    useTallScreen(tester);
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => const DocumentDetailScreen(documentId: 'd1')),
      GoRoute(
        path: '/documents/:id/edit',
        builder: (context, state) => Scaffold(body: Text('editing ${state.pathParameters['id']}')),
      ),
    ]);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        documentRepositoryProvider.overrideWithValue(documents),
        customerRepositoryProvider.overrideWithValue(customers),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('a finalized document can be sent to the customer by whatsapp, sms or a call', (tester) async {
    await pump(tester, _doc());

    await tester.ensureVisible(find.byKey(const Key('document-contact')));
    await tester.tap(find.byKey(const Key('document-contact')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('contact-whatsapp')), findsOneWidget);
    expect(find.textContaining('RWF 10,000 outstanding'), findsOneWidget);
  });

  testWidgets('a draft has no contact button because there is nothing to share yet', (tester) async {
    await pump(tester, _doc(status: DocumentStatus.draft));

    expect(find.byKey(const Key('document-contact')), findsNothing);
  });

  testWidgets('duplicate creates a copy and opens it', (tester) async {
    await pump(tester, _doc());
    when(() => documents.create(any())).thenAnswer((_) async => _doc(id: 'd-copy', status: DocumentStatus.draft));

    await tester.tap(find.byKey(const Key('document-duplicate')));
    await tester.pumpAndSettle();

    expect(find.text('editing d-copy'), findsOneWidget);
  });
}
