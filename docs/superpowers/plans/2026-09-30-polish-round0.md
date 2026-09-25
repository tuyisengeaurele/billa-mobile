# Polish Round 0 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix what was noticed on the Tecno CC7 and bring the app's copy and motion up to a consistent, modern standard: one splash, no em dashes, filled inputs that don't overlap, a neutral AppBar, item type-ahead on invoice lines, slide-up sheets in place of dialogs, and pull-to-refresh on lists.

**Architecture:** One shared sheet helper (`showAppSheet`) with a bottom sheet theme and a single slide-up animation style replaces every `AlertDialog`; confirm and prompt helpers keep their signatures so call sites barely change. The description field on a line becomes a `RawAutocomplete` over the items repository with a debounce. Theme changes live in `AppTheme` only.

**Tech Stack:** Flutter, `flutter_riverpod` 2.6.1, `go_router`, `flutter_native_splash`, `mocktail`.

**Spec:** The design agreed in chat on 2026-09-30 (screenshots of the Tecno CC7 and the mobile roadmap).

## Global Constraints

- Commits authored solely as `Ange Aurele TUYISENGE <tuyisengeauris@gmail.com>`; no trailers and no tooling attribution anywhere, including PR descriptions.
- Small, single-sentence conventional commits (lowercase type, imperative, no period), one logical change per commit; run the full tests before every commit and never commit with a failing test.
- Comments explain *why*, never *what*, never point at plan or spec documents, and contain no em dashes.
- No em dashes anywhere in the app's strings, comments, or tests; use a comma, colon, or full stop by reading each one in context.
- No dead ends: every failure has a specific message and a way forward.
- Motion is subtle: 150 to 300 ms, no bounce.
- Keep widget keys already used by tests.
- Do not run `dart format` at its default width; the codebase uses 120 columns.
- Do not stage the line-ending noise in regenerated `*.freezed.dart` / `*.g.dart` files that are not part of the change.

---

### Task 1: Remove the em dashes

**Files:** every `lib/**/*.dart` and `test/**/*.dart` file containing one (25 in `lib`, 21 in `test`).

- [ ] **Step 1:** Replace each in context: a pause before a clause becomes a comma or full stop, an explanation becomes a colon, a paired aside becomes commas or parentheses. User-facing examples: "Too many attempts, wait a few minutes and try again", "That code isn't right, try again", "This sign-in expired, log in again", "Nothing outstanding. All invoices are paid up".
- [ ] **Step 2:** Update the matching test expectations, searching `lib` and `test` for the em dash character must find nothing, run analyze and the full suite, commit `fix: remove em dashes from the app's copy and comments`.

---

### Task 2: Filled inputs that don't overlap, and a neutral AppBar

**Files:** Modify `lib/app/theme/app_theme.dart`, `test/app/theme/app_theme_test.dart`, `lib/features/documents/presentation/screens/document_editor_screen.dart`, `lib/features/onboarding/presentation/screens/onboarding_screen.dart`.

**Interfaces:** the input theme uses Material 3 filled behaviour (label floats inside the field, no outline at rest, rounded fill, a 2 px accent underline on focus that follows the corner radius); `AppBarTheme` uses the page colour, no surface tint, no elevation, the theme's foreground colour, and the Fraunces title style.

- [ ] **Step 1:** Tests: `border` is an `UnderlineInputBorder` with the large radius and no side; `focusedBorder` uses the primary colour at 2 px; the AppBar theme has a transparent `surfaceTintColor` and the page background in both themes.
- [ ] **Step 2:** Implement, add `SizedBox(height: 12)` between the rows of the line card so an error line never touches the next label, and remove the hard-coded white text on the onboarding "Skip onboarding" button so it follows the AppBar foreground. Run tests, commit in two commits: `fix: keep input labels inside the field and give rows room`, `fix: use a neutral app bar in light and dark`.

---

### Task 3: One splash screen

**Files:** Modify `pubspec.yaml` (`flutter_native_splash` section), add a transparent `assets/splash_blank.png`; regenerate the Android and iOS launch resources.

- [ ] **Step 1:** Set the native splash to the background colour only (`#FFFFFF` light, `#131315` dark) with no image, and give Android 12 a fully transparent icon so the system draws nothing on top of the colour. The animated Flutter splash is then the only visible one.
- [ ] **Step 2:** `dart run flutter_native_splash:create`, `flutter build apk --debug` succeeds, the resource diff contains only splash files, commit `fix: show only the animated splash screen`.

