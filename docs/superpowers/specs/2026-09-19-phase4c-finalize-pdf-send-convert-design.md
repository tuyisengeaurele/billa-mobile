# Phase 4c: Finalize, PDF, Send, Conversion — Design

## Context

Phases 4a/4b shipped read-only document browsing and a draft create/edit
editor. Every document created so far is stuck as a permanently-editable
draft with no number, no PDF, no way to email it, and (for proformas and
quotes) no way to turn it into an invoice. Phase 4c closes that: finalize
(assigns a permanent number, locks editing), PDF generation, emailing a
document to the customer, and proforma/quote → invoice conversion.

As with 4a/4b, the backend's exact contract was read directly from the
`billa` repo (a sibling project on this machine, not vendored into
billa-mobile):

- `server/src/lib/finalize-document.ts` — `finalizeDocumentById`: 404 if
  missing, 409 `already_finalized`, 400 `no_lines` if the document has no
  lines, otherwise atomically assigns the next sequence number and sets
  `status: FINALIZED`.
- `server/src/middleware/require-finalize-permission.ts` — when a
  business has opted into `requireApprovalToFinalize`, only the business
  owner can finalize; everyone else gets 403 `finalize_requires_approval`.
  Off by default, so most businesses never see this.
- `server/src/lib/convert-proforma.ts` — `convertProformaToInvoice`: only
  `PROFORMA`/`QUOTE` are convertible (400 `not_convertible`), the source
  must be `FINALIZED` (409 `not_finalized`), and it 409s with
  `already_converted`/`already_declined` if either already happened.
  Creates a new `DRAFT` invoice with `convertedFromId` set, lines copied,
  notes carried over, and a 30-day default due date.
- `server/src/routes/documents.ts` — `POST /:id/send` (404, 409
  `not_finalized`, 400 `customer_has_no_email`, 500 `pdf_render_failed`,
  502 `email_send_failed`; returns `{sentAt}`), `GET /:id/pdf` (returns
  raw PDF bytes, cookie-authenticated — no public/unauthenticated
  variant), `DELETE /:id` (404, 409 `already_finalized`, else 204).

Two decisions were made explicitly with the project owner:

1. **PDF handling** is download-bytes-then-native-share (`share_plus`),
   not "open in an external browser" — the PDF endpoint requires the same
   cookie session the app already holds, which a system browser tab
   doesn't have.
2. **Delete-draft** is in scope for this phase, even though it wasn't in
   the original phase wording — the backend already supports it
   (`DELETE /:id`, 409 once finalized) and today there is no way at all
   to remove an unwanted draft from the app.

## Non-goals

- **The public/customer-facing decline flow.** `declineDocument` and the
  public "accept via convert" path live behind `public-documents.ts`'s
  token-based routes, triggered by the *customer* from an emailed link —
  not something the business user does from this app. If a quote was
  declined by a customer, this phase does not add a dedicated indicator
  for it; the generic error-mapping below already surfaces
  `already_declined` gracefully if a convert attempt ever hits it.
- **`requireApprovalToFinalize`'s underlying approval workflow** (letting
  a business turn the setting on, or a non-owner request approval) — this
  phase only handles the 403 a non-owner gets today. Managing the setting
  itself is an account-settings concern, not a document-detail concern.
- **Overdue/expiry reminder toggling** (`PATCH /:id/reminders`,
  `POST /overdue/send-reminders`) and **recurring documents** — cron-job
  driven backend features unrelated to the four actions this phase adds.
- **Payments, write-off, reactivate** — Phase 5.

## Domain & repository additions

No new read-side fields are needed — `Document.convertedTo`/
`convertedFrom`/`sentAt` already exist from Phase 4a, and that's enough
to gate every button in this phase without an extra round trip.

`DocumentRepository` gains four one-shot calls and a byte-fetch, each a
thin wrapper over its endpoint — no new domain models, since none of
these responses need anything beyond the existing `Document`:

```dart
abstract class DocumentRepository {
  // ...existing members unchanged...
  Future<Document> finalize(String id);
  Future<Document> convert(String id);
  Future<String> send(String id); // returns the new sentAt
  Future<void> delete(String id);
  Future<List<int>> fetchPdfBytes(String id);
}
```

`finalize`/`convert` both unwrap the same `{document}` envelope
`get`/`create`/`update` already do. `send` unwraps `{sentAt}`. `delete`
expects a 204 with no body. `fetchPdfBytes` requests with
`responseType: ResponseType.bytes` and returns `response.data`.

These are simple enough — one request, one refresh — that they don't
need a dedicated Riverpod controller. `DocumentDetailScreen` already owns
a `Future<Document> _future` and a `setState`-driven reload
(`_future = _load()`); this phase adds a `_actionError` string and an
`_actionInProgress` bool alongside it, following the exact pattern
`CustomerDetailScreen`'s toggle-active handler already established in
Phase 3. Introducing a controller class for four fire-and-refresh actions
would be new machinery for a job the existing pattern already does.

