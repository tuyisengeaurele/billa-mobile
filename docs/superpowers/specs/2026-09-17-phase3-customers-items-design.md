# Phase 3: Customers and Items — Design

## Context

Builds on Phase 2's auth/onboarding (this branch stacks on the still-unmerged
`phase2-auth-onboarding`). This phase adds the first real business data: the
Customer catalog and the Item catalog — list, search, create/edit, and
deactivate. Both feed later phases (documents pick a customer and items off
these same lists), so the repository interfaces here are load-bearing, not
throwaway.

## Facts this design depends on

Confirmed by reading `server/src/routes/customers.ts` and
`server/src/routes/items.ts` in full, not assumed:

- **Items have no detail endpoint at all.** No `GET /items/:id`, no
  usage-count/analytics route. Everything the app will ever know about an
  item is already in the list response. Tapping an item opens its edit form
  directly using the object already in hand — there is no separate "view"
  state to design for, and no route that fetches an item by id.
- **Customers do have a detail endpoint** (`GET /customers/:id`) plus a
  separate stats endpoint (`GET /customers/:id/payment-stats` →
  `{ paidInvoiceCount, averageDaysToPay, onTimeRate }` — payment
  *timeliness*, not an outstanding-balance figure; nothing here overlaps
  with Phase 5's receivables work).
- **There is no hard delete anywhere.** No `DELETE` route on either
  resource. The only removal mechanism is `PATCH :id` with
  `isActive: false` — a soft deactivation, not a destructive delete, and
  never blocked by existing references (a deactivated customer's documents,
  or an item referenced in existing document lines, are untouched).
- **Both list endpoints share one shape**: query params `search`,
  `sortBy`, `sortOrder`, `page`, `pageSize` (max 100), `includeInactive`
  (default `false`); response `{ results, total, page, pageSize }`.
  Customer search matches `name` only; item search matches `description`
  only, with `category` as a separate exact-match filter, not part of
  free-text search.
- **Validation specifics worth mirroring exactly**: on `Customer`, `tin`,
  `address`, `phone`, `email` are `.optional()` but **not** `.nullable()` —
  an empty field must be omitted from the payload, never sent as `null`, or
  the server rejects it. `email` must be a valid email if present at all.
  On `Item`, `unitPrice` must be a positive integer (>0, not just
  non-negative), `taxRate` defaults to `18` and is clamped 0–100, and
  `category` is genuinely nullable (empty string transforms to `null`).

## Architecture

```
lib/
  core/
    pagination/
      paginated_list_controller.dart   # generic AsyncNotifier: page accumulation,
                                        # debounced search, includeInactive re-fetch
      paginated_result.dart            # { results, total, page, pageSize } as a
                                        # generic freezed class
  features/
    customers/
      domain/
        customer.dart                  # freezed
        customer_payment_stats.dart     # freezed
        customer_repository.dart        # interface
      data/
        customer_repository_impl.dart
      presentation/
        providers/
          customer_repository_provider.dart
          customer_list_controller.dart
        screens/
          customer_list_screen.dart
          customer_detail_screen.dart
          customer_form_screen.dart      # create + edit, one screen
        widgets/
          customer_list_tile.dart
    items/
      domain/
        item.dart                        # freezed
        item_repository.dart             # interface
      data/
        item_repository_impl.dart
      presentation/
        providers/
          item_repository_provider.dart
          item_list_controller.dart
        screens/
          item_list_screen.dart
          item_form_screen.dart          # create + edit, one screen
        widgets/
          item_list_tile.dart
```

### Shared pagination controller

Both lists need identical mechanics: accumulate pages, debounce search
(300ms) back to page 1, toggle `includeInactive` back to page 1, expose
`hasMore` for infinite scroll. `PaginatedListController<T>` is a generic
`AsyncNotifier<PaginatedState<T>>` base class; each feature's concrete
controller supplies only the fetch call (`CustomerRepository.list(...)` or
`ItemRepository.list(...)`) and re-triggers on parameter changes the same
way. This is the first genuinely reusable abstraction in `core/` beyond the
Phase 1 widgets — worth it here because the two call sites are truly
identical in shape, not just superficially similar.

### Customers

`CustomerRepository`: `Future<PaginatedResult<Customer>> list({String? search, bool includeInactive, int page, int pageSize})`,
`Future<Customer> get(String id)`, `Future<CustomerPaymentStats> paymentStats(String id)`,
`Future<Customer> create({required String name, String? tin, String? address, String? phone, String? email})`,
`Future<Customer> update(String id, {String? name, String? tin, String? address, String? phone, String? email, bool? isActive})`.

Routes: `/customers` (list, with search field + "Show inactive" toggle
chip), `/customers/:id` (detail — its own fetch, deep-linkable),
`/customers/new` and `/customers/:id/edit` (one `CustomerFormScreen`;
edit mode receives the existing `Customer` via `state.extra` from whichever
screen navigated in, so editing never needs a redundant fetch). Detail
shows the profile fields, a payment-stats card, and a "Deactivate customer"
action behind a confirmation dialog that states plainly what happens
("Hidden from lists. Their existing documents are not affected.") —
reactivating is the same action, offered instead when `isActive` is already
false.

### Items

`ItemRepository`: `Future<PaginatedResult<Item>> list({String? search, String? category, bool includeInactive, int page, int pageSize})`,
`Future<Item> create({required String description, required int unitPrice, required String unit, double taxRate, String? category})`,
`Future<Item> update(String id, {String? description, int? unitPrice, String? unit, double? taxRate, String? category, bool? isActive})`.

Routes: `/items` (list, search + category filter chip + "Show inactive")
and `/items/new`; editing opens the same `ItemFormScreen` via `state.extra`
carrying the tapped `Item` — there is deliberately no `/items/:id` route,
since nothing exists server-side to fetch there. Deactivate is a swipe
action or overflow-menu entry on the list row, same confirmation-dialog
pattern as customers.

### Forms

Both forms distinguish create vs. edit by whether an existing model was
passed in, not by a separate widget. Fields map 1:1 to the schemas above;
an empty optional text field is omitted from the submit payload rather than
sent as an explicit `null`, matching the non-nullable-optional validation.
Item's unit price uses `MoneyText`-style tabular figures in its input
formatting and display; tax rate defaults to `18` on create.

## Error handling

List fetch failures render `ErrorState` (Phase 1) with retry, replacing the
list body — not a toast that leaves a stale/empty list behind. Form submit
failures show the server's field-level message inline when the response
maps to a known field, otherwise a banner above the submit button. Empty
list (zero results, no filters active) uses `EmptyState` with "Add
customer" / "Add item" as the primary action; a search or filter that
matches nothing gets its own inline "No results for '…'" message instead of
the full empty-state treatment, since that's a different situation (data
exists, the filter just didn't match).

## Testing

- `PaginatedListController`: page accumulation, search-resets-to-page-1,
  `includeInactive` toggle re-fetch, `hasMore` correctness — against a fake
  fetch function, no real repository involved.
- `CustomerRepositoryImpl` / `ItemRepositoryImpl`: unit tests against a
  mocked `Dio`, including the omit-null-optional-fields behavior on create
  and the `isActive: false` deactivate call shape.
- Widget tests: empty state rendering + primary action, search debounce
  triggering exactly one re-fetch (not one per keystroke), and the
  deactivate confirmation dialog's copy and callback wiring.

## Out of scope for this phase

CSV export (`GET .../export.csv` on both routers exists server-side but
isn't built here — mobile export is a different UX pattern, share-sheet
based, and not core CRUD). The public customer portal (`portalToken`,
`public-customers.ts`) is a wholly separate feature surface untouched by
this phase. Item usage/history and customer outstanding-balance figures
don't exist as endpoints yet and aren't invented here — receivables (Phase
5) is where "what a customer owes" actually gets built.
