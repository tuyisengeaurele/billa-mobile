# Phase 5: Payments/Receivables — Design

## Context

Phase 4 made documents end-to-end usable (browse, create/edit, finalize/
PDF/send/convert), but a finalized invoice has no way to record that it
got paid, no way to see who owes money across the whole business, and no
way to correct a mistaken payment or write off a bad debt. Phase 5 closes
that.

As with every prior phase, the backend's exact contract was read
directly from the `billa` repo (a sibling project on this machine, not
vendored into billa-mobile):

- `server/src/routes/documents.ts` — `POST /:id/payments`
  (`createPaymentSchema`: amount/method/paidOn required, notes/
  referenceNumber/payerName/receiptImageUrl/generateReceipt optional;
  404, 400 `not_an_invoice`, 409 `not_finalized`, 400
  `amount_exceeds_owed`; returns `{payment, document}` — both the new
  payment and the invoice with its updated `amountPaid`/`paymentStatus`
  in one response), `POST /:id/payments/:paymentId/void`
  (`voidPaymentSchema`: `voidReason` required; 404, 409
  `already_voided`; returns `{document}`), `GET /:id/payments` (returns
  `{payments}`, ordered by `paidOn` descending), `POST /:id/write-off`
  (`writeOffInvoiceSchema`: `writeOffReason` required; 404, 400
  `not_an_invoice`, 409 `already_paid`), `POST /:id/reactivate` (404, 409
  `not_written_off`).
- `server/src/routes/documents.payment-receipt-upload.test.ts` —
  `POST /documents/payments/receipt`, a multipart upload (`receipt`
  field) returning `{url}` — a single-step upload, confirmed against the
  test's own PNG fixture.
- `server/src/routes/receivables.ts` + `server/src/lib/
  accounts-receivable.ts` — `GET /receivables`, returning outstanding
  `FINALIZED` invoices (`paymentStatus` unpaid or partially-paid) with
  `amountOwed` already computed server-side (invoice total minus
  finalized credit notes against it minus `amountPaid`), sorted by due
  date, plus each invoice's `daysOverdue`/`agingBucket` (`current`,
  `0-30`, `31-60`, `61-90`, `90+`).
- `server/src/middleware/require-active-subscription.ts` — blocks
  mutating requests (never `GET`) once a business's trial/subscription
  has lapsed, with 402 `subscription_required`. Applies to record/void/
  write-off/reactivate, never to `GET /receivables` or `GET .../payments`.
- `Prisma.InvoicePayment` — the model behind a payment record; includes
  a `momoPaymentRequestId` link that this phase deliberately never
  surfaces (see Non-goals).

One decision was made explicitly with the project owner:

- **Stay one phase**, not split into 5a/5b the way Phase 4 was. Most of
  this work repeats the one-shot-action-plus-error-mapping shape Phase
  4c already proved for finalize/convert/send/delete; the receivables
  screen is the only genuinely new UI type, and it's a single read-only
  list — not enough on its own to justify a second stacked branch.

## Non-goals

- **MoMo payment requests.** `InvoicePayment.momoPaymentRequestId` links
  a payment back to a Mobile-Money request, but that request is
  initiated by the *customer* from the public document link
  (`public-documents.momo.test.ts`), not by the business user from this
  app — same reasoning as 4c's exclusion of the public decline flow. The
  field is never modeled or displayed.
- **Precise `amount_exceeds_owed` pre-validation.** The server subtracts
  finalized credit notes issued against the invoice when computing what's
  owed; the app has no way to see those (`DocumentRepository.list()` has
  no `referencedDocumentId` filter, and the backend's own
  `documentListQuerySchema` doesn't expose one either — adding it would
  be a new backend capability, out of scope for a mobile-only phase). The
  payment form soft-caps its amount field at `total - amountPaid`
  (ignoring credit notes, a rare case) and trusts the server's mapped
  error message as the real authority.
