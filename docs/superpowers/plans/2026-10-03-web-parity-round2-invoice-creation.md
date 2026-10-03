# Web Parity Round 2: Invoice Creation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans (inline, chosen by the founder) to implement this plan task-by-task. Steps use checkbox syntax.

**Goal:** Bring the web's new invoice-creation features to the phone, adapted to a phone: payment terms, a credit limit warning, saving a typed line as an item, instalments (payment plans), and repeating invoices.

**Architecture:** The draft editor state already carries `installments` and `recurrence` untouched (Round 1, Task 2A). This round makes them editable. Pure rules (payment terms, instalment splitting, balance row, validation) live in small domain files with table-driven tests, ported from the web's `shared/src` so both apps agree. Screens only render state and call the editor controller.

**Tech Stack:** Flutter, Riverpod (no codegen), freezed (generated files committed), dio, mocktail.

**Spec:** `docs/superpowers/specs/2026-09-30-web-parity-round-design.md`, Round 2 items 9, 11, 13 and Round 3 item 14 (instalments) and Round 4 item 18 (repeat), pulled forward because the founder asked for invoice creation to use the new web features first. The web contract is in the same spec and in `shared/src/{installments,payment-terms,currency}.ts` of the web repo.

## Global Constraints

- Branch `web-parity-r2` in its own worktree, created from `fixes-refresh-privacy` (stacked: PR #24 then #25 then this one).
- Commits authored only as `Ange Aurele TUYISENGE <tuyisengeauris@gmail.com>`. No `Co-Authored-By` trailer, no mention of Claude, AI or an assistant anywhere. This rule overrides any attribution line a tool suggests.
- One lowercase conventional sentence per commit, imperative, no period, one logical change each.
- Comments explain why, never what. No em dashes anywhere. Lines within 120 columns. Do not run the default `dart format`.
- Riverpod without code generation. freezed and json outputs are regenerated with `dart run build_runner build --delete-conflicting-outputs`; keep only the generated files of the models you changed and restore the rest with `git checkout --`.
- Amounts are whole numbers of the currency's smallest unit; the draft's currency is `DocumentEditorState.currency`.
- No dead ends: every error says what happened and what to do next. The editor always shows its amounts (privacy mode does not apply there).
- Every task ends with `flutter analyze` clean and its tests passing; the last task runs the full suite and a debug build.

## Review Focus

1. Instalments on a draft whose lines change: the last row must follow the total (the balance), so a saved plan always adds up; typed earlier rows that already reach or pass the total must be reported, not saved. (Task 4)
2. A plan on a foreign-currency draft: amounts typed in whole units of that currency, two decimals handled, sums exact in the smallest unit. (Task 4)
3. A plan and a repeat schedule are mutually exclusive on the server (`400`), and a plan is for invoices only: the editor must never offer a combination the server refuses. (Tasks 4 and 5)
4. A credit limit lookup that fails must not block saving or show an error that looks like a problem with the invoice. (Task 2)
5. Saving a line as an item on a foreign-currency draft must store the catalog price in RWF (items are always RWF), not the foreign amount. (Task 3)

---

### Task 1: Payment terms on the draft

**Files:** create `lib/features/documents/domain/payment_terms.dart`; modify `document_editor_controller.dart` (state `paymentTermDays` derived, `setPaymentTerm`), `document_editor_screen.dart` (chips under the due date); tests `test/features/documents/domain/payment_terms_test.dart`, controller and screen tests.

**Interfaces:** `const paymentTermOptions = [(days: 0, label: 'Due on receipt'), (7, 'Net 7'), (14, 'Net 14'), (30, 'Net 30'), (60, 'Net 60')]`; `DateTime addDays(DateTime, int)` on calendar days; `int? matchPaymentTerm(DateTime issue, DateTime? due)` (null for a custom gap); controller `setPaymentTerm(int days)` sets `dueDate = issueDate + days`; `setIssueDate` keeps the chosen term (moves the due date with it) when the due date currently matches a preset.

- [ ] Failing tests: `matchPaymentTerm` for 0, 7, 14, 30, 60, a custom 10, a null due date; `addDays` across a month and a year end; controller: choosing Net 30 sets the due date 30 days after the issue date; changing the issue date moves a preset due date with it but leaves a custom one; screen: tapping `Net 14` shows the matching due date and the chip reads as selected, a custom date selects none.
- [ ] Implement, run tests, analyze, commit `feat: pick payment terms instead of a date on a draft`.

### Task 2: Customer credit limit and the invoice warning

**Files:** modify `customer.dart` (+ regenerate) adding `creditLimit` (`int?`), `portalToken` (`String?`), `outstandingBalance` (`int`, default 0), `outstandingTotals` (`List<MoneyTotal>` with `currency`, `amount`); `customer_repository.dart` and impl (create and update accept `creditLimit`, `clearCreditLimit`); `customer_form_screen.dart` (a whole-RWF field, empty clears it); `customer_detail_screen.dart` (show the limit and what the customer owes); a `CreditLimitWarning` widget in `lib/features/documents/presentation/widgets/`; the editor shows it for invoices when a customer is chosen. Tests for each.

**Interfaces:** the warning reads `customerRepositoryProvider.get(customerId)`; shows `{name} already owes {balance}. With this invoice they would owe {sum}, which is over their {limit} limit.` only when `creditLimit != null && balance + invoiceTotalRwf > creditLimit`, where `invoiceTotalRwf = toRwf(total, currency, exchangeRate)` (the web adds the invoice in its own currency, which is wrong for a foreign invoice). A failed lookup shows nothing.

- [ ] Failing tests: customer JSON parses `creditLimit`, `outstandingBalance`, `outstandingTotals`, `portalToken` and tolerates their absence; repository sends `creditLimit` on create and update and `null` to clear; the form validates a positive whole number and clears on empty; warning appears over the limit, not at or under it, not without a limit, not for non-invoices, converts a foreign total, and stays silent when the lookup throws.
- [ ] Implement, run tests, analyze, commit `feat: give a customer a credit limit` then `feat: warn when an invoice would take a customer over their credit limit`.

### Task 3: Save a typed line as an item

**Files:** modify the line card in `document_editor_screen.dart` (a `Save to my items` action on a line with a description and no linked item), `document_editor_controller.dart` (`linkLineItem(localId, itemId)`), use `itemRepositoryProvider.create`. Tests.

**Interfaces:** the item is created with `description`, `unitPrice = toRwf(line.unitPrice, currency, exchangeRate)` (the catalog is RWF; a foreign draft with no rate cannot save an item and says why), `unit: 'unit'`, `taxRate: line.taxRate`; on success the line links to the new item and `recentItemsProvider` remembers it.

- [ ] Failing tests: the action appears only for an unlinked line with text; saving an RWF line posts the same price; saving a USD line at a 1,400 rate posts the RWF price; a USD draft with no rate explains it and posts nothing; a failure keeps the line, shows the reason and offers a retry.
- [ ] Implement, test, analyze, commit `feat: save a line typed on an invoice as an item`.

### Task 4: Instalments

**Files:** create `lib/features/documents/domain/installment_plan.dart` (rules), `lib/features/documents/presentation/widgets/installments_section.dart`; modify `document_editor_controller.dart` (editable plan state), `document_editor_screen.dart`, `document.dart` (+ regenerate: `schedule` list of `DocumentScheduleStep`), `document_detail_screen.dart` (show the schedule). Tests for each.

**Rules (ported from the web `installments.ts`):** two to twelve rows of `{label?, amount, dueDate}`; every row's amount is typed except the last, which is always `total - sum(earlier)` (the balance); `splitEvenly(total, parts)` gives each `total ~/ parts` and the remainder to the last; `percentOfTotal(total, percent)`; a plan is invalid when fewer than two rows, more than twelve, any amount not positive, a date missing, or the earlier rows reach the total. `buildSchedule` is not ported: the server returns `schedule` with `status` `PAID`, `PARTIALLY_PAID`, `OVERDUE`, `UNPAID`, `number`, `label`, `dueDate`, `amount`, `paid`, `remaining`.

**Phone adaptation:** a `Payment plan` section for invoices only, hidden when the draft repeats. A switch `Pay in instalments` starts a plan from presets: `2 equal parts`, `3 equal parts`, `Deposit then balance` (a percentage field, default 30), first due date defaulting to the draft's due date or a month after the issue date, then one row per month. Each row shows an editable name, due date and amount (the last is read-only and labelled `Balance`). `Add instalment` up to twelve, remove down to two. Turning the switch off drops the plan.

**Interfaces:** `DocumentEditorState.installments` becomes editable (`List<InstallmentInput>` kept); controller `startPlan(PlanPreset preset, {double? depositPercent})`, `setInstallment(index, {label, amount, dueDate})`, `addInstallment()`, `removeInstallment(index)`, `clearPlan()`; `totals.total` changes re-balance the last row inside the state getter used by `toInput`; `isSavable` is false with a plan problem (`installmentPlanProblem(total, plan)` returns a plain message or null, shown under the section).

- [ ] Failing tests (domain): `splitEvenly` for 10,000/3, 100/2, 7/3; `percentOfTotal` clamps; the balance row follows the total; `installmentPlanProblem` for each rule; two decimals in USD (amounts in cents, 2 parts of 12.50 USD).
- [ ] Failing tests (controller): `startPlan` with each preset produces the right rows and dates one month apart; editing an earlier amount re-balances the last; changing a line price re-balances; overspent plan blocks saving and reports why; clearing the plan sends no `installments`; a draft with a plan locks its currency (existing) and a new plan on a foreign draft uses cents; a plan cannot be started on a non-invoice or a repeating draft.
- [ ] Failing tests (widgets): the section is absent for a quote; switching on shows the presets and rows; the last row is read-only and says `Balance`; an overspent plan shows the message; the detail screen lists the schedule with statuses and the next instalment line.
- [ ] Implement in small commits: `feat: add the payment plan rules the web uses`, `feat: edit a payment plan on an invoice draft`, `feat: show an invoice's payment schedule`.

### Task 5: Repeating invoices

**Files:** modify `document_editor_controller.dart` (`setRecurrence(interval, endDate)`, `clearRecurrence()`), `document_editor_screen.dart` (a `Repeat` section for invoices, hidden when a plan exists), `document_detail_screen.dart` (`Repeats monthly, next on {date}`). Tests.

**Interfaces:** `RecurrenceInput(interval, endDate)` with `WEEKLY`, `MONTHLY`, `QUARTERLY`, `ANNUALLY`; labels `Every week`, `Every month`, `Every quarter`, `Every year`; optional end date. A draft with a plan shows the repeat section disabled with `A repeating invoice cannot be paid in instalments`, and the reverse.

- [ ] Failing tests: choosing an interval sets `recurrence` and sends it; an end date is a plain date; turning it off sends none; the sections exclude each other; a non-invoice has no repeat section; the detail screen shows the schedule text from `recurrenceInterval` and `nextRecurrenceAt`.
- [ ] Implement, test, analyze, commit `feat: repeat an invoice on a schedule`.

### Task 6: Verify

- [ ] `flutter analyze`, `flutter test` (full), `flutter build apk --debug`; search for leftover `RWF` literals; push the branch and open the PR against `fixes-refresh-privacy` with no attribution line; release build and install on the phone when it is connected.
