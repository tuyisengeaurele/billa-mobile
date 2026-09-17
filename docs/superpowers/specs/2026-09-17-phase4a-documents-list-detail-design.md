# Phase 4a: Documents — List and Detail (Read-Only) — Design

## Context

Phase 4 ("Documents, the heart of the app" per the founding brief) is split into
three sub-projects, each with its own spec/plan/PR: **4a** (this one — list and
detail, read-only), **4b** (draft create/edit editor), **4c** (finalize, PDF,
email, proforma→invoice conversion). This split mirrors how Phases 1–3 were
sized, and follows real dependency order: the read side needs to exist and be
correct before the editor (4b) is testable end-to-end, and a working draft
needs to exist before finalize/PDF/email (4c) make sense.

This branch stacks on the still-unmerged `phase3-customers-items`, since it
reuses that phase's generic `PaginatedListController`/`PaginatedResult` core
directly.

## Facts this design depends on

Confirmed by reading `server/src/routes/documents.ts`'s list/detail handlers,
`shared/src/document-schemas.ts`, `shared/src/document-types.ts`, and real
test fixtures — not the Prisma schema alone, since decimal serialization is
easy to get wrong from the schema by itself:

- **`DocumentLine.quantity`, `taxRate`, and `discountValue` are JSON
  strings** (e.g. `"2.00"`, `"18.00"`), not numbers — Prisma `Decimal`
  columns serialize via `.toString()` with no custom mapper anywhere in the
  backend. `unitPrice`, `lineTotal`, `sortOrder` (`DocumentLine`) and
  `subtotal`, `taxTotal`, `total`, `amountPaid` (`Document`) are plain SQL
  integers and serialize as JSON numbers. Confirmed against
  `documents.create.test.ts` (`Number(res.body.document.lines[0].discountValue)`
  only makes sense if that field is a string) and `DocumentForm.tsx`'s own
  response type (`quantity: string | number`).
- **List rows and the detail response share one shape** — list rows simply
  lack `lines`, `convertedFrom`, `convertedTo`, `referencedDocument` (not
  present as keys at all, not null-but-present), since only the detail
  handler's `include` selects those relations. Both include `customer` as
  `{ name, email }` — **no `customer.id`** on either list or detail.
- **`referencingDocuments` does not exist on the wire.** It's a real Prisma
  relation but no route selects it — dropped entirely from the model rather
  than modeled as always-empty.
- **`convertedFrom`/`convertedTo`/`referencedDocument`** are each either
  `{ id, number, type }` or `null`. The scalar FKs `convertedFromId` and
  `referencedDocumentId` are also present alongside their nested
  counterparts (ordinary Prisma output). There is no `convertedToId` scalar
  column — only the nested `convertedTo` object.
