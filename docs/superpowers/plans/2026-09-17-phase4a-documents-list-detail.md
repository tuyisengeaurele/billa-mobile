# Phase 4a Documents List and Detail Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A searchable, type/status-filterable document list and a read-only document detail view (line items, totals, conversion/reference links) — the read-only foundation the 4b editor and 4c finalize/PDF/email work build on next.

**Architecture:** One `Document` model shared by list and detail (list rows just lack the detail-only relations), a `DocumentRepository` behind `DocumentListController extends PaginatedListController<Document>` (Phase 3's generic base), and two screens following the exact list/detail pattern Phase 3 established for customers and items.

**Tech Stack:** `flutter_riverpod`, `freezed`/`json_serializable` with custom `@JsonKey` converters (for the Decimal-as-string fields and the hand-written enums), `go_router`, `mocktail`.

**Spec:** [docs/superpowers/specs/2026-09-17-phase4a-documents-list-detail-design.md](../specs/2026-09-17-phase4a-documents-list-detail-design.md)

## Global Constraints

- `DocumentLine.quantity`, `taxRate`, `discountValue` arrive as JSON **strings** (e.g. `"2.00"`) — parse to `double`, never treat as numbers directly. Everything else numeric (`unitPrice`, `lineTotal`, `sortOrder`, and all `Document`-level totals) is a plain JSON number.
- List rows and detail share one `Document` shape; `lines` defaults to `[]` and `convertedFrom`/`convertedTo`/`referencedDocument` default to `null` when those keys are simply absent (list rows), not an error.
- `referencingDocuments` does not exist on the wire — never add it to the model.
- No Edit/Finalize action anywhere in this phase — those don't exist until 4b/4c, and a button with nowhere to go is exactly what the project's non-negotiables forbid.
- Dates (`issueDate`, `dueDate`, `sentAt`, `createdAt`, `updatedAt`) are full ISO datetime strings — keep as raw `String` in the model, same as every other phase so far.
- Comments explain *why*, never *what*; no AI-narration comments; conventional-commit messages, no trailing period.
- Every task ends with `flutter analyze` clean and `flutter test` passing for files touched so far.

---

### Task 1: Document enums

**Files:**
- Create: `lib/features/documents/domain/document_enums.dart`
- Test: `test/features/documents/domain/document_enums_test.dart`

**Interfaces:**
- Produces: `enum DocumentType { invoice, proforma, deliveryNote, quote, receipt, creditNote }` + `documentTypeFromJson(String)`/`documentTypeToJson(DocumentType)`; `enum DocumentStatus { draft, finalized }` + `documentStatusFromJson(String)`/`documentStatusToJson(DocumentStatus)`; `enum PaymentStatus { unpaid, partiallyPaid, paid, writtenOff }` + `paymentStatusFromJson(String?)`/`paymentStatusToJson(PaymentStatus?)` (nullable); `enum DiscountType { percent, flat }` + `discountTypeFromJson(String?)`/`discountTypeToJson(DiscountType?)` (nullable). All four helper pairs are public (no leading underscore) — they're reused from `document.dart`'s `@JsonKey` annotations *and* directly from the repository when building query params, so they can't be file-private.

- [ ] **Step 1: Write the failing test**

```dart
// test/features/documents/domain/document_enums_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';

void main() {
  test('DocumentType round-trips every value', () {
    for (final type in DocumentType.values) {
      expect(documentTypeFromJson(documentTypeToJson(type)), type);
    }
    expect(documentTypeToJson(DocumentType.deliveryNote), 'DELIVERY_NOTE');
    expect(documentTypeToJson(DocumentType.creditNote), 'CREDIT_NOTE');
  });

  test('DocumentType.fromJson rejects an unknown value', () {
    expect(() => documentTypeFromJson('SOMETHING_ELSE'), throwsArgumentError);
  });

  test('DocumentStatus round-trips both values', () {
    expect(documentStatusFromJson('DRAFT'), DocumentStatus.draft);
    expect(documentStatusFromJson('FINALIZED'), DocumentStatus.finalized);
    expect(documentStatusToJson(DocumentStatus.draft), 'DRAFT');
  });

  test('PaymentStatus handles null and round-trips every value', () {
    expect(paymentStatusFromJson(null), isNull);
    expect(paymentStatusToJson(null), isNull);
    for (final status in PaymentStatus.values) {
      expect(paymentStatusFromJson(paymentStatusToJson(status)), status);
    }
    expect(paymentStatusToJson(PaymentStatus.partiallyPaid), 'PARTIALLY_PAID');
    expect(paymentStatusToJson(PaymentStatus.writtenOff), 'WRITTEN_OFF');
  });

  test('DiscountType handles null and round-trips every value', () {
    expect(discountTypeFromJson(null), isNull);
    expect(discountTypeToJson(null), isNull);
    expect(discountTypeFromJson('PERCENT'), DiscountType.percent);
    expect(discountTypeFromJson('FLAT'), DiscountType.flat);
  });
}
```

- [ ] **Step 2: Run it to confirm it fails**

```bash
flutter test test/features/documents/domain/document_enums_test.dart
```

Expected: FAIL — `document_enums.dart` doesn't exist yet.

- [ ] **Step 3: Implement the enums**

```dart
// lib/features/documents/domain/document_enums.dart
enum DocumentType { invoice, proforma, deliveryNote, quote, receipt, creditNote }

DocumentType documentTypeFromJson(String value) => switch (value) {
      'INVOICE' => DocumentType.invoice,
      'PROFORMA' => DocumentType.proforma,
      'DELIVERY_NOTE' => DocumentType.deliveryNote,
      'QUOTE' => DocumentType.quote,
      'RECEIPT' => DocumentType.receipt,
      'CREDIT_NOTE' => DocumentType.creditNote,
      _ => throw ArgumentError('Unknown document type: $value'),
    };

String documentTypeToJson(DocumentType value) => switch (value) {
      DocumentType.invoice => 'INVOICE',
      DocumentType.proforma => 'PROFORMA',
      DocumentType.deliveryNote => 'DELIVERY_NOTE',
      DocumentType.quote => 'QUOTE',
      DocumentType.receipt => 'RECEIPT',
      DocumentType.creditNote => 'CREDIT_NOTE',
    };

enum DocumentStatus { draft, finalized }

DocumentStatus documentStatusFromJson(String value) => switch (value) {
      'DRAFT' => DocumentStatus.draft,
      'FINALIZED' => DocumentStatus.finalized,
      _ => throw ArgumentError('Unknown document status: $value'),
    };

String documentStatusToJson(DocumentStatus value) => switch (value) {
      DocumentStatus.draft => 'DRAFT',
      DocumentStatus.finalized => 'FINALIZED',
    };

enum PaymentStatus { unpaid, partiallyPaid, paid, writtenOff }

PaymentStatus? paymentStatusFromJson(String? value) => switch (value) {
      null => null,
      'UNPAID' => PaymentStatus.unpaid,
      'PARTIALLY_PAID' => PaymentStatus.partiallyPaid,
      'PAID' => PaymentStatus.paid,
      'WRITTEN_OFF' => PaymentStatus.writtenOff,
      _ => throw ArgumentError('Unknown payment status: $value'),
    };

String? paymentStatusToJson(PaymentStatus? value) => switch (value) {
      null => null,
      PaymentStatus.unpaid => 'UNPAID',
      PaymentStatus.partiallyPaid => 'PARTIALLY_PAID',
      PaymentStatus.paid => 'PAID',
      PaymentStatus.writtenOff => 'WRITTEN_OFF',
    };

enum DiscountType { percent, flat }

DiscountType? discountTypeFromJson(String? value) => switch (value) {
      null => null,
      'PERCENT' => DiscountType.percent,
      'FLAT' => DiscountType.flat,
      _ => throw ArgumentError('Unknown discount type: $value'),
    };

String? discountTypeToJson(DiscountType? value) => switch (value) {
      null => null,
      DiscountType.percent => 'PERCENT',
      DiscountType.flat => 'FLAT',
    };
```

- [ ] **Step 4: Run it to confirm it passes**

```bash
flutter test test/features/documents/domain/document_enums_test.dart
```

Expected: PASS (5 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/features/documents/domain/document_enums.dart test/features/documents/domain/document_enums_test.dart
git commit -m "feat: add document enums with explicit backend mapping"
```

---

### Task 2: Document domain models

**Files:**
- Create: `lib/features/documents/domain/document.dart`
- Test: `test/features/documents/domain/document_test.dart`

**Interfaces:**
- Consumes: `document_enums.dart` (Task 1).
- Produces: `DocumentRef({required String id, String? number, required DocumentType type})`, `DocumentCustomerRef({required String name, String? email})`, `DocumentLine({required String id, String? itemId, required String description, required double quantity, required int unitPrice, required double taxRate, DiscountType? discountType, double? discountValue, required int lineTotal, required int sortOrder})`, `Document({required String id, required DocumentType type, String? number, required DocumentStatus status, required String customerId, required DocumentCustomerRef customer, required String issueDate, String? dueDate, String? notes, String? customerReference, required int subtotal, required int taxTotal, required int total, String? sentAt, required int amountPaid, PaymentStatus? paymentStatus, String? writtenOffAt, String? writeOffReason, required String createdAt, required String updatedAt, String? convertedFromId, String? referencedDocumentId, List<DocumentLine> lines, DocumentRef? convertedFrom, DocumentRef? convertedTo, DocumentRef? referencedDocument})`, all with `.fromJson(...)`.

- [ ] **Step 1: Write the failing test**

```dart
// test/features/documents/domain/document_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/documents/domain/document.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';

Map<String, dynamic> _lineJson({String? discountType, String? discountValue}) => {
      'id': 'l1',
      'itemId': null,
      'description': 'Printing',
      'quantity': '2.00',
      'unitPrice': 5000,
      'taxRate': '18.00',
      'discountType': discountType,
      'discountValue': discountValue,
      'lineTotal': 10000,
      'sortOrder': 0,
    };

Map<String, dynamic> _documentJson({Map<String, dynamic>? extra}) => {
      'id': 'd1',
      'type': 'INVOICE',
      'number': 'INV-0001',
      'status': 'FINALIZED',
      'customerId': 'c1',
      'customer': {'name': 'Acme', 'email': 'acme@example.com'},
      'issueDate': '2026-01-01T00:00:00.000Z',
      'dueDate': '2026-01-31T00:00:00.000Z',
      'notes': null,
      'customerReference': null,
      'subtotal': 10000,
      'taxTotal': 1800,
      'total': 11800,
      'sentAt': null,
      'amountPaid': 0,
      'paymentStatus': null,
      'writtenOffAt': null,
      'writeOffReason': null,
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': '2026-01-01T00:00:00.000Z',
      'convertedFromId': null,
      'referencedDocumentId': null,
      ...?extra,
    };

void main() {
  test('DocumentLine.fromJson parses decimal strings into doubles', () {
    final line = DocumentLine.fromJson(_lineJson());
    expect(line.quantity, 2.0);
    expect(line.taxRate, 18.0);
    expect(line.discountValue, isNull);
    expect(line.discountType, isNull);
  });

  test('DocumentLine.fromJson parses a discount', () {
    final line = DocumentLine.fromJson(_lineJson(discountType: 'PERCENT', discountValue: '10.00'));
    expect(line.discountType, DiscountType.percent);
    expect(line.discountValue, 10.0);
  });

  test('Document.fromJson parses a detail response with lines and a converted-from link', () {
    final json = _documentJson(extra: {
      'lines': [_lineJson()],
      'convertedFrom': {'id': 'p1', 'number': 'PRO-0001', 'type': 'PROFORMA'},
      'convertedTo': null,
      'referencedDocument': null,
    });

    final document = Document.fromJson(json);

    expect(document.lines, hasLength(1));
    expect(document.convertedFrom?.id, 'p1');
    expect(document.convertedFrom?.type, DocumentType.proforma);
    expect(document.convertedTo, isNull);
  });

  test('Document.fromJson defaults lines and refs when parsing a list row (keys absent)', () {
    final document = Document.fromJson(_documentJson());

    expect(document.lines, isEmpty);
    expect(document.convertedFrom, isNull);
    expect(document.convertedTo, isNull);
    expect(document.referencedDocument, isNull);
    expect(document.paymentStatus, isNull);
  });
}
```

- [ ] **Step 2: Run it to confirm it fails**

```bash
flutter test test/features/documents/domain/document_test.dart
```

Expected: FAIL — `document.dart` doesn't exist yet.

- [ ] **Step 3: Implement the domain models**

```dart
// lib/features/documents/domain/document.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'document_enums.dart';

part 'document.freezed.dart';
part 'document.g.dart';

double _decimalFromJson(dynamic value) => double.parse(value as String);
String _decimalToJson(double value) => value.toStringAsFixed(2);

double? _nullableDecimalFromJson(dynamic value) {
  if (value == null) return null;
  return double.parse(value as String);
}

String? _nullableDecimalToJson(double? value) => value?.toStringAsFixed(2);

@freezed
class DocumentRef with _$DocumentRef {
  const factory DocumentRef({
    required String id,
    String? number,
    @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson) required DocumentType type,
  }) = _DocumentRef;

  factory DocumentRef.fromJson(Map<String, dynamic> json) => _$DocumentRefFromJson(json);
}

@freezed
class DocumentCustomerRef with _$DocumentCustomerRef {
  const factory DocumentCustomerRef({
    required String name,
    String? email,
  }) = _DocumentCustomerRef;

  factory DocumentCustomerRef.fromJson(Map<String, dynamic> json) => _$DocumentCustomerRefFromJson(json);
}

@freezed
class DocumentLine with _$DocumentLine {
  const factory DocumentLine({
    required String id,
    String? itemId,
    required String description,
    @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) required double quantity,
    required int unitPrice,
    @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) required double taxRate,
    @JsonKey(fromJson: discountTypeFromJson, toJson: discountTypeToJson) DiscountType? discountType,
    @JsonKey(fromJson: _nullableDecimalFromJson, toJson: _nullableDecimalToJson) double? discountValue,
    required int lineTotal,
    required int sortOrder,
  }) = _DocumentLine;

  factory DocumentLine.fromJson(Map<String, dynamic> json) => _$DocumentLineFromJson(json);
}

