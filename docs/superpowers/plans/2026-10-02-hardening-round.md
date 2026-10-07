# Hardening Round Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Close the security, speed, getting-paid, privacy and accessibility gaps found in the mobile audit, in five stacked implementation batches plus a verification pass.

**Architecture:** Storage and network concerns stay behind small interfaces (`Storage` for cookies, `SessionSnapshotStore`, a Dio cache interceptor, a `LinkLauncher`, an `AppLock` service) so screens and providers never touch platform APIs directly and each piece is testable with fakes.

**Tech Stack:** Flutter, `flutter_riverpod` 2.6.1, `dio`, `cookie_jar`, `flutter_secure_storage`, plus `local_auth`, `url_launcher`, `cached_network_image`, `connectivity_plus`, `flutter_slidable`, `flutter_contacts`, `mocktail`.

**Spec:** `docs/superpowers/specs/2026-10-02-hardening-round-design.md`

## Global Constraints

- Commits authored solely as `Ange Aurele TUYISENGE <tuyisengeauris@gmail.com>`; no trailers and no tooling attribution anywhere, including PR descriptions.
- Small, single-sentence conventional commits (lowercase type, imperative, no period), one logical change per commit. Run the relevant tests before every commit and the full suite before every push; never commit a failing test.
- One branch and PR per batch, each based on the previous batch's branch: `r2a-security`, `r2b-speed`, `r2c-paid`, `r2d-privacy`, `r2e-a11y`.
- Comments explain why, never what, and contain no em dashes anywhere in code, tests or docs.
- No dead ends: every new screen and section has a skeleton, a specific error with a working retry, and a real empty state.
- Keep existing widget keys where a test depends on them; update tests deliberately.
- Read auth state with `.valueOrNull`; `setState` callbacks never return a Future; mocktail stubs for failing futures use `thenAnswer((_) async => throw ...)`.
- Do not run `dart format` at its default width (120 columns). Do not stage line-ending noise from regenerated `*.freezed.dart` and `*.g.dart` files; stage only intended files.
- Bash heredocs containing apostrophes fail in the Bash tool: write files with the Write tool.
- Release builds always pass `--dart-define=API_BASE_URL=https://billa-api-og7v.onrender.com`.
- Before finishing each batch: `flutter analyze` with zero warnings, the full test suite, and `flutter build apk --debug`; the last batch also does a signed release build and a phone install.
- Out of scope: offline write queue, push notifications, UI language, printing, widgets, the accountant role, any backend change.

---

## Batch 1: security foundation (`r2a-security`)

### Task 1: Turn off Android backups

**Files:** Modify `android/app/src/main/AndroidManifest.xml`; create `android/app/src/main/res/xml/data_extraction_rules.xml` and `android/app/src/main/res/xml/backup_rules.xml`.

- [ ] Set `android:allowBackup="false"`, `android:fullBackupContent="@xml/backup_rules"`, `android:dataExtractionRules="@xml/data_extraction_rules"` and `android:label="Billa"` on `<application>`. Both XML files exclude every domain (`root`, `sharedpref`, `file`, `database`, `external`).
- [ ] Verify with `flutter build apk --debug` that the manifest merges.
- [ ] Commit: `fix: stop android backups from carrying app data`

### Task 2: Secure cookie storage

**Files:** Create `lib/core/network/secure_cookie_storage.dart` and `test/core/network/secure_cookie_storage_test.dart`; modify `lib/core/network/cookie_jar_provider.dart`, `lib/core/storage/secure_storage.dart`.

**Interfaces:** `class SecureCookieStorage implements Storage` (from `cookie_jar`) with `init(bool persistSession, bool ignoreExpires)`, `read(String key)`, `write(String key, String value)`, `delete(String key)`, `deleteAll(List<String> keys)`, backed by an injected `SecureStorage`; keys are prefixed `cookie:`. `createCookieJar()` builds `PersistCookieJar(storage: SecureCookieStorage(...))` and deletes the legacy `<support dir>/cookies` directory once.

- [ ] Write tests with a fake in-memory `SecureStorage`: write then read round-trips, delete removes, `deleteAll` removes only listed keys, keys are namespaced, a jar built on it persists a cookie across two instances.
- [ ] Implement, run the tests, then a debug build.
- [ ] Commit: `feat: keep login cookies in secure storage`
- [ ] Commit: `chore: remove the old plain-file cookie directory on launch`

