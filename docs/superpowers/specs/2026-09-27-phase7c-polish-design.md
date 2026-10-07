# Phase 7c: Dashboard, Search, Notifications, and Polish — Design

## Context

Last of the three phase 7 sub-phases (7a account, 7b business settings). The
home screen has been a placeholder of navigation buttons since phase 1. 7c
makes it a real dashboard, adds global search and a notifications inbox, and
closes the feel gaps the founding brief calls out: haptics and a success
micro-interaction on the moments that matter, purposeful page transitions,
and an audit of empty, loading, and error states.

The contract was read from the sibling `billa` repo:

- `server/src/routes/dashboard.ts` — `GET /dashboard/summary`: `{draftCount,
  overdueInvoiceCount, expiringQuoteCount, recentDocuments: [{id, type,
  number, status, customerName, issueDate, paymentStatus}] (six),
  documentsThisMonth, documentsLastMonth, documentsByType, activityByDay,
  customerCount, hasLogo}`. `GET /dashboard/revenue`: `{invoicedThisMonth,
  invoicedLastMonth, invoicedYearToDate, creditedYearToDate, netYearToDate,
  totalCollected, totalOutstanding, daysSalesOutstanding (nullable),
  monthlyRevenue: [{month "YYYY-MM", invoiced, credited, net}] (six months),
  topCustomers: [{customerId, name, total}], topItems}`. All amounts are
  integer RWF.
- `server/src/routes/search.ts` — `GET /search?q=` (2 to 100 characters, 400
  otherwise): `{results: [{type: customer | item | document, id, label,
  sublabel, href, documentType?}]}`, up to five of each, gated by an active
  subscription.
- `server/src/routes/notifications.ts` — `GET /notifications`: `{results:
  [{id, type, title, body, link, readAt, createdAt}] (latest 50),
  unreadCount}`; `POST /notifications/:id/read` (404 `not_found`);
  `POST /notifications/mark-all-read`. Types match the six already modelled
  for preferences. Links are web paths: `/documents/:id` for overdue,
  payment, accepted, and declined; `/settings` for a joined member;
  `/admin/messages` for admin-only contact messages.

## Non-goals

- Onboarding template and numbering setup, and the read-only (accountant)
  session distinction: the latter needs a decision on where the role comes
  from (the backend exposes only ownership), so it is deferred.
- `documentsByType`, `activityByDay`, and `topItems` (returned but not shown).
- Push notifications.
- Recurring documents and the activity log.

## Dashboard

New `lib/features/dashboard/` with `DashboardSummary`, `RevenueSummary`, and
their small parts as freezed models, a `DashboardRepository` (`summary()`,
`revenue()`), and two `FutureProvider.autoDispose`s that watch the active
business id. The two endpoints load independently so one failing never blanks
the other: each section shows its own skeleton, its own specific error, and
its own Retry.

`HomeScreen` replaces the placeholder. Top bar: business switcher (existing),
search, bell with unread badge, account. Body, in a pull-to-refresh list:

1. **Revenue hero:** "Invoiced this month" as a large Fraunces figure
   (`MoneyText`, tabular), a delta against last month ("12% more than last
   month", "12% less", or "First month of invoices" when last month was
   zero), then Collected and Outstanding.
2. **Needs attention:** three tappable counts: Drafts (opens documents
   filtered to drafts), Overdue invoices (opens receivables), Expiring
   quotes (opens documents filtered to quotes and proformas). Zero counts
   read as calm ("No overdue invoices") rather than alarming.
3. **Six months:** a bar per month for net revenue with month labels and a
   text alternative for screen readers; built from plain widgets, no charting
   dependency.
4. **Recent documents:** the six latest with number, customer, and status,
   each opening its detail; "See all" opens the list. A brand-new business
   with no documents and no customers gets a first-steps card (add a
   customer, create a document) instead of a wall of zeros.
5. **Shortcuts:** the existing Customers, Items, Documents, Receivables, and
   owner-only Team entries, kept with their keys.

`DocumentListScreen` accepts initial filters from the router. The list
controller gains one `setFilters` so applying both filters costs a single
fetch, and the screen applies its own chip state to the controller on open;
today the controller's filter survives leaving the screen while the chips
reset, so the two can disagree.

## Search

`SearchRepository.search(query)` returns typed `SearchResult`s.
`SearchScreen` (`/search`): autofocused field, 300 ms debounce, a hint under
two characters, results grouped as Customers, Items, and Documents, "No
matches for ..." when empty, and a specific error with Retry. Tapping opens
customers and documents by id and items on their list, matching the
backend's own `href`s.

## Notifications

`AppNotification`, `NotificationsPage`, and `NotificationsRepository`
(`list`, `markRead`, `markAllRead`). The bell reads the same provider as the
inbox, so the badge and the list cannot disagree. `NotificationsScreen`
(`/notifications`): rows with an unread dot, title, body, and relative time;
tapping marks the row read and opens its target; "Mark all read" appears when
anything is unread; empty state and error with Retry. `notificationRoute`
maps backend web paths to mobile routes: `/documents/:id` is the same,
`/settings` becomes `/team`, and anything else (admin paths) has no
destination, so the row is marked read and simply shows no chevron rather
than a tap that goes nowhere.

## Feel

- **Haptics:** `HapticFeedback.lightImpact()` on a successful finalize,
  recorded payment, and login.
- **Success micro-interaction:** `showSuccessCheck(context)` shows a brief
  animated check (scale and fade, under a second, no modal buttons) after a
  finalize and a recorded payment. Driven by an animation controller rather
  than a timer so it completes under test.
- **Transitions:** shared-axis horizontal transitions for pushes on both
  platforms via the `animations` package, set once in the theme.
- **State audit:** every list and detail screen is checked for a skeleton,
  a specific error with Retry, and a real empty state with a next action;
  gaps found are fixed in their own commits.

## Errors

The existing `describeActionError` covers these calls; a failed dashboard,
search, or inbox load uses the same helper for its message.

## Testing strategy

1. Haptic and success-check helpers, wired into finalize, payment, login.
2. Page transitions in the theme.
3. Notification models, repository, provider, and route mapping.
4. Notifications screen.
5. Search models, repository, and screen.
6. Dashboard models, repository, and providers.
7. Document list initial filters and `setFilters`.
8. `HomeScreen`, the bell badge, search entry, and router wiring.
9. State audit and fixes.
10. Final verification (`flutter analyze`, `flutter test`, `flutter build
    apk --debug`).
