# Round 1A Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give the app a persistent five-tab glass navigation shell, a reorganised home, a profile hub, a payments tab, a proper verification-code screen, and a login that survives idle time.

**Architecture:** `StatefulShellRoute.indexedStack` with the existing tab-root paths; a `GlassSurface` primitive with a low-end fallback; the nav bar, quick-create button, and sheet as shell widgets; each tab root redesigned in place; a reusable `CodeInput`; refresh-first session checks in the auth repository plus a resume observer.

**Tech Stack:** Flutter, `flutter_riverpod` 2.6.1, `go_router` 17, `dio`, `animations`, `mocktail`.

**Spec:** `docs/superpowers/specs/2026-10-01-round1a-shell-design.md`

## Global Constraints

- Commits authored solely as `Ange Aurele TUYISENGE <tuyisengeauris@gmail.com>`; no trailers and no tooling attribution anywhere, including PR descriptions.
- Small, single-sentence conventional commits (lowercase type, imperative, no period), one logical change per commit; run the full suite before every commit and never commit a failing test.
- Comments explain *why*, never *what*, and contain no em dashes anywhere in code, tests, or docs.
- No dead ends: every screen and section has a skeleton, a specific error with Retry, and a real empty state.
- Motion is subtle: 150 to 300 ms, no bounce. Haptics only on selection and confirmation.
- Keep existing widget keys where a test depends on them; update tests deliberately when a screen is redesigned.
- Read auth state with `.valueOrNull`. `setState` callbacks never return a Future.
- Do not run `dart format` at its default width; the codebase uses 120 columns. Do not stage line-ending noise from regenerated files.
- Out of scope: Round 1B to 4 features, Apple sign-in, multi-account, a longer mobile refresh window.

---

### Task 1: Logins that survive idle time

**Files:** Modify `lib/features/auth/data/auth_repository_impl.dart`, `lib/features/auth/domain/auth_repository.dart` (`refreshSession`), `lib/features/auth/presentation/providers/auth_controller.dart`, `lib/app/app.dart`; tests for each.

- [ ] **Step 1:** Tests: `me()` on a 401 refreshes then retries and returns the authenticated status; when the refresh itself returns 401 it returns unauthenticated; a network error during refresh rethrows (the launch retry screen handles it); it refreshes at most once per call. A resume observer test: resuming after more than 10 minutes calls `refreshSession` once, resuming sooner does not, a 401 from it signs out, a network failure changes nothing.
- [ ] **Step 2:** Implement (`refreshSession()` posts `/auth/refresh`; the controller keeps `lastRefreshAt`; `App` becomes a `WidgetsBindingObserver`). Run the suite, commit `fix: refresh an expired login before treating it as signed out` and `feat: refresh the session quietly when the app resumes`.

---

### Task 2: Glass surface

**Files:** Create `lib/core/widgets/glass_surface.dart`, `lib/core/platform/glass_support.dart` (provider deciding blur), `test/core/widgets/glass_surface_test.dart`.

**Interfaces:** `GlassSurface({child, borderRadius, padding, tintOpacity})`; `glassBlurEnabledProvider` (`Provider<bool>`, overridable in tests).