### Task 3: Secure session snapshot

**Files:** Modify `lib/features/auth/data/session_snapshot_store.dart`, `lib/main.dart`; update `test/features/auth/presentation/providers/auth_session_snapshot_test.dart`.

**Interfaces:** `SecureSessionSnapshotStore` with `static Future<SecureSessionSnapshotStore> load(SecureStorage storage)` reading the JSON once; `read()` stays synchronous from memory; `write` and `clear` update memory then storage. A one-time step deletes the old `session_snapshot` preference key.

- [ ] Tests first: load restores a stored snapshot, write persists, clear removes, an unreadable value yields null, the legacy preference key is removed.
- [ ] Wire `main.dart` to `await SecureSessionSnapshotStore.load(...)` and drop the `SharedPreferences` implementation.
- [ ] Commit: `feat: keep the remembered session in secure storage`

### Task 4: Release signing

**Files:** Modify `android/app/build.gradle.kts`, `.gitignore`, `README.md` (signing section); generate the keystore outside the repo.

- [ ] Generate `C:\Users\user\billa-signing\billa-release.jks` with `keytool` (RSA 2048, validity 10000 days, alias `billa`) using random passwords written only to a file in that folder; never print them in chat.
- [ ] `android/key.properties` (git-ignored) holds `storeFile`, `storePassword`, `keyAlias`, `keyPassword`. `build.gradle.kts` loads it if present and uses a `release` signing config, otherwise falls back to the debug config.
- [ ] Add `android/key.properties`, `*.jks` and `*.keystore` to `.gitignore`; document in the README that the key must be backed up and how to build.
- [ ] Build a release APK and confirm with `apksigner verify --print-certs` that it is not signed by the debug key.
- [ ] Commit: `build: sign release builds with a real key when one is configured`

### Task 5: Shrink release builds

**Files:** Modify `android/app/build.gradle.kts`; create `android/app/proguard-rules.pro`.

- [ ] Enable `isMinifyEnabled` and `isShrinkResources` for release with the Flutter default rules plus keep rules for Firebase Auth and Google Sign-In as needed.
- [ ] Build release, install on the phone, sign in, open Items, Documents and Profile to catch anything shrinking broke. If a plugin breaks, add the narrowest keep rule.
- [ ] Commit: `build: shrink and obfuscate release builds`
- [ ] Document `flutter build apk --release --split-per-abi --dart-define=...` in the README and record the arm64 APK size.
- [ ] Commit: `docs: describe the signed split-per-abi release build`

### Task 6: Batch 1 verification and PR

- [ ] `flutter analyze`, full tests, debug build, release build, install on the phone, confirm sign-in still works and a second launch opens instantly.
- [ ] Push `r2a-security` and open a PR against `round1a-shell` with no attribution line.

---

## Batch 2: speed foundation (`r2b-speed`)

### Task 7: Bundle the fonts

**Files:** Create `assets/google_fonts/*.ttf`; modify `pubspec.yaml`, `lib/main.dart`; test `test/app/theme/app_theme_test.dart`.

- [ ] Download the weights the theme actually uses (list them from `lib/app/theme/app_typography.dart`) of Fraunces and Plus Jakarta Sans from the Google Fonts repository, named as the `google_fonts` package expects (`Fraunces-SemiBold.ttf`, `PlusJakartaSans-Regular.ttf`, and so on), with their licences.
- [ ] Register `assets/google_fonts/` in `pubspec.yaml` and set `GoogleFonts.config.allowRuntimeFetching = false` in `main()`.
- [ ] The theme test that previously logged a font error now passes without one.
- [ ] Commit: `perf: bundle the app fonts instead of downloading them`

### Task 8: Concurrent startup

**Files:** Modify `lib/main.dart`.

- [ ] Run Firebase init, the API client, preferences, the session snapshot load and the glass-blur check with `Future.wait` instead of one after another; keep `runApp` after they finish.
- [ ] Commit: `perf: run startup work concurrently`

### Task 9: Image cache

**Files:** Modify `lib/features/account/presentation/widgets/user_avatar.dart`, `lib/features/business_settings/presentation/screens/logo_screen.dart`, `payments_screen.dart`; add `cached_network_image` to `pubspec.yaml`; tests for the avatar fallback.