@freezed
class Document with _$Document {
  const factory Document({
    required String id,
    @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson) required DocumentType type,
    String? number,
    @JsonKey(fromJson: documentStatusFromJson, toJson: documentStatusToJson) required DocumentStatus status,
    required String customerId,
    required DocumentCustomerRef customer,
    required String issueDate,
    String? dueDate,
    String? notes,
    String? customerReference,
    required int subtotal,
    required int taxTotal,
    required int total,
    String? sentAt,
    required int amountPaid,
    @JsonKey(fromJson: paymentStatusFromJson, toJson: paymentStatusToJson) PaymentStatus? paymentStatus,
    String? writtenOffAt,
    String? writeOffReason,
    required String createdAt,
    required String updatedAt,
    String? convertedFromId,
    String? referencedDocumentId,
    @Default(<DocumentLine>[]) List<DocumentLine> lines,
    DocumentRef? convertedFrom,
    DocumentRef? convertedTo,
    DocumentRef? referencedDocument,
  }) = _Document;

  factory Document.fromJson(Map<String, dynamic> json) => _$DocumentFromJson(json);
}
```

- [ ] **Step 4: Run code generation**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 5: Silence the `invalid_annotation_target` false positive**

`@JsonKey` on a freezed constructor parameter (used above for the Decimal-as-string fields and the enum converters) is a supported, common pattern that the plain analyzer can't distinguish from a genuinely misplaced annotation — `flutter analyze` will otherwise report 8 `invalid_annotation_target` warnings, one per `@JsonKey` usage. Add this to `analysis_options.yaml`, right after the `include:` line:

```yaml
analyzer:
  errors:
    # @JsonKey on a freezed constructor parameter is a supported, common
    # pattern (used for the Decimal-as-string document fields) that the
    # plain analyzer can't distinguish from a genuine misplaced annotation.
    invalid_annotation_target: ignore