---

### Task 4: Slide-up sheets instead of dialogs

**Files:** Create `lib/core/widgets/app_sheet.dart`, its test; modify `lib/app/theme/app_theme.dart` (`BottomSheetThemeData`), `confirm_dialog.dart`, `text_prompt_dialog.dart`, `security_screen.dart`, `customer_detail_screen.dart`, `team_screen.dart`, and every existing `showModalBottomSheet` call site.

**Interfaces:**
- `Future<T?> showAppSheet<T>(BuildContext context, {required WidgetBuilder builder})` opens a modal sheet with rounded top corners (12 dp), a drag handle, scroll control, keyboard-aware bottom padding, and a 300 ms ease-out slide up with a 200 ms reverse via `AnimationStyle`.
- `showConfirmDialog` keeps its signature and result, but renders a sheet with a title, optional message, a Cancel button and a confirm button (red when `destructive: true`).
- `showTextPromptDialog` keeps its signature but renders a sheet with the field above the actions.

- [ ] **Step 1:** Tests: the sheet appears with a drag handle and slides in (position moves up over time); confirm returns true, false, and false on dismiss; the destructive variant uses the error colour; the text prompt disables confirm while empty and returns trimmed text; the keyboard inset moves the content up.
- [ ] **Step 2:** Implement the helper and theme, convert the confirm and prompt helpers first (their many call sites and tests keep working), commit `feat: add a shared slide-up sheet`.
- [ ] **Step 3:** Convert the remaining dialogs (delete account, delete customer, team invite form) and route the existing sheets (document type, language, photo source, item picker) through `showAppSheet`; update the tests that tap dialog buttons; commit in small steps: `feat: confirm and prompt in slide-up sheets`, `feat: use sheets for account deletion and customer removal`, `feat: use a sheet for the team invite form`, `feat: give every existing sheet the same look and motion`.

---

### Task 5: Item type-ahead on invoice lines

**Files:** Create `lib/features/documents/presentation/widgets/item_search_field.dart`, its test; modify `document_editor_screen.dart`.

**Interfaces:** `ItemSearchField({controller, errorText, searchItems, onItemSelected, onTextChanged})`: a text field whose placeholder reads "Search items or type a description"; typing (300 ms debounce, stale results ignored) shows an overlay of up to 8 matches with name, unit and price (`MoneyText`), a loading row while fetching, and a "Use as description" row for free text; selecting fills description, price and tax through `selectLineItem`; free text keeps the existing decoupling behaviour.

- [ ] **Step 1:** Tests: typing shows matches after the debounce; a stale slower response does not replace a newer one; selecting a match calls `onItemSelected` and fills the field; free text calls `onTextChanged` and does not select; a failed search shows a message with Retry instead of an empty list; an empty search shows a hint; the error text from validation still shows and no longer overlaps the next row (the widget test lays out both rows and checks the rects do not intersect).
- [ ] **Step 2:** Implement with `RawAutocomplete`, remove the magnifier button, run the document tests, commit `feat: search items directly from the line description`.

---

### Task 6: Pull to refresh on lists

**Files:** Modify the customer, item, document, and receivables list screens and their tests.

- [ ] **Step 1:** Tests: pulling down refetches page one on each list; it works on an empty list and on an error state (the empty and error views scroll).
- [ ] **Step 2:** Wrap each list body in `RefreshIndicator` with always-scrollable physics (empty and error states inside a scrollable so the gesture works), commit `feat: pull down to refresh lists`.

---

### Task 7: Verification

- [ ] `flutter analyze` clean, `flutter test` passing, `flutter build apk --debug` succeeds; install on the Tecno CC7 for a visual check when the phone is connected.
- [ ] Push `polish-round0`, open a PR against `auth-polish` with no attribution line, and update the known-gaps memory with the round 1 to 4 roadmap.

## Definition of done

The app shows one splash, has no em dashes, inputs and error text never collide, the AppBar is neutral in both themes, invoice lines search the item catalogue as you type, every popup slides up as a sheet, and every list can be pulled to refresh. Analyze is clean, the suite passes, and the debug APK builds.