- [ ] Replace the three `Image.network` uses with `CachedNetworkImage`, keeping the initial-letter fallback as the error and placeholder widget.
- [ ] Commit: `perf: cache avatars and logos on disk`

### Task 10: Response cache interceptor

**Files:** Create `lib/core/network/response_cache.dart`, `lib/core/network/cache_interceptor.dart`, `test/core/network/cache_interceptor_test.dart`; modify `lib/core/network/api_client.dart`, `lib/features/auth/presentation/providers/auth_controller.dart`.

**Interfaces:** `abstract class ResponseCache { Future<CachedResponse?> read(String key); Future<void> write(String key, CachedResponse value); Future<void> clear(); }`; `CachedResponse { int statusCode; Object? data; DateTime savedAt; }`; `class CacheInterceptor extends Interceptor` with `String Function() businessId` and `void Function(bool stale) onStale`. The cache key is `businessId|path|sorted query`. Only GET requests that succeeded with a 2xx JSON body are stored; PDFs, `/auth/*` and paths under `/uploads` are never cached.

- [ ] Tests first: a successful GET is stored; a later `connectionError` or `connectionTimeout` returns the stored body with `extra['fromCache'] = true` and calls `onStale(true)`; a 4xx or 5xx is passed through untouched; non-GET requests bypass; different businesses do not share entries; `clear()` empties the cache; a fresh success calls `onStale(false)`.
- [ ] Implement with a file-backed `ResponseCache` under the app support directory and register the interceptor in `ApiClient.create`.
- [ ] Clear the cache when the auth controller reaches unauthenticated or logs out.
- [ ] Commit: `feat: serve saved data when the network fails`
- [ ] Commit: `fix: clear saved data when the user signs out`

### Task 11: Offline banner

**Files:** Create `lib/core/network/connectivity_provider.dart`, `lib/app/shell/offline_banner.dart`, `test/app/shell/offline_banner_test.dart`; modify `lib/app/shell/app_shell.dart`; add `connectivity_plus`.