```

- [ ] **Step 6: Run it to confirm it passes**

```bash
flutter test test/features/documents/domain/document_test.dart
```

Expected: PASS (4 tests). If it fails on missing generated files, re-run Step 4.

- [ ] **Step 7: Commit**

```bash
git add lib/features/documents/domain/document.dart lib/features/documents/domain/document.freezed.dart lib/features/documents/domain/document.g.dart test/features/documents/domain/document_test.dart analysis_options.yaml
git commit -m "feat: add document domain models with decimal-string parsing"
```

---

### Task 3: `DocumentRepository`

**Files:**
- Create: `lib/features/documents/domain/document_repository.dart`
- Create: `lib/features/documents/data/document_repository_impl.dart`
- Test: `test/features/documents/data/document_repository_impl_test.dart`

**Interfaces:**
- Consumes: `Document`, `DocumentType`, `DocumentStatus`, `documentTypeToJson`, `documentStatusToJson` (Tasks 1–2), `PaginatedResult` (Phase 3).
- Produces: `abstract class DocumentRepository { Future<PaginatedResult<Document>> list({List<DocumentType>? types, DocumentStatus? status, String? search, int page, int pageSize}); Future<Document> get(String id); }`.

- [ ] **Step 1: Write the interface**

```dart
// lib/features/documents/domain/document_repository.dart
import '../../../core/pagination/paginated_result.dart';
import 'document.dart';
import 'document_enums.dart';

abstract class DocumentRepository {
  Future<PaginatedResult<Document>> list({
    List<DocumentType>? types,
    DocumentStatus? status,
    String? search,
    int page = 1,
    int pageSize = 20,
  });

  Future<Document> get(String id);
}
```

- [ ] **Step 2: Write the failing test**

```dart
// test/features/documents/data/document_repository_impl_test.dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/documents/data/document_repository_impl.dart';

class _MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _response(int statusCode, Map<String, dynamic> data, RequestOptions options) {
  return Response(statusCode: statusCode, data: data, requestOptions: options);
}