- [ ] **Step 1:** Tests: with blur enabled it contains a `BackdropFilter`; disabled it does not and uses a more opaque tint; light and dark tints come from `AppColors`; it paints a hairline border; the child is laid out inside the padding.
- [ ] **Step 2:** Implement with `RepaintBoundary`, decide blur by Android SDK (via `dart:io` `Platform.version` parsing is unreliable, so use `device_info_plus`'s `AndroidDeviceInfo.version.sdkInt`, read once at startup in `main` and injected), commit `feat: add a glass surface with a low-end fallback`.

---

### Task 3: Navigation shell

**Files:** Create `lib/app/shell/app_shell.dart`, `glass_nav_bar.dart`, `quick_create_button.dart`, `quick_create_sheet.dart`; modify `lib/app/router.dart`, `DocumentListScreen` (re-apply filters on change, remove the FAB), `lib/features/dashboard/presentation/providers/dashboard_provider.dart` consumers for the badge; tests under `test/app/shell/`.

**Interfaces:** five tabs in the order Home, Documents, Customers, Payments, Profile; `overdueCountProvider` (from the dashboard summary); `quickCreateActions` list used by the sheet.

- [ ] **Step 1:** Tests: the bar shows five labelled items and the selected one is marked; tapping another tab switches and each keeps its own scroll and state; tapping the selected tab pops that branch to its root; the bar is absent on a pushed detail route and back again after popping; the Payments badge shows the overdue count and hides at zero; the "+" shows on four tabs and not on Profile; the sheet lists every document type, New customer, and Record payment and each navigates correctly; Record payment lets you choose an outstanding invoice first and handles an empty list with a message.
- [ ] **Step 2:** Implement, commit in steps: `feat: add the glass tab bar`, `feat: add the quick-create sheet and button`, `feat: move the app into a five-tab navigation shell`.

---

### Task 4: Home

**Files:** Modify `lib/features/dashboard/presentation/screens/home_screen.dart` and its widgets, tests.

- [ ] **Step 1:** Tests: greeting by time of day; tapping the business name opens the switcher; the avatar opens Profile; search and bell buttons behave as before; the hero shows the figure, trend chip, and the three actions each navigating correctly; Collected and Outstanding tiles; attention cards switch tabs with filters; the shortcut grid and account icon are gone; sections still fail and retry independently.
- [ ] **Step 2:** Implement, commit `feat: reorganise home around the invoiced figure and quick actions`.

---

### Task 5: Profile tab

**Files:** Modify `lib/features/account/presentation/screens/settings_screen.dart` and tests.

- [ ] **Step 1:** Tests: header shows avatar, name, email, and current business with a switch action; Business section shows Business settings and Team only for owners, plus Items and Businesses; Account section rows navigate; Sign out confirms.
- [ ] **Step 2:** Implement, commit `feat: turn settings into a profile hub`.

---

### Task 6: Payments tab

**Files:** Modify `lib/features/receivables/presentation/screens/receivables_screen.dart` and tests.

- [ ] **Step 1:** Tests: the summary card shows total outstanding and overdue count; aging chips filter the list; empty, error, and pull-to-refresh behaviour is kept.
- [ ] **Step 2:** Implement, commit `feat: show totals and aging filters on the payments tab`.

---

### Task 7: Verification code screen

**Files:** Create `lib/core/widgets/code_input.dart`, `lib/features/auth/presentation/widgets/verification_view.dart`, tests; modify the login screen, two-factor setup, and the turn-off prompt.

**Interfaces:** `CodeInput({length = 6, onCompleted, onChanged, controller, hasError})` with a public shake trigger via a key or `ValueNotifier`; `VerificationView({email, onSubmit, onBack, expiresIn})`.

- [ ] **Step 1:** Tests: typing fills boxes and focus follows; pasting six digits fills and completes; completing calls `onCompleted` once; a wrong code shakes and clears; the countdown ticks and at zero calls expiry; "Use a backup code" swaps to a text field that submits on Confirm; "Change" goes back to login; the masked email is shown.
- [ ] **Step 2:** Implement, wire login, setup, and turn-off, commit in steps: `feat: add a six-box code input`, `feat: redesign the verification code screen`, `feat: use the code input when setting up two-factor`.

---

### Task 8: Verification

- [ ] `flutter analyze` clean, `flutter test` passing, `flutter build apk --debug` succeeds, then install on the Tecno CC7 and check the shell and glass on the real device.
- [ ] Push `round1a-shell`, open a PR against `polish-round0` with no attribution line, update the roadmap memory.

## Definition of done

The app opens on a five-tab glass shell, the login survives idle time, Home leads with the invoiced figure and actions, Profile and Payments are real tab roots, and the verification screen is a modern code entry. Analyze is clean, the suite passes, and the debug APK builds and runs on the device.
