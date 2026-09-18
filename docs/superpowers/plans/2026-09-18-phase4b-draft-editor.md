# Phase 4b: Draft Create/Edit Editor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let a user create a new document (any of the six types) and edit
an existing draft, with autosave, live totals that match the backend
exactly, and pickers for customer/item/reference-document.

**Architecture:** New write-side domain models (`DocumentDraftInput`/
`DocumentLineInput`) mirror the backend's `documentSchema` exactly. A
`DocumentEditorController` (`AsyncNotifier`, `autoDispose.family` keyed by
create-type-or-edit-id) owns the draft and debounces autosave calls
through the existing `DocumentRepository`, now extended with
`create`/`update`. A reusable `SearchPickerSheet` backs the
customer/item/reference pickers. One `DocumentEditorScreen` serves both
create and edit.

**Tech Stack:** Flutter, `flutter_riverpod` 2.6.1 (plain `AsyncNotifier`/
`Provider`, no codegen), `go_router`, `dio`, `freezed`+`json_serializable`,
`mocktail` for tests.

**Spec:** `docs/superpowers/specs/2026-09-18-phase4b-draft-editor-design.md`

## Global Constraints

- Commits authored as `Ange Aurele TUYISENGE <tuyisengeauris@gmail.com>`; never a `Co-authored-by` trailer; never mention Claude/AI anywhere.
- Small, single-sentence, conventional-commit-style messages, one logical change per commit.
- Comments explain *why*, never *what*.
- No dead ends: every tap leads somewhere, every error has a retry, nothing silently fails.
- Every task ends with `flutter analyze` clean and `flutter test` passing.
- `type` is fixed once a document exists — never editable after creation.
- `recurrence` is out of scope entirely; the client never sends it.
- Finalize/PDF/send/conversion (proforma→invoice) are out of scope — 4c.

---

### Task 1: `DocumentLanguage` enum and write-side domain models

**Files:**
- Modify: `lib/features/documents/domain/document_enums.dart`
- Modify: `test/features/documents/domain/document_enums_test.dart`
- Create: `lib/features/documents/domain/document_draft_input.dart`
- Test: `test/features/documents/domain/document_draft_input_test.dart`

**Interfaces:**
- Consumes: `DocumentType`, `DiscountType` (already in `document_enums.dart`).
- Produces: `enum DocumentLanguage { en, fr }` + `documentLanguageFromJson`/`documentLanguageToJson`; `class DocumentLineInput`; `class DocumentDraftInput` with `.toJson()` matching the backend's `documentSchema` body shape exactly.

- [ ] **Step 1: Write the failing enum test**

Add to `test/features/documents/domain/document_enums_test.dart`:

```dart
  test('DocumentLanguage round-trips both values', () {
    expect(documentLanguageFromJson('EN'), DocumentLanguage.en);
    expect(documentLanguageFromJson('FR'), DocumentLanguage.fr);
    expect(documentLanguageToJson(DocumentLanguage.en), 'EN');
    expect(documentLanguageToJson(DocumentLanguage.fr), 'FR');
  });
```

- [ ] **Step 2: Run it to confirm it fails**

```bash
flutter test test/features/documents/domain/document_enums_test.dart
```

Expected: FAIL — `DocumentLanguage` doesn't exist yet.

- [ ] **Step 3: Add `DocumentLanguage` to `document_enums.dart`**

Append to `lib/features/documents/domain/document_enums.dart`:

```dart
enum DocumentLanguage { en, fr }

DocumentLanguage documentLanguageFromJson(String value) => switch (value) {
      'EN' => DocumentLanguage.en,
      'FR' => DocumentLanguage.fr,
      _ => throw ArgumentError('Unknown document language: $value'),
    };

String documentLanguageToJson(DocumentLanguage value) => switch (value) {
      DocumentLanguage.en => 'EN',
      DocumentLanguage.fr => 'FR',
    };
```

- [ ] **Step 4: Run it to confirm it passes**

```bash
flutter test test/features/documents/domain/document_enums_test.dart
```

Expected: PASS (6 tests total).

- [ ] **Step 5: Write the failing model test**

```dart
// test/features/documents/domain/document_draft_input_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/documents/domain/document_draft_input.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';

void main() {
  test('DocumentDraftInput.toJson matches the backend request shape', () {
    const input = DocumentDraftInput(
      type: DocumentType.invoice,
      customerId: 'c1',
      issueDate: '2026-08-19',
      lines: [
        DocumentLineInput(description: 'Printing', quantity: 2, unitPrice: 5000, taxRate: 18),
      ],
    );

    final json = input.toJson();

    expect(json['type'], 'INVOICE');
    expect(json['customerId'], 'c1');
    expect(json['issueDate'], '2026-08-19');
    expect(json['dueDate'], isNull);
    expect(json['language'], 'EN');
    expect(json['lines'], hasLength(1));
    expect(json['lines'][0]['description'], 'Printing');
    expect(json['lines'][0]['quantity'], 2);
    expect(json['lines'][0]['unitPrice'], 5000);
    expect(json['lines'][0]['taxRate'], 18);
  });

  test('DocumentLineInput.toJson carries an optional discount', () {
    const line = DocumentLineInput(
      description: 'Cement',
      quantity: 1,
      unitPrice: 10000,
      taxRate: 18,
      discountType: DiscountType.percent,
      discountValue: 10,
    );

    final json = line.toJson();

    expect(json['discountType'], 'PERCENT');
    expect(json['discountValue'], 10);
  });

  test('round-trips through fromJson', () {
    const input = DocumentDraftInput(
      type: DocumentType.creditNote,
      customerId: 'c1',
      issueDate: '2026-08-19',
      referencedDocumentId: 'inv1',
      language: DocumentLanguage.fr,
      lines: [],
    );

    final roundTripped = DocumentDraftInput.fromJson(input.toJson());

    expect(roundTripped, input);
  });
}
```

- [ ] **Step 6: Run it to confirm it fails**

```bash
flutter test test/features/documents/domain/document_draft_input_test.dart
```

Expected: FAIL — `document_draft_input.dart` doesn't exist yet.

- [ ] **Step 7: Implement `DocumentLineInput` and `DocumentDraftInput`**

