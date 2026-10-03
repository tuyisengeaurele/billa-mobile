import '../../../../support/tall_screen.dart';
import 'package:billa_mobile/features/business_settings/presentation/providers/business_settings_repository_provider.dart';
import 'package:billa_mobile/features/business_settings/domain/business_settings_repository.dart';
import 'package:billa_mobile/features/business_settings/domain/business_settings.dart';
import 'package:billa_mobile/core/platform/link_launcher.dart';
import 'package:billa_mobile/core/network/api_client.dart';
import 'package:billa_mobile/core/formatting/currency.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/customers/domain/customer.dart';
import 'package:billa_mobile/features/customers/domain/customer_payment_stats.dart';
import 'package:billa_mobile/features/customers/domain/customer_repository.dart';
import 'package:billa_mobile/features/customers/presentation/providers/customer_repository_provider.dart';
import 'package:billa_mobile/features/customers/presentation/screens/customer_detail_screen.dart';

class _MockCustomerRepository extends Mock implements CustomerRepository {}

class _MockSettings extends Mock implements BusinessSettingsRepository {}

class _FakeLauncher implements LinkLauncher {
  @override
  Future<bool> call(String phone) async => true;

  @override
  Future<bool> sms(String phone, {String? body}) async => true;

  @override
  Future<bool> whatsapp(String phone, String message) async => true;
}

const _customer = Customer(id: 'c1', name: 'Acme', phone: '0788000000', isActive: true, createdAt: '2026-01-01T00:00:00.000Z');
const _stats = CustomerPaymentStats(paidInvoiceCount: 3, averageDaysToPay: -2, onTimeRate: 67);

