import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/documents/domain/document.dart';
import 'package:billa_mobile/features/documents/domain/document_draft_input.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/domain/document_repository.dart';
import 'package:billa_mobile/features/documents/presentation/providers/document_duplicate.dart';
import 'package:billa_mobile/features/documents/presentation/providers/document_repository_provider.dart';

class _MockDocumentRepository extends Mock implements DocumentRepository {}

class _FakeInput extends Fake implements DocumentDraftInput {}

Document _doc(String id) => Document(
      id: id,
      type: DocumentType.invoice,
      number: 'INV-0001',
      status: DocumentStatus.finalized,
      customerId: 'c1',
      customer: const DocumentCustomerRef(name: 'Acme'),
      issueDate: '2026-02-01T00:00:00.000Z',
      subtotal: 100,
      taxTotal: 0,
      total: 100,
      amountPaid: 0,
      createdAt: '2026-02-01T00:00:00.000Z',
      updatedAt: '2026-02-01T00:00:00.000Z',
    );

void main() {
  late _MockDocumentRepository repository;

  setUpAll(() => registerFallbackValue(_FakeInput()));

  setUp(() {
    repository = _MockDocumentRepository();
  });

  Future<void> press(WidgetTester tester) async {
    final router = GoRouter(routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(
          body: Consumer(
            builder: (context, ref, _) => TextButton(
              onPressed: () => duplicateDocument(context, ref, documentId: 'd-old'),
              child: const Text('duplicate'),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/documents/:id/edit',
        builder: (context, state) => Scaffold(body: Text('editing ${state.pathParameters['id']}')),
      ),
    ]);
    await tester.pumpWidget(ProviderScope(
      overrides: [documentRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ));
    await tester.tap(find.text('duplicate'));
    await tester.pumpAndSettle();
  }

  testWidgets('creates a draft from the original and opens it in the editor', (tester) async {
    when(() => repository.get('d-old')).thenAnswer((_) async => _doc('d-old'));
    when(() => repository.create(any())).thenAnswer((_) async => _doc('d-new'));

    await press(tester);

    final input = verify(() => repository.create(captureAny())).captured.single as DocumentDraftInput;
    expect(input.customerId, 'c1');
    expect(find.text('editing d-new'), findsOneWidget);
  });

  testWidgets('says why when the original cannot be loaded', (tester) async {
    when(() => repository.get('d-old')).thenAnswer(
      (_) async => throw DioException(requestOptions: RequestOptions(path: '/documents/d-old'), type: DioExceptionType.connectionError),
    );

    await press(tester);

    expect(find.text('Check your connection and try again'), findsOneWidget);
    verifyNever(() => repository.create(any()));
  });

  testWidgets('says why when the copy cannot be saved and stays where it was', (tester) async {
    when(() => repository.get('d-old')).thenAnswer((_) async => _doc('d-old'));
    when(() => repository.create(any())).thenAnswer(
      (_) async => throw DioException(requestOptions: RequestOptions(path: '/documents'), type: DioExceptionType.connectionTimeout),
    );

    await press(tester);

    expect(find.text('Check your connection and try again'), findsOneWidget);
    expect(find.text('duplicate'), findsOneWidget);
  });
}