```dart
// lib/features/documents/domain/document_draft_input.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'document_enums.dart';

part 'document_draft_input.freezed.dart';
part 'document_draft_input.g.dart';

@freezed
class DocumentLineInput with _$DocumentLineInput {
  const factory DocumentLineInput({
    String? itemId,
    required String description,
    required double quantity,
    required int unitPrice,
    required double taxRate,
    @JsonKey(fromJson: discountTypeFromJson, toJson: discountTypeToJson) DiscountType? discountType,
    double? discountValue,
  }) = _DocumentLineInput;

  factory DocumentLineInput.fromJson(Map<String, dynamic> json) => _$DocumentLineInputFromJson(json);
}

@freezed
class DocumentDraftInput with _$DocumentDraftInput {
  const factory DocumentDraftInput({
    @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson) required DocumentType type,
    required String customerId,
    required String issueDate,
    String? dueDate,
    String? notes,
    String? customerReference,
    String? referencedDocumentId,
    @JsonKey(fromJson: documentLanguageFromJson, toJson: documentLanguageToJson)
    @Default(DocumentLanguage.en)
    DocumentLanguage language,
    @Default(<DocumentLineInput>[]) List<DocumentLineInput> lines,
  }) = _DocumentDraftInput;

  factory DocumentDraftInput.fromJson(Map<String, dynamic> json) => _$DocumentDraftInputFromJson(json);
}
```

Note: unlike the read-side `Document`/`DocumentLine` (Phase 4a), `unitPrice`/`quantity`/`taxRate`/`discountValue` here have **no** decimal-string `@JsonKey` converter — the backend's `documentSchema` accepts these as plain JSON numbers in the request body (confirmed against the backend's `documents.create.test.ts`, which posts `unitPrice: 5000` as a number), unlike the decimal-string convention Prisma's `Decimal` fields use in *responses*.

- [ ] **Step 8: Run `build_runner` and confirm the test passes**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/documents/domain/document_draft_input_test.dart
```

Expected: PASS (3 tests).

- [ ] **Step 9: Analyze and commit**

```bash
flutter analyze
git add lib/features/documents/domain/ test/features/documents/domain/
git commit -m "feat: add document language enum and draft input models"
```

---

### Task 2: Port the backend's totals calculation

**Files:**
- Create: `lib/features/documents/domain/document_totals.dart`
- Test: `test/features/documents/domain/document_totals_test.dart`

**Interfaces:**
- Consumes: `DocumentLineInput`, `DiscountType` (Task 1).
- Produces: `class LineTotals { lineTotal, taxAmount, discountAmount }`, `class DocumentTotals { lines, subtotal, taxTotal, total }`, `DocumentTotals calculateDocumentTotals(List<DocumentLineInput> lines)`.

This is a line-for-line port of the backend's `server/src/lib/document-totals.ts`, tested against the same fixtures as its own `document-totals.test.ts`, so the on-screen total during editing always matches what the server will persist.

- [ ] **Step 1: Write the failing tests**

```dart
// test/features/documents/domain/document_totals_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/documents/domain/document_draft_input.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/domain/document_totals.dart';

DocumentLineInput _line({
  double quantity = 1,
  required int unitPrice,
  required double taxRate,
  DiscountType? discountType,
  double? discountValue,
}) =>
    DocumentLineInput(
      description: 'Line',
      quantity: quantity,
      unitPrice: unitPrice,
      taxRate: taxRate,
      discountType: discountType,
      discountValue: discountValue,
    );

void main() {
  test('computes line totals, subtotal, tax, and total', () {
    final result = calculateDocumentTotals([
      _line(quantity: 2, unitPrice: 5000, taxRate: 18),
      _line(quantity: 1, unitPrice: 1000, taxRate: 0),
    ]);

    expect(result.lines[0], const LineTotals(lineTotal: 10000, taxAmount: 1800, discountAmount: 0));
    expect(result.lines[1], const LineTotals(lineTotal: 1000, taxAmount: 0, discountAmount: 0));
    expect(result.subtotal, 11000);
    expect(result.taxTotal, 1800);
    expect(result.total, 12800);
  });

  test('returns zeros for an empty line list', () {
    final result = calculateDocumentTotals([]);
    expect(result.lines, isEmpty);
    expect(result.subtotal, 0);
    expect(result.taxTotal, 0);
    expect(result.total, 0);
  });

  test('rounds fractional quantities to the nearest RWF', () {
    final result = calculateDocumentTotals([_line(quantity: 2.5, unitPrice: 1000, taxRate: 10)]);
    expect(result.lines[0].lineTotal, 2500);
    expect(result.lines[0].taxAmount, 250);
  });

  test('applies a percentage discount before computing tax', () {
    final result = calculateDocumentTotals([
      _line(unitPrice: 10000, taxRate: 18, discountType: DiscountType.percent, discountValue: 10),
    ]);

    expect(result.lines[0], const LineTotals(lineTotal: 9000, taxAmount: 1620, discountAmount: 1000));
    expect(result.subtotal, 9000);
    expect(result.total, 10620);
  });

  test('applies a flat discount before computing tax', () {
    final result = calculateDocumentTotals([
      _line(unitPrice: 10000, taxRate: 18, discountType: DiscountType.flat, discountValue: 2000),
    ]);

    expect(result.lines[0], const LineTotals(lineTotal: 8000, taxAmount: 1440, discountAmount: 2000));
  });

  test('clamps a discount so a line can never go negative', () {
    final result = calculateDocumentTotals([
      _line(unitPrice: 5000, taxRate: 18, discountType: DiscountType.flat, discountValue: 9000),
    ]);

    expect(result.lines[0], const LineTotals(lineTotal: 0, taxAmount: 0, discountAmount: 5000));
  });

  test('treats a missing discountType as no discount', () {
    final result = calculateDocumentTotals([_line(unitPrice: 5000, taxRate: 18)]);
    expect(result.lines[0].discountAmount, 0);
  });
}
```

- [ ] **Step 2: Run it to confirm it fails**

```bash
flutter test test/features/documents/domain/document_totals_test.dart
```

Expected: FAIL — `document_totals.dart` doesn't exist yet.

- [ ] **Step 3: Implement `calculateDocumentTotals`**

```dart
// lib/features/documents/domain/document_totals.dart
import 'document_draft_input.dart';
import 'document_enums.dart';

class LineTotals {
  const LineTotals({required this.lineTotal, required this.taxAmount, required this.discountAmount});

  final int lineTotal;
  final int taxAmount;
  final int discountAmount;

  @override
  bool operator ==(Object other) =>
      other is LineTotals &&
      other.lineTotal == lineTotal &&
      other.taxAmount == taxAmount &&
      other.discountAmount == discountAmount;

  @override
  int get hashCode => Object.hash(lineTotal, taxAmount, discountAmount);
}

class DocumentTotals {
  const DocumentTotals({required this.lines, required this.subtotal, required this.taxTotal, required this.total});

  final List<LineTotals> lines;
  final int subtotal;
  final int taxTotal;
  final int total;
}

