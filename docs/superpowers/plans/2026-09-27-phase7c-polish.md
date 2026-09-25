# Phase 7c: Dashboard, Search, Notifications, and Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the placeholder home with a real dashboard, add global search and a notifications inbox, and add the haptics, success animation, and transitions the brief asks for.

**Architecture:** Three small features (`dashboard`, `search`, `notifications`), each with a repository interface, freezed models, mocked-`Dio` repository tests, and auto-disposing providers that watch the active business. Sections of the home screen load independently. Feel changes live in `core/` helpers and the theme.

**Tech Stack:** Flutter, `flutter_riverpod` 2.6.1, `go_router`, `dio`, `freezed`, `animations`, `mocktail`.

**Spec:** `docs/superpowers/specs/2026-09-27-phase7c-polish-design.md`

## Global Constraints

- Commits authored solely as `Ange Aurele TUYISENGE <tuyisengeauris@gmail.com>`; no trailers and no tooling attribution anywhere, including PR descriptions.
- Small, single-sentence conventional commits (lowercase type, imperative, no period), one logical change per commit.
- Comments explain *why*, never *what*, and never point at plan or spec documents.
- No dead ends: every screen and section has a skeleton, a specific error with a working Retry, and a real empty state with a next action; every tap goes somewhere.
- Money uses `MoneyText` (tabular figures); large figures use the display font.
- Every task ends with `flutter analyze` clean and `flutter test` passing.
- Read auth state with `.valueOrNull`. Mocked Future methods that fail use `thenAnswer((_) async => throw ...)`.
- Do not run `dart format` at its default width; the codebase uses 120 columns.
- Onboarding template/numbering, the read-only session distinction, and push notifications are out of scope.

---

### Task 1: Haptics and the success check

**Files:**
- Create: `lib/core/widgets/success_check.dart`, `test/core/widgets/success_check_test.dart`
- Modify: `lib/features/documents/presentation/screens/document_detail_screen.dart`, `record_payment_screen.dart`, `lib/features/auth/presentation/screens/login_screen.dart` and their tests

**Interfaces:**
- Produces: `Future<void> showSuccessCheck(BuildContext context)` (light haptic, then a brief animated check dialog that closes itself).

- [ ] **Step 1:** Test: after calling it, a check icon is shown, and after `pumpAndSettle` it is gone and the future has completed; a haptic call is made on the `flutter/platform` channel (`HapticFeedbackType.lightImpact`).
- [ ] **Step 2:** Implement with `showGeneralDialog` and an `AnimationController` (scale in, hold, fade out, then pop); no `Timer`. Commit `feat: add a haptic success check`.
- [ ] **Step 3:** Call it after a successful finalize and a recorded payment (before navigating away), and add a haptic to login success. Extend the existing screen tests to assert the flow still completes. Commit `feat: confirm finalize, payments, and login with a haptic`.

---

### Task 2: Page transitions

**Files:** Modify `pubspec.yaml`, `lib/app/theme/app_theme.dart`, `test/app/theme/app_theme_test.dart`

- [ ] **Step 1:** Test: both light and dark themes use `SharedAxisPageTransitionsBuilder` for Android and iOS.
- [ ] **Step 2:** `flutter pub add animations`, set `pageTransitionsTheme` once in the shared theme builder, run the full suite, commit `feat: use shared-axis page transitions`.

---

### Task 3: Notifications data layer

**Files:**
- Create: `lib/features/notifications/domain/app_notification.dart`, `notifications_page.dart`, `notification_route.dart`, `notifications_repository.dart`, `data/notifications_repository_impl.dart`, `presentation/providers/notifications_repository_provider.dart`, `notifications_provider.dart`
- Test: `test/features/notifications/...` for models, route mapping, and the repository

**Interfaces:**
- Produces: `AppNotification{id, type: NotificationType?, title, body?, link?, readAt?, createdAt}` (unknown type parses to null, never throws); `NotificationsPage{results, unreadCount}`; `String? notificationRoute(String? link)` (`/documents/:id` unchanged, `/settings` becomes `/team`, anything else null); `NotificationsRepository{list(), markRead(id), markAllRead()}`; `notificationsProvider` (`FutureProvider.autoDispose<NotificationsPage>`).

- [ ] **Step 1:** Tests: JSON parsing including an unknown type and null body/link/readAt; route mapping for each backend link and null; repository calls `GET /notifications`, `POST /notifications/:id/read`, `POST /notifications/mark-all-read`.
- [ ] **Step 2:** Implement, run, analyze, commit `feat: add the notifications data layer`.

---

### Task 4: Notifications screen

**Files:** Create `lib/features/notifications/presentation/screens/notifications_screen.dart` and its test.

**Interfaces:** `NotificationsScreen`. Keys: `notifications-mark-all`, `notification-<id>`.

- [ ] **Step 1:** Tests: rows show title, body, and an unread dot for unread only; tapping an unread row marks it read, refreshes, and opens a mapped destination; a row with no destination is marked read and shows no chevron; Mark all read appears only with unread items and calls the endpoint; empty state with explanatory text; failed load and failed mark-read show specific messages with Retry.
- [ ] **Step 2:** Implement with the shared `_runAction` shape, add the `/notifications` route stub in the test support, run, commit `feat: add the notifications inbox`.

---

### Task 5: Search

**Files:** Create `lib/features/search/domain/search_result.dart`, `search_repository.dart`, `data/search_repository_impl.dart`, `presentation/providers/search_repository_provider.dart`, `presentation/screens/search_screen.dart`, and tests.

