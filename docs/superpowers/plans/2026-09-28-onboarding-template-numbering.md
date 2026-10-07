# Onboarding: Document Style and Numbering Steps

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extend the onboarding wizard from two steps (details, logo) to four by adding a document template step and a numbering step, completing onboarding only after the last step.

**Architecture:** The wizard keeps its single `_guard` for failures. The numbering form is extracted from the business settings screen into a public `NumberingForm` that takes a save callback, so the settings screen and the wizard share it. A new `setDefaultTemplate` repository method sends only the template, leaving reminder and approval settings untouched.

**Tech Stack:** Flutter, `flutter_riverpod` 2.6.1, `dio`, `mocktail`.

**Spec:** The design agreed in chat on 2026-09-28: four steps (Details, Logo, Document style, Numbering), "Skip this step" on each, onboarding completes only after the last step or through "Skip onboarding"; template is a three-way choice saved with `PATCH /business {defaultTemplate}`; numbering reuses the six-card form saved with one `PUT /business/sequences`.

## Global Constraints

- Commits authored solely as `Ange Aurele TUYISENGE <tuyisengeauris@gmail.com>`; no trailers and no tooling attribution anywhere, including PR descriptions.
- Small, single-sentence conventional commits (lowercase type, imperative, no period), one logical change per commit.
- Comments explain *why*, never *what*, and never point at plan or spec documents.
- No dead ends: every step has a specific error with a working Retry; a failed save never advances the step.
- Every task ends with `flutter analyze` clean and `flutter test` passing; run the tests before committing.
- Do not run `dart format` at its default width; the codebase uses 120 columns.
- Mocked Future methods that fail use `thenAnswer((_) async => throw ...)`.

---

### Task 1: Extract the numbering form

**Files:**
- Modify: `lib/features/business_settings/presentation/screens/numbering_screen.dart`
- Create: `lib/features/business_settings/presentation/widgets/numbering_form.dart`
- Test: `test/features/business_settings/presentation/screens/numbering_screen_test.dart` (unchanged, must stay green)

**Interfaces:**
- Produces: `NumberingForm({required List<DocumentSequence> initial, required Future<void> Function(List<DocumentSequence>) onSave, String saveLabel = 'Save'})`, keeping the validation, the six cards, the `num-*` keys, and its own error banner with Retry.

- [ ] **Step 1:** Move `_Row` and `_NumberingForm` into the new public widget; the form calls `onSave` with the six sequences and shows any thrown error through `describeActionError` with Retry.
- [ ] **Step 2:** `NumberingScreen` passes an `onSave` that saves, invalidates `sequencesProvider`, and shows the "Numbering saved" snackbar.
- [ ] **Step 3:** Run the settings tests, analyze, commit `refactor: share the numbering form between settings and onboarding`.

---

### Task 2: Save only the default template

**Files:**
- Modify: `lib/features/business_settings/domain/business_settings_repository.dart`, `data/business_settings_repository_impl.dart`, `test/features/business_settings/data/business_settings_repository_impl_test.dart`

**Interfaces:**
- Produces: `Future<BusinessSettings> setDefaultTemplate(DocumentTemplate template)` sending `{'defaultTemplate': 'CLASSIC'}` style uppercase.

- [ ] **Step 1:** Test that `setDefaultTemplate(DocumentTemplate.premium)` PATCHes exactly `{'defaultTemplate': 'PREMIUM'}` and parses the returned business; watch it fail.
- [ ] **Step 2:** Implement through the existing private `_patch`, run, commit `feat: add a repository call that saves only the default template`.

---

### Task 3: The wizard steps

**Files:**
- Create: `lib/features/onboarding/presentation/widgets/template_step.dart`, `numbering_step.dart`
- Modify: `lib/features/onboarding/presentation/screens/onboarding_screen.dart`
- Test: `test/features/onboarding/presentation/widgets/template_step_test.dart`, `numbering_step_test.dart`, `test/features/onboarding/presentation/screens/onboarding_screen_test.dart`

**Interfaces:**
- Produces: `TemplateStep({required Future<void> Function(DocumentTemplate) onSaved, required VoidCallback onSkip})` with keys `onboarding-template-<name>`, `onboarding-template-continue`, `onboarding-template-skip`; `NumberingStep({required Future<void> Function(List<DocumentSequence>) onSaved, required VoidCallback onSkip})` that loads `sequencesProvider` (skeleton, load error with Retry) and hosts `NumberingForm` with save label "Finish", plus key `onboarding-numbering-skip`.
- Wizard: title `Step N of 4`; logo `onDone` and `onSkip` advance to step 3 instead of completing; step 3 saves the template through `_guard` then advances; step 4 saves the sequences then completes onboarding (through `_completeAndRefresh`); "Skip this step" on step 4 and "Skip onboarding" complete it.

- [ ] **Step 1:** Tests, watching each fail first:
  - template: Minimal is selected by default; choosing Classic and Continue calls `onSaved(classic)`; Skip calls `onSkip`.
  - numbering: shows a skeleton then the six cards; a failed load shows Retry that reloads; Finish saves all six and completes; a failed save shows its message with Retry and does not complete; a blank prefix blocks Finish.
  - wizard: the title counts to four; the logo step no longer completes onboarding (advances to the template step); a failed template save shows its message, stays on step 3, and Retry advances; completing happens only after the numbering save or a skip; "Skip onboarding" still completes from any step.
- [ ] **Step 2:** Implement the two steps and rewire the wizard, run the onboarding and business settings tests, then the full suite and analyze.
- [ ] **Step 3:** Commit in two commits: `feat: add the document style and numbering onboarding steps`, then `feat: complete onboarding after the numbering step`.

---

### Task 4: Verification and notes

- [ ] `flutter analyze` clean, `flutter test` passing, `flutter build apk --debug` succeeds.
- [ ] Update the known-gaps memory (the onboarding template and numbering item is closed), push `onboarding-template-numbering`, and open a PR against `phase7c-polish` with no attribution line.

## Definition of done

A new owner can walk through details, logo, document style, and numbering, skipping any step, and only lands on the dashboard after the last step or "Skip onboarding". Every save failure shows a specific message with a working Retry and never advances a step. Analyze is clean, the suite passes, and the debug APK builds.
