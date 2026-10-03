# Web Parity Round 3: Getting Paid and Keeping Track Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans (inline, chosen by the founder). Steps use checkbox syntax.

**Goal:** Bring the rest of the web's new document features to the phone: opened tracking, share tracking, the instalment-aware receivables list, customer statements, delete a draft from the list, file attachments, reminder settings, and an activity feed.

**Architecture:** Each item is a small model or repository addition plus one screen change, with the pure wording and rules in domain files. Contracts are the web's, listed in `docs/superpowers/specs/2026-09-30-web-parity-round-design.md`.

**Tech Stack:** Flutter, Riverpod (no codegen), freezed (generated files committed), dio, mocktail, image_picker (already a dependency).

**Spec:** the web parity design, Round 2 items 7, 8, 10, 12 and Round 3 items 15, 16, 17, plus Round 4 item 20.

## Global Constraints

- Branch `web-parity-r3`, created from `web-parity-r2` (stacked: PRs 24, 25, 26, then this one).
- Commits authored only as `Ange Aurele TUYISENGE <tuyisengeauris@gmail.com>`, no trailer, no mention of Claude, AI or an assistant anywhere, one lowercase conventional sentence each. This overrides any attribution line a tool suggests.
- Comments explain why, never what. No em dashes. Lines within 120 columns. No default `dart format`.
- Riverpod without code generation; freezed outputs regenerated and only the changed models' generated files kept.
- No dead ends: every error says what happened and what to do next with a working retry.
- Each task is tests first: watch them fail, then implement; each ends with `flutter analyze` clean and its tests passing.

## Review Focus

1. A message or screen must never say a document was opened when it was not: `lastViewedAt` null means "sent, not opened yet" only for a sent finalized document, and nothing for a draft. (Task 1)
2. Recording a share must never block or fail the share: WhatsApp is already open by then, so a recording failure is silent. A reminder must not record a share. (Task 2)
3. A statement for a customer who owes nothing, has no email or has no phone must say what to do, not fail quietly. (Task 4)
4. An attachment over 5 MB, of the wrong type, or past the limit of five must be refused with the server's reason in plain words, and the list must stay correct after a failed upload. (Task 6)

---

### Task 1: Opened tracking

**Files:** `document.dart` (+ regenerate: `firstViewedAt`, `lastViewedAt`, `viewCount`), `notification_type.dart` (`documentViewed`), `document_list_tile.dart` (an `Opened` chip), `document_detail_screen.dart` (the opened line), `relative_time.dart` reused. Tests for each.

