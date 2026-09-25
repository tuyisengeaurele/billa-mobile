# Auth Polish, Splash, Transitions, and Document Language Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the misleading 2FA error, restyle login and register (filled fields, password visibility toggle, Google button with the real logo), add an animated-logo splash, add subtle transitions, and let the user pick English or French when sharing a PDF or sending a document by email.

**Architecture:** Small reusable widgets in `core/widgets` (`PasswordField`, `GoogleSignInButton`, `AnimatedBrandMark`) used by the auth screens; a global filled `InputDecorationTheme`; motion helpers (`FadeThroughPage`, a fade-and-slide `StepSwitcher`) applied where content swaps; `DocumentLanguage` added to the document model and threaded through the repository's PDF and send calls.

**Tech Stack:** Flutter, `flutter_riverpod` 2.6.1, `go_router`, `dio`, `flutter_svg`, `animations`, `mocktail`.

**Spec:** The design agreed in chat on 2026-09-29 (screenshots of the Tecno CC7 run and the reference login and splash screens).

## Global Constraints

- Commits authored solely as `Ange Aurele TUYISENGE <tuyisengeauris@gmail.com>`; no trailers and no tooling attribution anywhere, including PR descriptions.
- Small, single-sentence conventional commits (lowercase type, imperative, no period), one logical change per commit; run the tests before every commit.
- Comments explain *why*, never *what*, and never point at plan or spec documents.
- No dead ends: every failure has a specific message and a way forward.
- Motion is subtle: short (150 to 300 ms), no bounce, no long staggers.
- Money and typography rules unchanged; colours come from `AppColors`.
- Keep widget keys already used by tests (`login-email`, `login-password`, `login-submit`, `login-2fa-code`, `register-*`).
- Do not run `dart format` at its default width; the codebase uses 120 columns.
- Apple sign-in and "keep me signed in" are out of scope; the app-interface language is out of scope (only the document language).

---

### Task 1: Say why a verification code failed

**Files:** Modify `lib/features/auth/presentation/screens/login_screen.dart`, `lib/core/errors/action_errors.dart`, and their tests.

- [ ] **Step 1:** Tests: a 401 `invalid_code` shows "That code isn't right — try again" and stays on the code form; a 401 `invalid_challenge` returns to the login form with "This sign-in expired — log in again"; a 429 shows "Too many attempts — wait a few minutes and try again"; a connection failure shows the connection message; none of them show "incorrect or expired".
- [ ] **Step 2:** Add `invalid_challenge` and a 429 rule to `describeActionError`; replace the catch-all in `_submitTwoFactorCode` with `describeActionError`, return to the login form on `invalid_challenge`, and `debugPrint` the underlying error in debug builds so an unexpected cause shows up in the run log.
- [ ] **Step 3:** Run tests, analyze, commit `fix: say why a verification code was rejected`.

---

### Task 2: Show and hide password

**Files:** Create `lib/core/widgets/password_field.dart`, `test/core/widgets/password_field_test.dart`; modify the login and register screens.

**Interfaces:** `PasswordField({key, controller, label, onChanged, textInputAction})` obscured by default with a trailing eye button (tooltip "Show password"/"Hide password") that toggles visibility without losing text or focus.

- [ ] **Step 1:** Widget tests: obscured by default; tapping the eye reveals, tapping again hides; text is preserved; the tooltip flips.
- [ ] **Step 2:** Implement, use it for login password, register password, and confirm password (keeping their keys), run the auth tests, commit `feat: add a show and hide toggle to password fields`.

---

### Task 3: Google button with the real logo

**Files:** Modify `pubspec.yaml` (`flutter_svg`); create `lib/core/widgets/google_sign_in_button.dart`, its test; modify login and register.

**Interfaces:** `GoogleSignInButton({onPressed, label = 'Continue with Google', isLoading})`, an outlined full-width button with the multicolour "G" drawn from the official vector paths (`SvgPicture.string`), 20 px, before the label.

- [ ] **Step 1:** Tests: renders the label and a `SvgPicture`; calls `onPressed`; disabled while loading.
- [ ] **Step 2:** Implement, replace the two `OutlinedButton`s, run tests, commit `feat: show the Google logo on the sign-in button`.

---

### Task 4: Modern login and register

**Files:** Modify `lib/app/theme/app_theme.dart` (filled, rounded `InputDecorationTheme`), the login and register screens; create `lib/features/auth/presentation/widgets/auth_layout.dart`; update tests only where text changes.

