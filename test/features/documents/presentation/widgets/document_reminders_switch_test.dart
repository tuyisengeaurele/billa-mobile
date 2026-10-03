import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/documents/domain/document.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/domain/document_repository.dart';
import 'package:billa_mobile/features/documents/presentation/providers/document_repository_provider.dart';
import 'package:billa_mobile/features/documents/presentation/widgets/document_reminders_switch.dart';

class _MockDocumentRepository extends Mock implements DocumentRepository {}

Document _document({required bool reminders}) => Document(
      id: 'd1',
      type: DocumentType.invoice,
      status: DocumentStatus.finalized,
      customerId: 'c1',
      customer: const DocumentCustomerRef(name: 'Acme'),
      issueDate: '2026-01-01T00:00:00.000Z',
      subtotal: 0,
      taxTotal: 0,
      total: 0,
      amountPaid: 0,
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
      remindersEnabled: reminders,
    );

void main() {
  late _MockDocumentRepository repository;

  setUp(() => repository = _MockDocumentRepository());

  Widget build({required bool reminders}) => ProviderScope(
        overrides: [documentRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(body: DocumentRemindersSwitch(documentId: 'd1', initial: reminders)),
        ),
      );

  bool isOn(WidgetTester tester) => tester.widget<SwitchListTile>(find.byKey(const Key('document-reminders'))).value;

  testWidgets('reflects whether reminders are on for this document', (tester) async {
    await tester.pumpWidget(build(reminders: false));

    expect(isOn(tester), isFalse);
  });

  testWidgets('turning it off tells the server and stays off', (tester) async {
    when(() => repository.setReminders('d1', enabled: false)).thenAnswer((_) async => _document(reminders: false));
    await tester.pumpWidget(build(reminders: true));

    await tester.tap(find.byKey(const Key('document-reminders')));
    await tester.pumpAndSettle();

    verify(() => repository.setReminders('d1', enabled: false)).called(1);
    expect(isOn(tester), isFalse);
  });

  testWidgets('a failure puts the switch back and says why', (tester) async {
    when(() => repository.setReminders('d1', enabled: false)).thenAnswer((_) async => throw DioException(
          requestOptions: RequestOptions(path: '/documents/d1/reminders'),
          type: DioExceptionType.connectionError,
        ));
    await tester.pumpWidget(build(reminders: true));

    await tester.tap(find.byKey(const Key('document-reminders')));
    await tester.pumpAndSettle();

    expect(isOn(tester), isTrue);
    expect(find.text('Check your connection and try again'), findsOneWidget);
  });
}
