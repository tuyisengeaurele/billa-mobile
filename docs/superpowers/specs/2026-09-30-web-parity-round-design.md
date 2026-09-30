# Web parity: Design

## Context

The web app moved a long way while the mobile rounds were being built. This
document lists every web change since the mobile app was designed, decides
which of it belongs on a phone, and orders the work in rounds. It is a design
for approval. Only Round 1 has an implementation plan today; each later round
gets its own plan just before it starts, written against the code as it is then.

Method: the web state when the mobile app was designed is commit `52bea22`
(16 Sep 2026). Web `master` on 30 Sep is 145 commits later (133 server and
shared files, 72 client files). Every route, the Prisma schema, the shared
rules and every client page were diffed against that baseline, and the result
was compared with the mobile branch `r2e-a11y`, the tip of the stacked mobile
PRs.

## The filter

A feature goes on the phone when an owner would use it on the move, in a shop
or at a customer's door, with weak data. It stays on the web when it needs a
large screen, many rows, or one-time setup.

## What changed on the web (the contract)

### Removed
- `PATCH /business/members/:userId/role`. The accountant role is gone;
  `BUSINESS_MEMBER_ROLES` is only `MEMBER`, and an invite with no role is a
  member.

### Added endpoints that matter on a phone
- `GET /documents/rates` returns `{rates: {USD: number}, info: {USD: {source, date}}}`.
  `source` is `BNR` (the National Bank of Rwanda reference rate, refreshed at
  most every 12 hours, with a `date`) or `LAST_USED` (the rate this business
  used last, no date).
- `POST /documents/:id/shared` with `{channel: "WHATSAPP"}`. Finalized
  documents only (`409 not_finalized`). Sets `sentAt`, writes a
  `DOCUMENT_SHARED` activity, returns `{sentAt}`.
- `POST /documents/:id/attachments` (multipart field `file`) and
  `DELETE /documents/:id/attachments/:id` (`204`). Images (PNG, JPG, WebP) or
  PDF, 5 MB, at most 5 per document. Errors: `no_file`, `upload_failed`,
  `invalid_file_type`, `too_many_attachments` (409), `not_found`. Allowed after
  finalizing, never printed on the PDF.
- `POST /customers/:id/send-statement` returns
  `{sentTo, invoiceCount, totalOwed, totals}`. Errors: `customer_has_no_email`
  (400), `nothing_owed` (409), `email_send_failed` (502).
- `PATCH /documents/:id/reminders` with `{enabled}` (existed before; listed
  because Round 3 uses it).

### Added and web only
`POST /customers/import`, `POST /items/import`, `GET /reports/vat-register.csv`,
API keys (`/api-keys`), webhooks (`/webhooks`), the `/api/v1` API, the
Developers page, CSV export columns for currency.

### Changed behavior of existing endpoints
- **Saving a draft replaces all of it.** `PATCH /documents/:id` deletes the
  lines and instalments and rewrites every column from the request. A field
  left out is reset: `currency` returns to RWF through the schema default,
  `installments` are deleted, `recurrence` is cleared. The current phone app
  sends none of them, so editing a web-made foreign, instalment or repeating
  draft on it corrupts that draft.
- **Every document has `currency` and `exchangeRate`.** All amounts (lines,
  totals, payments, instalments, discounts) are whole numbers of the currency's
  smallest unit: RWF 0 decimals, USD, EUR, GBP, KES, TZS 2 decimals, UGX 0. The
  rate is RWF for one whole unit. A document that refers to an invoice (credit
  note, receipt, delivery note) takes the invoice's currency and rate whatever
  is sent. Conversion, proforma conversion and repeats keep the currency.
- **Documents also return** `installments`, `schedule`, `nextInstallment`,
  `attachments`, `firstViewedAt`, `lastViewedAt`, `viewCount`,
  `customer.phone` and `business.momoEnabled`.
- **Payment plans** are two to twelve steps of `{label?, amount, dueDate}` on an
  invoice, in the document's currency, and must add up to the total (otherwise
  `400 invalid_installments` with a plain `message`). A plan cannot be combined
  with a repeat schedule, and only invoices have one. The invoice's due date is
  its last instalment. Nothing about paid steps is stored: money is applied to
  the earliest step first, from the payments and credit notes on the invoice.
