# Web parity round: Design

## Context

The web app moved a long way while the mobile rounds were being built. This
document lists what changed on the web since the mobile contract was
written, decides which of it belongs on a phone, and orders the work. It is
a design for approval only. Nothing here is built yet.

Compared on 2026-09-30: web `master` (776 commits) against the mobile
branch `r2e-a11y`, the tip of the stacked mobile PRs. The last two weeks of
web commits were read closely, older ones by route and schema. Items marked
"confirm" need their endpoint payload read before they are specced.

## The filter

A feature goes on the phone when an owner would use it on the move, in a
shop or at a customer's door, with weak data. It stays on the web when it
needs a large screen, many rows, or one-time setup.

Out of scope on purpose: CSV import and export, the VAT register file,
approval rules, brand accent colours, MoMo credentials, bulk list actions,
customer portal setup, and the admin, API key, webhook and developer
features.

## Backend facts this design depends on

Read from the web source, not assumed:

- **Team roles.** The accountant role is gone (`5cca95c`). `BUSINESS_MEMBER_ROLES`
  is now only `MEMBER`, invites default to `MEMBER`, and the route
  `PATCH /business/members/:userId/role` no longer exists.
- **Sessions are per device.** Each session stores `deviceId`, `deviceName`
  and `lastUsedAt`. The device comes from a `device_id` cookie (path `/`, one
  year, httpOnly). Sign-in on a device replaces its session; sign-out ends
  every session on the device. The server accepts an `X-Billa-Device` header
  that overrides the name it would read from the user agent, and names the
  Dart client "Billa app" when no header is sent. A migration revoked every
  live session once.
- **Documents carry a currency and an exchange rate.** MoMo payment is offered
  only for RWF invoices. Reference rates come from `GET /documents/rates`.
- **Invoices can have a payment plan (instalments).** Receivables, overdue
  counts and reminders judge by the next instalment.
- **Overdue means the day after the due date**, one shared definition on the
  server.
- **Views are tracked.** Documents return `firstViewedAt`, `lastViewedAt` and
  `viewCount`, and the owner gets one notification on the first view.
- **Sharing is recorded** with `POST /documents/:id/shared`.
- **Customers have a `creditLimit`**, and `POST /customers/:id/send-statement`
  emails a statement.
- **Reminder settings** on the business: `remindersEnabled`,
  `reminderCadenceDays`, `dueSoonReminderDays`, plus a per-document
  `PATCH /documents/:id/reminders`.
- **Payment terms** are presets that set the due date.
- **Attachments** exist on documents (`DELETE /documents/:id/attachments/:id`
  is visible; the upload route and payload need confirming).
- **Recurring documents** use `recurrenceInterval`, `recurrenceEndDate` and
  `nextRecurrenceAt`.
- **Saving a draft replaces all of it** (`PATCH /documents/:id`, added after
  the first pass of this spec, found on a second read of the web code). A field
  left out is reset: `currency` returns to RWF through the schema default,
  `installments` are deleted, `recurrence` is cleared. The current phone app
  sends none of them, so editing a web-made foreign, instalment or repeating
  draft on it corrupts that draft.
- **Payment plans** are two to twelve steps of `{label?, amount, dueDate}` on an
  invoice, in the document's currency, and must add up to the total. A plan that
  does not is refused with `invalid_installments` and a plain `message`. A plan
  cannot be combined with a repeat schedule. Each document also returns
  `nextInstallment` (what to pay next and how much of it remains), `business.momoEnabled`,
  and view tracking fields.
- **Customer message wording** changed on the web: it names the business, adds a
  due line (`Due date` for invoices, `Valid until` for quotes and proformas),
  says `View and pay it here` only when the business takes MoMo and the invoice
  is RWF, and for a plan says which instalment is due now.

## The work, in rounds

Each item is its own small change: tests first, one logical commit at a
time, on a branch stacked on the previous one. Every round ends with a green
`flutter analyze`, the full test suite, and a debug Android build.

### Round 1: correctness (must do)