**Interfaces:** `AuthLayout({title, subtitle, children})` giving the brand mark, heading, and consistent spacing; fields get leading icons (mail, lock); headings "Welcome back" and "Create your account"; the divider reads "or continue with"; links are "Don't have an account? Sign up" and "Already have an account? Log in"; errors show in an `ActionErrorBanner`-style inline block instead of bare text.

- [ ] **Step 1:** Adjust the theme test for the input decoration; add tests for the new headings, links, and inline error.
- [ ] **Step 2:** Implement, run the whole suite, commit in two commits: `feat: use filled rounded inputs across the app`, `feat: restyle the login and register screens`.

---

### Task 5: Animated splash

**Files:** Add `assets/logo.png` (copy of the root logo) and register it in `pubspec.yaml`; create `lib/core/widgets/animated_brand_mark.dart`, its test; modify `lib/app/theme/bootstrap_screen.dart`.

**Interfaces:** `AnimatedBrandMark({size = 96})`: the logo fades and scales in over about 600 ms, then breathes with a soft glow behind it in the primary colour; the wordmark "Billa" and the tagline "Invoices, quotes and receipts for your business" beneath it stay static. The loading and error states of the bootstrap screen keep their behaviour.

- [ ] **Step 1:** Tests: the mark renders the asset; after settling under `pump` steps the opacity is 1; the bootstrap screen shows the static wordmark and tagline, and the error state still shows Retry. Repeating animations use `pump(duration)` rather than `pumpAndSettle`.
- [ ] **Step 2:** Implement, run tests, commit `feat: animate the logo on the splash screen`.

---

### Task 6: Subtle transitions

**Files:** Create `lib/core/widgets/step_switcher.dart`, `lib/app/fade_through_page.dart`; modify `router.dart`, the onboarding screen, the login screen, the home sections; tests for each helper.

**Interfaces:** `StepSwitcher({child, key})` an `AnimatedSwitcher` with a 220 ms fade plus a 16 px horizontal slide; `FadeThroughPage` for `/`, `/login`, `/register`, `/onboarding`, `/bootstrap` (top-level switches); dashboard sections and list content fade in over 200 ms when they replace a skeleton.

- [ ] **Step 1:** Tests: `StepSwitcher` shows the new child after settling and leaves no old child behind; a top-level route uses `FadeThroughTransition`; onboarding steps and the login-to-2FA swap still work through their existing tests.
- [ ] **Step 2:** Implement, run the whole suite, commit in small steps: `feat: fade through between top-level screens`, `feat: animate wizard steps and the verification form`, `feat: fade content in as it loads`.

---

### Task 7: Language picker for sharing and sending

**Files:** Modify `lib/features/documents/domain/document_enums.dart` (`DocumentLanguage {en, fr}` with JSON helpers and labels "English" and "Français"), `document.dart` (`language`, default en), `document_repository.dart`, `document_repository_impl.dart`, `document_detail_screen.dart`; create `lib/features/documents/presentation/widgets/language_picker_sheet.dart`; tests for each.

**Interfaces:** `fetchPdfBytes(id, {DocumentLanguage? language})` sends `?language=EN|FR`; `send(id, {DocumentLanguage? language})` sends `{language}` in the body; `showLanguagePicker(context, {required DocumentLanguage initial}) -> Future<DocumentLanguage?>` a small bottom sheet with two rows and a check on the current one, returning null on dismiss.

- [ ] **Step 1:** Tests: the model parses `language` and defaults to English; the repository sends the query parameter and body field; tapping Share PDF opens the picker preselected to the document's language and shares in the chosen one; cancelling shares nothing; the same for Send, keeping its confirmation about the recipient.
- [ ] **Step 2:** Implement, run tests, commit in steps: `feat: read the document language`, `feat: send the chosen language with the PDF and email`, `feat: ask for the language before sharing or sending`.

---

### Task 8: Verification and hand-off

- [ ] `flutter analyze` clean, `flutter test` passing, `flutter build apk --debug` succeeds; hot-restart on the Tecno CC7 for a visual check when the user is ready.
- [ ] Push `auth-polish`, open a PR against `google-cancel` with no attribution line, and update the known-gaps memory.

## Definition of done

Login and register look modern in light and dark, passwords can be shown, the Google button carries its logo, the splash shows an animated logo over static text, transitions are subtle and consistent, a rejected verification code says why, and Share PDF and Send email offer English or French. Analyze is clean, the suite passes, and the debug APK builds.
