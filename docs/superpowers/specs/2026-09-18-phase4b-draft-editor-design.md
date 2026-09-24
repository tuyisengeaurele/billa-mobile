# Phase 4b: Draft Create/Edit Editor — Design

## Context

Phase 4a shipped read-only document browsing (list + detail) for all six
document types, deliberately with **no Edit or Finalize action** — those
were deferred to **4b** (draft create/edit editor) and **4c** (finalize,
PDF, send-by-email, conversion). This spec covers 4b: the ability to
create a new document as a draft and edit an existing draft, with the
totals always computed the same way the backend computes them.

The backend's exact contract for creating/updating documents was read
directly from the production `billa` repo (a sibling project on this
machine, not vendored into billa-mobile):

- `shared/src/document-schemas.ts` — the zod `documentSchema` used by both
  `POST /documents` and `PATCH /documents/:id` (same shape for both).
- `shared/src/document-types.ts` — `DOCUMENT_TYPES`, `DISCOUNT_TYPES` (
  `PERCENT` | `FLAT`), `DOCUMENT_LANGUAGES` (`EN` | `FR`).
- `server/src/lib/document-totals.ts` — the exact rounding algorithm for
  subtotal/tax/total, confirmed against `document-totals.test.ts`.
- `server/src/routes/documents.ts` — `resolveReferencedDocument`, which
  enforces that a `referencedDocumentId` must point at a `FINALIZED`
  `INVOICE` belonging to the *same customer* as the document being
  created/edited.
- `client/src/pages/DocumentForm.tsx` — the production web editor, whose
  autosave state machine and item-picker autofill/decouple behavior this
  spec deliberately mirrors rather than re-inventing.

Two decisions were made explicitly with the project owner rather than
assumed:

1. **Autosave**, matching the web app, rather than an explicit "Save
   draft" button.
2. **All six document types** are creatable from 4b, including a
   reference-document picker for Delivery Note/Receipt/Credit Note —
   not just the three standalone types (Invoice/Proforma/Quote).

## Non-goals

- **Finalize, PDF, send-by-email, proforma→invoice conversion** — all
  4c. A draft never becomes `FINALIZED` in this phase.
- **Recurrence** (`recurrenceSchema`, `recurrenceInterval`) — a
  scheduling feature nowhere in the 7-phase roadmap. The client never
  sends a `recurrence` field; the backend already treats it as fully
  optional and defaults recurrence fields to null when absent.
- **Changing a draft's `type` after creation.** `type` is fixed at
  creation time in this app's UI, even though the backend's schema would
  technically accept a changed `type` on `PATCH`. Changing your mind
  about the type means starting a new document.
- **Payments, `amountPaid`, write-off** — Phase 5.

## Entry points

- **List screen** (`DocumentListScreen`, from 4a) gains a
  `FloatingActionButton`. Tapping it opens a bottom sheet listing all six
  `DocumentType` values (reusing `documentTypeLabel` from 4a). Picking one
  pushes `/documents/new` with the chosen `DocumentType` passed via
  `extra`.
- **Detail screen** (`DocumentDetailScreen`, from 4a) gains an "Edit"
  action in the `AppBar`, shown only when `document.status ==
  DocumentStatus.draft` (a `FINALIZED` document 409s on `PATCH`, so the
  UI never offers an edit path that would fail). It pushes
  `/documents/:id/edit`.
- One `DocumentEditorScreen` serves both: constructed with a `type` (and
  no `documentId`) for a blank new document, or a `documentId` (and no
  `type`) to load and edit an existing draft.

## Data model additions

Two new *write-side* models, distinct from the *read-side* `Document`/
`DocumentLine` from 4a (which carry server-computed fields like `id`,
`lineTotal`, `sortOrder` that a create/update request never sends):

```dart
// lib/features/documents/domain/document_draft_input.dart
@freezed
class DocumentLineInput with _$DocumentLineInput {
  const factory DocumentLineInput({
    String? itemId,
    required String description,
    required double quantity,
    required int unitPrice,
    required double taxRate,
    DiscountType? discountType,
    double? discountValue,
  }) = _DocumentLineInput;

  factory DocumentLineInput.fromJson(Map<String, dynamic> json) =>
      _$DocumentLineInputFromJson(json);
}

@freezed
class DocumentDraftInput with _$DocumentDraftInput {
  const factory DocumentDraftInput({
    required DocumentType type,
    required String customerId,
    required String issueDate,
    String? dueDate,
    String? notes,
    String? customerReference,
    String? referencedDocumentId,
    @Default(DocumentLanguage.en) DocumentLanguage language,
    @Default([]) List<DocumentLineInput> lines,
  }) = _DocumentDraftInput;

  factory DocumentDraftInput.fromJson(Map<String, dynamic> json) =>
      _$DocumentDraftInputFromJson(json);
}
```

