# Phase 5: Payments/Receivables Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Record and void payments against a finalized invoice, write off
and reactivate an invoice, attach a photo of proof of payment, and see a
cross-customer receivables aging report.

**Architecture:** `PaymentMethod` joins the existing enums in
`document_enums.dart`. New `Payment`/`PaymentInput` models and five new
`DocumentRepository` methods (matching their URL nesting under
`/documents/...`, same reasoning as Phase 4c's finalize/convert/send). A
new `receivables` feature (its own repository, one method) for the
top-level `GET /receivables` resource. `DocumentDetailScreen` gains a
Payments section and Write-off/Reactivate actions using the exact
`_runAction`/`_confirm`/error-banner machinery Phase 4c already built —
extended with one new dialog helper (`_promptText`) for the two actions
that need a typed reason, not just a yes/no. A new `RecordPaymentScreen`
and `ReceivablesScreen` follow the existing screen conventions
(`DocumentEditorScreen`'s `extra`-passed-model pattern, the app's
existing home-nav-button-per-feature pattern).

**Tech Stack:** Flutter, `flutter_riverpod` 2.6.1, `go_router`, `dio`,
`image_picker` (already a dependency, used here for the first time
outside onboarding), `path_provider` (already a dependency).

**Spec:** `docs/superpowers/specs/2026-09-20-phase5-payments-receivables-design.md`

## Global Constraints

- Commits authored as `Ange Aurele TUYISENGE <tuyisengeauris@gmail.com>`; never a `Co-authored-by` trailer; never mention Claude/AI anywhere.
- Small, single-sentence, conventional-commit-style messages, one logical change per commit.
- Comments explain *why*, never *what*.
- No dead ends: every action has a specific, actionable error message and a retry path — never a silent failure.
- Every task ends with `flutter analyze` clean and `flutter test` passing.
- MoMo payment requests, precise credit-note-aware `amount_exceeds_owed` pre-validation, any billing/subscription UI, and the `/dashboard/summary` endpoint are all out of scope — see the spec's Non-goals.

---

### Task 1: `PaymentMethod` enum and payment/receivables domain models

**Files:**
- Modify: `lib/features/documents/domain/document_enums.dart`
- Modify: `test/features/documents/domain/document_enums_test.dart`
- Create: `lib/features/documents/domain/payment.dart`
- Test: `test/features/documents/domain/payment_test.dart`
- Create: `lib/features/documents/domain/payment_input.dart`
- Test: `test/features/documents/domain/payment_input_test.dart`
- Create: `lib/features/receivables/domain/outstanding_invoice.dart`
- Test: `test/features/receivables/domain/outstanding_invoice_test.dart`

**Interfaces:**
- Consumes: nothing new.
- Produces: `enum PaymentMethod { cash, bankTransfer, mobileMoney, cheque, other }` + `paymentMethodFromJson`/`paymentMethodToJson`; `class Payment`; `class PaymentInput`; `class OutstandingInvoice`.

- [ ] **Step 1: Write the failing enum test**

Add to `test/features/documents/domain/document_enums_test.dart`:

```dart
  test('PaymentMethod round-trips every value', () {
    for (final method in PaymentMethod.values) {
      expect(paymentMethodFromJson(paymentMethodToJson(method)), method);
    }
    expect(paymentMethodToJson(PaymentMethod.bankTransfer), 'BANK_TRANSFER');
    expect(paymentMethodToJson(PaymentMethod.mobileMoney), 'MOBILE_MONEY');
  });
```

- [ ] **Step 2: Run it to confirm it fails**

```bash
flutter test test/features/documents/domain/document_enums_test.dart
```

Expected: FAIL — `PaymentMethod` doesn't exist yet.

- [ ] **Step 3: Add `PaymentMethod` to `document_enums.dart`**

Append to `lib/features/documents/domain/document_enums.dart`:

```dart
enum PaymentMethod { cash, bankTransfer, mobileMoney, cheque, other }

PaymentMethod paymentMethodFromJson(String value) => switch (value) {
      'CASH' => PaymentMethod.cash,
      'BANK_TRANSFER' => PaymentMethod.bankTransfer,
      'MOBILE_MONEY' => PaymentMethod.mobileMoney,
      'CHEQUE' => PaymentMethod.cheque,
      'OTHER' => PaymentMethod.other,
      _ => throw ArgumentError('Unknown payment method: $value'),
    };

String paymentMethodToJson(PaymentMethod value) => switch (value) {
      PaymentMethod.cash => 'CASH',
      PaymentMethod.bankTransfer => 'BANK_TRANSFER',
      PaymentMethod.mobileMoney => 'MOBILE_MONEY',
      PaymentMethod.cheque => 'CHEQUE',
      PaymentMethod.other => 'OTHER',
    };
```

- [ ] **Step 4: Run it to confirm it passes**

```bash
flutter test test/features/documents/domain/document_enums_test.dart
```

Expected: PASS (7 tests total).

- [ ] **Step 5: Write the failing `Payment`/`PaymentInput` tests**

```dart
// test/features/documents/domain/payment_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/domain/payment.dart';

void main() {
  test('Payment.fromJson parses a typical payment, ignoring unmodeled fields', () {
    final payment = Payment.fromJson({
      'id': 'pay1',
      'amount': 5000,
      'method': 'MOBILE_MONEY',
      'paidOn': '2026-01-05T00:00:00.000Z',
      'notes': null,
      'referenceNumber': 'TXN123',
      'payerName': 'John Doe',
      'receiptImageUrl': null,
      'receiptDocumentId': null,
      'voidedAt': null,
      'voidReason': null,
      'createdAt': '2026-01-05T00:00:00.000Z',
      'businessId': 'b1',
      'documentId': 'd1',
      'createdByUserId': 'u1',
      'momoPaymentRequestId': null,
    });

    expect(payment.id, 'pay1');
    expect(payment.amount, 5000);
    expect(payment.method, PaymentMethod.mobileMoney);
    expect(payment.referenceNumber, 'TXN123');
    expect(payment.voidedAt, isNull);
  });

  test('Payment.fromJson parses a voided payment', () {
    final payment = Payment.fromJson({
      'id': 'pay1',
      'amount': 5000,
      'method': 'CASH',
      'paidOn': '2026-01-05T00:00:00.000Z',
      'notes': null,
      'referenceNumber': null,
      'payerName': null,
      'receiptImageUrl': null,
      'receiptDocumentId': null,
      'voidedAt': '2026-01-06T00:00:00.000Z',
      'voidReason': 'Duplicate entry',
      'createdAt': '2026-01-05T00:00:00.000Z',
    });

    expect(payment.voidedAt, '2026-01-06T00:00:00.000Z');
    expect(payment.voidReason, 'Duplicate entry');
  });
}
```

```dart
// test/features/documents/domain/payment_input_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/domain/payment_input.dart';

void main() {
  test('PaymentInput.toJson matches the backend request shape', () {
    const input = PaymentInput(amount: 5000, method: PaymentMethod.cash, paidOn: '2026-01-05');

    final json = input.toJson();

    expect(json['amount'], 5000);
    expect(json['method'], 'CASH');
    expect(json['paidOn'], '2026-01-05');
    expect(json['generateReceipt'], false);
    expect(json['notes'], isNull);
  });

  test('round-trips through fromJson', () {
    const input = PaymentInput(
      amount: 10000,
      method: PaymentMethod.mobileMoney,
      paidOn: '2026-01-05',
      notes: 'Partial payment',
      referenceNumber: 'TXN1',
      payerName: 'Jane',
      receiptImageUrl: '/uploads/x.png',
      generateReceipt: true,
    );

    final roundTripped = PaymentInput.fromJson(input.toJson());

    expect(roundTripped, input);
  });
}
```

```dart
// test/features/receivables/domain/outstanding_invoice_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/receivables/domain/outstanding_invoice.dart';

void main() {
  test('OutstandingInvoice.fromJson parses a typical result', () {
    final invoice = OutstandingInvoice.fromJson({
      'id': 'd1',
      'number': 'INV-0001',
      'customerName': 'Acme',
      'total': 10000,
      'amountOwed': 4000,
      'dueDate': '2026-01-01',
      'daysOverdue': 12,
      'agingBucket': '0-30',
    });

    expect(invoice.id, 'd1');
    expect(invoice.amountOwed, 4000);
    expect(invoice.agingBucket, '0-30');
  });

  test('handles a null dueDate and number', () {
    final invoice = OutstandingInvoice.fromJson({
      'id': 'd1',
      'number': null,
      'customerName': 'Acme',
      'total': 10000,
      'amountOwed': 10000,
      'dueDate': null,
      'daysOverdue': 0,
      'agingBucket': 'current',
    });

    expect(invoice.number, isNull);
    expect(invoice.dueDate, isNull);
  });
}
```

- [ ] **Step 6: Run them to confirm they fail**

```bash
flutter test test/features/documents/domain/payment_test.dart test/features/documents/domain/payment_input_test.dart test/features/receivables/domain/outstanding_invoice_test.dart
```

Expected: FAIL — none of the three files exist yet.

- [ ] **Step 7: Implement the models**

```dart
// lib/features/documents/domain/payment.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'document_enums.dart';

part 'payment.freezed.dart';
part 'payment.g.dart';

@freezed
class Payment with _$Payment {
  const factory Payment({
    required String id,
    required int amount,
    @JsonKey(fromJson: paymentMethodFromJson, toJson: paymentMethodToJson) required PaymentMethod method,
    required String paidOn,
    String? notes,
    String? referenceNumber,
    String? payerName,
    String? receiptImageUrl,
    String? receiptDocumentId,
    String? voidedAt,
    String? voidReason,
    required String createdAt,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);
}
```

```dart
// lib/features/documents/domain/payment_input.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'document_enums.dart';

part 'payment_input.freezed.dart';
part 'payment_input.g.dart';

@freezed
class PaymentInput with _$PaymentInput {
  const factory PaymentInput({
    required int amount,
    @JsonKey(fromJson: paymentMethodFromJson, toJson: paymentMethodToJson) required PaymentMethod method,
    required String paidOn,
    String? notes,
    String? referenceNumber,
    String? payerName,
    String? receiptImageUrl,
    @Default(false) bool generateReceipt,
  }) = _PaymentInput;

  factory PaymentInput.fromJson(Map<String, dynamic> json) => _$PaymentInputFromJson(json);
}
```

```dart
// lib/features/receivables/domain/outstanding_invoice.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'outstanding_invoice.freezed.dart';
part 'outstanding_invoice.g.dart';

@freezed
class OutstandingInvoice with _$OutstandingInvoice {
  const factory OutstandingInvoice({
    required String id,
    String? number,
    required String customerName,
    required int total,
    required int amountOwed,
    String? dueDate,
    required int daysOverdue,
    required String agingBucket,
  }) = _OutstandingInvoice;

  factory OutstandingInvoice.fromJson(Map<String, dynamic> json) => _$OutstandingInvoiceFromJson(json);
}
```

- [ ] **Step 8: Run `build_runner` and confirm the tests pass**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/documents/domain/payment_test.dart test/features/documents/domain/payment_input_test.dart test/features/receivables/domain/outstanding_invoice_test.dart
```

Expected: PASS (6 tests).

If `build_runner` fails with a syntax error in
`document_repository_impl.dart` around the `'customerId': ?customerId,`
line: that null-aware map-entry syntax (from a `dart fix` applied during
Phase 4c) is newer than `build_runner`'s pinned `analyzer` (6.4.1, held
back by the same riverpod/freezed version constraints from Phase 1),
even though the Flutter SDK's own analyzer accepts it fine. Revert that
one line to `if (customerId != null) 'customerId': customerId,` and add
this to `analysis_options.yaml`'s `linter: rules:` section to keep
`flutter analyze` clean about the resulting lint:

```yaml
    use_null_aware_elements: false
```

- [ ] **Step 9: Analyze and commit**

```bash
flutter analyze
git add lib/features/documents/domain/ lib/features/receivables/domain/ test/features/documents/domain/ test/features/receivables/domain/ lib/features/documents/data/document_repository_impl.dart analysis_options.yaml
git commit -m "feat: add payment method enum and payment/receivables domain models"
```

---

### Task 2: Repository methods for payments, write-off, reactivate, receipt upload, and receivables

**Files:**
- Modify: `lib/features/documents/domain/document_repository.dart`
- Modify: `lib/features/documents/data/document_repository_impl.dart`
- Modify: `test/features/documents/data/document_repository_impl_test.dart`
- Create: `lib/features/receivables/domain/receivables_repository.dart`
- Create: `lib/features/receivables/data/receivables_repository_impl.dart`
- Test: `test/features/receivables/data/receivables_repository_impl_test.dart`

**Interfaces:**
- Consumes: `Payment`/`PaymentInput`/`OutstandingInvoice` (Task 1).
- Produces: `DocumentRepository.recordPayment(id, PaymentInput)`,
  `.voidPayment(id, paymentId, reason)`, `.listPayments(id)`,
  `.writeOff(id, reason)`, `.reactivate(id)`,
  `.uploadPaymentReceipt(bytes, filename)`; `ReceivablesRepository.list()`.

- [ ] **Step 1: Write the failing `DocumentRepository` tests**

Add to `test/features/documents/data/document_repository_impl_test.dart`:

```dart
  test('recordPayment posts to /payments and returns the updated document', () async {
    final options = RequestOptions(path: '/documents/d1/payments');
    const input = PaymentInput(amount: 5000, method: PaymentMethod.cash, paidOn: '2026-01-05');
    when(() => dio.post<Map<String, dynamic>>('/documents/d1/payments', data: input.toJson())).thenAnswer(
      (_) async => _response(201, {'payment': {'id': 'pay1'}, 'document': _documentJson()}, options),
    );

    final document = await repository.recordPayment('d1', input);

    expect(document.id, 'd1');
  });

  test('voidPayment posts the void reason and returns the updated document', () async {
    final options = RequestOptions(path: '/documents/d1/payments/pay1/void');
    when(() => dio.post<Map<String, dynamic>>('/documents/d1/payments/pay1/void', data: {'voidReason': 'Mistake'}))
        .thenAnswer((_) async => _response(200, {'document': _documentJson()}, options));

    final document = await repository.voidPayment('d1', 'pay1', 'Mistake');

    expect(document.id, 'd1');
  });

  test('listPayments fetches and maps the payments list', () async {
    final options = RequestOptions(path: '/documents/d1/payments');
    when(() => dio.get<Map<String, dynamic>>('/documents/d1/payments')).thenAnswer(
      (_) async => _response(200, {
        'payments': [
          {
            'id': 'pay1',
            'amount': 5000,
            'method': 'CASH',
            'paidOn': '2026-01-05T00:00:00.000Z',
            'notes': null,
            'referenceNumber': null,
            'payerName': null,
            'receiptImageUrl': null,
            'receiptDocumentId': null,
            'voidedAt': null,
            'voidReason': null,
            'createdAt': '2026-01-05T00:00:00.000Z',
          },
        ],
      }, options),
    );

    final payments = await repository.listPayments('d1');

    expect(payments.single.id, 'pay1');
  });

  test('writeOff posts the reason and returns the updated document', () async {
    final options = RequestOptions(path: '/documents/d1/write-off');
    when(() => dio.post<Map<String, dynamic>>('/documents/d1/write-off', data: {'writeOffReason': 'Bad debt'}))
        .thenAnswer((_) async => _response(200, {'document': _documentJson()}, options));

    final document = await repository.writeOff('d1', 'Bad debt');

    expect(document.id, 'd1');
  });

  test('reactivate posts to /reactivate and returns the updated document', () async {
    final options = RequestOptions(path: '/documents/d1/reactivate');
    when(() => dio.post<Map<String, dynamic>>('/documents/d1/reactivate')).thenAnswer(
      (_) async => _response(200, {'document': _documentJson()}, options),
    );

    final document = await repository.reactivate('d1');

    expect(document.id, 'd1');
  });

  test('uploadPaymentReceipt posts multipart form data and returns the url', () async {
    final options = RequestOptions(path: '/documents/payments/receipt');
    when(() => dio.post<Map<String, dynamic>>('/documents/payments/receipt', data: any(named: 'data'))).thenAnswer(
      (_) async => _response(201, {'url': '/uploads/b1/receipt.png'}, options),
    );

    final url = await repository.uploadPaymentReceipt([1, 2, 3], 'receipt.png');

    expect(url, '/uploads/b1/receipt.png');
  });
```

Add the new import at the top of the test file:

```dart
import 'package:billa_mobile/features/documents/domain/payment_input.dart';
```

- [ ] **Step 2: Run it to confirm it fails**

```bash
flutter test test/features/documents/data/document_repository_impl_test.dart
```

Expected: FAIL — none of the five methods exist yet.

- [ ] **Step 3: Add the methods to the abstract repository**

```dart
// lib/features/documents/domain/document_repository.dart
import '../../../core/pagination/paginated_result.dart';
import 'document.dart';
import 'document_draft_input.dart';
import 'document_enums.dart';
import 'payment.dart';
import 'payment_input.dart';

abstract class DocumentRepository {
  // ...existing members unchanged...
  Future<Document> recordPayment(String documentId, PaymentInput input);
  Future<Document> voidPayment(String documentId, String paymentId, String reason);
  Future<List<Payment>> listPayments(String documentId);
  Future<Document> writeOff(String documentId, String reason);
  Future<Document> reactivate(String documentId);
  Future<String> uploadPaymentReceipt(List<int> bytes, String filename);
}
```

- [ ] **Step 4: Implement them**

Add to `lib/features/documents/data/document_repository_impl.dart` (plus
the same two new imports as the abstract class):

```dart
  @override
  Future<Document> recordPayment(String documentId, PaymentInput input) async {
    final response = await _dio.post<Map<String, dynamic>>('/documents/$documentId/payments', data: input.toJson());
    return Document.fromJson(response.data!['document'] as Map<String, dynamic>);
  }

  @override
  Future<Document> voidPayment(String documentId, String paymentId, String reason) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/documents/$documentId/payments/$paymentId/void',
      data: {'voidReason': reason},
    );
    return Document.fromJson(response.data!['document'] as Map<String, dynamic>);
  }

  @override
  Future<List<Payment>> listPayments(String documentId) async {
    final response = await _dio.get<Map<String, dynamic>>('/documents/$documentId/payments');
    return (response.data!['payments'] as List).map((json) => Payment.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<Document> writeOff(String documentId, String reason) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/documents/$documentId/write-off',
      data: {'writeOffReason': reason},
    );
    return Document.fromJson(response.data!['document'] as Map<String, dynamic>);
  }

  @override
  Future<Document> reactivate(String documentId) async {
    final response = await _dio.post<Map<String, dynamic>>('/documents/$documentId/reactivate');
    return Document.fromJson(response.data!['document'] as Map<String, dynamic>);
  }

  @override
  Future<String> uploadPaymentReceipt(List<int> bytes, String filename) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/documents/payments/receipt',
      data: FormData.fromMap({'receipt': MultipartFile.fromBytes(bytes, filename: filename)}),
    );
    return response.data!['url'] as String;
  }
