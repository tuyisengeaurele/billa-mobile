import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/customers/domain/customer.dart';
import 'package:billa_mobile/features/customers/domain/customer_repository.dart';
import 'package:billa_mobile/features/customers/presentation/providers/customer_repository_provider.dart';
import 'package:billa_mobile/features/documents/presentation/widgets/credit_limit_warning.dart';

class _MockCustomerRepository extends Mock implements CustomerRepository {}

Customer _customer({int? limit, int owes = 0}) => Customer(
      id: 'c1',
      name: 'Acme',
      isActive: true,
      createdAt: '2026-01-01T00:00:00.000Z',
      creditLimit: limit,
      outstandingBalance: owes,
    );

void main() {
  late _MockCustomerRepository repository;

  setUp(() {
    repository = _MockCustomerRepository();
  });

  Widget host({String customerId = 'c1', required int total}) => ProviderScope(
        overrides: [customerRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(body: CreditLimitWarning(customerId: customerId, invoiceTotalRwf: total)),
        ),
      );

  testWidgets('warns when this invoice would take the customer past their limit', (tester) async {
    when(() => repository.get('c1')).thenAnswer((_) async => _customer(limit: 500000, owes: 400000));

    await tester.pumpWidget(host(total: 150000));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Acme already owes RWF 400,000. With this invoice they would owe RWF 550,000, '
        'which is over their RWF 500,000 limit.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('says nothing when the customer lands exactly on the limit', (tester) async {
    when(() => repository.get('c1')).thenAnswer((_) async => _customer(limit: 500000, owes: 400000));

    await tester.pumpWidget(host(total: 100000));
    await tester.pumpAndSettle();

    expect(find.textContaining('over their'), findsNothing);
  });

  testWidgets('says nothing for a customer with no limit', (tester) async {
    when(() => repository.get('c1')).thenAnswer((_) async => _customer(owes: 9000000));

    await tester.pumpWidget(host(total: 150000));
    await tester.pumpAndSettle();

    expect(find.textContaining('over their'), findsNothing);
  });

  testWidgets('a failed lookup shows nothing, because the invoice itself is fine', (tester) async {
    when(() => repository.get('c1')).thenAnswer((_) async => throw Exception('offline'));

    await tester.pumpWidget(host(total: 150000));
    await tester.pumpAndSettle();

    expect(find.textContaining('over their'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('follows the invoice total as lines change, without asking the server again', (tester) async {
    when(() => repository.get('c1')).thenAnswer((_) async => _customer(limit: 500000, owes: 400000));

    await tester.pumpWidget(host(total: 50000));
    await tester.pumpAndSettle();
    expect(find.textContaining('over their'), findsNothing);

    await tester.pumpWidget(host(total: 250000));
    await tester.pumpAndSettle();

    expect(find.textContaining('which is over their RWF 500,000 limit.'), findsOneWidget);
    verify(() => repository.get('c1')).called(1);
  });

  testWidgets('looks up the new customer when the invoice is for someone else', (tester) async {
    when(() => repository.get('c1')).thenAnswer((_) async => _customer(limit: 100, owes: 0));
    when(() => repository.get('c2')).thenAnswer(
      (_) async => const Customer(id: 'c2', name: 'Beta', isActive: true, createdAt: '2026-01-01T00:00:00.000Z', creditLimit: 100),
    );

    await tester.pumpWidget(host(total: 5000));
    await tester.pumpAndSettle();
    expect(find.textContaining('Acme already owes'), findsOneWidget);

    await tester.pumpWidget(host(customerId: 'c2', total: 5000));
    await tester.pumpAndSettle();

    expect(find.textContaining('Beta already owes'), findsOneWidget);
    expect(find.textContaining('Acme already owes'), findsNothing);
  });
}
