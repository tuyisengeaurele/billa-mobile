import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/documents/domain/document.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/domain/document_repository.dart';
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
}