**Interfaces:** `connectivityProvider` (a stream of `bool online`, overridable in tests) and `staleDataProvider` (a `StateProvider<bool>` set by the interceptor's `onStale`).

- [ ] Tests first: offline shows "You're offline. Showing saved data."; online with stale data shows "Showing saved data" with a Refresh action that invalidates the dashboard providers; online and fresh shows nothing; the banner animates in and out.
- [ ] Mount it at the top of the shell content, under the status bar.
- [ ] Commit: `feat: show an offline banner when data is saved or stale`

### Task 12: Forms keep input when a save fails

**Files:** Tests first: `test/features/customers/.../customer_form_screen_test.dart`, the item form, the document editor, record payment.

- [ ] For each form add a test where the save throws a connection error: the typed values are still in the fields, the specific message shows, and Retry saves successfully.
- [ ] Fix any form that clears or loses input.
- [ ] Commit per form fixed: `fix: keep typed values when a save fails`

### Task 13: Batch 2 verification and PR

- [ ] Analyzer, full tests, debug and release builds, phone install; turn the phone's data off and confirm saved Home, Documents and Customers still show with the banner.
- [ ] Push `r2b-speed` and open a PR against `r2a-security`.

---

## Batch 3: getting paid and fast capture (`r2c-paid`)

### Task 14: Link launcher

**Files:** Create `lib/core/platform/link_launcher.dart`, `lib/core/formatting/phone_number.dart` and tests; add `url_launcher`; add Android `<queries>` for `tel`, `sms`, `https` and `whatsapp` in the manifest.

**Interfaces:** `abstract class LinkLauncher { Future<bool> call(String phone); Future<bool> sms(String phone, {String? body}); Future<bool> whatsapp(String phone, String message); }`; `String? normaliseRwandaNumber(String raw)` returning `2507XXXXXXXX` digits or null; `linkLauncherProvider`.

- [ ] Tests first for normalisation: `0788123456`, `+250 788 123 456`, `250788123456`, `788123456`, spaces and dashes, garbage returns null, numbers in another country's format are kept as digits.
- [ ] Implement with `url_launcher`; WhatsApp opens `https://wa.me/<digits>?text=<encoded>`; a failed launch returns false so callers show a specific message.
- [ ] Commit: `feat: add phone number normalisation for rwanda`
- [ ] Commit: `feat: add a link launcher for calls, sms and whatsapp`

### Task 15: Contact actions and reminder messages

**Files:** Create `lib/features/documents/domain/share_message.dart`, `lib/core/widgets/contact_actions.dart` and tests; modify `customer_detail_screen.dart`, the receivable rows and the document detail.

**Interfaces:** `String reminderMessage({required String customer, required String number, required int amountOwed, required String link})` and `String shareMessage(...)`; `showContactActions(context, ref, {required String? phone, required String message})` opens a sheet with Call, SMS and WhatsApp, each disabled with the reason "No phone number saved" when missing.

- [ ] Tests first for the message wording and for the sheet: each action calls the fake launcher with the right arguments; a false result shows "Couldn't open that app. Is it installed?".
- [ ] Add the public link builder `publicDocumentUrl(publicToken)` from `apiBaseUrl`.
- [ ] Commit: `feat: add call, sms and whatsapp actions to customers and receivables`
- [ ] Commit: `feat: send a whatsapp reminder or share with the document link`

### Task 16: Swipe actions

**Files:** Modify the document list tile and the receivable rows; add `flutter_slidable`; tests.

- [ ] Documents: swipe to duplicate. Receivables: swipe to record a payment and to contact. Every swipe action is also reachable from the row's detail screen and has a label for screen readers.
- [ ] Commit: `feat: add swipe actions to document and receivable rows`

### Task 17: Duplicate a document

**Files:** Create `lib/features/documents/domain/duplicate_draft.dart` and a test; modify the document detail and the swipe action.

- [ ] `DocumentDraftInput draftFromDocument(Document)` copies customer and lines and resets dates, number and status; tests cover lines, discounts, currency and that no ids leak.
- [ ] The detail screen menu gets "Duplicate", which creates the draft through the existing repository and opens it in the editor.
- [ ] Commit: `feat: duplicate a document into a new draft`

### Task 18: Import a customer from contacts

**Files:** Modify `lib/features/customers/presentation/screens/customer_form_screen.dart`; add `flutter_contacts`; tests with a fake picker.

- [ ] A "From contacts" button uses the system picker (no permission) and fills name, phone and email; a cancelled pick changes nothing; a failure shows a specific message.
- [ ] Commit: `feat: fill a new customer from the phone contacts`

### Task 19: Frequent items

**Files:** Create `lib/features/items/presentation/providers/recent_items_provider.dart` and tests; modify the invoice line editor.

- [ ] Remember the last 8 items chosen, per business, in preferences; show them as chips above the search field; tapping a chip fills the line. Empty until something has been used.
- [ ] Commit: `feat: offer recently used items as chips on invoice lines`

### Task 20: Continue draft on Home

**Files:** Modify `lib/features/dashboard/presentation/widgets/summary_section.dart`; tests.

- [ ] Show a "Continue draft" card for the newest draft in the recent list, opening it in the editor; nothing when there is none.
- [ ] Commit: `feat: continue the latest draft from home`

### Task 21: Input polish

**Files:** Modify forms in customers, items, documents, payments, business settings and auth; tests where behaviour is observable.

- [ ] Money and quantity fields use numeric keyboards with digit-only formatters; phone fields use the phone keyboard and `AutofillHints.telephoneNumber`; email fields use the email keyboard; names capitalise words; `textInputAction.next` between fields and `done` on the last.
- [ ] Commit per form area: `fix: use the right keyboard and actions in <area> forms`

### Task 22: Batch 3 verification and PR

- [ ] Analyzer, tests, builds, and a phone check of call, SMS, WhatsApp, swipe, duplicate and contact import.
- [ ] Push `r2c-paid` and open a PR against `r2b-speed`.

---

## Batch 4: privacy (`r2d-privacy`)

### Task 23: App lock service

**Files:** Create `lib/core/security/app_lock.dart` and `test/core/security/app_lock_test.dart`; modify `MainActivity.kt` to extend `FlutterFragmentActivity`, the manifest (`USE_BIOMETRIC`) and `pubspec.yaml`.

**Interfaces:** `abstract class Authenticator { Future<bool> get available; Future<bool> authenticate(String reason); }`; `class AppLockController extends Notifier<LockState>` with `enabled`, `delay` (`immediately`, `oneMinute`, `fiveMinutes`) and `locked`; `onPaused()` records the time and `onResumed(now)` locks when the delay has passed.

- [ ] Tests first with a fake authenticator and clock: not enabled never locks; the immediate delay locks on any resume; a one-minute delay does not lock after 30 seconds and does after 61; a successful unlock clears the lock; a cancelled prompt keeps it; the lock survives a fresh start when enabled.
- [ ] Commit: `feat: add an app lock that follows the device biometrics`

### Task 24: Lock screen and settings

**Files:** Create `lib/features/security/presentation/lock_screen.dart`; add a Privacy section to the Profile tab and the route `/settings/privacy`; tests.

- [ ] The lock screen shows the logo and one Unlock button with the device prompt, and no data behind it. Turning the lock on first proves the user can unlock, and explains that the device screen lock is the fallback. Turning it on is refused with a clear message when the device has no screen lock.
- [ ] Wire the lock into `App` so it covers every route, including sheets.
- [ ] Commit: `feat: add the lock screen and privacy settings`

### Task 25: Privacy mode

**Files:** Create `lib/core/privacy/privacy_mode_provider.dart`; modify `lib/core/widgets/money_text.dart`, the Home hero and Profile; tests.

- [ ] When on, `MoneyText` shows `RWF ••••`; tapping the eye on Home reveals amounts for the session; the state is stored locally.
- [ ] Commit: `feat: hide amounts in privacy mode`

### Task 26: Hide from recents and block screenshots

**Files:** Modify `MainActivity.kt` (a `MethodChannel` `billa/secure_window` with `setSecure(bool)`); create `lib/core/platform/secure_window.dart`; tests with a fake channel.

- [ ] A toggle in Privacy settings, applied at startup from the stored value.
- [ ] Commit: `feat: hide the app from recents and block screenshots on request`

### Task 27: Batch 4 verification and PR

- [ ] Analyzer, tests, builds, and a phone check of unlock, lock delay, privacy mode and the recents preview.
- [ ] Push `r2d-privacy` and open a PR against `r2c-paid`.

---

## Batch 5: accessibility and polish (`r2e-a11y`)

### Task 28: Semantics and touch targets

**Files:** Modify list tiles, hero actions, status pills and icon buttons; add a shared test helper `expectAccessible(tester)`.

- [ ] Row semantics read as one sentence (for example "Invoice INV-0001, Acme Ltd, 12,000 francs, unpaid"); every `IconButton` has a tooltip; a test walks the key screens and asserts every tappable is at least 48 dp.
- [ ] Commit per area: `fix: label <area> for screen readers`

### Task 29: Large text

**Files:** Modify layouts that clip; tests pumping at a `textScaler` of 1.6 for Home, the create sheet, the tab bar and forms.

- [ ] Commit: `fix: keep layouts intact at large system font sizes`

### Task 30: Shared-element transitions

**Files:** Modify document and customer rows and detail headers; tests.

- [ ] `Hero` on the avatar or type icon between row and detail, skipped when reduce-motion is on.
- [ ] Commit: `feat: animate rows into their detail screens`

### Task 31: Undo on reversible actions

**Files:** Modify the actions that toggle or archive (the customer active toggle and any document action with a reverse endpoint); tests.

- [ ] Show a snackbar with Undo for 5 seconds; Undo restores through the reverse endpoint; irreversible actions keep their confirm sheet.
- [ ] Commit: `feat: undo reversible actions from a snackbar`

### Task 32: Support codes in errors

**Files:** Modify `lib/core/errors/action_errors.dart`; tests.

- [ ] Append "Code: <error>" for server errors that carry a machine code and are not already explained; connection and validation messages stay code-free.
- [ ] Commit: `feat: show a short support code with unexpected errors`

### Task 33: Dark theme review

**Files:** Modify colours where contrast fails; tests asserting contrast ratios of key text and button pairs at 4.5:1.

- [ ] Commit: `fix: correct low-contrast colours in the dark theme`

### Task 34: Final verification and PR

- [ ] Analyzer, full tests, debug build, a signed split-per-abi release build, install on the Tecno CC7, and a manual pass through login, idle reopen, offline, lock, share and duplicate.
- [ ] Update the `billa-mobile-roadmap` and `billa-mobile-known-gaps` memories; push `r2e-a11y` and open a PR against `r2d-privacy`.
