import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/network/api_client.dart';
import 'package:billa_mobile/features/customers/domain/customer.dart';
import 'package:billa_mobile/features/customers/domain/customer_repository.dart';
import 'package:billa_mobile/features/customers/presentation/providers/customer_repository_provider.dart';
import 'package:billa_mobile/features/documents/domain/document.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/domain/document_repository.dart';
import 'package:billa_mobile/features/documents/presentation/providers/document_contact.dart';
import 'package:billa_mobile/features/documents/presentation/providers/document_repository_provider.dart';
import '../../../../support/tall_screen.dart';

class _MockDocumentRepository extends Mock implements DocumentRepository {}

class _MockCustomerRepository extends Mock implements CustomerRepository {}

Document _document({
  DocumentType type = DocumentType.invoice,
  DocumentStatus status = DocumentStatus.finalized,
  String? publicToken = 'tok',
  int total = 10000,
  int amountPaid = 6000,
}) =>
    Document(
      id: 'd1',
      type: type,
      number: 'INV-0001',
      status: status,
      customerId: 'c1',
      customer: const DocumentCustomerRef(name: 'Acme Ltd'),
      issueDate: '2026-01-01T00:00:00.000Z',
      subtotal: total,
      taxTotal: 0,
      total: total,
      amountPaid: amountPaid,
      publicToken: publicToken,
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
    );

const _customer = Customer(id: 'c1', name: 'Acme Ltd', phone: '0788123456', isActive: true, createdAt: '2026-01-01T00:00:00.000Z');

void main() {
  late _MockDocumentRepository documents;
  late _MockCustomerRepository customers;

  setUp(() {
    documents = _MockDocumentRepository();
    customers = _MockCustomerRepository();
    when(() => customers.get('c1')).thenAnswer((_) async => _customer);
  });

  Future<void> pressGo(WidgetTester tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        documentRepositoryProvider.overrideWithValue(documents),
        customerRepositoryProvider.overrideWithValue(customers),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, _) => TextButton(
              onPressed: () => startDocumentContact(context, ref, documentId: 'd1'),
              child: const Text('go'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
  }

  Future<void> start(WidgetTester tester, Document document) async {
    when(() => documents.get('d1')).thenAnswer((_) async => document);
    await pressGo(tester);
  }

  testWidgets('an invoice with a balance opens a reminder with the amount owed and the public link', (tester) async {
    await start(tester, _document());

    expect(find.textContaining('RWF 4,000 outstanding'), findsOneWidget);
    expect(find.textContaining('$apiBaseUrl/view/tok'), findsOneWidget);
    expect(find.text('0788123456'), findsWidgets);
  });

  testWidgets('a quote opens a share message instead of a reminder', (tester) async {
    await start(tester, _document(type: DocumentType.quote, amountPaid: 0));

    expect(find.textContaining('here is quote INV-0001'), findsOneWidget);
    expect(find.textContaining('outstanding'), findsNothing);
  });

  testWidgets('a fully paid invoice is shared, not chased', (tester) async {
    await start(tester, _document(amountPaid: 10000));

    expect(find.textContaining('here is invoice INV-0001'), findsOneWidget);
  });

  testWidgets('a draft cannot be sent yet and says what to do first', (tester) async {
    await start(tester, _document(status: DocumentStatus.draft, publicToken: null));

    expect(find.text('Finalize this document first to share it'), findsOneWidget);
    expect(find.byKey(const Key('contact-whatsapp')), findsNothing);
  });

  testWidgets('a customer without a phone number still opens the sheet with the reason', (tester) async {
    when(() => customers.get('c1')).thenAnswer(
      (_) async => const Customer(id: 'c1', name: 'Acme Ltd', isActive: true, createdAt: '2026-01-01T00:00:00.000Z'),
    );

    await start(tester, _document());

    expect(find.text('No phone number saved'), findsNWidgets(3));
  });

  testWidgets('a failed load says why instead of doing nothing', (tester) async {
    when(() => documents.get('d1')).thenAnswer(
      (_) async => throw DioException(requestOptions: RequestOptions(path: '/documents/d1'), type: DioExceptionType.connectionError),
    );

    await pressGo(tester);

    expect(find.text('Check your connection and try again'), findsOneWidget);
  });
}
