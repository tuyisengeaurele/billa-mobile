import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/formatting/currency.dart';
import '../../domain/document.dart';
import '../../domain/document_draft_input.dart';
import '../../domain/document_enums.dart';
import '../../domain/document_totals.dart';
import '../../domain/exchange_rates.dart';
import '../../domain/payment_terms.dart';
import 'document_repository_provider.dart';

enum AutosaveStatus { idle, saving, saved, error }

class DocumentEditorArgs {
  const DocumentEditorArgs.create(this.type) : documentId = null;
  const DocumentEditorArgs.edit(this.documentId) : type = null;

  final DocumentType? type;
  final String? documentId;

  // Riverpod's family caches providers by this value's equality, without
  // this override, every rebuild would look like a brand-new document and
  // drop whatever draft state was already in progress.
  @override
  bool operator ==(Object other) =>
      other is DocumentEditorArgs && other.type == type && other.documentId == documentId;

  @override
  int get hashCode => Object.hash(type, documentId);
}

class DocumentLineDraft {
  const DocumentLineDraft({
    required this.localId,
    this.itemId,
    this.description = '',
    this.quantity = 1,
    this.unitPrice = 0,
    this.taxRate = 18,
    this.discountType,
    this.discountValue,
  });

  final int localId;
  final String? itemId;
  final String description;
  final double quantity;
  final int unitPrice;
  final double taxRate;
  final DiscountType? discountType;
  final double? discountValue;

  DocumentLineInput toInput() => DocumentLineInput(
        itemId: itemId,
        description: description,
        quantity: quantity,
        unitPrice: unitPrice,
        taxRate: taxRate,
        discountType: discountType,
        discountValue: discountValue,
      );
}

const _unset = Object();

class DocumentEditorState {
  const DocumentEditorState({
    required this.type,
    this.documentId,
    this.customerId,
    this.customerName,
    required this.issueDate,
    this.dueDate,
    this.notes = '',
    this.customerReference = '',
    this.referencedDocument,
    this.language = DocumentLanguage.en,
    this.currency = Currency.rwf,
    this.exchangeRate,
    this.installments = const [],
    this.recurrence,
    this.rateHint,
    this.repriceNote = false,
    this.lines = const [],
    this.autosaveStatus = AutosaveStatus.idle,
    this.autosaveError,
  });

  factory DocumentEditorState.blank(DocumentType type) =>
      DocumentEditorState(type: type, issueDate: DateTime.now());

  factory DocumentEditorState.fromDocument(Document document) => DocumentEditorState(
        type: document.type,
        documentId: document.id,
        customerId: document.customerId,
        customerName: document.customer.name,
        // Parses only the date portion as local midnight so the round trip
        // through the date picker and back to a request body never crosses
        // a timezone boundary (the full ISO string carries a UTC offset the
        // rest of this state never needs).
        issueDate: DateTime.parse(document.issueDate.split('T').first),
        dueDate: document.dueDate == null ? null : DateTime.parse(document.dueDate!.split('T').first),
        notes: document.notes ?? '',
        customerReference: document.customerReference ?? '',
        referencedDocument: document.referencedDocument,
        language: document.language,
        currency: document.currency,
        exchangeRate: document.exchangeRate,
        installments: [
          for (final step in document.installments)
            InstallmentInput(label: step.label, amount: step.amount, dueDate: step.dueDate.split('T').first),
        ],
        recurrence: document.recurrenceInterval == null
            ? null
            : RecurrenceInput(
                interval: document.recurrenceInterval!,
                endDate: document.recurrenceEndDate?.split('T').first,
              ),
        lines: document.lines
            .map((line) => DocumentLineDraft(
                  localId: line.sortOrder,
                  itemId: line.itemId,
                  description: line.description,
                  quantity: line.quantity,
                  unitPrice: line.unitPrice,
                  taxRate: line.taxRate,
                  discountType: line.discountType,
                  discountValue: line.discountValue,
                ))
            .toList(),
      );