DocumentTotals calculateDocumentTotals(List<DocumentLineInput> lines) {
  final computed = lines.map((line) {
    final rawLineTotal = (line.quantity * line.unitPrice).round();
    final rawDiscount = switch (line.discountType) {
      DiscountType.percent => (rawLineTotal * ((line.discountValue ?? 0) / 100)).round(),
      DiscountType.flat => (line.discountValue ?? 0).round(),
      null => 0,
    };
    final discountAmount = rawDiscount.clamp(0, rawLineTotal);
    final lineTotal = rawLineTotal - discountAmount;
    final taxAmount = (lineTotal * (line.taxRate / 100)).round();
    return LineTotals(lineTotal: lineTotal, taxAmount: taxAmount, discountAmount: discountAmount);
  }).toList();

  final subtotal = computed.fold(0, (sum, line) => sum + line.lineTotal);
  final taxTotal = computed.fold(0, (sum, line) => sum + line.taxAmount);
  return DocumentTotals(lines: computed, subtotal: subtotal, taxTotal: taxTotal, total: subtotal + taxTotal);
}
```

- [ ] **Step 4: Run it to confirm it passes**

```bash
flutter test test/features/documents/domain/document_totals_test.dart
```

Expected: PASS (7 tests).

- [ ] **Step 5: Analyze and commit**

```bash
flutter analyze
git add lib/features/documents/domain/document_totals.dart test/features/documents/domain/document_totals_test.dart
git commit -m "feat: port the backend's document totals calculation"
```

---

### Task 3: Repository `create`/`update` and a `customerId` list filter

**Files:**
- Modify: `lib/features/documents/domain/document_repository.dart`
- Modify: `lib/features/documents/data/document_repository_impl.dart`
- Modify: `test/features/documents/data/document_repository_impl_test.dart`

**Interfaces:**
- Consumes: `DocumentDraftInput` (Task 1), `Document` (Phase 4a).
- Produces: `DocumentRepository.create(DocumentDraftInput)`, `DocumentRepository.update(String id, DocumentDraftInput)`, `DocumentRepository.list(..., customerId: String?)`.

- [ ] **Step 1: Write the failing tests**

Add to `test/features/documents/data/document_repository_impl_test.dart` (alongside the existing three tests, reusing its `_documentJson()` helper):

```dart
  test('list includes a customerId filter when provided', () async {
    final options = RequestOptions(path: '/documents');
    when(() => dio.get<Map<String, dynamic>>('/documents', queryParameters: {
          'customerId': 'c1',
          'page': 1,
          'pageSize': 20,
        })).thenAnswer((_) async => _response(200, {'results': [], 'total': 0, 'page': 1, 'pageSize': 20}, options));

    final result = await repository.list(customerId: 'c1');

    expect(result.results, isEmpty);
  });

  test('create posts the draft and returns the created document', () async {
    final options = RequestOptions(path: '/documents');
    const input = DocumentDraftInput(
      type: DocumentType.invoice,
      customerId: 'c1',
      issueDate: '2026-08-19',
      lines: [],
    );
    when(() => dio.post<Map<String, dynamic>>('/documents', data: input.toJson())).thenAnswer(
      (_) async => _response(201, {'document': _documentJson()}, options),
    );

    final document = await repository.create(input);

    expect(document.id, 'd1');
  });

  test('update patches the draft and returns the updated document', () async {
    final options = RequestOptions(path: '/documents/d1');
    const input = DocumentDraftInput(
      type: DocumentType.invoice,
      customerId: 'c1',
      issueDate: '2026-08-20',
      lines: [],
    );
    when(() => dio.patch<Map<String, dynamic>>('/documents/d1', data: input.toJson())).thenAnswer(
      (_) async => _response(200, {'document': _documentJson()}, options),
    );

    final document = await repository.update('d1', input);

    expect(document.id, 'd1');
  });
```

Add the new import at the top of the test file:

```dart
import 'package:billa_mobile/features/documents/domain/document_draft_input.dart';
```

- [ ] **Step 2: Run it to confirm it fails**

```bash
flutter test test/features/documents/data/document_repository_impl_test.dart
```

Expected: FAIL — `create`/`update` don't exist on `DocumentRepository`/`DocumentRepositoryImpl` yet, and `list` doesn't accept `customerId`.

- [ ] **Step 3: Add the methods to the abstract repository**

```dart
// lib/features/documents/domain/document_repository.dart
import '../../../core/pagination/paginated_result.dart';
import 'document.dart';
import 'document_draft_input.dart';
import 'document_enums.dart';

abstract class DocumentRepository {
  Future<PaginatedResult<Document>> list({
    List<DocumentType>? types,
    DocumentStatus? status,
    String? search,
    String? customerId,
    int page = 1,
    int pageSize = 20,
  });