- **Receivables** return `customerPhone`, `publicToken`, `amountDue` (the next
  instalment still owing, else the balance), `nextInstallmentLabel`, `currency`,
  `amountOwedRwf`, and a top-level `momoEnabled`. Overdue starts the day after
  the due date and is judged per instalment; `daysOverdue` and `agingBucket`
  come from the server.
- **Customers** have `creditLimit` (whole RWF, positive, `null` clears it).
  `GET /customers/:id` also returns `outstandingBalance` (RWF, credit notes and
  foreign rates applied) and `outstandingTotals` (`[{currency, amount}]`).
- **Business** has `dueSoonReminderDays` (0 to 14, default 3).
- **Sessions** carry `deviceName`, `lastUsedAt`, and "this device" is found by a
  one-year `device_id` cookie. A device holds one session. The server names a
  device from an `X-Billa-Device` header, or "Billa app" for the Dart client.
  A migration revoked every live session once.
- **Notifications** gain the type `DOCUMENT_VIEWED` (and a preference key of the
  same name). Activity gains `DOCUMENT_SHARED` and `DOCUMENT_VIEWED`.
- **Public page:** MoMo takes RWF only (`momo_rwf_only`) and charges the next
  instalment. Customer views are counted, ignoring bots and signed-in people.

## What needs no mobile work (server side, verify only)

Overdue counts and the Home figures (converted to RWF by the server); due-soon,
overdue and statement emails; instalment aware reminders; the owner digest; PDF
changes (scan-to-view QR, currency footer, payment schedule, instalment
labels); the public page and its receipts; MoMo receipts on success; proforma
conversion and repeats keeping currency, language and payment window; session
cleanup; webhooks.

## Web only, skipped for mobile

CSV import and export, the VAT register download, API keys and webhooks, the
Developers page, the service worker and offline page, the landing page, the
product tour, admin pages, approval rules and brand colours in business
settings, bulk list actions, customer portal setup.

## The work, in rounds

Each item is its own small change: tests first, one logical commit at a time,
on a branch stacked on the previous one. Every round ends with a green
`flutter analyze`, the full test suite, a debug Android build, and a run on the
phone.

### Round 1: correctness (plan written: `plans/2026-09-30-web-parity-round1.md`)

1. **Team roles.** Remove the accountant option from invites and members, stop
   calling the removed route, read an unknown role as member.
2. **Currency.** Show every amount in its own currency, choose a currency and
   rate on the draft editor (bank rate prefilled and labelled, lines repriced
   through RWF, a flat discount typed in the currency), record payments in the
   invoice's currency, total receivables one currency at a time. No rate
   editor or history.
3. **Server-owned status.** The phone computes no overdue rule; it already uses
   the server's `daysOverdue`, `agingBucket` and overdue count. The only
   phone-side sum, the receivables total, stops mixing currencies.
4. **Signed-in devices.** Send `X-Billa-Device`, show name and last activity.
5. **Keep what the web saved.** Send `currency`, `exchangeRate`,
   `installments` and `recurrence` back unchanged when a draft is saved, say in
   the editor that a plan or repeat schedule is set up on the web, and show the
   server's reason when a plan no longer adds up. Most urgent, because the
   installed app can already damage web-made drafts.
6. **Message wording.** Reminders and shares use the web's words: the business
   name, a due line (`Due date` for invoices, `Valid until` for quotes and
   proformas), `View and pay it here` only when the business takes MoMo and the
   invoice is RWF, and the instalment due now for a plan.

### Round 2: quick wins

7. **Opened tracking.** A document list row shows an `Opened` chip when
   `lastViewedAt` is set and the invoice is not paid. The detail screen shows,
   for a finalized document that was sent: `Opened by the customer {relative}
   ({n} view/views)` or `Sent, not opened yet`. Add
   `NotificationType.documentViewed` (`DOCUMENT_VIEWED`, "Document opened") so the
   notification preferences screen offers its toggle; the inbox already skips
   unknown types instead of failing.
8. **Share tracking.** When a finalized document is shared on WhatsApp from its
   own screen, call `POST /documents/:id/shared` after opening WhatsApp and
   update `sentAt`. A failure to record is ignored. Reminders (from receivables
   or a chase on an invoice) do not record, exactly as on the web. The phone's
   contact sheet offers call, SMS and WhatsApp, so only the WhatsApp choice from
   a document share records.