**Behaviour (the web's):** the list shows an `Opened` chip when `lastViewedAt` is set and the invoice is not paid. The detail screen, for a finalized document that was sent (`sentAt` set), shows `Opened by the customer {relative} ({n} view/views)` or `Sent, not opened yet`. `NotificationType.documentViewed('DOCUMENT_VIEWED', 'Document opened')` so the notification preferences screen offers its toggle.

- [ ] Failing tests: model parses the three fields and tolerates their absence; chip shows for opened and unpaid, not for paid, not for never opened; detail line for opened (one view and many), for sent and not opened, and nothing for a draft or an unsent finalized document; the preferences screen lists the new type and its toggle calls the repository.
- [ ] Implement, test, analyze, commit `feat: show when a customer has opened a document`.

### Task 2: Share tracking

**Files:** `document_repository.dart` and impl (`markShared`), `contact_actions.dart` (an optional `onWhatsAppOpened` callback), `document_contact.dart` (pass it only for a share, never for a reminder). Tests.

**Contract:** `POST /documents/:id/shared` with `{channel: 'WHATSAPP'}` returns `{sentAt}`; `409 not_finalized` for a draft.

- [ ] Failing tests: repository posts the body; choosing WhatsApp from a share records it once after WhatsApp opens; a reminder (invoice with a balance) records nothing; a failing record shows no error and does not undo the share; SMS and call record nothing.
- [ ] Implement, test, analyze, commit `feat: record when a document is shared on WhatsApp`.

### Task 3: Delete a draft from the list

**Files:** `document_list_tile.dart` (an end swipe action `Delete` for drafts, with the existing confirm sheet), `document_list_screen.dart`, the list controller. Tests.

- [ ] Failing tests: a draft row has the Delete action and a finalized row does not; deleting asks first, calls `repository.delete`, removes the row and says `Draft deleted`; a failure keeps the row and shows the reason with a retry.
- [ ] Implement, test, analyze, commit `feat: delete a draft from the documents list`.

### Task 4: Customer statement

**Files:** `statement_message.dart` (wording), `customer_repository.dart` and impl (`sendStatement`), `customer_detail_screen.dart` (two actions), `action_errors.dart` (`nothing_owed`). Tests.

**Wording (the web's):** `Hello {customer}, this is your statement from {business}. You currently owe {totals joined by " + "}.` then `{See and pay your invoices here|See your invoices here}: {origin}/portal/{portalToken}`. The email action calls `POST /customers/:id/send-statement` and reports `Statement sent to {email}`.

- [ ] Failing tests: the wording for one and for several currencies and for the paying and non-paying case; WhatsApp action disabled with a reason when there is no phone, no portal link, or nothing owed; email action disabled when there is no email; email success message; `customer_has_no_email`, `nothing_owed` and `email_send_failed` map to plain messages with what to do next.
- [ ] Implement, test, analyze, commit `feat: send a customer their statement on WhatsApp or email`.

### Task 5: Receivables due now

**Files:** `outstanding_invoice.dart` (+ regenerate: `amountDue`, `nextInstallmentLabel`), `receivables_screen.dart`. Tests.

- [ ] Failing tests: model parses the two fields and tolerates absence; a row on a plan shows `{amountDue} due now` under the balance; a row not on a plan, or with the whole balance due, shows nothing extra.
- [ ] Implement, test, analyze, commit `feat: show what is due now on an invoice paid in instalments`.

### Task 6: Attachments

**Files:** `document.dart` (+ regenerate: `attachments`), `document_repository.dart` and impl (`uploadAttachment`, `deleteAttachment`), `document_detail_screen.dart` (an attachments section: photo from camera or gallery, list, remove, open), `action_errors.dart` (`too_many_attachments`). Tests.

**Contract:** `POST /documents/:id/attachments` multipart field `file`, images only on the phone (PDFs can be added on the web), 5 MB, at most 5; `DELETE /documents/:id/attachments/:id` returns 204. Allowed on drafts and finalized documents.

- [ ] Failing tests: model parses attachments; section lists files with size and a remove action; adding a photo uploads it and shows it; a failed upload keeps the list and shows the reason with a retry; the fifth file hides the add action and says why; removing confirms first.
- [ ] Implement, test, analyze, commit `feat: attach photos to a document`.

### Task 7: Reminder settings

**Files:** `business_settings.dart` (+ regenerate: `dueSoonReminderDays`), `business_settings_repository` impl, the reminders section of the document settings screen (a days choice, shown only when reminders are on), `document.dart` (`remindersEnabled`), `document_detail_screen.dart` (a per-document reminders switch), `document_repository` (`setReminders`). Tests.

**Contract:** `dueSoonReminderDays` 0 to 14, offered as Don't send, 1, 2, 3, 5, 7 days before; `PATCH /documents/:id/reminders` with `{enabled}`.

- [ ] Failing tests: model and repository carry the days; the choice appears only with reminders on and saves; the document switch reflects `remindersEnabled` and toggles it, reverting with a message on failure.
- [ ] Implement, test, analyze, commit `feat: choose how early customers are reminded`.

### Task 8: Activity feed

**Files:** `lib/features/activity/` (model, repository, provider, screen), a row in the business settings list, route. Tests.

**Contract:** `GET /business/activity?page&pageSize` returns `{results, total, page, pageSize}` of entries with `action`, `entityType`, `metadata`, `createdAt`, `actor {name, email}`; labels come from the web's `activityLabels.ts`.

- [ ] Failing tests: model and repository; the screen shows a skeleton, rows with who and what and when, an empty state with a next action, an error with retry, and loads the next page.
- [ ] Implement, test, analyze, commit `feat: read what happened in the business`.

### Task 9: Verify

- [ ] `flutter analyze`, full `flutter test`, debug build; push; open the PR against `web-parity-r2` with no attribution; release build and install when the phone is connected.
