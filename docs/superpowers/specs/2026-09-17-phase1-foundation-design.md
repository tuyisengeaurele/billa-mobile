# Phase 1: Foundation — Design

## Context

Billa Mobile is the Flutter companion to the production Billa web app (business
documents for Rwandan SMEs). The web app's source lives at
`../Web/billa` (sibling repo) — a Node/Express/Prisma API with a Vite/React
client, single-origin (client and API served from one process, so cookies
stay same-site). This phase builds the skeleton every later feature phase
sits on: theme, app shell, networking, and the handful of genuinely shared
widgets. No feature screens with real content ship in this phase.

Full product scope, design tokens, and phase breakdown live in the founding
brief (not committed to this repo — see project conversation history). This
document only covers what Phase 1 itself builds.

## Backend facts this design depends on

Established by reading the live web app source, not assumed:

- **Single origin, no `/api` prefix.** Routes mount directly at root:
  `/auth/session`, `/documents`, `/customers`, `/items`, `/business`,
  `/businesses`, `/receivables`, etc.
- **Cookie names are exactly** `access_token` (path `/`, 15 min TTL) and
  `refresh_token` (path `/auth/refresh` only, 30 day TTL). Both `httpOnly`,
  `sameSite=lax`. No bearer-token mode exists server-side today.
- **Refresh token rotates on every use; reuse revokes the whole session
  family.** Two concurrent `401`s must not each call `/auth/refresh`
  independently — the second call would present an already-rotated token and
  get treated as token reuse, logging the user out of every device. The
  client must single-flight refresh attempts.
- **Retry contract**: on `401` from any endpoint except `/auth/session`,
  `/auth/refresh`, `/auth/me`, `/auth/2fa/challenge`, attempt
  `POST /auth/refresh` once; on success, retry the original request once; on
  failure, treat the session as expired.
- **Amounts are integers** (RWF has no minor unit in this data model) — no
  cents/decimal handling needed anywhere money is displayed or submitted.
- Base URL and Firebase project are not committed anywhere in the web repo
  (dashboard/`.env`-only) and are not needed until Phase 2 (real sign-in).
  Phase 1 only needs a dev default.

## Architecture

```
lib/
  app/
    app.dart              # MaterialApp.router, theme wiring
    router.dart            # go_router config (single placeholder route this phase)
    theme/
      app_colors.dart      # ThemeExtension<AppColors>, light + dark token maps
      app_typography.dart  # Fraunces (display) + Plus Jakarta Sans (body) via google_fonts
      app_theme.dart       # ThemeData composition, light + dark
  core/
    network/
      api_client.dart          # Dio instance + cookie jar + interceptors
      auth_interceptor.dart    # 401 -> single-flight refresh -> retry-once
      cookie_jar_provider.dart # PersistCookieJar under app-support dir
    error/
      app_exception.dart       # typed exception the repositories throw
    storage/
      secure_storage.dart      # flutter_secure_storage wrapper (scalars only)
    widgets/
      loading_skeleton.dart
      empty_state.dart
      error_state.dart
      app_button.dart
      money_text.dart
  main.dart
```

This mirrors the target folder structure for the whole app (feature-first
under `features/`, which doesn't exist yet since Phase 1 has no features).

### Theming

`AppColors` is a `ThemeExtension<AppColors>` with one field per token
(`primary500`, `neutral50`...`neutral900`, `success`/`successBg`, etc.), two
static instances (`light`, `dark`) built from the exact hex values in the
design brief. `AppTheme.light`/`AppTheme.dark` compose `ThemeData` with
`extensions: [AppColors.light]` / `[AppColors.dark]`, plus `TextTheme` built
from `GoogleFonts.fraunces(...)` (display/headline styles) and
`GoogleFonts.plusJakartaSans(...)` (body/label styles). Corner radii (8dp
default, 12dp for modals/sheets, circular for avatars/pills/FABs) live as
constants in `app_theme.dart`, not hardcoded per-widget.

`MoneyText` (in `core/widgets/`) takes an integer RWF amount, formats it with
thousands separators, and renders it with
`TextStyle(fontFeatures: [FontFeature.tabularFigures()])`. No decimal
formatting logic — the backend survey confirmed integer-only amounts.

### Networking

`ApiClient` wraps a single `Dio` instance:

- `BaseOptions.baseUrl` from `String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:4000')`.
- `connectTimeout`/`receiveTimeout` at 20s, matching the web client.
- A `CookieManager(PersistCookieJar(storage: FileStorage(<app support dir>/cookies)))`
  interceptor, added first, so every request/response round-trips cookies
  exactly like a browser would.
- `AuthInterceptor` (a `QueuedInterceptor` or Dio interceptor guarded by a
  `Completer<void>`-based mutex): on receiving a `401` for a path outside the
  exempt list, if a refresh is already in flight, await it; otherwise start
  one (`POST /auth/refresh`), let every waiting request retry once it
  resolves. On refresh failure, clear local session state (nothing to clear
  yet in Phase 1 beyond the cookie jar itself) and rethrow as
  `AppException.sessionExpired` for the caller to handle — actual "route to
  login" wiring happens in Phase 2 once a login route exists.

No repository classes exist yet in Phase 1 (no features do), but
`ApiClient` is the one and only thing that will ever call `dio` directly;
this phase's test coverage proves the interceptor's retry/single-flight
behavior in isolation using a mocked adapter, ahead of any real repository
depending on it.

### App shell

`main.dart` wraps `ProviderScope` around `App` (`app/app.dart`), which is a
`MaterialApp.router` using `router.dart`'s `GoRouter` (one route, `/`,
rendering a minimal placeholder screen — just enough to prove theme, fonts,
and navigation are wired correctly end to end). Light/dark follows system
brightness by default (`ThemeMode.system`); the manual override toggle is a
Phase 7 settings feature, not built here, but `ThemeMode` is threaded through
a Riverpod provider now so that toggle has somewhere to plug in later.

### Assets

`flutter_launcher_icons` generates full adaptive icon sets from `logo.png`
(background color decided visually between `#FFFFFF` and `#C2185B` once
generated — whichever reads better against the mark). `flutter_native_splash`
centers `logo.png` on `#FFFFFF` (light) / `#131315` (dark), using each
platform's native splash API, no custom Flutter-drawn splash screen.

## Testing

- `AuthInterceptor`: unit tests with a mocked `Dio`/`HttpClientAdapter`
  (via `mocktail`) proving (a) a single `401` triggers exactly one refresh
  and one retry, (b) two concurrent `401`s trigger exactly one refresh call
  between them, (c) a failed refresh surfaces `AppException.sessionExpired`
  and does not retry.
- `MoneyText`: widget test for correct grouping/tabular-figures style on a
  few representative integers (0, small, large, with grouping).
- `AppTheme`: a smoke test that both `ThemeData` builds without throwing and
  expose the `AppColors` extension.
- `EmptyState`/`ErrorState`/`LoadingSkeleton`: widget tests confirming they
  render their required slots (icon, message, primary action / retry
  callback) — these three are reused by every feature phase from here on,
  so their contract needs to be locked now.

## Out of scope for this phase

Firebase, real login, business setup, logo pipeline, any feature under
`features/` — all Phase 2+. Production base URL and Firebase project wiring
are deferred to Phase 2, where they're actually needed.
