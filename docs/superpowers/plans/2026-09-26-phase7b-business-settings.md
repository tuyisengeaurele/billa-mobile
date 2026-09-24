# Phase 7b: Business Settings Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let a business owner maintain the business details, payment and signatory information, document behaviour, numbering, logo and brand, and see the subscription status.

**Architecture:** A new `BusinessSettingsRepository` (explicit nulls, unlike the onboarding repository) behind an auto-disposing `businessSettingsProvider` keyed to the active business. Section screens seed their forms once the data is loaded and share the `_runAction`/banner/Retry shape. The image picker becomes a shared core provider; the existing logo pipeline service is reused.

**Tech Stack:** Flutter, `flutter_riverpod` 2.6.1, `go_router`, `dio`, `freezed`, `mocktail`.

**Spec:** `docs/superpowers/specs/2026-09-26-phase7b-business-settings-design.md`

## Global Constraints

- Commits authored solely as `Ange Aurele TUYISENGE <tuyisengeauris@gmail.com>`; no trailers and no tooling attribution anywhere.
- Small, single-sentence, conventional-commit-style messages, one logical change per commit.
- Comments explain *why*, never *what*, and never point at plan or spec documents.
- No dead ends: every action has a specific error message and a retry path.
- Every task ends with `flutter analyze` clean and `flutter test` passing.
- Read auth state with `.valueOrNull`, never `.value`.
- Mocked Future-returning methods that should fail use `thenAnswer((_) async => throw ...)`, not `thenThrow`, when the call happens outside a try block.
- Keep the `if (x != null) 'key': x` map-entry form; the pinned analyzer can't parse null-aware entries.
- Do not run `dart format` with its default width; the codebase uses 120 columns.
- MoMo credentials, plan checkout, the activity log, and the onboarding wizard are out of scope.

---

### Task 1: Shared image picker and error codes

**Files:**
- Move: `lib/features/account/presentation/providers/avatar_picker_provider.dart` to `lib/core/media/image_picker_provider.dart` (rename `avatarPickerProvider` to `imagePickerProvider`, keep the `PickedImage` record type)
- Modify: `lib/features/account/presentation/screens/profile_screen.dart`, `test/features/account/presentation/screens/profile_screen_test.dart`
- Modify: `lib/core/errors/action_errors.dart`, `test/core/errors/action_errors_test.dart`

**Interfaces:**
- Produces: `imagePickerProvider`; `not_owner` ("Only the business owner can change this"); `forbidden` ("You don't have permission to use that file").

- [ ] **Step 1:** Move and rename with `git mv` and `sed`, update the two import sites, run `flutter analyze` and the account tests, commit `refactor: share the image picker provider across features`.
- [ ] **Step 2:** Add the two error-code assertions, watch them fail, add the cases, run, commit `feat: map owner-only and forbidden errors to user-facing messages`.

---

### Task 2: Domain models

**Files:**
- Create: `lib/features/business_settings/domain/document_template.dart`, `business_settings.dart`, `document_sequence.dart`, `subscription_status.dart`
- Test: `test/features/business_settings/domain/business_settings_models_test.dart`

**Interfaces:**
- Produces: `enum DocumentTemplate {minimal, premium, classic}` with `documentTemplateFromJson`/`documentTemplateToJson` (uppercase wire) and `documentTemplateLabel`; `BusinessSettings` (id, name, tin?, industry?, phone?, email?, address?, rraEbmNumber?, bankName?, bankAccountNumber?, signatoryName?, signatoryTitle?, signatureUrl?, logoUrl?, primaryColor?, accentColors default `[]`, remindersEnabled default true, reminderCadenceDays default 7, requireApprovalToFinalize default false, defaultTemplate default minimal); `DocumentSequence{type: DocumentType, prefix, nextNumber, resetYearly}` reusing `documentTypeFromJson`/`documentTypeToJson`; `SubscriptionStatus{plan?, trialEndsAt?, currentPeriodEnd?, activeUntil?}` with a `bool get isPaid`.

- [ ] **Step 1:** Tests: `BusinessSettings.fromJson` with a minimal `{id, name}` uses the defaults; a full payload maps template and booleans; `DocumentSequence` round-trips `DELIVERY_NOTE`; an unknown template throws `ArgumentError`; `SubscriptionStatus` with a `currentPeriodEnd` is paid and with only `trialEndsAt` is not.
- [ ] **Step 2:** Implement, `dart run build_runner build --delete-conflicting-outputs`, run, analyze, commit `feat: add business settings domain models`.

---

### Task 3: Repository

**Files:**
- Create: `lib/features/business_settings/domain/business_settings_repository.dart`, `data/business_settings_repository_impl.dart`, `presentation/providers/business_settings_repository_provider.dart`
- Test: `test/features/business_settings/data/business_settings_repository_impl_test.dart`

**Interfaces:** the abstract class from the spec; `businessSettingsRepositoryProvider`.

- [ ] **Step 1:** Tests with a mocked `Dio`: `get` parses `{business}`; `updateDetails` PATCHes every key with `null` for cleared ones (assert the exact map, including `'tin': null`); `updatePayments` and `updateDocumentSettings` send their exact keys with `defaultTemplate` uppercase; `uploadSignature` posts multipart field `signature`; `setSignature(null)` PATCHes `{signatureUrl: null}`; `sequences` and `saveSequences` map all six types and PUT the full list with wire type names; `subscription` GETs `/billing/status`.
- [ ] **Step 2:** Implement in the style of `TeamRepositoryImpl`, run, analyze, commit `feat: add the business settings repository`.

---

### Task 4: Provider and settings hub