- **Any billing/subscription-management UI.** A lapsed trial's 402 is
  surfaced as a clear message, not a checkout flow — there is no billing
  UI anywhere in this app yet, and building one is out of scope here.
- **The dashboard/summary endpoint** (`GET /dashboard/summary`) — a much
  larger, unrelated home-screen-overview feature (drafts, expiring
  quotes, revenue trends, activity feed) that was never part of this
  phase's named scope ("Payments/receivables").

## Domain & repository additions

`PaymentMethod` is a new enum (`cash`/`bankTransfer`/`mobileMoney`/
`cheque`/`other`), added alongside the existing `DocumentType`/
`DocumentStatus`/`PaymentStatus`/`DiscountType`/`DocumentLanguage` in
`document_enums.dart`, following the same `xFromJson`/`xToJson` pattern.
`PaymentStatus` (unpaid/partially-paid/paid/written-off) already exists
from Phase 4a and needs no changes.

A new `Payment` read model and `PaymentInput` write model:

```dart
// lib/features/documents/domain/payment.dart
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

// lib/features/documents/domain/payment_input.dart
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

`amount`/`unitPrice`-style fields stay plain JSON numbers on write, same
reasoning as `DocumentDraftInput` in Phase 4b (the backend's zod schema
accepts a plain number, unlike the decimal-string convention Prisma's
`Decimal` fields use elsewhere in *responses* — not applicable here since
`InvoicePayment.amount` is a Prisma `Int`, matching `Document.unitPrice`).

An `OutstandingInvoice` read model for the receivables list:

```dart
// lib/features/receivables/domain/outstanding_invoice.dart
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

### Repository placement

Payment actions join `DocumentRepository`, matching their URL nesting
under `/documents/...` — the same reasoning that put `finalize`/
`convert`/`send` there in Phase 4c:

```dart
abstract class DocumentRepository {
  // ...existing members unchanged...
  Future<Document> recordPayment(String documentId, PaymentInput input); // {payment, document} -> returns document
  Future<Document> voidPayment(String documentId, String paymentId, String reason);
  Future<List<Payment>> listPayments(String documentId);
  Future<Document> writeOff(String documentId, String reason);
  Future<Document> reactivate(String documentId);
  Future<String> uploadPaymentReceipt(List<int> bytes, String filename); // -> url
}
```

`recordPayment` returns the updated `Document` (not the new `Payment`)
because every call site immediately needs the refreshed
`amountPaid`/`paymentStatus` to redraw the detail screen, and the screen
reloads its payments list separately right after — so the response's
`payment` object is unwrapped and discarded, not modeled as a second
return value the caller has to juggle.

Receivables gets its own small repository, since `GET /receivables` is
a top-level resource, not nested under documents:

```dart
// lib/features/receivables/domain/receivables_repository.dart
abstract class ReceivablesRepository {
  Future<List<OutstandingInvoice>> list();
}
```

## Screen changes

**`DocumentDetailScreen`** (Phase 4a-4c) gains a "Payments" section,
placed between the existing convertedFrom/convertedTo/referencedDocument
links and the action-button row, shown whenever `document.type ==
invoice`:

- Each payment in `document`'s freshly-`listPayments`-loaded list: date,
  amount, method label, notes if present, and — for a payment that isn't
  already voided — a "Void" text action that opens a reason-prompt
  dialog then calls `voidPayment`.
- A "Record Payment" button, shown when `isFinalized && type == invoice
  && paymentStatus is unpaid or partiallyPaid` (i.e., there's something
  left to collect), pushing `/documents/:id/payments/new`.
- **Write-off** / **Reactivate** join the existing action row (Finalize/
  Convert/Share/Send from 4c): Write-off shown when `isFinalized && type
  == invoice && paymentStatus != paid` (confirmed via a required-reason
  dialog, matching the `writeOffReason` field), Reactivate shown when
  `paymentStatus == writtenOff`.

