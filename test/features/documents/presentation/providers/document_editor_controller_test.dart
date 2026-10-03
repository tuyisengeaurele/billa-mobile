import 'package:billa_mobile/features/documents/domain/installment_plan.dart';
import 'package:billa_mobile/features/documents/domain/exchange_rates.dart';
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
      DocumentLanguage language = DocumentLanguage.en,
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
          lines: const [
            DocumentLine(
              id: 'l1',
              description: 'Printing',
              quantity: 1,
              unitPrice: 11800,
              taxRate: 0,
              lineTotal: 11800,
              sortOrder: 0,
            ),
          ],
          language: language,
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
      expect(state.preservedPlanNote, isNull);
    });

    test('keeps its repeat schedule when saved', () async {
      final state = await open(webDraft(interval: 'MONTHLY'));

      expect(state.toInput().recurrence, const RecurrenceInput(interval: 'MONTHLY', endDate: '2027-01-01'));
      expect(state.toInput().installments, isNull);
      expect(state.preservedPlanNote, 'This draft repeats every month. Change how often on the web.');
    });

    test('keeps its language when saved, so a French draft is not turned into an English one', () async {
      final state = await open(webDraft(language: DocumentLanguage.fr));

      expect(state.language, DocumentLanguage.fr);
      expect(state.toInput().language, DocumentLanguage.fr);
    });

    test('a draft with a payment plan cannot change currency, because the plan is in the old one', () async {
      final state = await open(webDraft(installments: const [
        DocumentInstallment(amount: 4000, dueDate: '2026-10-01T00:00:00.000Z'),
        DocumentInstallment(amount: 7800, dueDate: '2026-11-01T00:00:00.000Z'),
      ]));
      expect(state.currencyLocked, isTrue);

      final notifier = container.read(documentEditorControllerProvider(const DocumentEditorArgs.edit('d1')).notifier);
      await notifier.setCurrency(Currency.usd);

      final after = container.read(documentEditorControllerProvider(const DocumentEditorArgs.edit('d1'))).requireValue;
      expect(after.currency, Currency.rwf);
      verifyNever(() => repository.rates());
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

  group('currency', () {
    const usdRates = ExchangeRates({Currency.usd: RateQuote(rate: 1400, source: 'BNR', date: '2026-09-29')});

    Future<DocumentEditorController> open() async {
      const arg = DocumentEditorArgs.create(DocumentType.invoice);
      container.listen(documentEditorControllerProvider(arg), (_, _) {});
      await container.read(documentEditorControllerProvider(arg).future);
      return container.read(documentEditorControllerProvider(arg).notifier);
    }

    DocumentEditorState current() =>
        container.read(documentEditorControllerProvider(const DocumentEditorArgs.create(DocumentType.invoice))).requireValue;

    test('switching to a foreign currency prefills the bank rate and reprices the lines through RWF', () async {
      when(() => repository.rates()).thenAnswer((_) async => usdRates);
      final notifier = await open();
      notifier.addLine();
      notifier.setLineUnitPrice(0, 14000);

      await notifier.setCurrency(Currency.usd);

      expect(current().currency, Currency.usd);
      expect(current().exchangeRate, 1400);
      expect(current().lines.single.unitPrice, 1000);
      expect(current().rateHint, 'National Bank of Rwanda reference rate, 29 Sep 2026.');
      expect(current().repriceNote, isFalse);
    });

    test('a flat discount is repriced with the prices, a percent discount is left alone', () async {
      when(() => repository.rates()).thenAnswer((_) async => usdRates);
      final notifier = await open();
      notifier.addLine();
      notifier.addLine();
      notifier.setLineDiscount(0, DiscountType.flat, 1400);
      notifier.setLineDiscount(1, DiscountType.percent, 10);

      await notifier.setCurrency(Currency.usd);

      expect(current().lines[0].discountValue, 100);
      expect(current().lines[1].discountValue, 10);
    });

    test('when the rates cannot be loaded the prices stay as typed and the user is told', () async {
      when(() => repository.rates()).thenAnswer((_) async => throw Exception('offline'));
      final notifier = await open();
      notifier.addLine();
      notifier.setLineUnitPrice(0, 14000);

      await notifier.setCurrency(Currency.usd);

      expect(current().currency, Currency.usd);
      expect(current().exchangeRate, isNull);
      expect(current().lines.single.unitPrice, 14000);
      expect(current().repriceNote, isTrue);
    });

    test('a foreign draft with no rate is not savable, and is once a rate is typed', () async {
      when(() => repository.rates()).thenAnswer((_) async => const ExchangeRates({}));
      final notifier = await open();
      notifier.setCustomer('c1', 'Acme');

      await notifier.setCurrency(Currency.usd);
      expect(current().isSavable, isFalse);

      notifier.setExchangeRate(1400);
      expect(current().isSavable, isTrue);
    });

    test('switching back to RWF clears the rate and reprices back', () async {
      when(() => repository.rates()).thenAnswer((_) async => usdRates);
      final notifier = await open();
      notifier.addLine();
      notifier.setLineUnitPrice(0, 14000);
      await notifier.setCurrency(Currency.usd);

      await notifier.setCurrency(Currency.rwf);

      expect(current().currency, Currency.rwf);
      expect(current().exchangeRate, isNull);
      expect(current().lines.single.unitPrice, 14000);
    });

    test('a document that refers to an invoice keeps the invoice currency and cannot change it', () async {
      final notifier = await open();

      notifier.setReferencedDocument(
        const DocumentRef(id: 'inv1', number: 'INV-1', type: DocumentType.invoice),
        currency: Currency.usd,
        exchangeRate: 1450,
      );
      expect(current().currency, Currency.usd);
      expect(current().exchangeRate, 1450);
      expect(current().currencyLocked, isTrue);

      await notifier.setCurrency(Currency.eur);
      expect(current().currency, Currency.usd);
    });

    test('picking a catalog item converts its RWF price into the draft currency', () async {
      when(() => repository.rates()).thenAnswer((_) async => usdRates);
      final notifier = await open();
      notifier.addLine();
      await notifier.setCurrency(Currency.usd);

      notifier.selectLineItem(0, itemId: 'i1', description: 'Printing', unitPrice: 14000, taxRate: 18);

      expect(current().lines.single.unitPrice, 1000);
    });

    test('picking the invoice of a credit note reprices the typed lines into the invoice currency', () async {
      final notifier = await open();
      notifier.addLine();
      notifier.setLineUnitPrice(0, 14000);

      notifier.setReferencedDocument(
        const DocumentRef(id: 'inv1', number: 'INV-1', type: DocumentType.invoice),
        currency: Currency.usd,
        exchangeRate: 1400,
      );

      expect(current().currency, Currency.usd);
      expect(current().lines.single.unitPrice, 1000);
      expect(current().repriceNote, isFalse);
    });

    test('when the typed prices cannot be converted into the invoice currency the user is told to check them', () async {
      when(() => repository.rates()).thenAnswer((_) async => const ExchangeRates({}));
      final notifier = await open();
      await notifier.setCurrency(Currency.usd);
      notifier.addLine();
      notifier.setLineUnitPrice(0, 1000);

      notifier.setReferencedDocument(
        const DocumentRef(id: 'inv1', number: 'INV-1', type: DocumentType.invoice),
        currency: Currency.eur,
        exchangeRate: 1500,
      );

      expect(current().currency, Currency.eur);
      expect(current().lines.single.unitPrice, 1000);
      expect(current().repriceNote, isTrue);
    });

    test('the request carries the currency and rate, and none for RWF', () async {
      when(() => repository.rates()).thenAnswer((_) async => usdRates);
      final notifier = await open();
      notifier.setCustomer('c1', 'Acme');

      expect(current().toInput().currency, Currency.rwf);
      expect(current().toInput().exchangeRate, isNull);

      await notifier.setCurrency(Currency.usd);
      expect(current().toInput().currency, Currency.usd);
      expect(current().toInput().exchangeRate, 1400);
    });
  });

  group('payment terms', () {
    const arg = DocumentEditorArgs.create(DocumentType.invoice);

    Future<DocumentEditorController> open() async {
      container.listen(documentEditorControllerProvider(arg), (_, _) {});
      await container.read(documentEditorControllerProvider(arg).future);
      return container.read(documentEditorControllerProvider(arg).notifier);
    }

    DocumentEditorState current() => container.read(documentEditorControllerProvider(arg)).requireValue;

    test('choosing a term sets the due date that many days after the issue date', () async {
      final notifier = await open();
      notifier.setIssueDate(DateTime(2026, 9, 1));

      notifier.setPaymentTerm(30);

      expect(current().dueDate, DateTime(2026, 10, 1));
      expect(current().paymentTermDays, 30);
    });

    test('moving the issue date moves a preset due date with it', () async {
      final notifier = await open();
      notifier.setIssueDate(DateTime(2026, 9, 1));
      notifier.setPaymentTerm(14);

      notifier.setIssueDate(DateTime(2026, 9, 10));

      expect(current().dueDate, DateTime(2026, 9, 24));
      expect(current().paymentTermDays, 14);
    });

    test('a custom due date stays where the user put it when the issue date moves', () async {
      final notifier = await open();
      notifier.setIssueDate(DateTime(2026, 9, 1));
      notifier.setDueDate(DateTime(2026, 9, 11));
      expect(current().paymentTermDays, isNull);

      notifier.setIssueDate(DateTime(2026, 9, 5));

      expect(current().dueDate, DateTime(2026, 9, 11));
    });

    test('a draft with no due date still has none after the issue date moves', () async {
      final notifier = await open();

      notifier.setIssueDate(DateTime(2026, 9, 5));

      expect(current().dueDate, isNull);
      expect(current().paymentTermDays, isNull);
    });
  });

  test('linking a line to an item keeps its text and price and marks it as a catalog line', () async {
    const arg = DocumentEditorArgs.create(DocumentType.invoice);
    container.listen(documentEditorControllerProvider(arg), (_, _) {});
    await container.read(documentEditorControllerProvider(arg).future);
    final notifier = container.read(documentEditorControllerProvider(arg).notifier);
    notifier.addLine();
    notifier.setLineDescription(0, 'Printing');
    notifier.setLineUnitPrice(0, 5000);

    notifier.linkLineItem(0, 'i9');

    final line = container.read(documentEditorControllerProvider(arg)).requireValue.lines.single;
    expect(line.itemId, 'i9');
    expect(line.description, 'Printing');
    expect(line.unitPrice, 5000);
  });

  group('payment plan', () {
    const arg = DocumentEditorArgs.create(DocumentType.invoice);

    Future<DocumentEditorController> open({int price = 10000}) async {
      container.listen(documentEditorControllerProvider(arg), (_, _) {});
      await container.read(documentEditorControllerProvider(arg).future);
      final notifier = container.read(documentEditorControllerProvider(arg).notifier);
      notifier.setIssueDate(DateTime(2026, 9, 1));
      notifier.setCustomer('c1', 'Acme');
      notifier.addLine();
      notifier.setLineDescription(0, 'Printing');
      notifier.setLineTaxRate(0, 0);
      notifier.setLineUnitPrice(0, price);
      return notifier;
    }

    DocumentEditorState current() => container.read(documentEditorControllerProvider(arg)).requireValue;

    test('two equal parts split the total, the first falling due a month after the issue date', () async {
      final notifier = await open();

      notifier.startPlan(PlanPreset.twoParts);

      expect(current().plannedInstallments.map((r) => (r.amount, r.dueDate)), [
        (5000, '2026-10-01'),
        (5000, '2026-11-01'),
      ]);
    });

    test('the first instalment follows a due date the user already chose', () async {
      final notifier = await open();
      notifier.setDueDate(DateTime(2026, 9, 20));

      notifier.startPlan(PlanPreset.twoParts);

      expect(current().plannedInstallments.first.dueDate, '2026-09-20');
    });

    test('a deposit preset takes thirty percent now and the balance later', () async {
      final notifier = await open();

      notifier.startPlan(PlanPreset.deposit);

      expect(current().plannedInstallments.map((r) => (r.label, r.amount)), [('Deposit', 3000), ('Balance', 7000)]);
    });

    test('editing an earlier amount moves the balance', () async {
      final notifier = await open();
      notifier.startPlan(PlanPreset.twoParts);

      notifier.setInstallmentAmount(0, 2000);

      expect(current().plannedInstallments.map((r) => r.amount), [2000, 8000]);
    });

    test('changing a line price moves the balance, so the saved plan always adds up', () async {
      final notifier = await open();
      notifier.startPlan(PlanPreset.deposit);

      notifier.setLineUnitPrice(0, 20000);

      expect(current().plannedInstallments.map((r) => r.amount), [3000, 17000]);
      expect(current().toInput().installments!.fold<int>(0, (a, r) => a + r.amount), 20000);
    });

    test('earlier instalments that reach the total are reported and block saving', () async {
      final notifier = await open();
      notifier.startPlan(PlanPreset.twoParts);
      expect(current().isSavable, isTrue);

      notifier.setInstallmentAmount(0, 10000);

      expect(
        current().installmentProblem,
        'The earlier instalments already add up to the whole total. Lower them so the balance is more than zero.',
      );
      expect(current().isSavable, isFalse);
    });

    test('adding puts a new row before the balance, up to twelve, and removing stops at two', () async {
      final notifier = await open();
      notifier.startPlan(PlanPreset.twoParts);

      notifier.addInstallment();
      expect(current().installments, hasLength(3));
      expect(current().installments.last.amount, 5000);

      for (var i = 0; i < 20; i++) {
        notifier.addInstallment();
      }
      expect(current().installments, hasLength(12));

      for (var i = 0; i < 20; i++) {
        notifier.removeInstallment(0);
      }
      expect(current().installments, hasLength(2));
    });

    test('a name left empty is no name, and a date is kept as a plain date', () async {
      final notifier = await open();
      notifier.startPlan(PlanPreset.twoParts);

      notifier.setInstallmentLabel(0, 'Deposit');
      notifier.setInstallmentLabel(0, '  ');
      notifier.setInstallmentDate(1, DateTime(2026, 12, 24));

      expect(current().installments.first.label, isNull);
      expect(current().installments.last.dueDate, '2026-12-24');
    });

    test('paying in full again drops the plan from the request', () async {
      final notifier = await open();
      notifier.startPlan(PlanPreset.twoParts);
      expect(current().toInput().installments, isNotNull);

      notifier.clearPlan();

      expect(current().installments, isEmpty);
      expect(current().toInput().installments, isNull);
    });

    test('a draft with a plan keeps its currency, because the amounts are in it', () async {
      final notifier = await open();
      notifier.startPlan(PlanPreset.twoParts);

      expect(current().currencyLocked, isTrue);
      await notifier.setCurrency(Currency.usd);

      expect(current().currency, Currency.rwf);
    });

    test('a foreign plan works in cents', () async {
      when(() => repository.rates()).thenAnswer(
        (_) async => const ExchangeRates({Currency.usd: RateQuote(rate: 1400, source: 'BNR', date: '2026-09-29')}),
      );
      final notifier = await open(price: 0);
      await notifier.setCurrency(Currency.usd);
      notifier.setLineUnitPrice(0, 10000);

      notifier.startPlan(PlanPreset.twoParts);

      expect(current().plannedInstallments.map((r) => r.amount), [5000, 5000]);
      expect(current().toInput().currency, Currency.usd);
    });

    test('only an invoice can be paid in instalments', () async {
      const quote = DocumentEditorArgs.create(DocumentType.quote);
      container.listen(documentEditorControllerProvider(quote), (_, _) {});
      await container.read(documentEditorControllerProvider(quote).future);
      final notifier = container.read(documentEditorControllerProvider(quote).notifier);
      notifier.addLine();
      notifier.setLineUnitPrice(0, 10000);

      notifier.startPlan(PlanPreset.twoParts);

      expect(container.read(documentEditorControllerProvider(quote)).requireValue.installments, isEmpty);
    });

    test('a repeating invoice cannot also be paid in instalments', () async {
      when(() => repository.get('d1')).thenAnswer((_) async => Document(
            id: 'd1',
            type: DocumentType.invoice,
            status: DocumentStatus.draft,
            customerId: 'c1',
            customer: _customer,
            issueDate: '2026-09-01T00:00:00.000Z',
            subtotal: 10000,
            taxTotal: 0,
            total: 10000,
            amountPaid: 0,
            recurrenceInterval: 'MONTHLY',
            createdAt: '2026-09-01T00:00:00.000Z',
            updatedAt: '2026-09-01T00:00:00.000Z',
          ));
      const repeating = DocumentEditorArgs.edit('d1');
      container.listen(documentEditorControllerProvider(repeating), (_, _) {});
      await container.read(documentEditorControllerProvider(repeating).future);
      final notifier = container.read(documentEditorControllerProvider(repeating).notifier);

      notifier.startPlan(PlanPreset.twoParts);

      final state = container.read(documentEditorControllerProvider(repeating)).requireValue;
      expect(state.installments, isEmpty);
      expect(state.canHavePlan, isFalse);
    });
  });
}