  final DocumentType type;
  final String? documentId;
  final String? customerId;
  final String? customerName;
  final DateTime issueDate;
  final DateTime? dueDate;
  final String notes;
  final String customerReference;
  final DocumentRef? referencedDocument;
  final DocumentLanguage language;
  final Currency currency;
  final double? exchangeRate;

  // Set up on the web and sent back exactly as loaded, because saving replaces the whole draft.
  final List<InstallmentInput> installments;
  final RecurrenceInput? recurrence;
  final String? rateHint;

  /// True when the currency changed but the prices could not be converted, so the user must check them.
  final bool repriceNote;

  // A document that refers to an invoice is always in the invoice's currency at its rate, and a payment plan
  // is a list of amounts in the draft's currency that the phone cannot rewrite.
  bool get currencyLocked => referencedDocument != null || installments.isNotEmpty;

  String? get currencyLockNote => installments.isEmpty
      ? null
      : "This draft's payment plan is in ${currency.code}. Change the currency on the web.";

  final List<DocumentLineDraft> lines;
  final AutosaveStatus autosaveStatus;
  final String? autosaveError;

  bool get referencedDocumentRequired => type == DocumentType.receipt || type == DocumentType.creditNote;
  bool get referencedDocumentAllowed => type == DocumentType.deliveryNote || referencedDocumentRequired;

  // Mirrors documentLineSchema exactly, so autosave never sends the server
  // a payload it would reject with 400, validation and save-readiness are
  // the same check, not two parallel implementations.
  bool get _linesValid => lines.every((line) =>
      line.description.trim().isNotEmpty &&
      line.quantity > 0 &&
      line.unitPrice >= 0 &&
      line.taxRate >= 0 &&
      line.taxRate <= 100 &&
      (line.discountValue == null || line.discountValue! >= 0) &&
      (line.discountType != DiscountType.percent || (line.discountValue ?? 0) <= 100));

  /// The preset the due date equals, or null for a custom date.
  int? get paymentTermDays => matchPaymentTerm(issueDate, dueDate);

  // A foreign draft with no rate would be refused by the server.
  bool get isSavable =>
      customerId != null &&
      (!referencedDocumentRequired || referencedDocument != null) &&
      _linesValid &&
      rateProblem(currency, exchangeRate) == null;

  // These are kept but not editable on the phone, so the phone says so instead of hiding them.
  String? get preservedPlanNote {
    if (installments.isNotEmpty) {
      return 'This draft is paid in instalments set up on the web. Keep the total the same, or change the plan there.';
    }
    final interval = recurrence?.interval;
    if (interval == null) return null;
    return 'This draft repeats ${_recurrenceWords(interval)}. Change how often on the web.';
  }

  DocumentTotals get totals => calculateDocumentTotals(lines.map((line) => line.toInput()).toList());

  DocumentDraftInput toInput() => DocumentDraftInput(
        type: type,
        customerId: customerId!,
        issueDate: _formatDate(issueDate),
        dueDate: dueDate == null ? null : _formatDate(dueDate!),
        notes: notes.isEmpty ? null : notes,
        customerReference: customerReference.isEmpty ? null : customerReference,
        referencedDocumentId: referencedDocument?.id,
        language: language,
        currency: currency,
        exchangeRate: currency == Currency.rwf ? null : exchangeRate,
        // The server refuses an empty plan, so no plan is sent as no field at all.
        installments: installments.isEmpty ? null : installments,
        recurrence: recurrence,
        lines: lines.map((line) => line.toInput()).toList(),
      );