Map<String, dynamic> _documentJson() => {
      'id': 'd1',
      'type': 'INVOICE',
      'number': 'INV-0001',
      'status': 'FINALIZED',
      'customerId': 'c1',
      'customer': {'name': 'Acme', 'email': null},
      'issueDate': '2026-01-01T00:00:00.000Z',
      'dueDate': null,
      'notes': null,
      'customerReference': null,
      'subtotal': 10000,
      'taxTotal': 1800,
      'total': 11800,
      'sentAt': null,
      'amountPaid': 0,
      'paymentStatus': null,
      'writtenOffAt': null,
      'writeOffReason': null,
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': '2026-01-01T00:00:00.000Z',
      'convertedFromId': null,
      'referencedDocumentId': null,
    };

void main() {
  late _MockDio dio;
  late DocumentRepositoryImpl repository;

  setUp(() {
    dio = _MockDio();
    repository = DocumentRepositoryImpl(dio);
  });

  test('list joins multiple types with a comma and maps results', () async {
    final options = RequestOptions(path: '/documents');
    when(() => dio.get<Map<String, dynamic>>('/documents', queryParameters: {
          'type': 'INVOICE,PROFORMA',
          'status': 'DRAFT',
          'search': 'acme',
          'page': 1,
          'pageSize': 20,
        })).thenAnswer((_) async => _response(200, {
          'results': [_documentJson()],
          'total': 1,
          'page': 1,
          'pageSize': 20,
        }, options));

    final result = await repository.list(
      types: [DocumentType.invoice, DocumentType.proforma],
      status: DocumentStatus.draft,
      search: 'acme',
    );

    expect(result.results.single.id, 'd1');
  });

  test('list omits type/status/search when not provided', () async {
    final options = RequestOptions(path: '/documents');
    when(() => dio.get<Map<String, dynamic>>('/documents', queryParameters: {
          'page': 1,
          'pageSize': 20,
        })).thenAnswer((_) async => _response(200, {'results': [], 'total': 0, 'page': 1, 'pageSize': 20}, options));

    final result = await repository.list();

    expect(result.results, isEmpty);
  });

  test('get fetches and unwraps the document envelope', () async {
    final options = RequestOptions(path: '/documents/d1');
    when(() => dio.get<Map<String, dynamic>>('/documents/d1')).thenAnswer(
      (_) async => _response(200, {'document': _documentJson()}, options),
    );

    final document = await repository.get('d1');

    expect(document.id, 'd1');
  });
}
```

Note this test file needs `DocumentType`/`DocumentStatus` in scope — add `import 'package:billa_mobile/features/documents/domain/document_enums.dart';` alongside the `document_repository_impl.dart` import.

- [ ] **Step 3: Run it to confirm it fails**

```bash
flutter test test/features/documents/data/document_repository_impl_test.dart
```

Expected: FAIL — `document_repository_impl.dart` doesn't exist yet.

- [ ] **Step 4: Implement `DocumentRepositoryImpl`**

```dart
// lib/features/documents/data/document_repository_impl.dart
import 'package:dio/dio.dart';
import '../../../core/pagination/paginated_result.dart';
import '../domain/document.dart';
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
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>('/documents', queryParameters: {
      if (types != null && types.isNotEmpty) 'type': types.map(documentTypeToJson).join(','),
      if (status != null) 'status': documentStatusToJson(status),
      if (search != null && search.isNotEmpty) 'search': search,
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
}
```

- [ ] **Step 5: Run it to confirm it passes**

```bash
flutter test test/features/documents/data/document_repository_impl_test.dart
```

Expected: PASS (3 tests).

- [ ] **Step 6: Commit**

```bash
git add lib/features/documents/domain/document_repository.dart lib/features/documents/data/ test/features/documents/data/
git commit -m "feat: add document repository"
```

---

### Task 4: Document repository provider and list controller

**Files:**
- Create: `lib/features/documents/presentation/providers/document_repository_provider.dart`
- Create: `lib/features/documents/presentation/providers/document_list_controller.dart`
- Test: `test/features/documents/presentation/providers/document_list_controller_test.dart`

**Interfaces:**
- Consumes: `DocumentRepository`/`DocumentRepositoryImpl` (Task 3), `apiClientProvider`, `PaginatedListController` (Phase 3).
- Produces: `documentRepositoryProvider` (`Provider<DocumentRepository>`), `documentListControllerProvider` (`AsyncNotifierProvider<DocumentListController, PaginatedState<Document>>`), `DocumentListController.setTypes(List<DocumentType>?)`, `DocumentListController.setStatusFilter(DocumentStatus?)`.

- [ ] **Step 1: Write the repository provider**

```dart
// lib/features/documents/presentation/providers/document_repository_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/document_repository_impl.dart';
import '../../domain/document_repository.dart';
import '../../../../core/network/api_client_provider.dart';

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepositoryImpl(ref.watch(apiClientProvider).dio);
});
```

- [ ] **Step 2: Write the failing test**

```dart
// test/features/documents/presentation/providers/document_list_controller_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/core/pagination/paginated_result.dart';
import 'package:billa_mobile/features/documents/domain/document.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/domain/document_repository.dart';
import 'package:billa_mobile/features/documents/presentation/providers/document_list_controller.dart';
import 'package:billa_mobile/features/documents/presentation/providers/document_repository_provider.dart';

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
  test('setStatusFilter refetches from page 1 with the given status', () async {
    final repository = _MockDocumentRepository();
    when(() => repository.list(types: null, status: null, search: null, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: <Document>[], total: 0, page: 1, pageSize: 20),
    );
    when(() => repository.list(types: null, status: DocumentStatus.draft, search: null, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: [_document], total: 1, page: 1, pageSize: 20),
    );
    final container = ProviderContainer(overrides: [
      documentRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);
    await container.read(documentListControllerProvider.future);

    await container.read(documentListControllerProvider.notifier).setStatusFilter(DocumentStatus.draft);

    final state = container.read(documentListControllerProvider).value!;
    expect(state.items.single.id, 'd1');
  });

  test('setTypes refetches with the given type list', () async {
    final repository = _MockDocumentRepository();
    when(() => repository.list(types: null, status: null, search: null, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: <Document>[], total: 0, page: 1, pageSize: 20),
    );
    when(() => repository.list(types: [DocumentType.invoice], status: null, search: null, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: [_document], total: 1, page: 1, pageSize: 20),
    );
    final container = ProviderContainer(overrides: [
      documentRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);
    await container.read(documentListControllerProvider.future);

    await container.read(documentListControllerProvider.notifier).setTypes([DocumentType.invoice]);

    final state = container.read(documentListControllerProvider).value!;
    expect(state.items.single.id, 'd1');
  });
}
```

- [ ] **Step 3: Run it to confirm it fails**

```bash
flutter test test/features/documents/presentation/providers/document_list_controller_test.dart
```

Expected: FAIL — `document_list_controller.dart` doesn't exist yet.

- [ ] **Step 4: Implement `DocumentListController`**

```dart
// lib/features/documents/presentation/providers/document_list_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/pagination/paginated_list_controller.dart';
import '../../../../core/pagination/paginated_result.dart';
import '../../../../core/pagination/paginated_state.dart';
import '../../domain/document.dart';
import '../../domain/document_enums.dart';
import 'document_repository_provider.dart';

class DocumentListController extends PaginatedListController<Document> {
  List<DocumentType>? _types;
  DocumentStatus? _statusFilter;

  Future<void> setTypes(List<DocumentType>? types) {
    _types = types;
    return refresh();
  }

  Future<void> setStatusFilter(DocumentStatus? status) {
    _statusFilter = status;
    return refresh();
  }

  @override
  Future<PaginatedResult<Document>> fetchPage({
    required String search,
    required bool includeInactive,
    required int page,
  }) {
    return ref.read(documentRepositoryProvider).list(
          types: _types,
          status: _statusFilter,
          search: search.isEmpty ? null : search,
          page: page,
          pageSize: PaginatedListController.pageSize,
        );
  }
}

final documentListControllerProvider =
    AsyncNotifierProvider<DocumentListController, PaginatedState<Document>>(DocumentListController.new);
```

- [ ] **Step 5: Run it to confirm it passes**

```bash
flutter test test/features/documents/presentation/providers/document_list_controller_test.dart
```

Expected: PASS (2 tests).

- [ ] **Step 6: Commit**

```bash
git add lib/features/documents/presentation/providers/ test/features/documents/presentation/providers/
git commit -m "feat: add document list controller"
```

---

### Task 5: `DocumentStatusPill` and `DocumentListTile`

**Files:**
- Create: `lib/features/documents/presentation/widgets/document_status_pill.dart`
- Create: `lib/features/documents/presentation/widgets/document_list_tile.dart`
- Test: `test/features/documents/presentation/widgets/document_status_pill_test.dart`
- Test: `test/features/documents/presentation/widgets/document_list_tile_test.dart`

**Interfaces:**
- Consumes: `DocumentStatus`, `PaymentStatus`, `Document`, `AppColors`, `MoneyText` (Phase 1).
- Produces: `class DocumentStatusPill extends StatelessWidget { const DocumentStatusPill({required DocumentStatus status, PaymentStatus? paymentStatus}); }`, `class DocumentListTile extends StatelessWidget { const DocumentListTile({required Document document, required VoidCallback onTap}); }`.

- [ ] **Step 1: Write the failing tests**

```dart
// test/features/documents/presentation/widgets/document_status_pill_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/presentation/widgets/document_status_pill.dart';

void main() {
  testWidgets('shows Draft for a draft document', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(body: DocumentStatusPill(status: DocumentStatus.draft)),
    ));
    expect(find.text('Draft'), findsOneWidget);
  });

  testWidgets('shows the payment status label for a finalized invoice', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(
        body: DocumentStatusPill(status: DocumentStatus.finalized, paymentStatus: PaymentStatus.partiallyPaid),
      ),
    ));
    expect(find.text('Partially paid'), findsOneWidget);
  });

  testWidgets('shows Finalized when there is no payment status', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(body: DocumentStatusPill(status: DocumentStatus.finalized)),
    ));
    expect(find.text('Finalized'), findsOneWidget);
  });
}
```

```dart
// test/features/documents/presentation/widgets/document_list_tile_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/documents/domain/document.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/presentation/widgets/document_list_tile.dart';

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
  testWidgets('shows the document number, type, customer, and total', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: DocumentListTile(document: _document, onTap: () {})),
    ));

    expect(find.text('INV-0001'), findsOneWidget);
    expect(find.textContaining('Acme'), findsOneWidget);
    expect(find.text('RWF 11,800'), findsOneWidget);
  });

  testWidgets('shows "Draft <Type>" when the document has no number yet', (tester) async {
    const draft = Document(
      id: 'd2',
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

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: DocumentListTile(document: draft, onTap: () {})),
    ));

    expect(find.text('Draft Invoice'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run them to confirm they fail**

```bash
flutter test test/features/documents/presentation/widgets/document_status_pill_test.dart test/features/documents/presentation/widgets/document_list_tile_test.dart
```

Expected: FAIL — neither widget file exists yet.

- [ ] **Step 3: Implement `DocumentStatusPill`**

```dart
// lib/features/documents/presentation/widgets/document_status_pill.dart
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/document_enums.dart';

class DocumentStatusPill extends StatelessWidget {
  const DocumentStatusPill({super.key, required this.status, this.paymentStatus});

  final DocumentStatus status;
  final PaymentStatus? paymentStatus;

  String get _label {
    if (status == DocumentStatus.draft) return 'Draft';
    return switch (paymentStatus) {
      null => 'Finalized',
      PaymentStatus.unpaid => 'Unpaid',
      PaymentStatus.partiallyPaid => 'Partially paid',
      PaymentStatus.paid => 'Paid',
      PaymentStatus.writtenOff => 'Written off',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final (background, foreground) = status == DocumentStatus.draft
        ? (colors.neutral200, colors.neutral600)
        : switch (paymentStatus) {
            PaymentStatus.paid => (colors.successBg, colors.success),
            PaymentStatus.writtenOff => (colors.neutral200, colors.neutral600),
            _ => (colors.warningBg, colors.warning),
          };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(_label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: foreground)),
    );
  }
}
```

- [ ] **Step 4: Implement `DocumentListTile`**

```dart
// lib/features/documents/presentation/widgets/document_list_tile.dart
import 'package:flutter/material.dart';
import '../../../../core/widgets/money_text.dart';
import '../../domain/document.dart';
import '../../domain/document_enums.dart';
import 'document_status_pill.dart';

String documentTypeLabel(DocumentType type) => switch (type) {
      DocumentType.invoice => 'Invoice',
      DocumentType.proforma => 'Proforma',
      DocumentType.deliveryNote => 'Delivery note',
      DocumentType.quote => 'Quote',
      DocumentType.receipt => 'Receipt',
      DocumentType.creditNote => 'Credit note',
    };

class DocumentListTile extends StatelessWidget {
  const DocumentListTile({super.key, required this.document, required this.onTap});

  final Document document;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(document.number ?? 'Draft ${documentTypeLabel(document.type)}'),
      subtitle: Text('${documentTypeLabel(document.type)} · ${document.customer.name}'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          MoneyText(document.total),
          const SizedBox(height: 4),
          DocumentStatusPill(status: document.status, paymentStatus: document.paymentStatus),
        ],
      ),
    );
  }
}
```

`documentTypeLabel` is declared without a leading underscore because Task 6's list screen (the type filter chips) reuses it for chip labels — keeping one label mapping instead of two copies.

- [ ] **Step 5: Run them to confirm they pass**

```bash
flutter test test/features/documents/presentation/widgets/document_status_pill_test.dart test/features/documents/presentation/widgets/document_list_tile_test.dart
```

Expected: PASS (5 tests total).

- [ ] **Step 6: Commit**

```bash
git add lib/features/documents/presentation/widgets/ test/features/documents/presentation/widgets/document_status_pill_test.dart test/features/documents/presentation/widgets/document_list_tile_test.dart
git commit -m "feat: add document status pill and list tile widgets"
```

---

### Task 6: `DocumentListScreen`

This task also makes `EmptyState`'s action optional — Phase 1's version required `actionLabel`/`onAction` always, but a brand-new business's document list has no in-app "create" action yet (that's 4b), and the project's own rule is to leave an action out entirely rather than invent one that goes nowhere.

**Files:**
- Modify: `lib/core/widgets/empty_state.dart`
- Modify: `test/core/widgets/empty_state_test.dart`
- Create: `lib/features/documents/presentation/screens/document_list_screen.dart`
- Test: `test/features/documents/presentation/screens/document_list_screen_test.dart`

**Interfaces:**
- Consumes: `documentListControllerProvider` (Task 4), `documentRepositoryProvider` (Task 4), `DocumentListTile`/`documentTypeLabel` (Task 5), `EmptyState`/`ErrorState`/`LoadingSkeleton` (Phase 1).
- Produces: `EmptyState({required IconData icon, required String message, String? actionLabel, VoidCallback? onAction})` (action now optional), `class DocumentListScreen extends ConsumerStatefulWidget`.

- [ ] **Step 1: Write the failing test for the optional action**

Add this test case to the existing `test/core/widgets/empty_state_test.dart` (alongside its current test):

```dart
  testWidgets('renders with no button when no action is given', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const EmptyState(icon: Icons.description_outlined, message: 'No documents yet'),
    ));

    expect(find.text('No documents yet'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });
```

- [ ] **Step 2: Run it to confirm it fails**

```bash
flutter test test/core/widgets/empty_state_test.dart
```

Expected: FAIL — `actionLabel`/`onAction` are currently required constructor parameters, so this call doesn't compile.

- [ ] **Step 3: Make the action optional on `EmptyState`**

```dart
// lib/core/widgets/empty_state.dart
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: colors.neutral300),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.neutral600),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.small)),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run it to confirm it passes**

```bash
flutter test test/core/widgets/empty_state_test.dart
```

Expected: PASS (2 tests — the original plus the new one). The Phase 1 test and every Phase 3 call site (which always pass both `actionLabel` and `onAction`) are unaffected, since a non-null `String`/`VoidCallback` is still valid where a nullable one is now accepted.

- [ ] **Step 5: Write the failing screen test**

```dart
// test/features/documents/presentation/screens/document_list_screen_test.dart
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

  Widget buildApp() {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => const DocumentListScreen()),
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
}
```

- [ ] **Step 6: Run it to confirm it fails**

```bash
flutter test test/features/documents/presentation/screens/document_list_screen_test.dart
```

Expected: FAIL — `document_list_screen.dart` doesn't exist yet.

- [ ] **Step 7: Implement `DocumentListScreen`**

```dart
// lib/features/documents/presentation/screens/document_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../domain/document_enums.dart';
import '../providers/document_list_controller.dart';
import '../widgets/document_list_tile.dart';