1. **Team roles.** Remove the accountant option from invite and member
   screens, stop calling the role route, drop `TeamRole.accountant`, and
   remove the `read_only_role` message and the accountant gap from the notes.
   Existing parsing must not throw on a server that returns only `member`.
2. **Currency on documents.** Add `currency` and `exchangeRate` to the
   document model. Show every amount in its own currency, choose a currency
   on the draft editor with the bank rate prefilled and labelled, and hide
   any MoMo or pay-online wording for a foreign-currency invoice. No rate
   editor and no rate history on the phone.
3. **Server-owned status.** Show overdue, next instalment and receivable
   status from server values. Find and remove any overdue rule the phone
   computes itself (confirm where the app decides this today).
4. **Signed-in devices.** Send `X-Billa-Device` on every request with the
   phone's name from the device info package that is already a dependency
   (for example "Tecno CC7, Android 9"). Add `deviceName` and `lastUsedAt` to
   `SessionInfo`, and show name, "Active now" or "Last active 2 days ago",
   and the "This device" marker. One clear message after the one-time session
   reset is worth adding if the app can tell that case apart from a normal
   expiry (confirm).

5. **Keep what the web saved.** Send `currency`, `exchangeRate`, `installments`
   and `recurrence` back unchanged when a draft is saved from the phone, say in
   the editor that a plan or repeat schedule is set up on the web, and show the
   server's reason when a plan no longer adds up. This is the most urgent item,
   because the installed app can already damage web-made drafts.
6. **Message wording.** Reminders and shares use the web's words, business
   name, due line and payment invitation rules.

### Round 2: quick wins

5. **Opened tracking.** Mark a sent document the customer has opened, and
   show first and last view on the detail screen. The notification arrives
   through the existing inbox.
6. **Share tracking.** Call `POST /documents/:id/shared` after the WhatsApp
   share, with no visible change.
7. **Payment terms presets** (7, 14, 30 days and similar) on the draft editor
   in place of picking a date.
8. **Statement on WhatsApp.** One tap on the customer screen builds the
   message with the existing WhatsApp sheet. Emailing the statement uses the
   send-statement route.
9. **Credit limit.** One field on the customer form and a warning on the
   invoice form when the customer would go over. A warning, not a block.

### Round 3: capture and getting paid

10. **Photo attachments** on a document, taken with the camera (confirm the
    upload contract first).
11. **Pay in instalments.** Show the schedule and the next instalment on the
    invoice, and create a plan from presets ("2 or 3 equal parts"). The web's
    full plan editor stays on the web (confirm the plan payload).
12. **Reminder settings.** Two switches and the number of days in business
    settings, and the per-document reminder toggle.

### Round 4: light versions

13. **Recurring invoices.** Turn on repeat when creating, and show the next
    date. Managing many schedules stays on the web.
14. **Revenue and tax glance.** A read-only card on Home with this month and
    VAT collected. The full report stays on the web.
15. **Activity feed.** A read-only list in the business area.

## Behaviour rules that apply to every item

The standing rules hold: no dead ends, every error says what happened and
what to do next, empty states have a next action, money uses tabular
figures, comments explain why, and commits are small single-sentence
conventional commits authored only as Ange Aurele TUYISENGE.

## Testing

Repository tests with a mocked dio for each new call. Widget tests for each
new screen state (loading skeleton, error with retry, empty, populated).
Currency and instalment display get table-driven tests, because those change
how every amount reads.

## Risks

- **Currency is the widest change.** It touches every place an amount is
  shown, so it goes first among the features and gets the most tests.
- **The web keeps moving.** Payloads for attachments and instalments must be
  read again when their items are specced, not taken from this document.
- **Session device name.** A wrong or missing header only costs a generic
  name, never a broken sign-in, so it is safe to ship early.
- **Nothing here has run on a physical device yet** beyond the sign-in and
  two-factor checks in this session. Each round should end with a phone run.

## Decisions needed

1. Approve the filter and the four rounds, or move items between rounds.
2. Whether Round 1 ships as one PR or as four small ones (recommended: one
   PR holding four separate commits, since each item is small).
3. Whether the "session reset" message is worth building, or the plain login
   screen is enough.