  Future<Document> get(String id);
  Future<Document> create(DocumentDraftInput input);
  Future<Document> update(String id, DocumentDraftInput input);
}
```

- [ ] **Step 4: Implement them**

```dart
// lib/features/documents/data/document_repository_impl.dart
import 'package:dio/dio.dart';
import '../../../core/pagination/paginated_result.dart';
import '../domain/document.dart';
import '../domain/document_draft_input.dart';
import '../domain/document_enums.dart';
import '../domain/document_repository.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  DocumentRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<PaginatedResult<Document>> list({
    List<DocumentType>? types,
    DocumentStatus? status,
    String? search,
    String? customerId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>('/documents', queryParameters: {
      if (types != null && types.isNotEmpty) 'type': types.map(documentTypeToJson).join(','),
      if (status != null) 'status': documentStatusToJson(status),
      if (search != null && search.isNotEmpty) 'search': search,
      if (customerId != null) 'customerId': customerId,
      'page': page,
      'pageSize': pageSize,
    });
    final data = response.data!;
    final results = (data['results'] as List)
        .map((json) => Document.fromJson(json as Map<String, dynamic>))
        .toList();
    return PaginatedResult(
      results: results,
      total: data['total'] as int,
      page: data['page'] as int,
      pageSize: data['pageSize'] as int,
    );
  }

  @override
  Future<Document> get(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/documents/$id');
    return Document.fromJson(response.data!['document'] as Map<String, dynamic>);
  }

  @override
  Future<Document> create(DocumentDraftInput input) async {
    final response = await _dio.post<Map<String, dynamic>>('/documents', data: input.toJson());
    return Document.fromJson(response.data!['document'] as Map<String, dynamic>);
  }

  @override
  Future<Document> update(String id, DocumentDraftInput input) async {
    final response = await _dio.patch<Map<String, dynamic>>('/documents/$id', data: input.toJson());
    return Document.fromJson(response.data!['document'] as Map<String, dynamic>);
  }
}
```

- [ ] **Step 5: Run it to confirm it passes**

```bash
flutter test test/features/documents/data/document_repository_impl_test.dart
```

Expected: PASS (6 tests).

- [ ] **Step 6: Analyze and commit**

```bash
flutter analyze
git add lib/features/documents/domain/document_repository.dart lib/features/documents/data/document_repository_impl.dart test/features/documents/data/document_repository_impl_test.dart
git commit -m "feat: add document create/update and a customerId list filter"
```

---

### Task 4: `DocumentEditorController`

**Files:**
- Create: `lib/features/documents/presentation/providers/document_editor_controller.dart`
- Test: `test/features/documents/presentation/providers/document_editor_controller_test.dart`

**Interfaces:**
- Consumes: `documentRepositoryProvider` (Phase 4a), `DocumentDraftInput`/`DocumentLineInput` (Task 1), `calculateDocumentTotals` (Task 2), `Document`/`DocumentRef` (Phase 4a).
- Produces: `class DocumentEditorArgs` (`.create(type)` / `.edit(documentId)`), `enum AutosaveStatus`, `class DocumentLineDraft`, `class DocumentEditorState`, `class DocumentEditorController`, `documentEditorControllerProvider`.

This is the state machine the rest of 4b is built on: it owns the draft,
recomputes live totals on every change, and debounces autosave the same
way the web app does — while guaranteeing a slow save in flight can never
be raced into a duplicate `create()`.

- [ ] **Step 1: Write the failing tests**

```dart
// test/features/documents/presentation/providers/document_editor_controller_test.dart
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
    container.listen(documentEditorControllerProvider(arg), (_, __) {});
    await container.read(documentEditorControllerProvider(arg).future);

    await Future<void>.delayed(const Duration(milliseconds: 900));

    verifyNever(() => repository.create(any()));
  });

  test('debounced autosave creates then updates the draft', () async {
    when(() => repository.create(any())).thenAnswer((_) async => _document());
    when(() => repository.update('d1', any())).thenAnswer((_) async => _document());

    const arg = DocumentEditorArgs.create(DocumentType.invoice);
    container.listen(documentEditorControllerProvider(arg), (_, __) {});
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
    container.listen(documentEditorControllerProvider(arg), (_, __) {});
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
    container.listen(documentEditorControllerProvider(arg), (_, __) {});
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
    container.listen(documentEditorControllerProvider(arg), (_, __) {});
    await container.read(documentEditorControllerProvider(arg).future);
    final notifier = container.read(documentEditorControllerProvider(arg).notifier);

    notifier.setCustomer('c1', 'Acme');
    notifier.addLine();
    await Future<void>.delayed(const Duration(milliseconds: 900));

    verifyNever(() => repository.create(any()));
  });
}
```

- [ ] **Step 2: Run it to confirm it fails**

```bash
flutter test test/features/documents/presentation/providers/document_editor_controller_test.dart
```

Expected: FAIL — `document_editor_controller.dart` doesn't exist yet.

- [ ] **Step 3: Implement `DocumentEditorController` and its state**

```dart
// lib/features/documents/presentation/providers/document_editor_controller.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  // Riverpod's family caches providers by this value's equality — without
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
  // a payload it would reject with 400 — validation and save-readiness are
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
  // item — the same behavior the production web editor's ItemPicker uses.
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

    // A save already in flight is never raced — a debounce firing mid-save
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
    } catch (_) {
      final latest = state.value;
      if (latest != null) {
        state = AsyncData(latest.copyWith(autosaveStatus: AutosaveStatus.error, autosaveError: "Couldn't save"));
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
```

- [ ] **Step 4: Run it to confirm it passes**

```bash
flutter test test/features/documents/presentation/providers/document_editor_controller_test.dart
```

Expected: PASS (6 tests).

- [ ] **Step 5: Analyze and commit**

```bash
flutter analyze
git add lib/features/documents/presentation/providers/document_editor_controller.dart test/features/documents/presentation/providers/document_editor_controller_test.dart
git commit -m "feat: add document editor controller with debounced autosave"
```

---

### Task 5: `SearchPickerSheet`

**Files:**
- Create: `lib/core/widgets/search_picker_sheet.dart`
- Test: `test/core/widgets/search_picker_sheet_test.dart`

**Interfaces:**
- Produces: `Future<T?> showSearchPickerSheet<T>({required BuildContext context, required String title, required Future<List<T>> Function(String search) fetch, required Widget Function(T item) itemBuilder})`.

One reusable modal bottom sheet backs the customer/item/reference pickers
in Task 6 — search field on top, a debounced async list below,
tap-to-select pops the sheet with the chosen value.

- [ ] **Step 1: Write the failing tests**

```dart
// test/core/widgets/search_picker_sheet_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/widgets/search_picker_sheet.dart';

void main() {
  testWidgets('shows fetched results and returns the tapped item', (tester) async {
    String? selected;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            selected = await showSearchPickerSheet<String>(
              context: context,
              title: 'Pick one',
              fetch: (search) async =>
                  ['Acme', 'Beta'].where((s) => s.toLowerCase().contains(search.toLowerCase())).toList(),
              itemBuilder: (item) => ListTile(title: Text(item)),
            );
          },
          child: const Text('Open'),
        ),
      ),
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Acme'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);

    await tester.tap(find.text('Acme'));
    await tester.pumpAndSettle();

    expect(selected, 'Acme');
  });

  testWidgets('debounces search input to a single fetch per pause', (tester) async {
    var fetchCount = 0;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => showSearchPickerSheet<String>(
            context: context,
            title: 'Pick one',
            fetch: (search) async {
              fetchCount++;
              return ['Acme'];
            },
            itemBuilder: (item) => ListTile(title: Text(item)),
          ),
          child: const Text('Open'),
        ),
      ),
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(fetchCount, 1);

    await tester.enterText(find.byKey(const Key('search-picker-field')), 'ac');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(fetchCount, 2);
  });
}
```

- [ ] **Step 2: Run it to confirm it fails**

```bash
flutter test test/core/widgets/search_picker_sheet_test.dart
```

Expected: FAIL — `search_picker_sheet.dart` doesn't exist yet.

- [ ] **Step 3: Implement `SearchPickerSheet`**

```dart
// lib/core/widgets/search_picker_sheet.dart
import 'dart:async';
import 'package:flutter/material.dart';

Future<T?> showSearchPickerSheet<T>({
  required BuildContext context,
  required String title,
  required Future<List<T>> Function(String search) fetch,
  required Widget Function(T item) itemBuilder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _SearchPickerSheet<T>(title: title, fetch: fetch, itemBuilder: itemBuilder),
  );
}

class _SearchPickerSheet<T> extends StatefulWidget {
  const _SearchPickerSheet({required this.title, required this.fetch, required this.itemBuilder});

  final String title;
  final Future<List<T>> Function(String search) fetch;
  final Widget Function(T item) itemBuilder;

  @override
  State<_SearchPickerSheet<T>> createState() => _SearchPickerSheetState<T>();
}