- **Dates are full ISO datetime strings** (`"2026-08-19T00:00:00.000Z"`) on
  list/detail, confirmed by fixtures that `.slice(0, 10)` them to get just
  the date portion. (The CSV-export and reports endpoints format dates
  differently server-side, but that's out of scope here.)
- **List query params** (`documentListQuerySchema`): `type` (comma-separated
  `DocumentType` list), `search` (matches `document.number` OR
  `customer.name`), `status` (`DRAFT`/`FINALIZED`), `sortBy` (exactly
  `issueDate` | `total` | `createdAt` — not `dueDate` or `status`),
  `sortOrder`, `page`, `pageSize`. `customerId`/`dateFrom`/`dateTo` also
  exist server-side but aren't built into 4a's UI — the founding brief's own
  scope for this phase is "filterable by type and status" only.
- **Enums** (`shared/src/document-types.ts`, verbatim):
  `DOCUMENT_TYPES = [INVOICE, PROFORMA, DELIVERY_NOTE, QUOTE, RECEIPT, CREDIT_NOTE]`,
  `DOCUMENT_STATUSES = [DRAFT, FINALIZED]`,
  `INVOICE_PAYMENT_STATUSES = [UNPAID, PARTIALLY_PAID, PAID, WRITTEN_OFF]` (nullable
  on `Document` — null until an invoice is finalized/paid/written off),
  `DISCOUNT_TYPES = [PERCENT, FLAT]`. `template`/`language` exist but 4a
  never branches on them — kept as raw strings, not modeled as enums.

## Architecture

```
lib/
  features/documents/
    domain/
      document.dart              # freezed: Document, DocumentLine, DocumentRef,
                                  # DocumentCustomerRef, DocumentType, DocumentStatus,
                                  # PaymentStatus, DiscountType
      document_repository.dart   # interface
    data/
      document_repository_impl.dart
    presentation/
      providers/
        document_repository_provider.dart
        document_list_controller.dart   # extends Phase 3's PaginatedListController<Document>
      screens/
        document_list_screen.dart
        document_detail_screen.dart
      widgets/
        document_list_tile.dart
        document_status_pill.dart        # shared by list tile and detail screen
```

### Domain model

One `Document` model, not split by list/detail — matching the API's own
behavior: fields present on both (`id`, `type`, `number` (nullable — null
until finalized), `status`, `customerId`, `customer`, `issueDate`, `dueDate`,
`notes`, `customerReference`, `subtotal`, `taxTotal`, `total`, `sentAt`,
`amountPaid`, `paymentStatus`, `writtenOffAt`, `writeOffReason`, `createdAt`,
`updatedAt`, `convertedFromId`, `referencedDocumentId`) plus detail-only
relations that default to absent on list rows (`lines` → `@Default([])`,
`convertedFrom`/`convertedTo`/`referencedDocument` → nullable, default
`null`).

`DocumentType`, `DocumentStatus`, `PaymentStatus`, `DiscountType` are plain
Dart enums with lower-camel-case values (`invoice`, `deliveryNote`, …) and
explicit `fromJson`/`toJson` extension methods mapping to the backend's
`SCREAMING_CASE` strings — not `@JsonEnum`/`JsonValue` codegen, to keep the
mapping visible and avoid a lint fight over non-camel-case enum names.

`quantity`, `taxRate`, `discountValue` on `DocumentLine` parse from their
JSON string form into `double` (via `double.parse`) in `fromJson` — needed
as real numbers for 4b's live-total math later, not just display here.

### Repository and list controller

`DocumentRepository`: `Future<PaginatedResult<Document>> list({List<DocumentType>? types, DocumentStatus? status, String? search, int page, int pageSize})`,
`Future<Document> get(String id)`. `DocumentListController extends PaginatedListController<Document>`
(Phase 3's generic base) — same debounced-search/includeInactive-shaped
mechanics, except the "extra filter" here is `types`/`status` instead of
Item's `category`, following the same pattern `ItemListController`
established for `setCategory`.

### Screens

`/documents`: type filter chips (multi-select, matching the six
`DocumentType` values), a status toggle (All / Draft / Finalized), search,
infinite scroll, `EmptyState`/`ErrorState` — structurally identical to
Phase 3's list screens. Each row shows type + number-or-"Draft", customer
name, total (`MoneyText`), and a status pill (shared `DocumentStatusPill`
widget, reused on the detail screen).

`/documents/:id`: customer, issue/due dates, a line-items table (description,
quantity, unit price, tax rate, line total — all tabular figures), discount
shown per line when present (`"10% off"` or `"1,000 RWF off"` depending on
`discountType`), subtotal/tax/total, the status pill, and — when present —
a tappable link to the converted-from/to document or the referenced
document (navigating to that document's own detail route). **Deliberately
no Edit or Finalize action** — those don't exist until 4b/4c, and a button
that goes nowhere is exactly what the founding brief's non-negotiables rule
out.

Home screen gains a third nav button, "Documents".

## Error handling

Same pattern as Phase 3: `ErrorState` with retry replacing the list/detail
body on failure, never a toast over stale content. `EmptyState` ("No
documents yet") only when zero results with no filters active; a
search/filter with no matches gets an inline "no results" message instead.

## Testing

- `Document`/`DocumentLine` model tests covering the string-decimal parsing
  (`quantity`/`taxRate`/`discountValue`) and the list-row-shape (missing
  `lines`/`convertedFrom`/etc. defaulting correctly rather than throwing).
- `DocumentRepositoryImpl` unit tests against a mocked `Dio`: list query
  params (including the comma-joined `type` list), detail parsing including
  a populated and a null `convertedFrom`/`referencedDocument`.
- `DocumentListController` — reuses Phase 3's `PaginatedListController` test
  coverage by construction; only its own `setTypes`/`setStatus` filter
  methods need new tests.
- Widget tests: empty state, a document row's status pill and total
  rendering, and the detail screen's line-items table with a discount
  applied.

## Out of scope for this phase

Create/edit draft (4b). Finalize, PDF, send-by-email, proforma→invoice
conversion (4c). Payments/write-off/receivables (Phase 5 — already
established). `customerId`/`dateFrom`/`dateTo` list filters (server
supports them; no UI for them yet — the founding brief's own scope for this
phase is type + status only). CSV export.