```

- [ ] **Step 5: Run it to confirm it passes**

```bash
flutter test test/features/documents/data/document_repository_impl_test.dart
```

Expected: PASS (16 tests).

- [ ] **Step 6: Write the failing `ReceivablesRepository` test**

```dart
// test/features/receivables/data/receivables_repository_impl_test.dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/receivables/data/receivables_repository_impl.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late ReceivablesRepositoryImpl repository;

  setUp(() {
    dio = _MockDio();
    repository = ReceivablesRepositoryImpl(dio);
  });

  test('list fetches and maps the outstanding invoices', () async {
    final options = RequestOptions(path: '/receivables');
    when(() => dio.get<Map<String, dynamic>>('/receivables')).thenAnswer(
      (_) async => Response(
        statusCode: 200,
        requestOptions: options,
        data: {
          'results': [
            {
              'id': 'd1',
              'number': 'INV-0001',
              'customerName': 'Acme',
              'total': 10000,
              'amountOwed': 4000,
              'dueDate': '2026-01-01',
              'daysOverdue': 12,
              'agingBucket': '0-30',
            },
          ],
          'total': 1,
        },
      ),
    );

    final results = await repository.list();

    expect(results.single.id, 'd1');
  });
}
```

- [ ] **Step 7: Run it to confirm it fails**

```bash
flutter test test/features/receivables/data/receivables_repository_impl_test.dart
```

Expected: FAIL — `receivables_repository_impl.dart` doesn't exist yet.

- [ ] **Step 8: Implement `ReceivablesRepository`**

```dart
// lib/features/receivables/domain/receivables_repository.dart
import 'outstanding_invoice.dart';

