import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/pagination/paginated_result.dart';
import 'package:billa_mobile/features/documents/domain/document.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/domain/document_repository.dart';
import 'package:billa_mobile/features/documents/presentation/providers/document_repository_provider.dart';
import 'package:billa_mobile/features/documents/presentation/screens/document_list_screen.dart';

class _MockDocumentRepository extends Mock implements DocumentRepository {}

const _customer = DocumentCustomerRef(name: 'Acme');
const _document = Document(
  id: 'd1',
  type: DocumentType.invoice,
  number: 'INV-0001',
  status: DocumentStatus.finalized,
  customerId: 'c1',
  customer: _customer,
  issueDate: '2026-01-01T00:00:00.000Z',
  subtotal: 10000,
  taxTotal: 1800,
  total: 11800,
  amountPaid: 0,
  createdAt: '2026-01-01T00:00:00.000Z',
  updatedAt: '2026-01-01T00:00:00.000Z',
);

void main() {
  late _MockDocumentRepository repository;

  setUp(() {
    repository = _MockDocumentRepository();
  });

  Widget buildApp({DocumentStatus? initialStatus, List<DocumentType>? initialTypes}) {
    final router = GoRouter(routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => DocumentListScreen(initialStatus: initialStatus, initialTypes: initialTypes),
      ),
      GoRoute(
        path: '/documents/new',
        builder: (context, state) => Scaffold(body: Text('new document screen: ${state.extra}')),
      ),
      GoRoute(path: '/documents/:id', builder: (context, state) => const Scaffold(body: Text('document detail screen'))),
    ]);
    return ProviderScope(
      overrides: [documentRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  testWidgets('shows the empty state with no action for a brand-new business', (tester) async {
    when(() => repository.list(types: null, status: null, search: null, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: <Document>[], total: 0, page: 1, pageSize: 20),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('No documents yet'), findsOneWidget);
  });

  testWidgets('toggling a type chip refetches with that type', (tester) async {
    when(() => repository.list(types: null, status: null, search: null, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: <Document>[], total: 0, page: 1, pageSize: 20),
    );
    when(() => repository.list(types: [DocumentType.invoice], status: null, search: null, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: [_document], total: 1, page: 1, pageSize: 20),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Invoice'));
    await tester.pumpAndSettle();

    expect(find.text('INV-0001'), findsOneWidget);
  });

  testWidgets('tapping a row opens the detail screen', (tester) async {
    when(() => repository.list(types: null, status: null, search: null, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: [_document], total: 1, page: 1, pageSize: 20),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('INV-0001'));
    await tester.pumpAndSettle();

    expect(find.text('document detail screen'), findsOneWidget);
  });

  testWidgets('there is no floating add button: creating lives in the shell', (tester) async {
    when(() => repository.list(types: null, status: null, search: null, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: <Document>[], total: 0, page: 1, pageSize: 20),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('a tab that stays alive re-applies filters when it is opened with new ones', (tester) async {
    when(() => repository.list(types: null, status: null, search: null, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: <Document>[], total: 0, page: 1, pageSize: 20),
    );
    when(() => repository.list(types: null, status: DocumentStatus.draft, search: null, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: [_document], total: 1, page: 1, pageSize: 20),
    );
    final container = ProviderContainer(overrides: [documentRepositoryProvider.overrideWithValue(repository)]);
    addTearDown(container.dispose);

    Widget host(DocumentStatus? status) => UncontrolledProviderScope(
          container: container,
          child: MaterialApp(theme: AppTheme.light, home: DocumentListScreen(initialStatus: status)),
        );

    await tester.pumpWidget(host(null));
    await tester.pumpAndSettle();
    await tester.pumpWidget(host(DocumentStatus.draft));
    await tester.pumpAndSettle();

    expect(tester.widget<ChoiceChip>(find.byKey(const Key('document-status-draft'))).selected, isTrue);
    expect(find.text('INV-0001'), findsOneWidget);
  });

  testWidgets('opens with the initial status selected and fetches only those documents', (tester) async {
    when(() => repository.list(types: null, status: DocumentStatus.draft, search: null, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: [_document], total: 1, page: 1, pageSize: 20),
    );

    await tester.pumpWidget(buildApp(initialStatus: DocumentStatus.draft));
    await tester.pumpAndSettle();

    expect(tester.widget<ChoiceChip>(find.byKey(const Key('document-status-draft'))).selected, isTrue);
    expect(find.text('INV-0001'), findsOneWidget);
  });

  testWidgets('opens with the initial types selected', (tester) async {
    when(() => repository.list(types: [DocumentType.quote, DocumentType.proforma], status: null, search: null, page: 1, pageSize: 20))
        .thenAnswer((_) async => const PaginatedResult(results: [_document], total: 1, page: 1, pageSize: 20));

    await tester.pumpWidget(buildApp(initialTypes: [DocumentType.quote, DocumentType.proforma]));
    await tester.pumpAndSettle();

    expect(find.text('INV-0001'), findsOneWidget);
  });

  testWidgets('reopening without filters resets a filter left over from an earlier visit', (tester) async {
    when(() => repository.list(types: null, status: DocumentStatus.draft, search: null, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: <Document>[], total: 0, page: 1, pageSize: 20),
    );
    when(() => repository.list(types: null, status: null, search: null, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: [_document], total: 1, page: 1, pageSize: 20),
    );
    final container = ProviderContainer(overrides: [documentRepositoryProvider.overrideWithValue(repository)]);
    addTearDown(container.dispose);

    Widget host(Widget screen) => UncontrolledProviderScope(
          container: container,
          child: MaterialApp(theme: AppTheme.light, home: screen),
        );

    await tester.pumpWidget(host(const DocumentListScreen(initialStatus: DocumentStatus.draft)));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(host(const DocumentListScreen()));
    await tester.pumpAndSettle();

    expect(tester.widget<ChoiceChip>(find.byKey(const Key('document-status-all'))).selected, isTrue);
    expect(find.text('INV-0001'), findsOneWidget);
  });

  PaginatedResult<Document> page(List<Document> documents) =>
      PaginatedResult(results: documents, total: documents.length, page: 1, pageSize: 20);

  Future<void> swipeToDelete(WidgetTester tester, String id) async {
    await tester.drag(find.text('Draft Invoice'), const Offset(-400, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('document-swipe-delete-$id')));
    await tester.pumpAndSettle();
  }

  final draft = Document(
    id: 'd9',
    type: DocumentType.invoice,
    status: DocumentStatus.draft,
    customerId: 'c1',
    customer: _customer,
    issueDate: '2026-01-01T00:00:00.000Z',
    subtotal: 0,
    taxTotal: 0,
    total: 0,
    amountPaid: 0,
    createdAt: '2026-01-01T00:00:00.000Z',
    updatedAt: '2026-01-01T00:00:00.000Z',
  );

  testWidgets('deleting a draft asks first, removes it and says so', (tester) async {
    var listed = [draft];
    when(() => repository.list(types: null, status: null, search: null, page: 1, pageSize: 20))
        .thenAnswer((_) async => page(listed));
    when(() => repository.delete('d9')).thenAnswer((_) async => listed = []);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await swipeToDelete(tester, 'd9');

    expect(find.text('Delete this draft?'), findsOneWidget);
    verifyNever(() => repository.delete(any()));

    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();

    verify(() => repository.delete('d9')).called(1);
    expect(find.text('Draft deleted'), findsOneWidget);
    expect(find.text('Draft Invoice'), findsNothing);
  });

  testWidgets('cancelling the question leaves the draft alone', (tester) async {
    when(() => repository.list(types: null, status: null, search: null, page: 1, pageSize: 20))
        .thenAnswer((_) async => page([draft]));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await swipeToDelete(tester, 'd9');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(() => repository.delete(any()));
    expect(find.text('Draft Invoice'), findsOneWidget);
  });

  testWidgets('a failed delete keeps the draft, says why and offers a retry that works', (tester) async {
    var failing = true;
    var listed = [draft];
    when(() => repository.list(types: null, status: null, search: null, page: 1, pageSize: 20))
        .thenAnswer((_) async => page(listed));
    when(() => repository.delete('d9')).thenAnswer((_) async {
      if (failing) {
        throw DioException(requestOptions: RequestOptions(path: '/documents/d9'), type: DioExceptionType.connectionError);
      }
      listed = [];
    });

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await swipeToDelete(tester, 'd9');
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();

    expect(find.text('Check your connection and try again'), findsOneWidget);
    expect(find.text('Draft Invoice'), findsOneWidget);

    failing = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Draft deleted'), findsOneWidget);
    expect(find.text('Draft Invoice'), findsNothing);
  });

  testWidgets('if the list cannot refresh after the delete, says it was deleted and never deletes twice', (tester) async {
    var listed = [draft];
    var refreshFails = false;
    when(() => repository.list(types: null, status: null, search: null, page: 1, pageSize: 20)).thenAnswer((_) async {
      if (refreshFails) throw DioException(requestOptions: RequestOptions(path: '/documents'), type: DioExceptionType.connectionError);
      return page(listed);
    });
    when(() => repository.delete('d9')).thenAnswer((_) async {
      listed = [];
      refreshFails = true;
    });

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await swipeToDelete(tester, 'd9');
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();

    expect(find.text('Draft deleted. Pull down to refresh the list'), findsOneWidget);
    verify(() => repository.delete('d9')).called(1);
    expect(find.text('Retry'), findsNothing);
  });
}
