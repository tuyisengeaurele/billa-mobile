import 'package:billa_mobile/core/formatting/currency.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/network/api_client.dart';
import 'package:billa_mobile/core/platform/link_launcher.dart';
import 'package:billa_mobile/features/customers/domain/customer.dart';
import 'package:billa_mobile/features/customers/domain/customer_repository.dart';
import 'package:billa_mobile/features/customers/presentation/providers/customer_repository_provider.dart';
import 'package:billa_mobile/features/documents/domain/document.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/domain/document_repository.dart';
import 'package:billa_mobile/features/documents/presentation/providers/document_contact.dart';
import 'package:billa_mobile/features/documents/presentation/providers/document_repository_provider.dart';
import 'package:billa_mobile/features/auth/presentation/providers/auth_controller.dart';
import '../../../account/support.dart';
import '../../../../support/tall_screen.dart';

class _MockDocumentRepository extends Mock implements DocumentRepository {}

class _MockCustomerRepository extends Mock implements CustomerRepository {}

class _FakeLauncher implements LinkLauncher {
  @override
  Future<bool> call(String phone) async => true;

  @override
  Future<bool> sms(String phone, {String? body}) async => true;

  @override
  Future<bool> whatsapp(String phone, String message) async => true;
}

Document _document({
  DocumentType type = DocumentType.invoice,
  DocumentStatus status = DocumentStatus.finalized,
  String? publicToken = 'tok',
  int total = 10000,
  int amountPaid = 6000,
  String? sentAt = '2026-01-02T00:00:00.000Z',
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
      sentAt: sentAt,
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
        authControllerProvider.overrideWith(FakeAuthController.new),
        linkLauncherProvider.overrideWithValue(_FakeLauncher()),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, _) {
              // The signed-in business is already loaded by the time anyone taps share; watching it here does the same.
              ref.watch(authControllerProvider);
              return TextButton(
                onPressed: () => startDocumentContact(context, ref, documentId: 'd1'),
                child: const Text('go'),
              );
            },
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

    expect(find.textContaining('Acme sent you quote INV-0001'), findsOneWidget);
    expect(find.textContaining('outstanding'), findsNothing);
  });

  testWidgets('a fully paid invoice is shared, not chased', (tester) async {
    await start(tester, _document(amountPaid: 10000));

    expect(find.textContaining('sent you invoice INV-0001'), findsOneWidget);
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

  testWidgets('a reminder names the business and takes payment only when MoMo is on and the invoice is RWF', (tester) async {
    await start(
      tester,
      _document().copyWith(business: const DocumentBusinessRef(momoEnabled: true), dueDate: '2026-10-01T00:00:00.000Z'),
    );

    expect(find.textContaining('a reminder from Acme that invoice INV-0001'), findsOneWidget);
    expect(find.textContaining('Due date: 1 Oct 2026.'), findsOneWidget);
    expect(find.textContaining('View and pay it here'), findsOneWidget);
  });

  testWidgets('a foreign invoice reminder is in its currency and does not invite payment', (tester) async {
    await start(
      tester,
      _document(total: 125050, amountPaid: 25000).copyWith(
        currency: Currency.usd,
        exchangeRate: 1450,
        business: const DocumentBusinessRef(momoEnabled: true),
      ),
    );

    expect(find.textContaining('USD 1,000.50 outstanding'), findsOneWidget);
    expect(find.textContaining('View it here'), findsOneWidget);
    expect(find.textContaining('View and pay'), findsNothing);
  });

  testWidgets('a reminder for an invoice on a plan says which instalment is due now', (tester) async {
    await start(
      tester,
      _document().copyWith(nextInstallment: const DocumentNextInstallment(label: 'Deposit', remaining: 1500, dueDate: '2026-10-01')),
    );

    expect(find.textContaining('of which RWF 1,500 (Deposit) is due now'), findsOneWidget);
  });

  testWidgets('sharing a quote on WhatsApp records that it went out', (tester) async {
    when(() => documents.markShared('d1')).thenAnswer((_) async => '2026-02-01T10:00:00.000Z');
    await start(tester, _document(type: DocumentType.quote, amountPaid: 0));

    await tester.tap(find.byKey(const Key('contact-whatsapp')));
    await tester.pumpAndSettle();

    verify(() => documents.markShared('d1')).called(1);
  });

  testWidgets('a payment reminder is not a first share, so it records nothing', (tester) async {
    await start(tester, _document());

    await tester.tap(find.byKey(const Key('contact-whatsapp')));
    await tester.pumpAndSettle();

    verifyNever(() => documents.markShared(any()));
  });

  testWidgets('texting a quote does not record a WhatsApp share', (tester) async {
    await start(tester, _document(type: DocumentType.quote, amountPaid: 0));

    await tester.tap(find.byKey(const Key('contact-sms')));
    await tester.pumpAndSettle();

    verifyNever(() => documents.markShared(any()));
  });

  testWidgets('failing to record the share stays silent, because WhatsApp is already open', (tester) async {
    when(() => documents.markShared('d1')).thenAnswer((_) async => throw Exception('server down'));
    await start(tester, _document(type: DocumentType.quote, amountPaid: 0));

    await tester.tap(find.byKey(const Key('contact-whatsapp')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('the first WhatsApp message about an unpaid invoice is the invoice going out, and is recorded', (tester) async {
    when(() => documents.markShared('d1')).thenAnswer((_) async => '2026-02-01T10:00:00.000Z');
    await start(tester, _document(sentAt: null));

    expect(find.textContaining('sent you invoice INV-0001'), findsOneWidget);
    await tester.tap(find.byKey(const Key('contact-whatsapp')));
    await tester.pumpAndSettle();

    verify(() => documents.markShared('d1')).called(1);
  });
}