abstract class ReceivablesRepository {
  Future<List<OutstandingInvoice>> list();
}
```

```dart
// lib/features/receivables/data/receivables_repository_impl.dart
import 'package:dio/dio.dart';
import '../domain/outstanding_invoice.dart';
import '../domain/receivables_repository.dart';

class ReceivablesRepositoryImpl implements ReceivablesRepository {
  ReceivablesRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<OutstandingInvoice>> list() async {
    final response = await _dio.get<Map<String, dynamic>>('/receivables');
    return (response.data!['results'] as List)
        .map((json) => OutstandingInvoice.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
```

- [ ] **Step 9: Run it to confirm it passes**

```bash
flutter test test/features/receivables/data/receivables_repository_impl_test.dart
```

Expected: PASS (1 test).

- [ ] **Step 10: Analyze and commit**

```bash
flutter analyze
git add lib/features/documents/domain/document_repository.dart lib/features/documents/data/document_repository_impl.dart test/features/documents/data/document_repository_impl_test.dart lib/features/receivables/domain/receivables_repository.dart lib/features/receivables/data/ test/features/receivables/data/
git commit -m "feat: add payment, write-off, reactivate, receipt-upload, and receivables repositories"
```

---

### Task 3: Extend `describeDocumentActionError` with payment/write-off error codes

**Files:**
- Modify: `lib/features/documents/presentation/document_action_errors.dart`
- Modify: `test/features/documents/presentation/document_action_errors_test.dart`

**Interfaces:**
- Produces: the same `describeDocumentActionError` function, now also
  mapping `not_an_invoice`, `amount_exceeds_owed`, `already_voided`,
  `already_paid`, `not_written_off`, `subscription_required`.

- [ ] **Step 1: Write the failing test cases**

Add to the first test in `test/features/documents/presentation/document_action_errors_test.dart`
(inside the existing `'maps every known error code to its message'` test,
alongside the current expects):

```dart
    expect(describeDocumentActionError(_error('not_an_invoice')), 'Only invoices support this action');
    expect(
      describeDocumentActionError(_error('amount_exceeds_owed')),
      "That's more than what's owed on this invoice",
    );
    expect(describeDocumentActionError(_error('already_voided')), 'This payment was already voided');
    expect(describeDocumentActionError(_error('already_paid')), 'This invoice is already fully paid');
    expect(describeDocumentActionError(_error('not_written_off')), "This invoice hasn't been written off");
    expect(
      describeDocumentActionError(_error('subscription_required')),
      'Subscription required to record payments',
    );
```

- [ ] **Step 2: Run it to confirm it fails**

```bash
flutter test test/features/documents/presentation/document_action_errors_test.dart
```

Expected: FAIL — the new codes all fall through to the generic message.

- [ ] **Step 3: Add the new cases**

Add to the `switch` in `describeDocumentActionError`
(`lib/features/documents/presentation/document_action_errors.dart`),
before the `_ =>` fallback:

```dart
    'not_an_invoice' => 'Only invoices support this action',
    'amount_exceeds_owed' => "That's more than what's owed on this invoice",
    'already_voided' => 'This payment was already voided',
    'already_paid' => 'This invoice is already fully paid',
    'not_written_off' => "This invoice hasn't been written off",
    'subscription_required' => 'Subscription required to record payments',
```

- [ ] **Step 4: Run it to confirm it passes**

```bash
flutter test test/features/documents/presentation/document_action_errors_test.dart
```

Expected: PASS (3 tests, one with more expects than before).

- [ ] **Step 5: Analyze and commit**

```bash
flutter analyze
git add lib/features/documents/presentation/document_action_errors.dart test/features/documents/presentation/document_action_errors_test.dart
git commit -m "feat: map payment and write-off error codes to user-facing messages"
```

---

### Task 4: Payments section, Write-off, and Reactivate on `DocumentDetailScreen`

**Execute this task's code changes after Task 5, not before**, even
though it's numbered first: Task 4's implementation imports
`paymentMethodLabel` from Task 5's `record_payment_screen.dart`, so
writing Task 4's Step 3 before that file exists breaks compilation, not
just the intended "test fails for the right reason." Task 5 has no
dependency on Task 4 (its own Interfaces list only Task 1/Task 2/Phase
4a), so it's safe to build first. Task 4's *tests* can still be written
first if you want the red step recorded before Task 5's — only the
implementation step needs to wait.

**Files:**
- Modify: `lib/features/documents/presentation/screens/document_detail_screen.dart`
- Modify: `test/features/documents/presentation/screens/document_detail_screen_test.dart`

**Interfaces:**
- Consumes: `DocumentRepository.listPayments`/`.voidPayment`/`.writeOff`/`.reactivate`
  (Task 2), `Payment`/`PaymentMethod` (Task 1), `paymentMethodLabel` (Task 5).
- Produces: a "Payments" section (list + per-payment Void), a "Record
  Payment" button, Write-off/Reactivate actions.

Fetching payments unconditionally in `initState` (regardless of document
type) is deliberate and safe: the backend's `GET /:id/payments` has no
type restriction (only the mutating `POST` does), so it simply returns
an empty list for a non-invoice document — no special-casing needed, and
every existing test needs this call stubbed regardless of what type of
document it uses.

- [ ] **Step 1: Write the failing tests**

First, add a default stub to the existing top-level `setUp()` in
`test/features/documents/presentation/screens/document_detail_screen_test.dart`
(every existing test needs this or it'll hit a `MissingStubError` the
moment the screen's `initState` calls it):

```dart
  setUp(() {
    repository = _MockDocumentRepository();
    when(() => repository.get('d1')).thenAnswer((_) async => _document);
    when(() => repository.listPayments('d1')).thenAnswer((_) async => []);
  });
```

Add the new import:

```dart
import 'package:billa_mobile/features/documents/domain/payment.dart';
```

Then add these test cases:

```dart
  testWidgets('the Payments section lists recorded payments with a Void action', (tester) async {
    when(() => repository.get('d1')).thenAnswer((_) async => _document);
    when(() => repository.listPayments('d1')).thenAnswer((_) async => [
          const Payment(
            id: 'pay1',
            amount: 5000,
            method: PaymentMethod.cash,
            paidOn: '2026-01-05T00:00:00.000Z',
            createdAt: '2026-01-05T00:00:00.000Z',
          ),
        ]);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('RWF 5,000'), findsOneWidget);
    expect(find.text('Void'), findsOneWidget);
  });

  testWidgets('voiding a payment confirms with a reason and reloads', (tester) async {
    when(() => repository.get('d1')).thenAnswer((_) async => _document);
    when(() => repository.listPayments('d1')).thenAnswer((_) async => [
          const Payment(
            id: 'pay1',
            amount: 5000,
            method: PaymentMethod.cash,
            paidOn: '2026-01-05T00:00:00.000Z',
            createdAt: '2026-01-05T00:00:00.000Z',
          ),
        ]);
    when(() => repository.voidPayment('d1', 'pay1', 'Mistake')).thenAnswer((_) async => _document);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Void'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Mistake');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Void').last);
    await tester.pumpAndSettle();

    verify(() => repository.voidPayment('d1', 'pay1', 'Mistake')).called(1);
  });