  DocumentEditorState copyWith({
    String? documentId,
    String? customerId,
    String? customerName,
    DateTime? issueDate,
    Object? dueDate = _unset,
    String? notes,
    String? customerReference,
    Object? referencedDocument = _unset,
    DocumentLanguage? language,
    Currency? currency,
    Object? exchangeRate = _unset,
    Object? rateHint = _unset,
    bool? repriceNote,
    List<DocumentLineDraft>? lines,
    AutosaveStatus? autosaveStatus,
    Object? autosaveError = _unset,
  }) {
    return DocumentEditorState(
      type: type,
      documentId: documentId ?? this.documentId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      issueDate: issueDate ?? this.issueDate,
      // dueDate/referencedDocument/autosaveError must be clearable back to
      // null (unlike the fields above, which only ever move from unset to
      // set), hence the sentinel default instead of a plain `??` fallback.
      dueDate: identical(dueDate, _unset) ? this.dueDate : dueDate as DateTime?,
      notes: notes ?? this.notes,
      customerReference: customerReference ?? this.customerReference,
      referencedDocument:
          identical(referencedDocument, _unset) ? this.referencedDocument : referencedDocument as DocumentRef?,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      exchangeRate: identical(exchangeRate, _unset) ? this.exchangeRate : exchangeRate as double?,
      installments: installments,
      recurrence: recurrence,
      rateHint: identical(rateHint, _unset) ? this.rateHint : rateHint as String?,
      repriceNote: repriceNote ?? this.repriceNote,
      lines: lines ?? this.lines,
      autosaveStatus: autosaveStatus ?? this.autosaveStatus,
      autosaveError: identical(autosaveError, _unset) ? this.autosaveError : autosaveError as String?,
    );
  }
}

String _recurrenceWords(String interval) => switch (interval) {
      'WEEKLY' => 'every week',
      'MONTHLY' => 'every month',
      'QUARTERLY' => 'every quarter',
      'ANNUALLY' => 'every year',
      _ => 'on a schedule',
    };

String _formatDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

class DocumentEditorController extends AutoDisposeFamilyAsyncNotifier<DocumentEditorState, DocumentEditorArgs> {
  static const _autosaveDebounce = Duration(milliseconds: 800);

  Timer? _debounceTimer;
  bool _saving = false;
  bool _saveAgainAfterCurrent = false;
  Completer<void>? _inFlight;
  int _nextLocalId = 0;

  @override
  Future<DocumentEditorState> build(DocumentEditorArgs arg) async {
    ref.onDispose(() => _debounceTimer?.cancel());
    if (arg.documentId case final id?) {
      final document = await ref.read(documentRepositoryProvider).get(id);
      return DocumentEditorState.fromDocument(document);
    }
    return DocumentEditorState.blank(arg.type!);
  }