class DocumentListScreen extends ConsumerStatefulWidget {
  const DocumentListScreen({super.key});

  @override
  ConsumerState<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends ConsumerState<DocumentListScreen> {
  final _scrollController = ScrollController();
  final Set<DocumentType> _selectedTypes = {};
  DocumentStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(documentListControllerProvider.notifier).loadMore();
    }
  }

  void _toggleType(DocumentType type, bool selected) {
    setState(() {
      if (selected) {
        _selectedTypes.add(type);
      } else {
        _selectedTypes.remove(type);
      }
    });
    ref.read(documentListControllerProvider.notifier).setTypes(_selectedTypes.isEmpty ? null : _selectedTypes.toList());
  }

  void _selectStatus(DocumentStatus? status) {
    setState(() => _selectedStatus = status);
    ref.read(documentListControllerProvider.notifier).setStatusFilter(status);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(documentListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Documents')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              key: const Key('document-search'),
              decoration: const InputDecoration(hintText: 'Search documents', prefixIcon: Icon(Icons.search)),
              onChanged: (value) => ref.read(documentListControllerProvider.notifier).setSearch(value),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ChoiceChip(
                  key: const Key('document-status-all'),
                  label: const Text('All'),
                  selected: _selectedStatus == null,
                  onSelected: (_) => _selectStatus(null),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  key: const Key('document-status-draft'),
                  label: const Text('Draft'),
                  selected: _selectedStatus == DocumentStatus.draft,
                  onSelected: (_) => _selectStatus(DocumentStatus.draft),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  key: const Key('document-status-finalized'),
                  label: const Text('Finalized'),
                  selected: _selectedStatus == DocumentStatus.finalized,
                  onSelected: (_) => _selectStatus(DocumentStatus.finalized),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final type in DocumentType.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(documentTypeLabel(type)),
                      selected: _selectedTypes.contains(type),
                      onSelected: (selected) => _toggleType(type, selected),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: switch (state) {
              AsyncData(value: final data) when data.items.isEmpty => const EmptyState(
                  icon: Icons.description_outlined,
                  message: 'No documents yet',
                ),
              AsyncData(value: final data) => ListView.builder(
                  controller: _scrollController,
                  itemCount: data.items.length + (data.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= data.items.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    }
                    final document = data.items[index];
                    return DocumentListTile(
                      document: document,
                      onTap: () => context.push('/documents/${document.id}'),
                    );
                  },
                ),
              AsyncError() => ErrorState(
                  message: "Couldn't load your documents",
                  onRetry: () => ref.read(documentListControllerProvider.notifier).refresh(),
                ),
              _ => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(children: [LoadingSkeleton(height: 64), SizedBox(height: 12), LoadingSkeleton(height: 64)]),
                ),
            },
          ),
        ],
      ),
    );
  }
}
```

Note the `documentTypeLabel` import comes transitively from `document_list_tile.dart` — no separate import needed since it's already imported there and re-exported by Dart's normal visibility (importing a file gives access to all its public top-level declarations).

- [ ] **Step 8: Run it to confirm it passes**

```bash
flutter test test/features/documents/presentation/screens/document_list_screen_test.dart
```

Expected: PASS (3 tests).

- [ ] **Step 9: Commit**

```bash
git add lib/core/widgets/empty_state.dart test/core/widgets/empty_state_test.dart lib/features/documents/presentation/screens/document_list_screen.dart test/features/documents/presentation/screens/document_list_screen_test.dart
git commit -m "feat: add document list screen with type and status filters"
```

---

### Task 7: `DocumentDetailScreen`

**Files:**
- Create: `lib/features/documents/presentation/screens/document_detail_screen.dart`
- Test: `test/features/documents/presentation/screens/document_detail_screen_test.dart`

**Interfaces:**
- Consumes: `documentRepositoryProvider` (Task 4), `Document`/`DocumentLine`/`DocumentRef` (Task 2), `DocumentStatusPill` (Task 5), `ErrorState`/`LoadingSkeleton`/`MoneyText` (Phase 1).
- Produces: `class DocumentDetailScreen extends ConsumerStatefulWidget { const DocumentDetailScreen({required String documentId}); }`.

- [ ] **Step 1: Write the failing test**

```dart
// test/features/documents/presentation/screens/document_detail_screen_test.dart
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
```

- [ ] **Step 2: Run it to confirm it fails**

```bash
flutter test test/features/documents/presentation/screens/document_detail_screen_test.dart
```

Expected: FAIL — `document_detail_screen.dart` doesn't exist yet.

- [ ] **Step 3: Implement `DocumentDetailScreen`**

```dart
// lib/features/documents/presentation/screens/document_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/money_text.dart';
import '../../domain/document.dart';
import '../../domain/document_enums.dart';
import '../providers/document_repository_provider.dart';
import '../widgets/document_status_pill.dart';