Payments load via a second `Future` (`_paymentsFuture`, loaded alongside
`_future` in `initState`/reload) rather than folding them into the
existing document-load future — a payment list failing to load
shouldn't block rendering the invoice itself, and reloading after a
void/record only needs to refresh payments, not necessarily re-run
`_load()` for the whole document every time (though in practice this
phase reloads both together for simplicity, per the pattern below).

**`RecordPaymentScreen`** (new, reached via `/documents/:id/payments/new`,
constructed with the invoice's already-loaded `Document` passed via
`extra` — the same way `CustomerFormScreen`/`ItemFormScreen` already
receive their existing model, and it avoids a redundant fetch of a
document the detail screen already has in hand): amount (soft-capped
using the passed-in `total`/`amountPaid`, numeric),
method (dropdown over the four `PaymentMethod` values), paid-on date
picker (defaults to today), notes/reference number/payer name (optional
text fields), a receipt-photo picker (camera or gallery via a bottom
sheet, uploaded through `uploadPaymentReceipt` before the payment is
submitted, so `receiptImageUrl` is already known by the time
`recordPayment` is called), and a "Generate a receipt document" checkbox
(defaults unchecked, matching the backend's own default). A single
"Record Payment" `AppButton` submits; on success it pops back to the
detail screen, which reloads both the document and its payments.

**`ReceivablesScreen`** (new, reached via a 4th home-nav button
alongside Customers/Items/Documents): a plain list (no search/filter for
v1 — outstanding-invoice counts are small enough for most of this app's
target businesses that a flat sorted list is sufficient), each row
showing the customer name, invoice number, `MoneyText(amountOwed)`, due
date, and a small aging-bucket pill (a new, purpose-built widget, since
`DocumentStatusPill` is typed to `DocumentStatus`/`PaymentStatus`, not a
generic bucket string — built from the same `AppColors` tokens
`DocumentStatusPill` already uses: neutral for `current`, escalating
through `warningBg`/`warning` to `errorBg`/`error` as the bucket ages).
Tapping a row pushes
`/documents/:id` — reusing the existing `DocumentDetailScreen` rather
than building a second read view.

## Error mapping

Extends Phase 4c's existing `describeDocumentActionError` (same
function, more `switch` cases — not a parallel helper, since both
document actions and payment actions throw the same `DioException`
shape with the same `{error: code}` body):

```dart
    'not_an_invoice' => 'Only invoices support this action',
    'amount_exceeds_owed' => "That's more than what's owed on this invoice",
    'already_voided' => 'This payment was already voided',
    'already_paid' => 'This invoice is already fully paid',
    'not_written_off' => "This invoice hasn't been written off",
    'subscription_required' => 'Subscription required to record payments',
```

## Testing strategy

Following the established TDD rhythm, one task at a time:

1. `PaymentMethod` enum + `Payment`/`PaymentInput`/`OutstandingInvoice`
   models + JSON round-trip tests.
2. `DocumentRepository` payment/write-off/reactivate/receipt-upload
   methods + repository tests (mocked `Dio`, same pattern as every prior
   phase's `document_repository_impl_test.dart`); `ReceivablesRepository`
   + its own repository test.
3. `describeDocumentActionError`'s new cases — extend the existing test
   file with the new codes.
4. `DocumentDetailScreen`'s Payments section + Write-off/Reactivate
   actions — widget tests for each gate condition and each action's
   success path.
5. `RecordPaymentScreen` — widget tests for the amount soft-cap, the
   receipt-photo picker (camera/gallery choice shown, upload called
   before submit), the generate-receipt checkbox, and successful submit
   navigating back.
6. `ReceivablesScreen` + its home-nav button + router wiring — widget
   tests for the empty state, row rendering with aging tags, and
   tap-through to the detail screen; a `router_test.dart` case
   end-to-end through the real `appRouterProvider`, matching the pattern
   every prior phase's Task 7/8 established.
7. Final verification: `flutter analyze`, `flutter test`, `flutter build
   apk --debug`.