  testWidgets('Record Payment appears for an unpaid finalized invoice and opens the record screen', (tester) async {
    const unpaidInvoice = Document(
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
      paymentStatus: PaymentStatus.unpaid,
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
    );
    when(() => repository.get('d1')).thenAnswer((_) async => unpaidInvoice);
    when(() => repository.listPayments('d1')).thenAnswer((_) async => []);
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => const DocumentDetailScreen(documentId: 'd1')),
      GoRoute(path: '/documents/:id/payments/new', builder: (context, state) => const Scaffold(body: Text('record payment screen'))),
    ]);

    await tester.pumpWidget(ProviderScope(
      overrides: [documentRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Record Payment'));
    await tester.pumpAndSettle();

    expect(find.text('record payment screen'), findsOneWidget);
  });

  testWidgets('Write off appears for an unpaid finalized invoice and succeeds with a reason', (tester) async {
    const unpaidInvoice = Document(
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
      paymentStatus: PaymentStatus.unpaid,
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
    );
    when(() => repository.get('d1')).thenAnswer((_) async => unpaidInvoice);
    when(() => repository.writeOff('d1', 'Bad debt')).thenAnswer(
      (_) async => unpaidInvoice.copyWith(paymentStatus: PaymentStatus.writtenOff),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Write off'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Bad debt');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Write off').last);
    await tester.pumpAndSettle();

    verify(() => repository.writeOff('d1', 'Bad debt')).called(1);
  });

  testWidgets('Reactivate appears for a written-off invoice and succeeds', (tester) async {
    const writtenOffInvoice = Document(
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
      paymentStatus: PaymentStatus.writtenOff,
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
    );
    when(() => repository.get('d1')).thenAnswer((_) async => writtenOffInvoice);
    when(() => repository.reactivate('d1')).thenAnswer(
      (_) async => writtenOffInvoice.copyWith(paymentStatus: PaymentStatus.unpaid),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reactivate'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reactivate').last);
    await tester.pumpAndSettle();

    verify(() => repository.reactivate('d1')).called(1);
  });