9. **Payment terms.** Presets `Due on receipt`, `Net 7`, `Net 14`, `Net 30`,
   `Net 60` set the due date from the issue date (calendar days, UTC). Changing
   the issue date keeps the chosen term; a due date that matches no preset reads
   as custom.
10. **Customer statement.** WhatsApp text `Hello {customer}, this is your
    statement from {business}. You currently owe {totals joined by " + "}.` then
    `{See and pay your invoices here|See your invoices here}: {origin}/portal/{portalToken}`,
    with the totals from `outstandingTotals` and the payment wording when the
    business takes MoMo. An email option calls `send-statement` and maps
    `customer_has_no_email`, `nothing_owed` and `email_send_failed` to plain
    messages with what to do next.
11. **Credit limit.** A whole-RWF field on the customer form (positive, empty
    clears it) and, on an invoice for that customer, a warning, never a block:
    `{name} already owes {balance}. With this invoice they would owe {sum}, which
    is over their {limit} limit.` The web adds the invoice total in its own
    currency to an RWF balance, which is wrong for a foreign invoice. The phone
    converts the invoice total to RWF with the draft's rate first.
12. **Delete a draft from the list.** A swipe or menu action on draft rows with
    a confirmation, as the web list now has; the detail menu already deletes.
13. **Add an item while picking.** From the item picker, add a new item without
    leaving the invoice (the web's picker now has an add-new form), so an item
    typed on the spot is saved for next time.

### Round 3: getting paid and capture

14. **Instalments.** Show the schedule on an invoice (`Payment plan`, each step
    `{label or "Instalment N"}`, `Due {date}`, amount, status `Paid`, `Partly
    paid`, `Overdue`, `Due`) and the next instalment line. Create a plan on the
    phone from presets only: an even split into 2 to 12 steps, or a deposit by
    percentage plus a balance, where the last step is always the balance. Editing
    a custom plan stays on the web. Invoices only, not on a repeating invoice.
15. **Photo attachments.** Attach an image or PDF to a document from the camera,
    gallery or files, with the limits and error messages above, and remove one.
16. **Reminder settings.** Add the `dueSoonReminderDays` choice (Don't send, 1, 2,
    3, 5 or 7 days before) beside the reminders switch and cadence the app already
    has, shown only when reminders are on, and the per-document reminders toggle.
17. **Receivables due now.** Show `{amountDue} due now` under the balance for an
    invoice on a plan, and add the instalment to a reminder (Round 1's wording
    already has the slot).

### Round 4: light versions

18. **Repeating invoices.** Turn on repeat when creating an invoice
    (`WEEKLY`, `MONTHLY`, `QUARTERLY`, `ANNUALLY`, optional end date) and show the
    next date. Not together with instalments. Managing many schedules stays on the
    web.
19. **Revenue glance.** A read-only card on Home. The server already converts the
    dashboard figures to RWF.
20. **Activity feed.** A read-only list from `GET /business/activity` (paged, 20
    to 100), with labels for the new `DOCUMENT_SHARED` and `DOCUMENT_VIEWED`.

## Behaviour rules that apply to every item

The standing rules hold: no dead ends, every error says what happened and what
to do next, empty states have a next action, money uses tabular figures,
comments explain why, and commits are small single-sentence conventional
commits authored only as Ange Aurele TUYISENGE.

## Testing

Repository tests with a mocked dio for each new call. Widget tests for each new
screen state (loading skeleton, error with retry, empty, populated). Currency
and instalment display get table-driven tests, because those change how every
amount reads. Anything that sends a draft to the server gets a round-trip test
that proves fields it does not edit come back unchanged.

## Risks

- **The installed app can already damage web-made drafts.** Round 1 item 5 is
  the first thing built and should ship before anything else if the round is
  split.
- **Currency is the widest change.** It touches every place an amount is shown.
- **The web keeps moving.** Payloads must be read again when a round's plan is
  written, not taken from this document.
- **Session device name.** A wrong or missing header only costs a generic name,
  never a broken sign-in.
- **Nothing here has run on a physical device** beyond the sign-in and
  two-factor checks in this session. Each round ends with a phone run.

## Decisions needed

1. Approve the filter and the four rounds, or move items between rounds
   (approved for Round 1; Rounds 2 to 4 are new).
2. Whether the one-time "your session ended after a security update" message is
   worth building. The app cannot yet tell it from a normal expiry, so it is not
   in any round until decided.