## Error mapping

One shared helper turns a `DioException`'s server error code into the
message the user sees, used by every action below:

```dart
String describeDocumentActionError(Object error) {
  final code = error is DioException ? error.response?.data?['error'] as String? : null;
  return switch (code) {
    'no_lines' => 'Add at least one line before finalizing',
    'finalize_requires_approval' => 'Only the business owner can finalize documents',
    'already_finalized' => 'This document was already finalized',
    'not_convertible' => "This document type can't be converted to an invoice",
    'not_finalized' => 'Finalize this document first',
    'already_converted' => 'This was already converted to an invoice',
    'already_declined' => 'The customer already declined this',
    'customer_has_no_email' => 'This customer has no email on file',
    'pdf_render_failed' => "Couldn't generate the PDF",
    'email_send_failed' => "Couldn't send the email",
    _ => "Something went wrong — try again",
  };
}
```

Every action catches, calls this, and shows the result as a dismissible
inline banner with a **Retry** button that re-runs the same action — no
action in this phase ever fails silently.

## Screen changes

**`DocumentDetailScreen`** (Phase 4a/4b), below the existing totals
footer, context-sensitive on `document.status`/`document.type`/
`document.convertedTo`:

- **`status == draft`**: a full-width "Finalize" `AppButton`. Tapping
  shows a confirmation dialog ("Finalize this document? It will get a
  permanent number and can no longer be edited.") before calling
  `finalize`. On success, reloads the document in place (`_future =
  _load()`), which now shows the assigned number and a `FINALIZED`
  `DocumentStatusPill`.
- **`status == finalized && (type == proforma || type == quote) &&
  convertedTo == null`**: a full-width "Convert to Invoice" `AppButton`.
  Confirmation dialog, then `convert`; on success `context.push`es to
  `/documents/${newInvoice.id}` (a `push`, not `pushReplacement`, so back
  navigation returns to the original document, which the pushed screen's
  own reload will now show as converted).
- **`status == finalized`**: a `Row` of two buttons — "Share PDF" and
  "Send". "Send" is disabled (with a tooltip: "Add an email for this
  customer first") when `document.customer.email == null` — the app
  already has that field, so it never lets the user tap into a call that
  can only fail. Tapping "Send" shows a confirmation dialog naming the
  recipient email, then calls `send`; on success it shows a transient
  "Sent" confirmation and reloads (so `document.sentAt` reflects the
  send). Tapping "Share PDF" fetches the bytes, writes them to a temp
  file, and calls `share_plus`'s `Share.shareXFiles`.
- **App bar**: unchanged Edit icon (draft only, from 4b) plus a new `⋮`
  `PopupMenuButton` shown only for drafts, with one item: "Delete".
  Tapping it shows a confirmation dialog ("Delete this draft? This can't
  be undone."), then calls `delete`; on success, pops back to the list
  screen and calls `ref.invalidate` on the list controller so the deleted
  draft disappears immediately rather than on the next natural refresh.

## PDF file handling

```dart
Future<void> _sharePdf() async {
  setState(() => _actionInProgress = true);
  try {
    final bytes = await ref.read(documentRepositoryProvider).fetchPdfBytes(widget.documentId);
    final dir = await getTemporaryDirectory();
    final file = await File('${dir.path}/${widget.documentId}.pdf').writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)]);
  } catch (e) {
    setState(() => _actionError = describeDocumentActionError(e));
  } finally {
    setState(() => _actionInProgress = false);
  }
}
```

`getTemporaryDirectory()` comes from the already-installed `path_provider`
package. `share_plus` is the one new dependency this phase adds, as
`share_plus: ^13.3.0` (the version `dart pub add share_plus` resolves to
today) — a caret range, matching most of this project's dependencies
(`dio`, `path_provider`, `go_router`, etc.); only the Riverpod/freezed/
json-serializable family are exact-pinned, and only because of the real
compatibility conflicts Phase 1 hit with those specifically.

## Testing strategy

Following the established TDD rhythm, one task at a time:

1. `DocumentRepository.finalize`/`convert`/`send`/`delete`/`fetchPdfBytes`
   + repository tests (mocked `Dio`, same pattern as 4a/4b's
   `document_repository_impl_test.dart`).
2. `describeDocumentActionError` unit tests — one case per known error
   code, plus the unknown-code fallback.
3. `DocumentDetailScreen` widget tests: Finalize button appears only for
   drafts and reloads on success; Convert button appears only for
   finalized Proforma/Quote with no `convertedTo` and navigates on
   success; Send is disabled when the customer has no email and shows a
   confirmation + reload on success; Share PDF invokes the fetch (share
   sheet itself isn't asserted — that's `share_plus`'s own concern, not
   ours); the overflow Delete action appears only for drafts, confirms,
   and pops back to the list.
4. Final verification: `flutter analyze`, `flutter test`, `flutter build
   apk --debug`.
