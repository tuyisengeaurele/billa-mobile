# Phase 7b: Business Settings — Design

## Context

Second of three sub-phases of phase 7 (7a account, 7b business settings, 7c
polish). Until now the only business editing on mobile is the onboarding
wizard, which writes a handful of fields once. 7b gives the owner a place to
maintain everything the documents and PDFs depend on.

The contract was read from the sibling `billa` repo:

- `server/src/routes/business.ts`, all owner-only (403 `not_owner`):
  `GET /business` (`{business}` with every column), `PATCH /business` (any
  non-empty subset of `name, tin, industry, phone, email, address,
  rraEbmNumber, bankName, bankAccountNumber, signatoryName, signatoryTitle,
  signatureUrl, remindersEnabled, reminderCadenceDays (1-90),
  requireApprovalToFinalize, defaultTemplate (MINIMAL | PREMIUM | CLASSIC),
  primaryColor`; every nullable text field accepts `null` to clear it and
  `email` must be a valid address), `GET|PUT /business/sequences` (six
  document types, each `{type, prefix (1-10 chars), nextNumber (>= 1),
  resetYearly}`; `PUT` takes a partial, duplicate-free list and always
  returns all six merged with defaults), `POST /business/logo` and
  `/business/signature` (multipart, 5 MB, images only: 400 `upload_failed` /
  `no_file` / `invalid_file_type`; 201 `{url}`), and the logo pipeline
  `/business/logo/remove-background`, `/logo/extract-colors`,
  `/logo/confirm`.
- `server/src/routes/billing.ts`: `GET /billing/status` returns `{plan,
  trialEndsAt, currentPeriodEnd, activeUntil}` (plan is `MONTHLY`, `ANNUAL`,
  or null; dates are ISO strings or null).

## Non-goals

- MTN MoMo credentials, plan checkout, and any payment flow (subscription is
  read-only).
- The activity log and creating businesses (the latter shipped in phase 6).
- Changing the onboarding wizard or its repository.

## Architecture

New code lives in `lib/features/business_settings/`. The existing
`BusinessRepository` (onboarding) stays as it is: it drops null fields, so it
cannot clear a value, and settings needs exactly that. A new
`BusinessSettingsRepository` sends every field of a section explicitly, with
`null` for a cleared one, and returns a `BusinessSettings` model. `Business`
stays small because it lives inside the auth state.

```dart
abstract class BusinessSettingsRepository {
  Future<BusinessSettings> get();
  Future<BusinessSettings> updateDetails({required String name, String? tin, String? industry,
      String? phone, String? email, String? address, String? rraEbmNumber});
  Future<BusinessSettings> updatePayments({String? bankName, String? bankAccountNumber,
      String? signatoryName, String? signatoryTitle});
  Future<BusinessSettings> updateDocumentSettings({required DocumentTemplate defaultTemplate,
      required bool requireApprovalToFinalize, required bool remindersEnabled,
      required int reminderCadenceDays});
  Future<String> uploadSignature(List<int> bytes, String filename);
  Future<BusinessSettings> setSignature(String? url);
  Future<List<DocumentSequence>> sequences();
  Future<List<DocumentSequence>> saveSequences(List<DocumentSequence> sequences);
  Future<SubscriptionStatus> subscription();
}
```

`businessSettingsProvider` is a `FutureProvider.autoDispose` that watches the
active business id, so switching business never shows the previous one's
settings; a successful save invalidates it. Empty text is trimmed and sent as
`null`, because the backend rejects empty strings and `null` is how a field
is cleared. A name change also calls `AuthController.setBusiness` so the home
header follows.

The image picker moves from the account feature into
`core/media/image_picker_provider.dart` as `imagePickerProvider`, since the
avatar, the signature, and the logo all use it and none of them owns it.
`LogoPipelineService` is reused as is, behind a provider so tests can supply
a fake.

## Screens

Everything is owner-only. Settings shows a "Business settings" row only when
`isOwnerOfActiveBusinessProvider` is true, and a stale deep link still gets
the server's `not_owner`, mapped to "Only the business owner can change
this".

- **`BusinessSettingsScreen`** (`/settings/business`): a subscription card
  (plan, active until, or "Free trial until ..."), then rows Business
  details, Payments and signatory, Documents, Numbering, Logo and brand. Load
  failure shows Retry.
- **Business details** (`/settings/business/details`): name (required) plus
  TIN, industry, phone, email (validated), address, RRA EBM number.
- **Payments and signatory** (`/settings/business/payments`): bank name,
  account number, signatory name and title, and the signature image with
  Change and Remove.
- **Documents** (`/settings/business/documents`): default template, require
  approval to finalize, reminders on/off, and reminder cadence in days
  (1-90, only editable while reminders are on).
- **Numbering** (`/settings/business/numbering`): one card per document type
  with prefix, next number, and reset yearly, saved in one request. Blank
  prefix, a prefix over 10 characters, or a next number below 1 blocks Save
  and shows why, so a server rejection is rare.
- **Logo and brand** (`/settings/business/logo`): current logo and colour,
  Choose a new logo runs upload, background check, and colour extraction with
  progress, then Confirm. Any stage failure shows its message with Retry
  instead of stalling.

All forms follow the established shape: forms seed once the data is loaded,
one `_runAction` with the shared banner and Retry, and a "Saved" snackbar.

## Errors

`describeActionError` gains `not_owner` and `forbidden` ("You don't have
permission to use that file"). The existing `invalid_file_type`,
`upload_failed`, and `no_file` cover uploads.

## Testing strategy

1. Move the image picker to `core/media`; add error codes.
2. Models (`BusinessSettings`, `DocumentTemplate`, `DocumentSequence`,
   `SubscriptionStatus`) with JSON tests.
3. `BusinessSettingsRepository` with a mocked `Dio` (explicit nulls, sequence
   list, signature multipart).
4. Provider, the current-business helper, and the settings hub screen.
5. Details and payments screens.
6. Documents and numbering screens.
7. Logo and brand screen.
8. Settings entry row, routes, router tests, and final verification
   (`flutter analyze`, `flutter test`, `flutter build apk --debug`).