```

- [ ] **Step 2: Run it to confirm it fails**

```bash
flutter test test/features/documents/presentation/screens/document_detail_screen_test.dart
```

Expected: FAIL — every existing test now also fails on the unstubbed
`listPayments` call, and none of the new UI exists yet.

- [ ] **Step 3: Implement the Payments section and the two new actions**

Add these imports to `lib/features/documents/presentation/screens/document_detail_screen.dart`:

```dart
import '../../domain/payment.dart';
import 'record_payment_screen.dart' show paymentMethodLabel;
```

(`paymentMethodLabel` is defined in Task 5's `record_payment_screen.dart`,
a sibling file in this same `screens/` directory — matching how
`documentTypeLabel` lives in `document_list_tile.dart` and is imported
elsewhere with `show`.)

Add these fields and methods to `_DocumentDetailScreenState`:

```dart
  late Future<List<Payment>> _paymentsFuture;

  @override
  void initState() {
    super.initState();
    _future = _load();
    _paymentsFuture = _loadPayments();
  }

  Future<List<Payment>> _loadPayments() => ref.read(documentRepositoryProvider).listPayments(widget.documentId);

  void _reloadAll() => setState(() {
        _future = _load();
        _paymentsFuture = _loadPayments();
      });

  Future<String?> _promptText(String title, String label, String confirmLabel) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: label),
            autofocus: true,
            onChanged: (_) => setDialogState(() {}),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: controller.text.trim().isEmpty ? null : () => Navigator.pop(context, controller.text.trim()),
              child: Text(confirmLabel),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _voidPayment(String paymentId) async {
    final reason = await _promptText('Void this payment?', 'Reason', 'Void');
    if (reason == null) return;
    await _runAction(() async {
      await ref.read(documentRepositoryProvider).voidPayment(widget.documentId, paymentId, reason);
      _reloadAll();
    });
  }

  Future<void> _openRecordPayment(Document document) async {
    final recorded = await context.push<bool>('/documents/${document.id}/payments/new', extra: document);
    if (recorded == true) _reloadAll();
  }

  Future<void> _writeOff() async {
    final reason = await _promptText('Write off this invoice?', 'Reason', 'Write off');
    if (reason == null) return;
    await _runAction(() async {
      await ref.read(documentRepositoryProvider).writeOff(widget.documentId, reason);
      _reload();
    });
  }

  Future<void> _reactivate() async {
    if (!await _confirm('Reactivate this invoice?', 'This clears the write-off.', 'Reactivate')) return;
    await _runAction(() async {
      await ref.read(documentRepositoryProvider).reactivate(widget.documentId);
      _reload();
    });
  }
```

In `build()`, add these gate variables alongside the existing
`isDraft`/`isFinalized`/`isConvertible`/`colors`:

```dart
        final isInvoice = document.type == DocumentType.invoice;
        // Deliberately excludes writtenOff as well as paid — showing
        // Write-off and Reactivate at once for the same invoice would be
        // a contradictory pair of actions on screen at the same time.
        final hasOutstandingBalance =
            document.paymentStatus == PaymentStatus.unpaid || document.paymentStatus == PaymentStatus.partiallyPaid;
        final canRecordPayment = isFinalized && isInvoice && hasOutstandingBalance;
        final canWriteOff = isFinalized && isInvoice && hasOutstandingBalance;
        final canReactivate = document.paymentStatus == PaymentStatus.writtenOff;
