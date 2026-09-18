import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/receivables/domain/outstanding_invoice.dart';
import 'package:billa_mobile/features/receivables/domain/receivables_repository.dart';
import 'package:billa_mobile/features/receivables/presentation/providers/receivables_repository_provider.dart';
import 'package:billa_mobile/features/receivables/presentation/screens/receivables_screen.dart';

class _MockReceivablesRepository extends Mock implements ReceivablesRepository {}

void main() {
  late _MockReceivablesRepository repository;

  setUp(() {
    repository = _MockReceivablesRepository();
  });

  Widget buildApp() {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => const ReceivablesScreen()),
      GoRoute(path: '/documents/:id', builder: (context, state) => const Scaffold(body: Text('detail screen'))),
    ]);
    return ProviderScope(
      overrides: [receivablesRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  testWidgets('shows an empty state when nothing is outstanding', (tester) async {
    when(() => repository.list()).thenAnswer((_) async => []);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Nothing outstanding — all invoices are paid up'), findsOneWidget);
  });

  testWidgets('shows each outstanding invoice with its aging bucket and navigates on tap', (tester) async {
    when(() => repository.list()).thenAnswer((_) async => [
          const OutstandingInvoice(
            id: 'd1',
            number: 'INV-0001',
            customerName: 'Acme',
            total: 10000,
            amountOwed: 4000,
            dueDate: '2026-01-01',
            daysOverdue: 12,
            agingBucket: '0-30',
          ),
        ]);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Acme'), findsOneWidget);
    expect(find.text('RWF 4,000'), findsOneWidget);

    await tester.tap(find.text('Acme'));
    await tester.pumpAndSettle();

    expect(find.text('detail screen'), findsOneWidget);
  });
}