  void _update(DocumentEditorState Function(DocumentEditorState) transform) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(transform(current));
    _scheduleAutosave();
  }

  void setCustomer(String customerId, String customerName) {
    _update((s) => s.customerId == customerId
        ? s.copyWith(customerName: customerName)
        // A reference is scoped to a specific customer server-side, so
        // switching customers always invalidates whatever was picked.
        : s.copyWith(customerId: customerId, customerName: customerName, referencedDocument: null));
  }

  // A due date picked from a term keeps its term when the issue date moves, as "Net 30" would; a date the
  // user chose by hand is theirs and stays put.
  void setIssueDate(DateTime date) => _update((s) {
        final term = s.paymentTermDays;
        return s.copyWith(issueDate: date, dueDate: term == null ? _unset : addDays(date, term));
      });
  void setPaymentTerm(int days) => _update((s) => s.copyWith(dueDate: addDays(s.issueDate, days)));
  void setDueDate(DateTime? date) => _update((s) => s.copyWith(dueDate: date));
  void setNotes(String value) => _update((s) => s.copyWith(notes: value));
  void setCustomerReference(String value) => _update((s) => s.copyWith(customerReference: value));
  // The typed prices were written in the old currency, so they are converted into the invoice's rather than
  // quietly relabelled, as a credit note for a dollar invoice would otherwise read a franc price as dollars.
  void setReferencedDocument(DocumentRef? reference, {Currency? currency, double? exchangeRate}) =>
      _update((s) {
        if (reference == null || currency == null) return s.copyWith(referencedDocument: reference);
        final repriced = _repriceLines(
          s.lines,
          from: s.currency,
          fromRate: s.exchangeRate,
          to: currency,
          toRate: exchangeRate,
        );
        return s.copyWith(
          referencedDocument: reference,
          currency: currency,
          exchangeRate: exchangeRate,
          lines: repriced ?? s.lines,
          repriceNote: repriced == null && s.lines.any((line) => line.unitPrice > 0),
        );
      });
  void setLanguage(DocumentLanguage language) => _update((s) => s.copyWith(language: language));

  // Asked every time a currency is chosen, as the web form does: the server keeps the rates fresh, and a
  // long editing session should not keep using a rate from when the draft was opened. A failure is not
  // an error to show, it just means no rate could be prefilled, and the user types one.
  Future<ExchangeRates?> _loadRates() async {
    try {
      return await ref.read(documentRepositoryProvider).rates();
    } catch (_) {
      return null;
    }
  }

  // Null when a rate is missing, so the caller keeps the typed numbers and asks the user to check them.
  List<DocumentLineDraft>? _repriceLines(
    List<DocumentLineDraft> lines, {
    required Currency from,
    required double? fromRate,
    required Currency to,
    required double? toRate,
  }) {
    final repriced = <DocumentLineDraft>[];
    for (final line in lines) {
      final price = convertMinor(line.unitPrice, from: from, fromRate: fromRate, to: to, toRate: toRate);
      final flat = line.discountType == DiscountType.flat;
      final discount = flat
          ? convertMinor((line.discountValue ?? 0).round(), from: from, fromRate: fromRate, to: to, toRate: toRate)
          : null;
      if (price == null || (flat && discount == null)) return null;
      repriced.add(_cloneLine(line, unitPrice: price, discountValue: flat ? discount!.toDouble() : line.discountValue));
    }
    return repriced;
  }

  Future<void> setCurrency(Currency next) async {
    final current = state.value;
    if (current == null || current.currencyLocked || next == current.currency) return;

    final quote = next == Currency.rwf ? null : (await _loadRates())?[next];
    final rate = quote?.rate;
    // The state may have moved on while the rates were loading.
    final latest = state.value;
    if (latest == null || latest.currencyLocked) return;

    final repriced = _repriceLines(
      latest.lines,
      from: latest.currency,
      fromRate: latest.exchangeRate,
      to: next,
      toRate: rate,
    );

    _update((s) => s.copyWith(
          currency: next,
          exchangeRate: rate,
          rateHint: rateHint(quote),
          lines: repriced ?? s.lines,
          repriceNote: repriced == null && s.lines.any((line) => line.unitPrice > 0),
        ));
  }

  void setExchangeRate(double? rate) => _update((s) => s.copyWith(exchangeRate: rate, rateHint: null));

  void addLine() {
    final localId = _nextLocalId++;
    _update((s) => s.copyWith(lines: [...s.lines, DocumentLineDraft(localId: localId)]));
  }

  void removeLine(int localId) {
    _update((s) => s.copyWith(lines: s.lines.where((line) => line.localId != localId).toList()));
  }

  void _updateLine(int localId, DocumentLineDraft Function(DocumentLineDraft) transform) {
    _update((s) => s.copyWith(
          lines: [for (final line in s.lines) if (line.localId == localId) transform(line) else line],
        ));
  }

  DocumentLineDraft _cloneLine(
    DocumentLineDraft line, {
    Object? itemId = _unset,
    String? description,
    double? quantity,
    int? unitPrice,
    double? taxRate,
    Object? discountType = _unset,
    Object? discountValue = _unset,
  }) =>
      DocumentLineDraft(
        localId: line.localId,
        itemId: identical(itemId, _unset) ? line.itemId : itemId as String?,
        description: description ?? line.description,
        quantity: quantity ?? line.quantity,
        unitPrice: unitPrice ?? line.unitPrice,
        taxRate: taxRate ?? line.taxRate,
        discountType: identical(discountType, _unset) ? line.discountType : discountType as DiscountType?,
        discountValue: identical(discountValue, _unset) ? line.discountValue : discountValue as double?,
      );

  // Editing the description by hand decouples the line from any linked
  // item, the same behavior the production web editor's ItemPicker uses.
  void setLineDescription(int localId, String text) =>
      _updateLine(localId, (line) => _cloneLine(line, description: text, itemId: null));

  // [unitPrice] is the catalog price, which is always in RWF.
  void selectLineItem(
    int localId, {
    required String itemId,
    required String description,
    required int unitPrice,
    required double taxRate,
  }) {
    final current = state.value;
    final price = current == null ? unitPrice : fromRwf(unitPrice, current.currency, current.exchangeRate);
    _updateLine(
      localId,
      (line) => _cloneLine(line, itemId: itemId, description: description, unitPrice: price, taxRate: taxRate),
    );
  }

  // Saving a typed line to the catalog links it afterwards, without touching the text or the price.
  void linkLineItem(int localId, String itemId) => _updateLine(localId, (line) => _cloneLine(line, itemId: itemId));

  void setLineQuantity(int localId, double quantity) =>
      _updateLine(localId, (line) => _cloneLine(line, quantity: quantity));
  void setLineUnitPrice(int localId, int unitPrice) =>
      _updateLine(localId, (line) => _cloneLine(line, unitPrice: unitPrice));
  void setLineTaxRate(int localId, double taxRate) => _updateLine(localId, (line) => _cloneLine(line, taxRate: taxRate));
  void setLineDiscount(int localId, DiscountType? type, double? value) =>
      _updateLine(localId, (line) => _cloneLine(line, discountType: type, discountValue: value));

  void _scheduleAutosave() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_autosaveDebounce, _runAutosave);
  }

  Future<void> _runAutosave() async {
    final current = state.value;
    if (current == null || !current.isSavable) return;

    // A save already in flight is never raced, a debounce firing mid-save
    // just queues one more run after it settles, rather than starting a
    // second overlapping request (which would silently create a duplicate
    // draft via a second create()).
    if (_saving) {
      _saveAgainAfterCurrent = true;
      return _inFlight?.future;
    }

    _saving = true;
    _inFlight = Completer<void>();
    state = AsyncData(current.copyWith(autosaveStatus: AutosaveStatus.saving));
    try {
      final repository = ref.read(documentRepositoryProvider);
      final saved = current.documentId == null
          ? await repository.create(current.toInput())
          : await repository.update(current.documentId!, current.toInput());
      final latest = state.value;
      if (latest != null) {
        state = AsyncData(latest.copyWith(
          documentId: saved.id,
          autosaveStatus: AutosaveStatus.saved,
          autosaveError: null,
        ));
      }
    } catch (e) {
      final latest = state.value;
      if (latest != null) {
        state = AsyncData(latest.copyWith(autosaveStatus: AutosaveStatus.error, autosaveError: describeActionError(e)));
      }
    } finally {
      _saving = false;
      final completer = _inFlight;
      _inFlight = null;
      if (_saveAgainAfterCurrent) {
        _saveAgainAfterCurrent = false;
        await _runAutosave();
      }
      completer?.complete();
    }
  }

  Future<void> retrySave() => _runAutosave();

  Future<void> flushPendingSave() async {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
      await _runAutosave();
      return;
    }
    if (_inFlight != null) await _inFlight!.future;
  }
}

final documentEditorControllerProvider = AsyncNotifierProvider.autoDispose
    .family<DocumentEditorController, DocumentEditorState, DocumentEditorArgs>(DocumentEditorController.new);