void main() {
  late _MockCustomerRepository repository;

  setUp(() {
    repository = _MockCustomerRepository();
    when(() => repository.get('c1')).thenAnswer((_) async => _customer);
    when(() => repository.paymentStats('c1')).thenAnswer((_) async => _stats);
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [customerRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(theme: AppTheme.light, home: const CustomerDetailScreen(customerId: 'c1')),
    );
  }

  testWidgets('shows the customer profile and payment stats', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Acme'), findsOneWidget);
    expect(find.text('0788000000'), findsOneWidget);
    expect(find.text('3 paid invoices'), findsOneWidget);
    expect(find.text('67% paid on time'), findsOneWidget);
  });

  testWidgets('deactivate asks for confirmation, then calls update', (tester) async {
    when(() => repository.update('c1', isActive: false)).thenAnswer(
      (_) async => const Customer(id: 'c1', name: 'Acme', phone: '0788000000', isActive: false, createdAt: '2026-01-01T00:00:00.000Z'),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('customer-toggle-active')));
    await tester.pumpAndSettle();
    expect(find.text('Deactivate Acme?'), findsOneWidget);

    await tester.tap(find.text('Deactivate'));
    await tester.pumpAndSettle();

    verify(() => repository.update('c1', isActive: false)).called(1);
  });

  testWidgets('Contact opens the call, sms and whatsapp sheet for their number', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('customer-contact')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('contact-whatsapp')), findsOneWidget);
    expect(find.text('Hello Acme,'), findsOneWidget);
  });

  testWidgets('Contact on a customer with no number explains why the actions are off', (tester) async {
    when(() => repository.get('c1')).thenAnswer(
      (_) async => const Customer(id: 'c1', name: 'Acme', isActive: true, createdAt: '2026-01-01T00:00:00.000Z'),
    );
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('customer-contact')));
    await tester.pumpAndSettle();

    expect(find.text('No phone number saved'), findsNWidgets(3));
  });

  testWidgets('deactivating confirms afterwards and Undo brings the customer back', (tester) async {
    when(() => repository.update('c1', isActive: false)).thenAnswer(
      (_) async => const Customer(id: 'c1', name: 'Acme', isActive: false, createdAt: '2026-01-01T00:00:00.000Z'),
    );
    when(() => repository.update('c1', isActive: true)).thenAnswer((_) async => _customer);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('customer-toggle-active')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deactivate'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 750));

    expect(find.text('Acme deactivated'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pump();

    verify(() => repository.update('c1', isActive: true)).called(1);
  });

  testWidgets('a failed deactivation says why and leaves the customer as they were', (tester) async {
    when(() => repository.update('c1', isActive: false)).thenAnswer(
      (_) async => throw DioException(requestOptions: RequestOptions(path: '/customers/c1'), type: DioExceptionType.connectionError),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('customer-toggle-active')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deactivate'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 750));

    expect(find.text('Check your connection and try again'), findsOneWidget);
    expect(find.text('Deactivate customer'), findsOneWidget);
  });

  testWidgets('shows the credit limit and what the customer owes, one currency at a time', (tester) async {
    when(() => repository.get('c1')).thenAnswer(
      (_) async => const Customer(
        id: 'c1',
        name: 'Acme',
        isActive: true,
        createdAt: '2026-01-01T00:00:00.000Z',
        creditLimit: 500000,
        outstandingBalance: 120000,
        outstandingTotals: [
          OutstandingTotal(currency: Currency.rwf, amount: 70000),
          OutstandingTotal(currency: Currency.usd, amount: 50000),
        ],
      ),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Credit limit'), findsOneWidget);
    expect(find.text('RWF 500,000'), findsOneWidget);
    expect(find.text('Owes'), findsOneWidget);
    expect(find.text('RWF 70,000'), findsOneWidget);
    expect(find.text('USD 500.00'), findsOneWidget);
  });

  testWidgets('says nothing about credit for a customer with no limit and no balance', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Credit limit'), findsNothing);
    expect(find.text('Owes'), findsNothing);
  });

  group('statement', () {
    const owing = Customer(
      id: 'c1',
      name: 'Acme',
      phone: '0788123456',
      email: 'ada@example.com',
      isActive: true,
      createdAt: '2026-01-01T00:00:00.000Z',
      portalToken: 'tok123',
      outstandingBalance: 70000,
      outstandingTotals: [
        OutstandingTotal(currency: Currency.rwf, amount: 70000),
        OutstandingTotal(currency: Currency.usd, amount: 50000),
      ],
    );
    late _MockSettings settings;

    Widget buildWith() => ProviderScope(
          overrides: [
            customerRepositoryProvider.overrideWithValue(repository),
            businessSettingsRepositoryProvider.overrideWithValue(settings),
            linkLauncherProvider.overrideWithValue(_FakeLauncher()),
          ],
          child: MaterialApp(theme: AppTheme.light, home: const CustomerDetailScreen(customerId: 'c1')),
        );

    BusinessSettings business({bool momo = false}) =>
        BusinessSettings(id: 'b1', name: 'Kigali Traders', momoEnabled: momo);

    setUp(() {
      settings = _MockSettings();
      when(() => settings.get()).thenAnswer((_) async => business());
      when(() => repository.get('c1')).thenAnswer((_) async => owing);
    });

    testWidgets('shows the statement message first, with each currency on its own', (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(buildWith());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('customer-statement')));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Hello Acme, this is your statement from Kigali Traders. You currently owe RWF 70,000 + USD 500.00.'),
        findsOneWidget,
      );
      expect(find.textContaining('See your invoices here: $apiBaseUrl/portal/tok123'), findsOneWidget);
    });

    testWidgets('invites payment when the business takes MoMo', (tester) async {
      when(() => settings.get()).thenAnswer((_) async => business(momo: true));
      useTallScreen(tester);
      await tester.pumpWidget(buildWith());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('customer-statement')));
      await tester.pumpAndSettle();

      expect(find.textContaining('See and pay your invoices here'), findsOneWidget);
    });

    testWidgets('still sends a statement when the business details cannot be loaded', (tester) async {
      when(() => settings.get()).thenAnswer((_) async => throw Exception('offline'));
      useTallScreen(tester);
      await tester.pumpWidget(buildWith());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('customer-statement')));
      await tester.pumpAndSettle();

      expect(find.textContaining('this is your statement from'), findsOneWidget);
      expect(find.textContaining('See your invoices here'), findsOneWidget);
    });

    testWidgets('emailing asks first, then sends and says where it went', (tester) async {
      when(() => repository.sendStatement('c1')).thenAnswer((_) async => 'ada@example.com');
      useTallScreen(tester);
      await tester.pumpWidget(buildWith());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('customer-statement-email')));
      await tester.pumpAndSettle();
      expect(find.text('Email the statement to ada@example.com?'), findsOneWidget);
      verifyNever(() => repository.sendStatement(any()));

      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();

      verify(() => repository.sendStatement('c1')).called(1);
      expect(find.text('Statement sent to ada@example.com'), findsOneWidget);
    });

    testWidgets('a failed email says why and Retry sends it again', (tester) async {
      var failing = true;
      when(() => repository.sendStatement('c1')).thenAnswer((_) async {
        if (failing) {
          throw DioException(
            requestOptions: RequestOptions(path: '/customers/c1/send-statement'),
            response: Response(
              requestOptions: RequestOptions(path: '/customers/c1/send-statement'),
              statusCode: 502,
              data: {'error': 'email_send_failed'},
            ),
          );
        }
        return 'ada@example.com';
      });
      useTallScreen(tester);
      await tester.pumpWidget(buildWith());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('customer-statement-email')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();
      expect(find.text("Couldn't send the email"), findsOneWidget);

      failing = false;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('Statement sent to ada@example.com'), findsOneWidget);
    });

    testWidgets('a customer with no email cannot be emailed and the screen says what to do', (tester) async {
      when(() => repository.get('c1')).thenAnswer((_) async => owing.copyWith(email: null));
      useTallScreen(tester);
      await tester.pumpWidget(buildWith());
      await tester.pumpAndSettle();

      expect(tester.widget<OutlinedButton>(find.byKey(const Key('customer-statement-email'))).onPressed, isNull);
      expect(find.text('Add an email address to this customer to email a statement.'), findsOneWidget);
      expect(tester.widget<OutlinedButton>(find.byKey(const Key('customer-statement'))).onPressed, isNotNull);
    });

    testWidgets('a customer who owes nothing has no statement, and the screen says so', (tester) async {
      when(() => repository.get('c1')).thenAnswer((_) async => owing.copyWith(outstandingBalance: 0, outstandingTotals: const []));
      useTallScreen(tester);
      await tester.pumpWidget(buildWith());
      await tester.pumpAndSettle();

      expect(tester.widget<OutlinedButton>(find.byKey(const Key('customer-statement'))).onPressed, isNull);
      expect(tester.widget<OutlinedButton>(find.byKey(const Key('customer-statement-email'))).onPressed, isNull);
      expect(find.text('They owe nothing right now, so there is no statement to send.'), findsOneWidget);
    });
  });
}