class _SearchPickerSheetState<T> extends State<_SearchPickerSheet<T>> {
  static const _debounce = Duration(milliseconds: 300);
  Timer? _debounceTimer;
  late Future<List<T>> _results = widget.fetch('');

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounce, () {
      if (mounted) {
        setState(() {
          _results = widget.fetch(value);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.75,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  key: const Key('search-picker-field'),
                  decoration: const InputDecoration(hintText: 'Search', prefixIcon: Icon(Icons.search)),
                  onChanged: _onSearchChanged,
                ),
              ),
              Expanded(
                child: FutureBuilder<List<T>>(
                  future: _results,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final items = snapshot.data!;
                    if (items.isEmpty) return const Center(child: Text('No results'));
                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return InkWell(
                          onTap: () => Navigator.of(context).pop(item),
                          child: widget.itemBuilder(item),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run it to confirm it passes**

```bash
flutter test test/core/widgets/search_picker_sheet_test.dart
```

Expected: PASS (2 tests).

- [ ] **Step 5: Analyze and commit**

```bash
flutter analyze
git add lib/core/widgets/search_picker_sheet.dart test/core/widgets/search_picker_sheet_test.dart
git commit -m "feat: add reusable search picker sheet"
```

---

### Task 6: `DocumentEditorScreen`

**Files:**
- Create: `lib/features/documents/presentation/screens/document_editor_screen.dart`
- Test: `test/features/documents/presentation/screens/document_editor_screen_test.dart`

**Interfaces:**
- Consumes: `documentEditorControllerProvider`/`DocumentEditorArgs`/`AutosaveStatus` (Task 4), `showSearchPickerSheet` (Task 5), `customerRepositoryProvider` (Phase 3), `itemRepositoryProvider` (Phase 3), `documentRepositoryProvider` (Phase 4a), `documentTypeLabel` (Phase 4a), `ErrorState`/`LoadingSkeleton`/`MoneyText` (Phase 1).
- Produces: `class DocumentEditorScreen extends ConsumerStatefulWidget` with `.create({required DocumentType type})` and `.edit({required String documentId})` constructors.

- [ ] **Step 1: Write the failing tests**

```dart
// test/features/documents/presentation/screens/document_editor_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/pagination/paginated_result.dart';
import 'package:billa_mobile/features/customers/domain/customer.dart';
import 'package:billa_mobile/features/customers/domain/customer_repository.dart';
import 'package:billa_mobile/features/customers/presentation/providers/customer_repository_provider.dart';
import 'package:billa_mobile/features/documents/domain/document.dart';
import 'package:billa_mobile/features/documents/domain/document_draft_input.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/domain/document_repository.dart';
import 'package:billa_mobile/features/documents/presentation/providers/document_repository_provider.dart';
import 'package:billa_mobile/features/documents/presentation/screens/document_editor_screen.dart';
import 'package:billa_mobile/features/items/domain/item.dart';
import 'package:billa_mobile/features/items/domain/item_repository.dart';
import 'package:billa_mobile/features/items/presentation/providers/item_repository_provider.dart';

class _MockDocumentRepository extends Mock implements DocumentRepository {}
class _MockCustomerRepository extends Mock implements CustomerRepository {}
class _MockItemRepository extends Mock implements ItemRepository {}
class _FakeDocumentDraftInput extends Fake implements DocumentDraftInput {}

const _customer = Customer(id: 'c1', name: 'Acme', isActive: true, createdAt: '2026-01-01T00:00:00.000Z');
const _item = Item(id: 'i1', description: 'Printing', unitPrice: 5000, unit: 'unit', taxRate: 18, isActive: true);
const _documentCustomer = DocumentCustomerRef(name: 'Acme');
Document _savedDocument() => Document(
      id: 'd1',
      type: DocumentType.invoice,
      status: DocumentStatus.draft,
      customerId: 'c1',
      customer: _documentCustomer,
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

  late _MockDocumentRepository documentRepository;
  late _MockCustomerRepository customerRepository;
  late _MockItemRepository itemRepository;

  setUp(() {
    documentRepository = _MockDocumentRepository();
    customerRepository = _MockCustomerRepository();
    itemRepository = _MockItemRepository();
    when(() => customerRepository.list(search: any(named: 'search'))).thenAnswer(
      (_) async => const PaginatedResult(results: [_customer], total: 1, page: 1, pageSize: 20),
    );
    when(() => itemRepository.list(search: any(named: 'search'))).thenAnswer(
      (_) async => const PaginatedResult(results: [_item], total: 1, page: 1, pageSize: 20),
    );
  });

  Widget buildApp(Widget screen) {
    return ProviderScope(
      overrides: [
        documentRepositoryProvider.overrideWithValue(documentRepository),
        customerRepositoryProvider.overrideWithValue(customerRepository),
        itemRepositoryProvider.overrideWithValue(itemRepository),
      ],
      child: MaterialApp(theme: AppTheme.light, home: screen),
    );
  }

  testWidgets('picking a customer triggers an autosave', (tester) async {
    when(() => documentRepository.create(any())).thenAnswer((_) async => _savedDocument());

    await tester.pumpWidget(buildApp(DocumentEditorScreen.create(type: DocumentType.invoice)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Choose a customer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Acme'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    verify(() => documentRepository.create(any())).called(1);
  });

  testWidgets('picking an item fills the line description, price, and tax', (tester) async {
    await tester.pumpWidget(buildApp(DocumentEditorScreen.create(type: DocumentType.invoice)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add line'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Choose an item'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Printing'));
    await tester.pumpAndSettle();

    expect(find.text('Printing'), findsWidgets);
  });

  testWidgets('a credit note cannot autosave without a chosen reference invoice', (tester) async {
    await tester.pumpWidget(buildApp(DocumentEditorScreen.create(type: DocumentType.creditNote)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Choose a customer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Acme'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    verifyNever(() => documentRepository.create(any()));
  });
}
```

- [ ] **Step 2: Run it to confirm it fails**

```bash
flutter test test/features/documents/presentation/screens/document_editor_screen_test.dart
```

Expected: FAIL — `document_editor_screen.dart` doesn't exist yet.

- [ ] **Step 3: Implement `DocumentEditorScreen`**

```dart
// lib/features/documents/presentation/screens/document_editor_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../../core/widgets/search_picker_sheet.dart';
import '../../../customers/presentation/providers/customer_repository_provider.dart';
import '../../../items/presentation/providers/item_repository_provider.dart';
import '../../domain/document.dart';
import '../../domain/document_enums.dart';
import '../../domain/document_totals.dart';
import '../providers/document_editor_controller.dart';
import '../providers/document_repository_provider.dart';
import '../widgets/document_list_tile.dart' show documentTypeLabel;

String _formatDisplayDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

class DocumentEditorScreen extends ConsumerStatefulWidget {
  // Not const: the initializer calls DocumentEditorArgs.create(type), and a
  // const constructor can't invoke another const constructor with one of
  // its own formal parameters as the argument.
  DocumentEditorScreen.create({super.key, required DocumentType type}) : args = DocumentEditorArgs.create(type);
  DocumentEditorScreen.edit({super.key, required String documentId}) : args = DocumentEditorArgs.edit(documentId);

  final DocumentEditorArgs args;

  @override
  ConsumerState<DocumentEditorScreen> createState() => _DocumentEditorScreenState();
}

class _DocumentEditorScreenState extends ConsumerState<DocumentEditorScreen> {
  bool _popping = false;

  Future<void> _handlePop(bool didPop) async {
    if (didPop || _popping) return;
    _popping = true;
    await ref.read(documentEditorControllerProvider(widget.args).notifier).flushPendingSave();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(documentEditorControllerProvider(widget.args));
    final type = widget.args.type ?? async.value?.type;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => _handlePop(didPop),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.args.documentId == null
              ? 'New ${type != null ? documentTypeLabel(type) : ''}'
              : 'Edit document'),
          actions: [
            if (async.value != null) _AutosaveIndicator(state: async.value!, args: widget.args),
          ],
        ),
        body: switch (async) {
          AsyncData(value: final state) => _DocumentEditorForm(args: widget.args, state: state),
          AsyncError() => ErrorState(
              message: "Couldn't load this document",
              onRetry: () => ref.invalidate(documentEditorControllerProvider(widget.args)),
            ),
          _ => const Padding(
              padding: EdgeInsets.all(16),
              child: Column(children: [LoadingSkeleton(height: 24), SizedBox(height: 12), LoadingSkeleton(height: 200)]),
            ),
        },
      ),
    );
  }
}

class _AutosaveIndicator extends ConsumerWidget {
  const _AutosaveIndicator({required this.state, required this.args});

  final DocumentEditorState state;
  final DocumentEditorArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (state.autosaveStatus) {
      AutosaveStatus.idle => const SizedBox.shrink(),
      AutosaveStatus.saving => const Padding(
          padding: EdgeInsets.only(right: 16),
          child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
        ),
      AutosaveStatus.saved => const Padding(
          padding: EdgeInsets.only(right: 16),
          child: Center(child: Icon(Icons.check, size: 20)),
        ),
      AutosaveStatus.error => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: TextButton(
            onPressed: () => ref.read(documentEditorControllerProvider(args).notifier).retrySave(),
            child: const Text('Retry'),
          ),
        ),
    };
  }
}

class _DocumentEditorForm extends ConsumerWidget {
  const _DocumentEditorForm({required this.args, required this.state});

  final DocumentEditorArgs args;
  final DocumentEditorState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(documentEditorControllerProvider(args).notifier);
    final totals = state.totals;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(state.customerName ?? 'Choose a customer'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final customer = await showSearchPickerSheet(
                context: context,
                title: 'Choose a customer',
                fetch: (search) async =>
                    (await ref.read(customerRepositoryProvider).list(search: search)).results,
                itemBuilder: (customer) => ListTile(title: Text(customer.name)),
              );
              if (customer != null) controller.setCustomer(customer.id, customer.name);
            },
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Issued ${_formatDisplayDate(state.issueDate)}'),
            trailing: const Icon(Icons.calendar_today, size: 20),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: state.issueDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) controller.setIssueDate(picked);
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(state.dueDate == null ? 'Add a due date' : 'Due ${_formatDisplayDate(state.dueDate!)}'),
            trailing: state.dueDate == null
                ? const Icon(Icons.calendar_today, size: 20)
                : IconButton(icon: const Icon(Icons.close), onPressed: () => controller.setDueDate(null)),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: state.dueDate ?? state.issueDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) controller.setDueDate(picked);
            },
          ),
          if (state.referencedDocumentAllowed) ...[
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              enabled: state.customerId != null,
              title: Text(state.referencedDocument?.number ?? 'Choose the invoice this document is for'),
              trailing: const Icon(Icons.chevron_right),
              onTap: state.customerId == null
                  ? null
                  : () async {
                      final reference = await showSearchPickerSheet(
                        context: context,
                        title: 'Choose the invoice this document is for',
                        fetch: (search) async => (await ref.read(documentRepositoryProvider).list(
                              types: [DocumentType.invoice],
                              status: DocumentStatus.finalized,
                              customerId: state.customerId,
                              search: search,
                            ))
                                .results,
                        itemBuilder: (document) => ListTile(title: Text(document.number ?? document.id)),
                      );
                      if (reference != null) {
                        controller.setReferencedDocument(
                          DocumentRef(id: reference.id, number: reference.number, type: reference.type),
                        );
                      }
                    },
            ),
          ],
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('document-editor-customer-reference'),
            initialValue: state.customerReference,
            decoration: const InputDecoration(labelText: 'Customer reference (optional)'),
            onChanged: controller.setCustomerReference,
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const Key('document-editor-notes'),
            initialValue: state.notes,
            decoration: const InputDecoration(labelText: 'Notes (optional)'),
            maxLines: 3,
            onChanged: controller.setNotes,
          ),
          const SizedBox(height: 12),
          SegmentedButton<DocumentLanguage>(
            segments: const [
              ButtonSegment(value: DocumentLanguage.en, label: Text('EN')),
              ButtonSegment(value: DocumentLanguage.fr, label: Text('FR')),
            ],
            selected: {state.language},
            onSelectionChanged: (selection) => controller.setLanguage(selection.first),
          ),
          const SizedBox(height: 16),
          Text('Line items', style: Theme.of(context).textTheme.titleMedium),
          for (var i = 0; i < state.lines.length; i++)
            // calculateDocumentTotals preserves list order, so index i's
            // LineTotals always matches index i's line — computed once here
            // rather than re-derived per card, so a card's total can never
            // drift from what the footer's subtotal actually sums.
            _LineCard(args: args, line: state.lines[i], lineTotal: totals.lines[i]),
          TextButton(onPressed: controller.addLine, child: const Text('Add line')),
          const Divider(height: 32),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Subtotal'), MoneyText(totals.subtotal)]),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Tax'), MoneyText(totals.taxTotal)]),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: Theme.of(context).textTheme.titleMedium),
              MoneyText(totals.total, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ],
      ),
    );
  }
}

// A line's description/unit price/tax rate can change from OUTSIDE this
// widget's own typing (picking an item overwrites all three at once), so
// plain `TextFormField(initialValue: ...)` isn't enough — Flutter only
// applies `initialValue` on first build, not on later rebuilds carrying a
// new value in from the controller. This owns real TextEditingControllers
// and re-syncs them in didUpdateWidget whenever the incoming value differs
// from what's currently displayed.
class _LineCard extends ConsumerStatefulWidget {
  const _LineCard({required this.args, required this.line, required this.lineTotal});

  final DocumentEditorArgs args;
  final DocumentLineDraft line;
  final LineTotals lineTotal;

  @override
  ConsumerState<_LineCard> createState() => _LineCardState();
}

class _LineCardState extends ConsumerState<_LineCard> {
  late final _descriptionController = TextEditingController(text: widget.line.description);
  late final _quantityController = TextEditingController(text: widget.line.quantity.toString());
  late final _unitPriceController = TextEditingController(text: widget.line.unitPrice.toString());
  late final _taxRateController = TextEditingController(text: widget.line.taxRate.toString());
  late final _discountValueController = TextEditingController(text: (widget.line.discountValue ?? 0).toString());

  @override
  void didUpdateWidget(covariant _LineCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only reachable from picking an item, never from typing in these exact
    // fields, so this can't clobber text the user is mid-way through typing.
    if (widget.line.description != _descriptionController.text) {
      _descriptionController.text = widget.line.description;
    }
    if (widget.line.unitPrice.toString() != _unitPriceController.text) {
      _unitPriceController.text = widget.line.unitPrice.toString();
    }
    if (widget.line.taxRate.toString() != _taxRateController.text) {
      _taxRateController.text = widget.line.taxRate.toString();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _taxRateController.dispose();
    _discountValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(documentEditorControllerProvider(widget.args).notifier);
    final line = widget.line;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    key: ValueKey('line-description-${line.localId}'),
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      errorText: line.description.trim().isEmpty ? 'Enter a description' : null,
                    ),
                    // Typing here decouples the line from any linked item —
                    // matches the production web editor's ItemPicker.
                    onChanged: (value) => controller.setLineDescription(line.localId, value),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: 'Choose an item',
                  onPressed: () async {
                    final item = await showSearchPickerSheet(
                      context: context,
                      title: 'Choose an item',
                      fetch: (search) async => (await ref.read(itemRepositoryProvider).list(search: search)).results,
                      itemBuilder: (item) => ListTile(title: Text(item.description)),
                    );
                    if (item != null) {
                      controller.selectLineItem(
                        line.localId,
                        itemId: item.id,
                        description: item.description,
                        unitPrice: item.unitPrice,
                        taxRate: item.taxRate,
                      );
                    }
                  },
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => controller.removeLine(line.localId)),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: ValueKey('line-quantity-${line.localId}'),
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: 'Qty',
                      errorText: line.quantity > 0 ? null : 'Enter a quantity greater than zero',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final parsed = double.tryParse(value);
                      if (parsed != null) controller.setLineQuantity(line.localId, parsed);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    key: ValueKey('line-unit-price-${line.localId}'),
                    controller: _unitPriceController,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      errorText: line.unitPrice >= 0 ? null : "Price can't be negative",
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed != null) controller.setLineUnitPrice(line.localId, parsed);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    key: ValueKey('line-tax-rate-${line.localId}'),
                    controller: _taxRateController,
                    decoration: InputDecoration(
                      labelText: 'Tax %',
                      errorText: line.taxRate >= 0 && line.taxRate <= 100 ? null : 'Must be between 0 and 100',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final parsed = double.tryParse(value);
                      if (parsed != null) controller.setLineTaxRate(line.localId, parsed);
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                DropdownButton<DiscountType?>(
                  value: line.discountType,
                  hint: const Text('No discount'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('No discount')),
                    DropdownMenuItem(value: DiscountType.percent, child: Text('% off')),
                    DropdownMenuItem(value: DiscountType.flat, child: Text('RWF off')),
                  ],
                  onChanged: (type) =>
                      controller.setLineDiscount(line.localId, type, type == null ? null : (line.discountValue ?? 0)),
                ),
                if (line.discountType != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      key: ValueKey('line-discount-value-${line.localId}'),
                      controller: _discountValueController,
                      decoration: InputDecoration(
                        labelText: 'Discount',
                        errorText: (line.discountValue ?? 0) >= 0 &&
                                (line.discountType != DiscountType.percent || (line.discountValue ?? 0) <= 100)
                            ? null
                            : (line.discountType == DiscountType.percent ? "Can't exceed 100%" : "Can't be negative"),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final parsed = double.tryParse(value);
                        if (parsed != null) controller.setLineDiscount(line.localId, line.discountType, parsed);
                      },
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: MoneyText(widget.lineTotal.lineTotal),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run it to confirm it passes**

```bash
flutter test test/features/documents/presentation/screens/document_editor_screen_test.dart
```

Expected: PASS (3 tests).

- [ ] **Step 5: Analyze and commit**

```bash
flutter analyze
git add lib/features/documents/presentation/screens/document_editor_screen.dart test/features/documents/presentation/screens/document_editor_screen_test.dart
git commit -m "feat: add document editor screen"
```

---

### Task 7: Entry points — FAB, Edit button, router wiring

**Files:**
- Modify: `lib/features/documents/presentation/screens/document_list_screen.dart`
- Modify: `lib/features/documents/presentation/screens/document_detail_screen.dart`
- Modify: `lib/app/router.dart`
- Modify: `test/features/documents/presentation/screens/document_list_screen_test.dart`
- Modify: `test/features/documents/presentation/screens/document_detail_screen_test.dart`
- Modify: `test/app/router_test.dart`

**Interfaces:**
- Consumes: `DocumentEditorScreen` (Task 6), `documentTypeLabel` (Phase 4a).
- Produces: routes `/documents/new` (reads a `DocumentType` from `state.extra`) and `/documents/:id/edit`; a FAB on the list screen; a conditional Edit action on the detail screen.

- [ ] **Step 1: Write the failing list-screen test**

First add a `/documents/new` route to the existing `buildApp()` helper in
`test/features/documents/presentation/screens/document_list_screen_test.dart`
(this test file builds its own isolated router, separate from the app's
real one, so it needs the route too):

```dart
      GoRoute(
        path: '/documents/new',
        builder: (context, state) => Scaffold(body: Text('new document screen: ${state.extra}')),
      ),
```

placed before the existing `/documents/:id` route. Then add the test:

```dart
  testWidgets('the new-document FAB opens a type picker that navigates to the editor', (tester) async {
    when(() => repository.list(types: null, status: null, search: null, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: <Document>[], total: 0, page: 1, pageSize: 20),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Invoice').last); // the type-picker sheet's row, not the list screen's filter chip
    await tester.pumpAndSettle();

    expect(find.text('new document screen: DocumentType.invoice'), findsOneWidget);
  });
```

- [ ] **Step 2: Run it to confirm it fails**

```bash
flutter test test/features/documents/presentation/screens/document_list_screen_test.dart
```

Expected: FAIL — no FAB exists yet on `DocumentListScreen`.

- [ ] **Step 3: Add the FAB and type-picker sheet to `DocumentListScreen`**

Add this method to `_DocumentListScreenState` in `lib/features/documents/presentation/screens/document_list_screen.dart`:

```dart
  Future<void> _createDocument() async {
    final type = await showModalBottomSheet<DocumentType>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final type in DocumentType.values)
              ListTile(
                title: Text(documentTypeLabel(type)),
                onTap: () => Navigator.of(context).pop(type),
              ),
          ],
        ),
      ),
    );
    if (type != null && mounted) context.push('/documents/new', extra: type);
  }
```

Add `floatingActionButton: FloatingActionButton(onPressed: _createDocument, child: const Icon(Icons.add)),` to the `Scaffold` returned by `build()`, and add the `go_router` import (`import 'package:go_router/go_router.dart';`) if not already present — it already is, from the row `onTap`.

- [ ] **Step 4: Run it to confirm it passes**

```bash
flutter test test/features/documents/presentation/screens/document_list_screen_test.dart
```

Expected: PASS (4 tests).

- [ ] **Step 5: Write the failing detail-screen test**

Add to `test/features/documents/presentation/screens/document_detail_screen_test.dart` (its existing fixture `_document` has `status: DocumentStatus.finalized`; add a second fixture for this test):

```dart
  testWidgets('a draft document shows an Edit action that opens the editor', (tester) async {
    const draft = Document(
      id: 'd1',
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
    when(() => repository.get('d1')).thenAnswer((_) async => draft);
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => const DocumentDetailScreen(documentId: 'd1')),
      GoRoute(path: '/documents/:id/edit', builder: (context, state) => const Scaffold(body: Text('editor screen'))),
    ]);

    await tester.pumpWidget(ProviderScope(
      overrides: [documentRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    expect(find.text('editor screen'), findsOneWidget);
  });

  testWidgets('a finalized document shows no Edit action', (tester) async {
    when(() => repository.get('d1')).thenAnswer((_) async => _document);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.edit), findsNothing);
  });
```

- [ ] **Step 6: Run it to confirm it fails**

```bash
flutter test test/features/documents/presentation/screens/document_detail_screen_test.dart
```

Expected: FAIL — no Edit action exists yet.

- [ ] **Step 7: Add the conditional Edit action to `DocumentDetailScreen`**

In `lib/features/documents/presentation/screens/document_detail_screen.dart`, change the `AppBar` inside the `AsyncData`/`FutureBuilder`'s success branch (where `document` is in scope) to:

```dart
              appBar: AppBar(
                title: const Text('Document'),
                actions: [
                  if (document.status == DocumentStatus.draft)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => context.push('/documents/${document.id}/edit'),
                    ),
                ],
              ),