A new `DocumentLanguage` enum (`en`/`fr`) is added to `document_enums.dart`
alongside the existing four, following the exact same
`xFromJson`/`xToJson` pattern (`'EN'`/`'FR'` on the wire).

`DocumentDraftInput.toJson()` is the literal request body for both
`POST /documents` and `PATCH /documents/:id` — the backend uses the same
schema for both, so the client does too. `unitPrice` serializes as a
JSON *number* (not the decimal-string convention used for `Document`'s
read-side `Decimal` fields) because the backend accepts `unitPrice` as a
plain integer in the request body — confirmed against
`documents.create.test.ts`, which posts `unitPrice: 5000` as a number.
Likewise `quantity`/`taxRate`/`discountValue` are plain JSON numbers on
the way in, unlike their decimal-string form on the way out.

### Repository

```dart
abstract class DocumentRepository {
  Future<PaginatedResult<Document>> list({
    List<DocumentType>? types,
    DocumentStatus? status,
    String? search,
    String? customerId,      // new — additive, defaults to no filter
    int page = 1,
    int pageSize = 20,
  });
  Future<Document> get(String id);
  Future<Document> create(DocumentDraftInput input);          // new
  Future<Document> update(String id, DocumentDraftInput input); // new
}
```

`create`/`update` both unwrap the same `{document}` envelope `get`
already does, and return the full `Document` (so the newly-assigned `id`
and server-computed totals come back in one round trip — no separate
re-fetch needed after a save).

### Totals

The backend's rounding algorithm (`document-totals.ts`) is ported
verbatim so the on-screen total during editing always matches what the
server will persist:

```dart
// lib/features/documents/domain/document_totals.dart
class LineTotals {
  const LineTotals({required this.lineTotal, required this.taxAmount, required this.discountAmount});
  final int lineTotal;
  final int taxAmount;
  final int discountAmount;
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

  final subtotal = computed.fold(0, (sum, l) => sum + l.lineTotal);
  final taxTotal = computed.fold(0, (sum, l) => sum + l.taxAmount);
  return DocumentTotals(lines: computed, subtotal: subtotal, taxTotal: taxTotal, total: subtotal + taxTotal);
}
```

Tested against the same fixtures as the backend's own
`document-totals.test.ts` (plain line, percent discount, flat discount,
discount clamped to the line total, zero tax).

## Editor state & autosave

`DocumentEditorController` is a Riverpod `StateNotifier`, exposed as
`StateNotifierProvider.autoDispose.family<DocumentEditorController,
DocumentEditorState, DocumentEditorArgs>` where:

```dart
class DocumentEditorArgs {
  const DocumentEditorArgs.create(this.type) : documentId = null;
  const DocumentEditorArgs.edit(this.documentId) : type = null;
  final DocumentType? type;
  final String? documentId;
}

enum AutosaveStatus { idle, saving, saved, error }

class DocumentEditorState {
  // documentId (null until first successful save), draft fields,
  // List<_LineDraft> (each with a locally-generated key for widget
  // identity, independent of any server-assigned line id),
  // AutosaveStatus, and the live DocumentTotals recomputed on every
  // change.
}
```

`autoDispose` is safe here because leaving the screen always flushes a
pending save first (see below) — there's no scenario where the provider
disposes with unsaved changes still in flight.

**Autosave mechanics**, matching the web app's debounced approach:

- Every field or line change calls a `_scheduleAutosave()` that cancels
  any pending `Timer` and starts a fresh ~800ms one (the same debounce
  mechanism 4a's `PaginatedListController.setSearch` already uses, just
  a longer delay since this is a write, not a search).
- When the timer fires: if the draft isn't savable yet (no `customerId`,
  no `issueDate`, or a required `referencedDocumentId` missing for
  Receipt/Credit Note), it does nothing and stays `idle` — this is a
  normal "not ready yet" state, not an error.
- Otherwise: `create()` if `documentId` is still null (capturing the
  returned id for every subsequent save), `update(documentId)`
  otherwise.
- **No overlapping saves.** If the debounce fires while a save is already
  in flight, it doesn't start a second request — it sets a
  `_saveAgainAfterCurrent` flag and re-runs once the in-flight call
  settles. This is the one place a race would actually corrupt data (a
  double `create()` would silently produce two draft documents), so it's
  a hard guard, not best-effort.
- On failure, status becomes `AutosaveStatus.error` with the underlying
  message; the UI shows an inline "Couldn't save" row with a **Retry**
  button that re-triggers the save immediately (bypassing the debounce).
  No dead-end silent failures.
- **Leaving the screen** wraps the editor in `PopScope`: if a save is
  currently pending (debounce armed or a request in flight),
  `onPopInvokedWithResult` cancels the debounce, awaits the in-flight or
  a final immediate save, then pops programmatically. A fast back-swipe
  can't drop the last few keystrokes.

## Pickers

One reusable widget backs all three "search and pick one" needs, so the
behavior (and its tests) exist in one place:

```dart
// lib/core/widgets/search_picker_sheet.dart
Future<T?> showSearchPickerSheet<T>({
  required BuildContext context,
  required String title,
  required Future<List<T>> Function(String search) fetch,
  required Widget Function(T item) itemBuilder,
});
```

It's a modal bottom sheet: a search field on top, a debounced (300ms,
same as 4a's list search) async list below, tap-to-select pops the sheet
with the selected value.

- **Customer picker** — required header field. `fetch` calls
  `customerRepositoryProvider.list(search: ...)`.
- **Item picker** — per line. `fetch` calls
  `itemRepositoryProvider.list(search: ...)`. Selecting an item sets
  `itemId`, `description`, `unitPrice`, and `taxRate` on that line in one
  update. Manually editing the description afterward clears `itemId`
  (decouples the line from inventory) — this exact
  select-fills/edit-decouples behavior is lifted directly from
  `DocumentForm.tsx`'s `ItemPicker` usage.
- **Reference-document picker** — only shown for Delivery Note/Receipt/
  Credit Note, and only enabled once a customer is chosen (it needs
  `customerId` to filter). `fetch` calls
  `documentRepositoryProvider.list(types: [DocumentType.invoice], status:
  DocumentStatus.finalized, customerId: customerId, search: ...)` — this
  mirrors `resolveReferencedDocument`'s server-side check exactly (must
  be a finalized invoice for the same customer), so the picker can never
  offer a choice the server would reject with `referenced_document_*`.
  If the customer is changed after a reference was already picked and
  the reference no longer belongs to the new customer, the reference is
  cleared and the field shows as required-but-empty again.

## Screen layout

`DocumentEditorScreen` (single `ConsumerStatefulWidget`, wrapped in
`PopScope` as above):

- App bar: document type label (e.g. "New Invoice" / "Edit Invoice"), and
  an autosave status indicator (small text: nothing when `idle`,
  "Saving…" spinner, "Saved" checkmark that fades, "Couldn't save · Retry"
  on error).
- Customer field (tap opens the customer picker) — required.
- Issue date (date picker, defaults to today), due date (optional date
  picker).
- Reference-document field — only rendered when `type` is Delivery Note/
  Receipt/Credit Note; required for Receipt/Credit Note, optional for
  Delivery Note.
- Customer reference, notes — optional text fields.
- Language — a two-option segmented control (EN/FR), defaulting to EN.
- Line items: a card per line (description/item-picker trigger, discount
  row, quantity/unit price/tax fields, per-line total), an "Add line"
  button, swipe-to-remove per line.
- Totals footer: subtotal, tax, total — computed live via
  `calculateDocumentTotals`, using the existing `MoneyText` widget so it
  reads identically to the detail screen from 4a.

## Validation

Client-side checks mirror `documentSchema`/`documentLineSchema` exactly,
shown inline as the user types (not just on save attempt):

- `customerId` required ("Choose a customer").
- `issueDate` required.
- `referencedDocumentId` required when `type` is Receipt or Credit Note
  ("Choose the invoice this document is for").
- Per line: `description` required, `quantity > 0`, `unitPrice` a
  non-negative integer, `taxRate` between 0 and 100, `discountValue`
  non-negative and (when `discountType` is percent) at most 100.

These same rules gate autosave (an invalid draft simply doesn't attempt
to save yet, per the autosave section above) — validation and
save-readiness are the same check, not two parallel implementations.
Any 400 the server still returns (e.g. a race on a since-deleted
customer) is caught and surfaced as a save error via the same
`AutosaveStatus.error` path, not a separate error UI.

## Testing strategy

Following this project's established TDD rhythm (write failing test,
confirm fail, implement, confirm pass, commit), one task at a time:

1. `DocumentLanguage` enum + `DocumentLineInput`/`DocumentDraftInput`
   models + JSON round-trip tests.
2. `calculateDocumentTotals` unit tests (ported from the backend's own
   fixtures).
3. `DocumentRepository.create`/`update`/`list(customerId: ...)` +
   repository tests (mocked `Dio`, same pattern as 4a's
   `document_repository_impl_test.dart`).
4. `DocumentEditorController` unit tests: debounced autosave fires
   create-then-update, no-overlap guard under a slow first save, error
   sets `AutosaveStatus.error`, save-readiness gating.
5. `SearchPickerSheet` widget tests: search debounce, tap-to-select
   returns the value.
6. `DocumentEditorScreen` widget tests: customer/item/reference pickers
   wire into the controller, validation messages appear, totals update
   live, `PopScope` flushes a pending save before popping.
7. Router wiring (`/documents/new`, `/documents/:id/edit`) + FAB on the
   list screen + conditional Edit button on the detail screen, with
   `router_test.dart` additions.
8. Final verification: `flutter analyze`, `flutter test`, `flutter build
   apk --debug`.