```

Insert the Payments section right after the `referencedDocument` link
block and before the `_actionError` banner:

```dart
                if (isInvoice) ...[
                  const SizedBox(height: 24),
                  Text('Payments', style: Theme.of(context).textTheme.titleMedium),
                  FutureBuilder<List<Payment>>(
                    future: _paymentsFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: LoadingSkeleton(height: 40));
                      }
                      final payments = snapshot.data!;
                      if (payments.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('No payments recorded yet'),
                        );
                      }
                      return Column(
                        children: [
                          for (final payment in payments)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: MoneyText(payment.amount),
                              subtitle: Text(
                                '${paymentMethodLabel(payment.method)} · ${payment.paidOn.split('T').first}'
                                '${payment.voidedAt != null ? ' · Voided' : ''}',
                              ),
                              trailing: payment.voidedAt == null
                                  ? TextButton(onPressed: () => _voidPayment(payment.id), child: const Text('Void'))
                                  : null,
                            ),
                        ],
                      );
                    },
                  ),
                  if (canRecordPayment)
                    AppButton(
                      label: 'Record Payment',
                      isLoading: _actionInProgress,
                      onPressed: () => _openRecordPayment(document),
                    ),
                ],
```

Add Write-off/Reactivate to the action-button area, right after the
existing Share PDF/Send row:

```dart
                if (canWriteOff) ...[
                  const SizedBox(height: 8),
                  AppButton(label: 'Write off', isLoading: _actionInProgress, onPressed: _writeOff),
                ],
                if (canReactivate) ...[
                  const SizedBox(height: 8),
                  AppButton(label: 'Reactivate', isLoading: _actionInProgress, onPressed: _reactivate),
                ],
```

- [ ] **Step 4: Run it to confirm it passes**

```bash
flutter test test/features/documents/presentation/screens/document_detail_screen_test.dart
```

Expected: PASS (15 tests).

- [ ] **Step 5: Run the full suite, analyze, and commit**

```bash
flutter test
flutter analyze
git add lib/features/documents/presentation/screens/document_detail_screen.dart test/features/documents/presentation/screens/document_detail_screen_test.dart
git commit -m "feat: add payments section, write-off, and reactivate to the document detail screen"
```

---

### Task 5: `RecordPaymentScreen`

**Files:**
- Create: `lib/features/documents/presentation/screens/record_payment_screen.dart`
- Test: `test/features/documents/presentation/screens/record_payment_screen_test.dart`

**Interfaces:**
- Consumes: `DocumentRepository.recordPayment`/`.uploadPaymentReceipt`
  (Task 2), `PaymentInput`/`PaymentMethod` (Task 1), `Document` (Phase 4a).
- Produces: `class RecordPaymentScreen extends ConsumerStatefulWidget { const RecordPaymentScreen({required Document document}); }`,
  top-level `String paymentMethodLabel(PaymentMethod method)` (imported
  by Task 4's detail screen with `show`, the same pattern
  `documentTypeLabel` already established in `document_list_tile.dart`).

- [ ] **Step 1: Write the failing tests**

```dart
// test/features/documents/presentation/screens/record_payment_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/documents/domain/document.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/domain/document_repository.dart';
import 'package:billa_mobile/features/documents/domain/payment_input.dart';
import 'package:billa_mobile/features/documents/presentation/providers/document_repository_provider.dart';
import 'package:billa_mobile/features/documents/presentation/screens/record_payment_screen.dart';

class _MockDocumentRepository extends Mock implements DocumentRepository {}
class _FakePaymentInput extends Fake implements PaymentInput {}

const _customer = DocumentCustomerRef(name: 'Acme');
const _invoice = Document(
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
  amountPaid: 4000,
  paymentStatus: PaymentStatus.partiallyPaid,
  createdAt: '2026-01-01T00:00:00.000Z',
  updatedAt: '2026-01-01T00:00:00.000Z',
);