```

Wait — `DocumentDetailScreen`'s current `Scaffold`/`AppBar` is built once at the top of `build()`, before the `document` value is known (it's inside a `FutureBuilder` further down). Restructure so the `AppBar`'s actions are built from the same `FutureBuilder` snapshot: move the `Scaffold` itself inside the `FutureBuilder`'s `builder`, giving each branch (error/loading/data) its own `Scaffold` with an appropriate `AppBar` — the error and loading branches keep the current plain `AppBar(title: Text('Document'))`, and only the data branch adds the conditional Edit action. Add the `go_router` import for `context.push`.

- [ ] **Step 8: Run it to confirm it passes**

```bash
flutter test test/features/documents/presentation/screens/document_detail_screen_test.dart
```

Expected: PASS (4 tests).

- [ ] **Step 9: Wire the routes in `router.dart`**

Add imports:

```dart
import '../features/documents/domain/document_enums.dart';
import '../features/documents/presentation/screens/document_editor_screen.dart';
```

(`document_detail_screen.dart`/`document_list_screen.dart` are already imported.)

Add routes, placed before `/documents/:id` isn't required for correctness (go_router matches literal segments over parameters regardless of order) but keeps related routes visually grouped:

```dart
      GoRoute(
        path: '/documents/new',
        builder: (context, state) => DocumentEditorScreen.create(type: state.extra as DocumentType),
      ),
      GoRoute(
        path: '/documents/:id/edit',
        builder: (context, state) => DocumentEditorScreen.edit(documentId: state.pathParameters['id']!),
      ),
