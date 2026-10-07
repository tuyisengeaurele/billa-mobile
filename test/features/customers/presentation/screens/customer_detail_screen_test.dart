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
}