**Files:**
- Create: `lib/features/business_settings/presentation/providers/business_settings_provider.dart`, `presentation/screens/business_settings_screen.dart`
- Modify: `lib/features/auth/presentation/providers/active_business_provider.dart` (add `currentBusinessProvider`)
- Test: `test/features/business_settings/presentation/screens/business_settings_screen_test.dart`, `test/features/business_settings/support.dart`

**Interfaces:**
- Produces: `businessSettingsProvider` (`FutureProvider.autoDispose<BusinessSettings>`, watches `activeBusinessIdProvider`); `subscriptionProvider` (`FutureProvider.autoDispose<SubscriptionStatus>`); `currentBusinessProvider` (`Provider<Business?>`); `BusinessSettingsScreen`. Keys: `bs-details`, `bs-payments`, `bs-documents`, `bs-numbering`, `bs-logo`.
- Test support: a `businessSettingsApp` helper like `accountApp`, stubbing the section routes.

- [ ] **Step 1:** Tests: the hub lists the five rows and each opens its route; the subscription card shows "Free trial until 2026-03-01" for a trial and "Monthly plan, active until 2026-04-01" when paid; a failed settings load shows Retry that reloads; a failed subscription load does not hide the rows.
- [ ] **Step 2:** Implement, run, analyze, commit `feat: add the business settings hub`.

---

### Task 5: Details and payments screens

**Files:**
- Create: `lib/features/business_settings/presentation/screens/business_details_screen.dart`, `payments_screen.dart`
- Test: matching test files under `test/features/business_settings/presentation/screens/`

**Interfaces:**
- Produces: `BusinessDetailsScreen`, `PaymentsScreen`. Keys: `bd-name`, `bd-tin`, `bd-industry`, `bd-phone`, `bd-email`, `bd-address`, `bd-rra`, `bd-save`; `pay-bank`, `pay-account`, `pay-signatory-name`, `pay-signatory-title`, `pay-save`, `pay-signature-change`, `pay-signature-remove`.

- [ ] **Step 1:** Tests: a form seeded from settings once loaded; save sends trimmed values with empty as null and invalidates the provider; a blank name disables Save; an invalid email blocks Save with a message; a name change updates the auth business name; a `not_owner` error shows its message with Retry; the signature Change uploads then calls `setSignature(url)`, Remove calls `setSignature(null)`, an `invalid_file_type` shows its message.
- [ ] **Step 2:** Implement with the wrapper-then-form pattern from the profile screen, run, analyze, commit in two commits: `feat: add the business details screen`, `feat: add the payments and signatory screen`.

---

### Task 6: Documents and numbering screens

**Files:**
- Create: `lib/features/business_settings/presentation/screens/document_settings_screen.dart`, `numbering_screen.dart`
- Test: matching test files

**Interfaces:**
- Produces: `DocumentSettingsScreen`, `NumberingScreen`. Keys: `ds-template-<name>`, `ds-approval`, `ds-reminders`, `ds-cadence`, `ds-save`; `num-prefix-<TYPE>`, `num-next-<TYPE>`, `num-yearly-<TYPE>`, `num-save`.

- [ ] **Step 1:** Tests: documents screen saves the chosen template and switches, the cadence field is disabled while reminders are off and rejects 0 and 91; numbering shows six cards, a blank prefix, an 11-character prefix, or a next number of 0 disables Save with the reason shown, and a valid edit sends all six sequences with wire type names.
- [ ] **Step 2:** Implement, run, analyze, commit in two commits: `feat: add the document settings screen`, `feat: add the numbering screen`.

---

### Task 7: Logo and brand screen

**Files:**
- Create: `lib/features/business_settings/presentation/providers/logo_pipeline_provider.dart`, `presentation/screens/logo_screen.dart`
- Test: `test/features/business_settings/presentation/screens/logo_screen_test.dart`

**Interfaces:**
- Produces: `logoPipelineServiceProvider` (`Provider.autoDispose<LogoPipelineService>`); `LogoScreen`. Keys: `logo-choose`, `logo-confirm`.

- [ ] **Step 1:** Tests with a fake pipeline service: choosing an image shows each stage label then the extracted colour and Confirm; Confirm calls the service and invalidates the settings; backing out of the picker does nothing; a stage failure shows its mapped message with Retry that re-runs the same image; a confirm failure shows its message with Retry.
- [ ] **Step 2:** Implement (stream errors are caught and surfaced, never left as a stalled spinner), run, analyze, commit `feat: add the logo and brand screen`.

---

### Task 8: Entry row, routes, and verification

**Files:**
- Modify: `lib/features/account/presentation/screens/settings_screen.dart`, `lib/app/router.dart`, `test/features/account/presentation/screens/settings_screen_test.dart`, `test/app/router_test.dart`

**Interfaces:** routes `/settings/business`, `/settings/business/details`, `/settings/business/payments`, `/settings/business/documents`, `/settings/business/numbering`, `/settings/business/logo`; a `settings-business` row shown only when `isOwnerOfActiveBusinessProvider` is true.

- [ ] **Step 1:** Tests: the row is present for an owner and absent for a non-owner; through the real router, the row opens the hub and each hub row opens its screen.
- [ ] **Step 2:** Implement, run the full suite, analyze, commit `feat: add business settings to the settings hub and router`.
- [ ] **Step 3:** `flutter analyze` clean, `flutter test` passing, `flutter build apk --debug` succeeds; iOS verification stays deferred to macOS.

## Definition of done

Analyze is clean, the suite passes, the debug APK builds, and a manual run as an owner shows: Settings has a Business settings row (absent for non-owners); the hub shows the subscription status; details, payment and signatory, and document settings save and reload with cleared fields actually cleared; numbering saves all six sequences with clear validation; a new logo runs through its stages and updates the brand colour; every failure shows a specific message with a working Retry.
