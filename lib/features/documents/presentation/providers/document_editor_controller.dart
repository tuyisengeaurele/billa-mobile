import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/action_errors.dart';
import '../../domain/document.dart';
import '../../domain/document_draft_input.dart';
import '../../domain/document_enums.dart';
import '../../domain/document_totals.dart';
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

  bool get isSavable =>
      customerId != null && (!referencedDocumentRequired || referencedDocument != null) && _linesValid;

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
      lines: lines ?? this.lines,
      autosaveStatus: autosaveStatus ?? this.autosaveStatus,
      autosaveError: identical(autosaveError, _unset) ? this.autosaveError : autosaveError as String?,
    );
  }
}

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

  void setIssueDate(DateTime date) => _update((s) => s.copyWith(issueDate: date));
  void setDueDate(DateTime? date) => _update((s) => s.copyWith(dueDate: date));
  void setNotes(String value) => _update((s) => s.copyWith(notes: value));
  void setCustomerReference(String value) => _update((s) => s.copyWith(customerReference: value));
  void setReferencedDocument(DocumentRef? reference) => _update((s) => s.copyWith(referencedDocument: reference));
  void setLanguage(DocumentLanguage language) => _update((s) => s.copyWith(language: language));

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

  void selectLineItem(
    int localId, {
    required String itemId,
    required String description,
    required int unitPrice,
    required double taxRate,
  }) =>
      _updateLine(
        localId,
        (line) => _cloneLine(line, itemId: itemId, description: description, unitPrice: unitPrice, taxRate: taxRate),
      );

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