String _lineDiscountLabel(DocumentLine line) {
  if (line.discountType == null || line.discountValue == null) return '';
  return line.discountType == DiscountType.percent
      ? '${line.discountValue!.toStringAsFixed(0)}% off'
      : 'RWF ${line.discountValue!.toStringAsFixed(0)} off';
}

class DocumentDetailScreen extends ConsumerStatefulWidget {
  const DocumentDetailScreen({super.key, required this.documentId});

  final String documentId;

  @override
  ConsumerState<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends ConsumerState<DocumentDetailScreen> {
  late Future<Document> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Document> _load() => ref.read(documentRepositoryProvider).get(widget.documentId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Document')),
      body: FutureBuilder<Document>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorState(
              message: "Couldn't load this document",
              onRetry: () => setState(() {
                _future = _load();
              }),
            );
          }
          if (!snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Column(children: [LoadingSkeleton(height: 24), SizedBox(height: 12), LoadingSkeleton(height: 200)]),
            );
          }
          final document = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(document.number ?? 'Draft', style: Theme.of(context).textTheme.headlineSmall),
                    DocumentStatusPill(status: document.status, paymentStatus: document.paymentStatus),
                  ],
                ),
                const SizedBox(height: 8),
                Text(document.customer.name),
                if (document.customer.email != null) Text(document.customer.email!),
                const SizedBox(height: 16),
                Text('Issued ${document.issueDate.split('T').first}'),
                if (document.dueDate != null) Text('Due ${document.dueDate!.split('T').first}'),
                if (document.notes != null) ...[
                  const SizedBox(height: 16),
                  Text(document.notes!),
                ],
                const SizedBox(height: 24),
                for (final line in document.lines)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(line.description),
                              Text(
                                '${line.quantity.toStringAsFixed(2)} × RWF ${line.unitPrice}'
                                '${_lineDiscountLabel(line).isEmpty ? '' : ' · ${_lineDiscountLabel(line)}'}',
                              ),
                            ],
                          ),
                        ),
                        MoneyText(line.lineTotal),
                      ],
                    ),
                  ),
                const Divider(height: 32),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Subtotal'), MoneyText(document.subtotal)]),
                const SizedBox(height: 4),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Tax'), MoneyText(document.taxTotal)]),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: Theme.of(context).textTheme.titleMedium),
                    MoneyText(document.total, style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                if (document.convertedFrom != null) ...[
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => context.push('/documents/${document.convertedFrom!.id}'),
                    child: Text('Converted from ${document.convertedFrom!.number ?? document.convertedFrom!.id}'),
                  ),
                ],
                if (document.convertedTo != null)
                  TextButton(
                    onPressed: () => context.push('/documents/${document.convertedTo!.id}'),
                    child: Text('Converted to ${document.convertedTo!.number ?? document.convertedTo!.id}'),
                  ),
                if (document.referencedDocument != null)
                  TextButton(
                    onPressed: () => context.push('/documents/${document.referencedDocument!.id}'),
                    child: Text('References ${document.referencedDocument!.number ?? document.referencedDocument!.id}'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 4: Run it to confirm it passes**

```bash
flutter test test/features/documents/presentation/screens/document_detail_screen_test.dart
```

Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/features/documents/presentation/screens/document_detail_screen.dart test/features/documents/presentation/screens/document_detail_screen_test.dart
git commit -m "feat: add document detail screen with line items and conversion links"
```

---

### Task 8: Router wiring and home navigation

**Files:**
- Modify: `lib/app/router.dart`
- Modify: `test/app/router_test.dart`

**Interfaces:**
- Consumes: `DocumentListScreen`/`DocumentDetailScreen` (Tasks 6–7), `documentRepositoryProvider` (Task 4).
- Produces: routes `/documents`, `/documents/:id`; a third keyed button on the placeholder home screen.

- [ ] **Step 1: Add the new routes and home navigation button to `router.dart`**

```dart
// lib/app/router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/providers/auth_controller.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/customers/domain/customer.dart';
import '../features/customers/presentation/screens/customer_detail_screen.dart';
import '../features/customers/presentation/screens/customer_form_screen.dart';
import '../features/customers/presentation/screens/customer_list_screen.dart';
import '../features/documents/presentation/screens/document_detail_screen.dart';
import '../features/documents/presentation/screens/document_list_screen.dart';
import '../features/items/domain/item.dart';
import '../features/items/presentation/screens/item_form_screen.dart';
import '../features/items/presentation/screens/item_list_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import 'theme/bootstrap_screen.dart';

const _authRoutes = {'/login', '/register'};

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshNotifier(ref),
    redirect: (context, state) {
      final status = ref.read(authControllerProvider).value;
      final path = state.uri.path;
      if (status == null) return path == '/bootstrap' ? null : '/bootstrap';

      return status.when(
        unauthenticated: () => _authRoutes.contains(path) ? null : '/login',
        // Handled inline by login_screen.dart — never a route-level redirect.
        twoFactorRequired: (challengeId) => null,
        authenticated: (user, business) {
          final needsOnboarding = business.onboardingCompletedAt == null;
          if (needsOnboarding) return path == '/onboarding' ? null : '/onboarding';
          return (_authRoutes.contains(path) || path == '/onboarding') ? '/' : null;
        },
      );
    },
    routes: [
      GoRoute(path: '/bootstrap', builder: (context, state) => const BootstrapScreen()),
      GoRoute(path: '/', builder: (context, state) => const _PlaceholderHomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/customers', builder: (context, state) => const CustomerListScreen()),
      GoRoute(path: '/customers/new', builder: (context, state) => const CustomerFormScreen()),
      GoRoute(
        path: '/customers/:id/edit',
        builder: (context, state) => CustomerFormScreen(existing: state.extra as Customer?),
      ),
      GoRoute(
        path: '/customers/:id',
        builder: (context, state) => CustomerDetailScreen(customerId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/items', builder: (context, state) => const ItemListScreen()),
      GoRoute(path: '/items/new', builder: (context, state) => const ItemFormScreen()),
      GoRoute(
        path: '/items/:id/edit',
        builder: (context, state) => ItemFormScreen(existing: state.extra as Item?),
      ),
      GoRoute(path: '/documents', builder: (context, state) => const DocumentListScreen()),
      GoRoute(
        path: '/documents/:id',
        builder: (context, state) => DocumentDetailScreen(documentId: state.pathParameters['id']!),
      ),
    ],
  );
});

class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(Ref ref) {
    ref.listen(authControllerProvider, (_, _) => notifyListeners());
  }
}

class _PlaceholderHomeScreen extends StatelessWidget {
  const _PlaceholderHomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Billa', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 24),
            ElevatedButton(
              key: const Key('home-nav-customers'),
              onPressed: () => context.push('/customers'),
              child: const Text('Customers'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              key: const Key('home-nav-items'),
              onPressed: () => context.push('/items'),
              child: const Text('Items'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              key: const Key('home-nav-documents'),
              onPressed: () => context.push('/documents'),
              child: const Text('Documents'),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Add a home-navigation test case to `router_test.dart`**

Add these imports to the top of the existing `test/app/router_test.dart` (alongside what's already there):

```dart
import 'package:billa_mobile/core/pagination/paginated_result.dart';
import 'package:billa_mobile/features/documents/domain/document_repository.dart';
import 'package:billa_mobile/features/documents/presentation/providers/document_repository_provider.dart';
```

(`PaginatedResult` and `mocktail` are already imported there from the Phase 3 test cases — don't duplicate those imports.)

Add this mock class near the existing `_MockCustomerRepository`/`_MockItemRepository`:

```dart
class _MockDocumentRepository extends Mock implements DocumentRepository {}
```

Add this test case inside `main()`, alongside the existing five:

```dart
  testWidgets('home screen navigates to the documents list', (tester) async {
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

    expect(find.text('No documents yet'), findsOneWidget);
  });
```

- [ ] **Step 3: Run it to confirm it passes, then the full suite**

```bash
flutter test test/app/router_test.dart
flutter test
```

Expected: router test passes (6 cases total); full suite green.

- [ ] **Step 4: Commit**

```bash
git add lib/app/router.dart test/app/router_test.dart
git commit -m "feat: wire document routes into the router"
```

---

### Task 9: Final verification

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

Expected: every test from Tasks 1–8 passes, plus all of Phases 1–3's existing tests still pass unchanged.

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
git commit -m "fix: resolve analyzer warnings from phase 4a verification"
```

If nothing needed fixing, this step is a no-op.

---

## Definition of done for this plan

`flutter analyze` is clean, `flutter test` passes in full, `flutter build apk --debug` succeeds, and a manual run shows: home screen → Documents button → list with search, type filter chips, a status toggle, and a real (actionless) empty state for a brand-new business → tap a row → detail view with line items (tabular figures, discounts shown correctly), subtotal/tax/total, a status pill, and — when a document was converted or references another — a working link to it. No Edit or Finalize button anywhere; that's 4b and 4c.