**Interfaces:** `SearchResult{type: SearchResultType, id, label, sublabel, documentType?}`; `SearchRepository.search(String query)`; `SearchScreen`. Keys: `search-field`, `search-result-<id>`.

- [ ] **Step 1:** Repository tests (query parameter, parsing all three types, unknown type skipped). Commit `feat: add the search repository`.
- [ ] **Step 2:** Screen tests with fake timers replaced by real short delays: under two characters shows a hint and calls nothing; a query after the debounce shows grouped results; a customer opens `/customers/:id`, a document `/documents/:id`, an item `/items`; no matches shows "No matches for ..." and a suggestion; a failure shows its message with a Retry that re-runs the query; a fast typist fires one request.
- [ ] **Step 3:** Implement, run, commit `feat: add global search`.

---

### Task 6: Dashboard data layer

**Files:** Create `lib/features/dashboard/domain/dashboard_summary.dart`, `revenue_summary.dart`, `dashboard_repository.dart`, `data/dashboard_repository_impl.dart`, `presentation/providers/dashboard_repository_provider.dart`, `dashboard_provider.dart`, and tests.

**Interfaces:** `DashboardSummary`, `RecentDocument`, `RevenueSummary`, `MonthlyRevenue`, `TopCustomer`; `DashboardRepository{summary(), revenue()}`; `dashboardSummaryProvider`, `revenueProvider` (both watch the active business id).

- [ ] **Step 1:** Tests: parsing full payloads (nullable `daysSalesOutstanding`, null document `number`/`paymentStatus`); repository endpoints; the revenue delta helper (`RevenueSummary.monthOverMonthPercent`: null when last month is zero, otherwise a rounded signed percentage).
- [ ] **Step 2:** Implement, run, commit `feat: add the dashboard data layer`.

---

### Task 7: Document list initial filters

**Files:** Modify `lib/features/documents/presentation/providers/document_list_controller.dart`, `screens/document_list_screen.dart`, `lib/app/router.dart` (the `/documents` route reads `status` and `types` query parameters), and their tests.

**Interfaces:** `DocumentListController.setFilters({List<DocumentType>? types, DocumentStatus? status})` (one refresh); `DocumentListScreen({initialTypes, initialStatus})`.

- [ ] **Step 1:** Tests: `setFilters` triggers one fetch with both filters; opening the screen with `initialStatus: draft` selects the Drafts chip and fetches drafts only; opening with no filters after a filtered visit resets the controller so chips and list agree.
- [ ] **Step 2:** Implement, run, commit `fix: keep the document list filters in step with the chips` then `feat: open the document list with initial filters`.

---

### Task 8: Home dashboard

**Files:** Create `lib/features/dashboard/presentation/screens/home_screen.dart` and section widgets under `presentation/widgets/`; modify `lib/app/router.dart` (remove `_PlaceholderHomeScreen`, add `/search` and `/notifications`); create `test/features/dashboard/presentation/screens/home_screen_test.dart`; keep `test/app/router_test.dart` green.

**Interfaces:** `HomeScreen`. Keys retained: `home-account`, `home-business-switcher`, `home-nav-customers`, `home-nav-items`, `home-nav-documents`, `home-nav-receivables`, `home-nav-team`. New: `home-search`, `home-bell`, `home-attention-drafts`, `home-attention-overdue`, `home-attention-expiring`, `home-see-all-documents`, `home-recent-<id>`.

- [ ] **Step 1:** Tests: the hero shows the invoiced figure and the delta text for up, down, and first-month cases; attention cards show counts and route to the filtered lists and receivables; a zero count reads calm; recent documents open their detail; a brand-new business shows the first-steps card whose buttons open the customer form and document creation; the revenue section failing shows its own message and Retry while the rest still renders (and the reverse); pull-to-refresh reloads both; the bell shows an unread badge from the notifications provider and opens the inbox; search opens `/search`; the owner-only Team shortcut is unchanged.
- [ ] **Step 2:** Implement (Fraunces for the hero figure, skeletons per section, six-month bars from plain widgets with a text alternative), move the placeholder's header behaviour across unchanged, run the full suite, commit in steps: `feat: add the dashboard sections`, `feat: replace the placeholder home with the dashboard`.

---

### Task 9: Empty, loading, and error state audit

- [ ] **Step 1:** For every list and detail screen (customers, items, documents, receivables, team, businesses, sessions, notifications, search, dashboard sections), record whether it has a skeleton, a specific error with a working Retry, and an empty state with real content and a next action. Grep for `CircularProgressIndicator` and bare `Text('Error` patterns.
- [ ] **Step 2:** Fix each gap in its own commit with a test that would have caught it; anything found but deliberately left goes in the PR description.

---

### Task 10: Final verification

- [ ] `flutter analyze` clean, `flutter test` passing, `flutter build apk --debug` succeeds; iOS verification stays deferred to macOS. Update the known-gaps memory.

## Definition of done

Analyze is clean, the suite passes, the debug APK builds, and a manual run shows: home opens on a real dashboard with the month's invoiced figure, attention counts that open the right lists, six months of revenue, and recent documents; search finds customers, items, and documents; the bell shows unread notifications and the inbox opens their targets; finalize, payment, and login give a haptic and finalize and payment show a brief success check; pushes use shared-axis transitions; every failure shows a specific message with a working Retry.
