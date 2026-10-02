import 'package:billa_mobile/core/formatting/currency.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/documents/domain/document.dart';
import 'package:billa_mobile/features/documents/domain/document_draft_input.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/domain/document_repository.dart';
import 'package:billa_mobile/features/documents/presentation/providers/document_editor_controller.dart';
import 'package:billa_mobile/features/documents/presentation/providers/document_repository_provider.dart';

class _MockDocumentRepository extends Mock implements DocumentRepository {}
class _FakeDocumentDraftInput extends Fake implements DocumentDraftInput {}

const _customer = DocumentCustomerRef(name: 'Acme');
Document _document({String id = 'd1'}) => Document(
      id: id,
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

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeDocumentDraftInput());
  });

  late _MockDocumentRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _MockDocumentRepository();
    container = ProviderContainer(overrides: [documentRepositoryProvider.overrideWithValue(repository)]);
    addTearDown(container.dispose);
  });

  test('does not autosave until the draft has a customer', () async {
    const arg = DocumentEditorArgs.create(DocumentType.invoice);
    container.listen(documentEditorControllerProvider(arg), (_, _) {});
    await container.read(documentEditorControllerProvider(arg).future);

    await Future<void>.delayed(const Duration(milliseconds: 900));

    verifyNever(() => repository.create(any()));
  });

  test('debounced autosave creates then updates the draft', () async {
    when(() => repository.create(any())).thenAnswer((_) async => _document());
    when(() => repository.update('d1', any())).thenAnswer((_) async => _document());

    const arg = DocumentEditorArgs.create(DocumentType.invoice);
    container.listen(documentEditorControllerProvider(arg), (_, _) {});
    await container.read(documentEditorControllerProvider(arg).future);
    final notifier = container.read(documentEditorControllerProvider(arg).notifier);

    notifier.setCustomer('c1', 'Acme');
    await Future<void>.delayed(const Duration(milliseconds: 900));
    verify(() => repository.create(any())).called(1);

    notifier.setNotes('Thanks for your business');
    await Future<void>.delayed(const Duration(milliseconds: 900));
    verify(() => repository.update('d1', any())).called(1);
  });

  test('a change during an in-flight save does not start a second request', () async {
    var createCalls = 0;
    when(() => repository.create(any())).thenAnswer((_) async {
      createCalls++;
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return _document();
    });
    when(() => repository.update('d1', any())).thenAnswer((_) async => _document());

    const arg = DocumentEditorArgs.create(DocumentType.invoice);
    container.listen(documentEditorControllerProvider(arg), (_, _) {});
    await container.read(documentEditorControllerProvider(arg).future);
    final notifier = container.read(documentEditorControllerProvider(arg).notifier);

    notifier.setCustomer('c1', 'Acme');
    await Future<void>.delayed(const Duration(milliseconds: 900)); // debounce fires; slow create() starts
    notifier.setNotes('changed mid-save');
    await Future<void>.delayed(const Duration(milliseconds: 900)); // second debounce fires while create() still in flight
    await Future<void>.delayed(const Duration(milliseconds: 700)); // let create() finish and any queued re-save run

    expect(createCalls, 1);
    verify(() => repository.update('d1', any())).called(1);
  });

  test('a failed save sets AutosaveStatus.error', () async {
    when(() => repository.create(any())).thenThrow(Exception('network down'));

    const arg = DocumentEditorArgs.create(DocumentType.invoice);
    container.listen(documentEditorControllerProvider(arg), (_, _) {});
    await container.read(documentEditorControllerProvider(arg).future);
    final notifier = container.read(documentEditorControllerProvider(arg).notifier);

    notifier.setCustomer('c1', 'Acme');
    await Future<void>.delayed(const Duration(milliseconds: 900));

    final state = container.read(documentEditorControllerProvider(arg)).value!;
    expect(state.autosaveStatus, AutosaveStatus.error);
  });

  test('loading an existing document populates the draft from it', () async {
    when(() => repository.get('d1')).thenAnswer((_) async => _document());

    const arg = DocumentEditorArgs.edit('d1');
    final state = await container.read(documentEditorControllerProvider(arg).future);

    expect(state.documentId, 'd1');
    expect(state.customerId, 'c1');
  });

  test('a line with no description blocks autosave even with a customer chosen', () async {
    const arg = DocumentEditorArgs.create(DocumentType.invoice);
    container.listen(documentEditorControllerProvider(arg), (_, _) {});
    await container.read(documentEditorControllerProvider(arg).future);
    final notifier = container.read(documentEditorControllerProvider(arg).notifier);

    notifier.setCustomer('c1', 'Acme');
    notifier.addLine();
    await Future<void>.delayed(const Duration(milliseconds: 900));

    verifyNever(() => repository.create(any()));
  });

  group('a draft made on the web', () {
    Document webDraft({
      Currency currency = Currency.rwf,
      double? rate,
      List<DocumentInstallment> installments = const [],
      String? interval,
    }) =>
        Document(
          id: 'd1',
          type: DocumentType.invoice,
          status: DocumentStatus.draft,
          customerId: 'c1',
          customer: _customer,
          issueDate: '2026-01-01T00:00:00.000Z',
          dueDate: '2026-11-01T00:00:00.000Z',
          subtotal: 11800,
          taxTotal: 0,
          total: 11800,
          currency: currency,
          exchangeRate: rate,
          installments: installments,
          recurrenceInterval: interval,
          recurrenceEndDate: interval == null ? null : '2027-01-01T00:00:00.000Z',
          amountPaid: 0,
          createdAt: '2026-01-01T00:00:00.000Z',
          updatedAt: '2026-01-01T00:00:00.000Z',
        );

    Future<DocumentEditorState> open(Document document) async {
      when(() => repository.get('d1')).thenAnswer((_) async => document);
      const arg = DocumentEditorArgs.edit('d1');
      container.listen(documentEditorControllerProvider(arg), (_, _) {});
      return container.read(documentEditorControllerProvider(arg).future);
    }

    test('keeps its currency and rate when saved', () async {
      final state = await open(webDraft(currency: Currency.usd, rate: 1450.5));

      expect(state.currency, Currency.usd);
      expect(state.exchangeRate, 1450.5);
      expect(state.toInput().currency, Currency.usd);
      expect(state.toInput().exchangeRate, 1450.5);
    });

    test('keeps its payment plan, with dates as plain dates, when saved', () async {
      final state = await open(webDraft(installments: const [
        DocumentInstallment(label: 'Deposit', amount: 4000, dueDate: '2026-10-01T00:00:00.000Z'),
        DocumentInstallment(amount: 7800, dueDate: '2026-11-01T00:00:00.000Z'),
      ]));

      expect(state.toInput().installments, const [
        InstallmentInput(label: 'Deposit', amount: 4000, dueDate: '2026-10-01'),
        InstallmentInput(amount: 7800, dueDate: '2026-11-01'),
      ]);
      expect(state.preservedPlanNote, contains('instalments'));
    });

    test('keeps its repeat schedule when saved', () async {
      final state = await open(webDraft(interval: 'MONTHLY'));

      expect(state.toInput().recurrence, const RecurrenceInput(interval: 'MONTHLY', endDate: '2027-01-01'));
      expect(state.toInput().installments, isNull);
      expect(state.preservedPlanNote, 'This draft repeats every month. Change how often on the web.');
    });

    test('a plain RWF draft sends neither a plan nor a schedule', () async {
      final state = await open(webDraft());

      expect(state.toInput().installments, isNull);
      expect(state.toInput().recurrence, isNull);
      expect(state.preservedPlanNote, isNull);
    });

    test('a foreign draft with no saved rate is not savable until one is typed', () async {
      final state = await open(webDraft(currency: Currency.usd));

      expect(state.isSavable, isFalse);
    });
  });
}