```

- [ ] **Step 10: Add an end-to-end router test through the real `appRouterProvider`**

Every isolated screen test above proves its own screen works, but none of
them prove the *real* app router (with its auth redirect logic) actually
reaches the new routes. Add to `test/app/router_test.dart`, alongside the
existing "home screen navigates to..." cases:

```dart
  testWidgets('the documents list FAB reaches the real document editor screen', (tester) async {
    final documentRepository = _MockDocumentRepository();
    when(() => documentRepository.list(types: null, status: null, search: null, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: [], total: 0, page: 1, pageSize: 20),
    );
    const business = Business(id: 'b1', name: 'Acme', onboardingCompletedAt: '2026-01-01T00:00:00.000Z');
    final container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(() => _FakeAuthController(const AuthStatus.authenticated(_user, business))),
      documentRepositoryProvider.overrideWithValue(documentRepository),
    ]);
    addTearDown(container.dispose);

    await _pumpRouter(tester, container);
    await tester.tap(find.byKey(const Key('home-nav-documents')));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Invoice').last);
    await tester.pumpAndSettle();

    expect(find.text('New Invoice'), findsOneWidget);
    expect(find.text('Choose a customer'), findsOneWidget);
  });
```

- [ ] **Step 11: Run the full suite**

```bash
flutter test
```

Expected: every test passes, including the router's now-seven cases.

- [ ] **Step 12: Analyze and commit**

```bash
flutter analyze
git add lib/features/documents/presentation/screens/document_list_screen.dart lib/features/documents/presentation/screens/document_detail_screen.dart lib/app/router.dart test/features/documents/presentation/screens/document_list_screen_test.dart test/features/documents/presentation/screens/document_detail_screen_test.dart test/app/router_test.dart
git commit -m "feat: wire the document editor into the list, detail, and router"
```

---

### Task 8: Final verification

**Files:** none created — this task only runs checks and fixes anything they surface.

- [ ] **Step 1: Static analysis**

```bash
flutter analyze
```

Expected: "No issues found!" — fix anything reported and re-run until clean.

- [ ] **Step 2: Full test suite**

```bash
flutter test
```

Expected: every test from Tasks 1–7 passes, plus all of Phases 1–4a's existing tests still pass unchanged.

- [ ] **Step 3: Android debug build**

```bash
flutter build apk --debug
```

Expected: builds successfully.

- [ ] **Step 4: Note the iOS build status**

Same as every prior phase: iOS build verification is deferred to macOS (this branch is built on Windows).

- [ ] **Step 5: Commit any fixes from Steps 1–2**

Only if something needed fixing:

```bash
git add -A
git commit -m "fix: resolve issues from phase 4b verification"
```

If nothing needed fixing, this step is a no-op.

---

## Definition of done for this plan

`flutter analyze` is clean, `flutter test` passes in full, `flutter build
apk --debug` succeeds, and a manual run shows: list screen → "+" → pick a
type → editor opens blank → pick a customer → autosave creates the draft
(status indicator shows Saving → Saved) → add a line, pick an item, watch
totals update live → back button flushes the last change and returns to
the list, where the new draft now appears → open it → Edit → the same
editor loads the saved draft and continues autosaving. A Receipt or
Credit Note additionally requires picking a reference invoice before
autosave will fire. No Finalize/PDF/send/convert action anywhere — that's
4c.