void main() {
  setUpAll(() {
    registerFallbackValue(_FakePaymentInput());
  });

  late _MockDocumentRepository repository;
  late GoRouter router;

  setUp(() {
    repository = _MockDocumentRepository();
  });

  Widget buildApp() {
    router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => const Scaffold(body: Text('detail screen'))),
      GoRoute(path: '/payment', builder: (context, state) => const RecordPaymentScreen(document: _invoice)),
    ]);
    return ProviderScope(
      overrides: [documentRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  testWidgets('defaults the amount to the outstanding balance', (tester) async {
    await tester.pumpWidget(buildApp());
    router.push('/payment');
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byKey(const Key('payment-amount')));
    expect(field.controller!.text, '6620'); // total 10620 - amountPaid 4000
  });

  testWidgets('records a payment and pops back on success', (tester) async {
    when(() => repository.recordPayment('d1', any())).thenAnswer((_) async => _invoice);

    await tester.pumpWidget(buildApp());
    router.push('/payment');
    await tester.pumpAndSettle();

    // Two problems with a plain text tap here: the AppBar title is also
    // "Record Payment" (ambiguous finder), and the button sits below the
    // fold of this long scrollable form (tap without scrolling first hits
    // nothing and no-ops with a hit-test warning rather than failing loud).
    await tester.ensureVisible(find.byKey(const Key('payment-submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('payment-submit')));
    await tester.pumpAndSettle();

    verify(() => repository.recordPayment('d1', any())).called(1);
    expect(find.text('detail screen'), findsOneWidget);
  });

  testWidgets('the generate-receipt checkbox defaults unchecked', (tester) async {
    await tester.pumpWidget(buildApp());
    router.push('/payment');
    await tester.pumpAndSettle();

    final checkbox = tester.widget<CheckboxListTile>(find.byType(CheckboxListTile));
    expect(checkbox.value, false);
  });

  testWidgets('picking a receipt photo opens a camera/gallery choice', (tester) async {
    await tester.pumpWidget(buildApp());
    router.push('/payment');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add receipt photo'));
    await tester.pumpAndSettle();

    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run it to confirm it fails**

```bash
flutter test test/features/documents/presentation/screens/record_payment_screen_test.dart
```

Expected: FAIL — `record_payment_screen.dart` doesn't exist yet.

- [ ] **Step 3: Implement `RecordPaymentScreen`**

```dart
// lib/features/documents/presentation/screens/record_payment_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/document.dart';
import '../../domain/document_enums.dart';
import '../../domain/payment_input.dart';
import '../document_action_errors.dart';
import '../providers/document_repository_provider.dart';

String paymentMethodLabel(PaymentMethod method) => switch (method) {
      PaymentMethod.cash => 'Cash',
      PaymentMethod.bankTransfer => 'Bank transfer',
      PaymentMethod.mobileMoney => 'Mobile Money',
      PaymentMethod.cheque => 'Cheque',
      PaymentMethod.other => 'Other',
    };

String _formatDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

class RecordPaymentScreen extends ConsumerStatefulWidget {
  const RecordPaymentScreen({super.key, required this.document});

  final Document document;

  @override
  ConsumerState<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends ConsumerState<RecordPaymentScreen> {
  late final _amountController =
      TextEditingController(text: (widget.document.total - widget.document.amountPaid).toString());
  final _notesController = TextEditingController();
  final _referenceController = TextEditingController();
  final _payerController = TextEditingController();
  PaymentMethod _method = PaymentMethod.cash;
  DateTime _paidOn = DateTime.now();
  bool _generateReceipt = false;
  String? _receiptImageUrl;
  bool _uploadingReceipt = false;
  bool _isSaving = false;
  String? _errorMessage;

  Future<void> _pickReceipt() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await ImagePicker().pickImage(source: source);
    if (picked == null) return;
    setState(() => _uploadingReceipt = true);
    try {
      final bytes = await File(picked.path).readAsBytes();
      final url = await ref.read(documentRepositoryProvider).uploadPaymentReceipt(bytes, picked.name);
      if (mounted) setState(() => _receiptImageUrl = url);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = describeDocumentActionError(e));
    } finally {
      if (mounted) setState(() => _uploadingReceipt = false);
    }
  }

  Future<void> _save() async {
    final amount = int.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = 'Enter an amount greater than zero');
      return;
    }
    setState(() {
      _errorMessage = null;
      _isSaving = true;
    });
    try {
      await ref.read(documentRepositoryProvider).recordPayment(
            widget.document.id,
            PaymentInput(
              amount: amount,
              method: _method,
              paidOn: _formatDate(_paidOn),
              notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
              referenceNumber: _referenceController.text.trim().isEmpty ? null : _referenceController.text.trim(),
              payerName: _payerController.text.trim().isEmpty ? null : _payerController.text.trim(),
              receiptImageUrl: _receiptImageUrl,
              generateReceipt: _generateReceipt,
            ),
          );
      if (mounted) context.pop(true);
    } catch (e) {
      setState(() => _errorMessage = describeDocumentActionError(e));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const Key('payment-amount'),
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<PaymentMethod>(
              initialValue: _method,
              decoration: const InputDecoration(labelText: 'Method'),
              items: [
                for (final method in PaymentMethod.values)
                  DropdownMenuItem(value: method, child: Text(paymentMethodLabel(method))),
              ],
              onChanged: (value) => setState(() => _method = value!),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Paid on ${_formatDate(_paidOn)}'),
              trailing: const Icon(Icons.calendar_today, size: 20),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _paidOn,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _paidOn = picked);
              },
            ),
            const SizedBox(height: 12),
            TextField(controller: _referenceController, decoration: const InputDecoration(labelText: 'Reference number (optional)')),
            const SizedBox(height: 12),
            TextField(controller: _payerController, decoration: const InputDecoration(labelText: 'Payer name (optional)')),
            const SizedBox(height: 12),
            TextField(controller: _notesController, decoration: const InputDecoration(labelText: 'Notes (optional)'), maxLines: 3),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_receiptImageUrl == null ? 'Add receipt photo' : 'Receipt photo attached'),
              trailing: _uploadingReceipt
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(_receiptImageUrl == null ? Icons.add_a_photo : Icons.check),
              onTap: _uploadingReceipt ? null : _pickReceipt,
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Generate a receipt document'),
              value: _generateReceipt,
              onChanged: (value) => setState(() => _generateReceipt = value ?? false),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(_errorMessage!),
            ],
            const SizedBox(height: 16),
            AppButton(
              key: const Key('payment-submit'),
              label: 'Record Payment',
              isLoading: _isSaving,
              onPressed: _save,
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
flutter test test/features/documents/presentation/screens/record_payment_screen_test.dart
```

Expected: PASS (4 tests).

- [ ] **Step 5: Re-run `DocumentDetailScreen`'s test now that its sibling import resolves**

Task 4's Step 3 already imported `paymentMethodLabel` from
`record_payment_screen.dart`; that file didn't exist yet at the time, so
confirm it all still compiles and passes now that it does.

```bash
flutter test test/features/documents/presentation/screens/document_detail_screen_test.dart
flutter analyze
```

Expected: PASS, no analyzer issues.

- [ ] **Step 6: Run the full suite, analyze, and commit**

```bash
flutter test
flutter analyze
git add lib/features/documents/presentation/screens/record_payment_screen.dart test/features/documents/presentation/screens/record_payment_screen_test.dart lib/features/documents/presentation/screens/document_detail_screen.dart
git commit -m "feat: add record payment screen with receipt photo capture"
```

---

### Task 6: `ReceivablesScreen`, home-nav entry, and router wiring

**Files:**
- Create: `lib/features/receivables/presentation/providers/receivables_repository_provider.dart`
- Create: `lib/features/receivables/presentation/widgets/aging_pill.dart`
- Create: `lib/features/receivables/presentation/screens/receivables_screen.dart`
- Test: `test/features/receivables/presentation/screens/receivables_screen_test.dart`
- Modify: `lib/app/router.dart`
- Modify: `test/app/router_test.dart`

**Interfaces:**
- Consumes: `ReceivablesRepository`/`OutstandingInvoice` (Tasks 1-2).
- Produces: routes `/receivables` and `/documents/:id/payments/new`; a
  4th home-nav button; `class ReceivablesScreen extends ConsumerStatefulWidget`.

- [ ] **Step 1: Write the failing screen test**

```dart
// test/features/receivables/presentation/screens/receivables_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/receivables/domain/outstanding_invoice.dart';
import 'package:billa_mobile/features/receivables/domain/receivables_repository.dart';
import 'package:billa_mobile/features/receivables/presentation/providers/receivables_repository_provider.dart';
import 'package:billa_mobile/features/receivables/presentation/screens/receivables_screen.dart';

class _MockReceivablesRepository extends Mock implements ReceivablesRepository {}

void main() {
  late _MockReceivablesRepository repository;

  setUp(() {
    repository = _MockReceivablesRepository();
  });

  Widget buildApp() {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => const ReceivablesScreen()),
      GoRoute(path: '/documents/:id', builder: (context, state) => const Scaffold(body: Text('detail screen'))),
    ]);
    return ProviderScope(
      overrides: [receivablesRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  testWidgets('shows an empty state when nothing is outstanding', (tester) async {
    when(() => repository.list()).thenAnswer((_) async => []);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Nothing outstanding — all invoices are paid up'), findsOneWidget);
  });

  testWidgets('shows each outstanding invoice with its aging bucket and navigates on tap', (tester) async {
    when(() => repository.list()).thenAnswer((_) async => [
          const OutstandingInvoice(
            id: 'd1',
            number: 'INV-0001',
            customerName: 'Acme',
            total: 10000,
            amountOwed: 4000,
            dueDate: '2026-01-01',
            daysOverdue: 12,
            agingBucket: '0-30',
          ),
        ]);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Acme'), findsOneWidget);
    expect(find.text('RWF 4,000'), findsOneWidget);

    await tester.tap(find.text('Acme'));
    await tester.pumpAndSettle();

    expect(find.text('detail screen'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run it to confirm it fails**

```bash
flutter test test/features/receivables/presentation/screens/receivables_screen_test.dart
```

Expected: FAIL — none of the new files exist yet.

- [ ] **Step 3: Implement the provider, aging pill, and screen**

```dart
// lib/features/receivables/presentation/providers/receivables_repository_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client_provider.dart';
import '../../data/receivables_repository_impl.dart';
import '../../domain/receivables_repository.dart';

final receivablesRepositoryProvider = Provider<ReceivablesRepository>((ref) {
  return ReceivablesRepositoryImpl(ref.watch(apiClientProvider).dio);
});
```

```dart
// lib/features/receivables/presentation/widgets/aging_pill.dart
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class AgingPill extends StatelessWidget {
  const AgingPill({super.key, required this.bucket});

  final String bucket;

  String get _label => switch (bucket) {
        'current' => 'Current',
        '0-30' => '0-30 days',
        '31-60' => '31-60 days',
        '61-90' => '61-90 days',
        _ => '90+ days',
      };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final (background, foreground) = switch (bucket) {
      'current' => (colors.neutral200, colors.neutral600),
      '0-30' || '31-60' => (colors.warningBg, colors.warning),
      _ => (colors.errorBg, colors.error),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(_label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: foreground)),
    );
  }
}
```

```dart
// lib/features/receivables/presentation/screens/receivables_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/money_text.dart';
import '../../domain/outstanding_invoice.dart';
import '../providers/receivables_repository_provider.dart';
import '../widgets/aging_pill.dart';

class ReceivablesScreen extends ConsumerStatefulWidget {
  const ReceivablesScreen({super.key});

  @override
  ConsumerState<ReceivablesScreen> createState() => _ReceivablesScreenState();
}

class _ReceivablesScreenState extends ConsumerState<ReceivablesScreen> {
  late Future<List<OutstandingInvoice>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<OutstandingInvoice>> _load() => ref.read(receivablesRepositoryProvider).list();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receivables')),
      body: FutureBuilder<List<OutstandingInvoice>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorState(
              message: "Couldn't load receivables",
              onRetry: () => setState(() {
                _future = _load();
              }),
            );
          }
          if (!snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Column(children: [LoadingSkeleton(height: 64), SizedBox(height: 12), LoadingSkeleton(height: 64)]),
            );
          }
          final invoices = snapshot.data!;
          if (invoices.isEmpty) {
            return const EmptyState(
              icon: Icons.check_circle_outline,
              message: 'Nothing outstanding — all invoices are paid up',
            );
          }
          return ListView.builder(
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              return ListTile(
                title: Text(invoice.customerName),
                subtitle: Text(
                  invoice.dueDate == null
                      ? (invoice.number ?? 'Draft')
                      : '${invoice.number ?? 'Draft'} · Due ${invoice.dueDate}',
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [MoneyText(invoice.amountOwed), const SizedBox(height: 4), AgingPill(bucket: invoice.agingBucket)],
                ),
                onTap: () => context.push('/documents/${invoice.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 4: Run it to confirm it passes**

```bash
flutter test test/features/receivables/presentation/screens/receivables_screen_test.dart
```

Expected: PASS (2 tests).

- [ ] **Step 5: Wire the routes and home-nav button in `router.dart`**

Add imports (`document.dart` is needed explicitly here — Dart doesn't
re-export a type just because another imported file happens to use it):

```dart
import '../features/documents/domain/document.dart';
import '../features/documents/presentation/screens/record_payment_screen.dart';
import '../features/receivables/presentation/screens/receivables_screen.dart';
```

Add routes (after the existing `/documents/:id` route):

```dart
      GoRoute(
        path: '/documents/:id/payments/new',
        builder: (context, state) => RecordPaymentScreen(document: state.extra as Document),
      ),
      GoRoute(path: '/receivables', builder: (context, state) => const ReceivablesScreen()),
```

Add a 4th button to `_PlaceholderHomeScreen`, after the existing
`home-nav-documents` button:

```dart
            const SizedBox(height: 12),
            ElevatedButton(
              key: const Key('home-nav-receivables'),
              onPressed: () => context.push('/receivables'),
              child: const Text('Receivables'),
            ),
```

- [ ] **Step 6: Add an end-to-end router test**

Add to `test/app/router_test.dart`:

```dart
import 'package:billa_mobile/features/receivables/domain/outstanding_invoice.dart';
import 'package:billa_mobile/features/receivables/domain/receivables_repository.dart';
import 'package:billa_mobile/features/receivables/presentation/providers/receivables_repository_provider.dart';
```

```dart
class _MockReceivablesRepository extends Mock implements ReceivablesRepository {}
```

```dart
  testWidgets('home screen navigates to receivables', (tester) async {
    final receivablesRepository = _MockReceivablesRepository();
    when(() => receivablesRepository.list()).thenAnswer((_) async => []);
    const business = Business(id: 'b1', name: 'Acme', onboardingCompletedAt: '2026-01-01T00:00:00.000Z');
    final container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(() => _FakeAuthController(const AuthStatus.authenticated(_user, business))),
      receivablesRepositoryProvider.overrideWithValue(receivablesRepository),
    ]);
    addTearDown(container.dispose);

    await _pumpRouter(tester, container);
    await tester.tap(find.byKey(const Key('home-nav-receivables')));
    await tester.pumpAndSettle();

    expect(find.text('Nothing outstanding — all invoices are paid up'), findsOneWidget);
  });
```

- [ ] **Step 7: Run the full suite, analyze, and commit**

```bash
flutter test
flutter analyze
git add lib/features/receivables/presentation/ test/features/receivables/presentation/ lib/app/router.dart test/app/router_test.dart
git commit -m "feat: add receivables screen and wire it into the router"
```

---

### Task 7: Final verification

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

Expected: every test from Tasks 1–6 passes, plus all of Phases 1–4c's existing tests still pass unchanged.

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
git commit -m "fix: resolve issues from phase 5 verification"
```

If nothing needed fixing, this step is a no-op.

---

## Definition of done for this plan

`flutter analyze` is clean, `flutter test` passes in full, `flutter build
apk --debug` succeeds, and a manual run shows: an unpaid finalized
invoice → Record Payment → amount defaults to the outstanding balance →
attach a receipt photo (camera or gallery) → optionally generate a
receipt document → submit → the invoice's Payments section shows the new
payment and its status pill updates → Void that payment with a reason →
it shows as voided and the invoice reverts to unpaid → Write off (with a
reason) → Reactivate clears it → separately, the home screen's new
Receivables button shows every outstanding invoice across all customers
with its aging bucket, and tapping one opens that invoice's existing
detail screen. Every failure path (amount exceeds owed, already voided,
already paid, not written off, subscription required) shows its specific
message with a working Retry.
