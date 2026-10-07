# Phase 7a: Account Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A settings area where a signed-in user edits their profile and avatar, manages two-factor auth, devices, and account deletion, sets notification preferences and the app theme, and signs out.

**Architecture:** Two repositories split by backend router (`ProfileRepository`, `SecurityRepository`) under `lib/features/account/`. The signed-in user stays in `AuthStatus.authenticated`; `AuthController.updateUser` patches it in place. Screens reuse the shared confirm/prompt dialogs, error banner, and `describeActionError`. The theme choice is a device preference persisted through a small store abstraction.

**Tech Stack:** Flutter, `flutter_riverpod` 2.6.1, `go_router`, `dio`, `freezed`, `shared_preferences`, `image_picker`, `mocktail`.

**Spec:** `docs/superpowers/specs/2026-09-25-phase7a-account-design.md`

## Global Constraints

- Commits authored solely as `Ange Aurele TUYISENGE <tuyisengeauris@gmail.com>`; no trailers and no tooling attribution anywhere.
- Small, single-sentence, conventional-commit-style messages, one logical change per commit.
- Comments explain *why*, never *what*, and never point at plan or spec documents.
- No dead ends: every action has a specific error message and a retry path.
- Every task ends with `flutter analyze` clean and `flutter test` passing.
- Read auth state with `.valueOrNull`, never `.value`, in code that tests may run without auth overrides.
- Keep the `if (x != null) 'key': x` map-entry form; the pinned analyzer can't parse null-aware entries.
- Business settings, dashboard, search, and the notifications inbox are out of scope (7b and 7c).

---

### Task 1: Error codes, asset URLs, and auth-state helpers

**Files:**
- Modify: `lib/core/errors/action_errors.dart`, `test/core/errors/action_errors_test.dart`
- Create: `lib/core/network/asset_url.dart`, `test/core/network/asset_url_test.dart`
- Modify: `lib/features/auth/presentation/providers/auth_controller.dart`, `test/features/auth/presentation/providers/auth_controller_test.dart`

**Interfaces:**
- Produces: six new messages in `describeActionError`: `invalid_code` "That code isn't right — try again", `not_enabled` "Two-factor sign-in isn't turned on", `has_admin_history` "This account can't be deleted because it has administrator history", `upload_failed` "The upload failed — try again", `invalid_file_type` "Choose a PNG, JPG, or WebP image", `no_file` "Choose an image first"; `String resolveAssetUrl(String url, {String base = apiBaseUrl})`; `AuthController.updateUser(AuthUser Function(AuthUser) change)`; `AuthController.clearSession()`.

- [ ] **Step 1: Write the failing tests.** Extend the error-code test with the six codes. `asset_url_test.dart` asserts `resolveAssetUrl('/uploads/a.png', base: 'http://h:4000')` is `http://h:4000/uploads/a.png`, an `https://` URL passes through unchanged, and a base with a trailing slash doesn't double it. Auth controller tests assert `updateUser` replaces the user while keeping the business, is a no-op when unauthenticated, and `clearSession` yields `AuthStatus.unauthenticated()` without calling the repository.
- [ ] **Step 2: Run them, confirm they fail, then implement:**

```dart
// lib/core/network/asset_url.dart
import 'api_client.dart';

/// The backend stores uploads as relative paths, so anything not already
/// absolute needs the API origin in front before an image widget can load it.
String resolveAssetUrl(String url, {String base = apiBaseUrl}) {
  if (url.startsWith('http://') || url.startsWith('https://')) return url;
  final origin = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
  return url.startsWith('/') ? '$origin$url' : '$origin/$url';
}
```

```dart
  // Profile edits and 2FA changes happen server-side without re-issuing the
  // session, so the signed-in user is patched locally instead of refetched.
  void updateUser(AuthUser Function(AuthUser current) change) {
    final current = state.valueOrNull;
    if (current is Authenticated) {
      state = AsyncData(AuthStatus.authenticated(change(current.user), current.business));
    }
  }

  // After account deletion the server has already cleared the cookies, so a
  // logout request would only 401.
  void clearSession() => state = const AsyncData(AuthStatus.unauthenticated());
```

- [ ] **Step 3: Run tests, analyze, commit** as `feat: add account error codes, asset URL resolution, and auth-user updates`.

---

### Task 2: Domain models

**Files:**
- Create: `lib/features/account/domain/user_profile.dart`, `session_info.dart`, `two_factor_setup.dart`, `notification_type.dart`
- Test: `test/features/account/domain/account_models_test.dart`

**Interfaces:**
- Produces: `UserProfile{id, email, name?, phone?, avatarUrl?}`; `SessionInfo{id, createdAt, expiresAt, isCurrent}`; `TwoFactorSetup{secret, otpauthUrl, qrCodeDataUri}`; `enum NotificationType` with `wireName` (`INVOICE_OVERDUE`, `PAYMENT_RECEIVED`, `MEMBER_JOINED`, `CONTACT_MESSAGE_RECEIVED`, `DOCUMENT_ACCEPTED`, `DOCUMENT_DECLINED`), `label`, and `NotificationType.fromWire(String)` returning null for unknown names so a new server type can't crash the screen.

- [ ] **Step 1: Failing tests.** JSON parsing for the three freezed models (including a null phone and avatar); `fromWire` round-trips all six and returns null for `SOMETHING_NEW`.
- [ ] **Step 2: Implement** the freezed classes (same shape as the team models) and the enum, run `dart run build_runner build --delete-conflicting-outputs`, tests, analyze, commit `feat: add account domain models`.

---

### Task 3: Repositories

**Files:**
- Create: `lib/features/account/domain/profile_repository.dart`, `security_repository.dart`, `lib/features/account/data/profile_repository_impl.dart`, `security_repository_impl.dart`, `lib/features/account/presentation/providers/profile_repository_provider.dart`, `security_repository_provider.dart`
- Test: `test/features/account/data/profile_repository_impl_test.dart`, `security_repository_impl_test.dart`

**Interfaces:** the two abstract classes exactly as in the spec; `profileRepositoryProvider`, `securityRepositoryProvider`.

- [ ] **Step 1: Failing tests with a mocked `Dio`.** Cover: `updateProfile` sends `{name, phone}` and sends `phone: null` when cleared; `uploadAvatar` posts `FormData` to `/profile/avatar` and returns `url`; `removeAvatar` DELETEs; `notificationPreferences` maps wire names to `NotificationType` and drops unknown ones; `setNotificationPreference` PATCHes `{preferences: {PAYMENT_RECEIVED: false}}`; `setUpTwoFactor` parses the setup; `verifyTwoFactor` returns backup codes; `disableTwoFactor` posts `{code}`; `sessions` parses `results`; `revokeSession` and `revokeOtherSessions` hit `/profile/sessions/:id/revoke` and `/profile/sessions/revoke-others`; `deleteAccount` DELETEs `/auth/me`.
- [ ] **Step 2: Implement** with `_dio.get<Map<String, dynamic>>` and friends in the same style as `TeamRepositoryImpl`, provider files mirroring `team_repository_provider.dart`; run tests, analyze, commit `feat: add profile and security repositories`.

---

### Task 4: Theme preference

**Files:**
- Modify: `pubspec.yaml` (add `shared_preferences`), `lib/app/theme/theme_mode_provider.dart`, `lib/main.dart`
- Create: `lib/app/theme/theme_preference_store.dart`
- Test: `test/app/theme/theme_mode_provider_test.dart`

**Interfaces:**
- Produces: `abstract class ThemePreferenceStore { String? read(); Future<void> write(String value); }`; `InMemoryThemePreferenceStore`; `SharedPreferencesThemePreferenceStore(SharedPreferences)`; `themePreferenceStoreProvider` (in-memory default); `themeModeProvider` as `NotifierProvider<ThemeModeController, ThemeMode>` with `set(ThemeMode)`.

- [ ] **Step 1: Failing tests.** Defaults to system; reads a stored `dark`; `set(ThemeMode.light)` updates state and writes `light`; an unknown stored value falls back to system.
- [ ] **Step 2: Implement.** `main.dart` awaits `SharedPreferences.getInstance()` and overrides `themePreferenceStoreProvider`. Run `flutter pub get`, the full suite (the existing `app_test.dart` reads `themeModeProvider`), analyze, commit `feat: persist the theme choice on the device`.

---

### Task 5: Settings hub, profile, and appearance screens

**Files:**
- Create: `lib/features/account/presentation/widgets/user_avatar.dart`, `lib/features/account/presentation/providers/avatar_picker_provider.dart`, `lib/features/account/presentation/screens/settings_screen.dart`, `profile_screen.dart`, `appearance_screen.dart`
- Test: `test/features/account/presentation/screens/settings_screen_test.dart`, `profile_screen_test.dart`, `appearance_screen_test.dart`

**Interfaces:**
- Produces: `UserAvatar({required AuthUser user, double radius})` (network image via `resolveAssetUrl`, initials fallback); `avatarPickerProvider` (`Provider<Future<({List<int> bytes, String name})?> Function()>`, default wraps `ImagePicker`); `SettingsScreen`, `ProfileScreen`, `AppearanceScreen`. Widget keys: `settings-profile`, `settings-security`, `settings-notifications`, `settings-appearance`, `settings-sign-out`, `profile-name`, `profile-phone`, `profile-save`, `profile-avatar-change`, `profile-avatar-remove`.

- [ ] **Step 1: Failing tests.** Settings shows name/email and the five rows, and sign out confirms then calls `logout()`. Profile saves name/phone through `updateProfile` and updates the auth user, a cleared phone sends null, a blank name blocks Save, an `upload_failed` avatar error shows its message with Retry, choosing an image uploads then updates `avatarUrl`, and Remove calls `removeAvatar` and clears it. Appearance shows three choices and tapping Dark sets the provider.
- [ ] **Step 2: Implement** using the shared `_runAction` shape, `ActionErrorBanner`, `showConfirmDialog`, and `AuthController.updateUser`; run tests, analyze, commit `feat: add the settings, profile, and appearance screens`.

---

### Task 6: Security, two-factor, sessions, delete account, notifications

**Files:**
- Create: `lib/features/account/presentation/screens/security_screen.dart`, `two_factor_setup_screen.dart`, `sessions_screen.dart`, `notification_preferences_screen.dart`
- Test: one test file per screen under `test/features/account/presentation/screens/`

**Interfaces:**
- Produces: the four screens. Keys: `security-two-factor`, `security-sessions`, `security-delete`, `two-factor-code`, `two-factor-verify`, `two-factor-saved`, `two-factor-done`, `sessions-revoke-others`, `delete-email`, `delete-confirm`.

- [ ] **Step 1: Failing tests.** Security shows Turn on or Turn off by `totpEnabled`; turning off asks for a code and maps `invalid_code`, and success calls `updateUser(totpEnabled: false)`. Setup loads the QR and secret, a wrong code shows "That code isn't right — try again", a right code shows the backup codes, Done stays disabled until the checkbox is ticked, and finishing sets `totpEnabled: true`. Sessions marks the current one non-revocable, revoke confirms and reloads, and "Sign out other devices" appears only with more than one session. Delete requires typing the exact email, success calls `clearSession`, and `has_admin_history` shows its message. Preferences shows six labelled switches, toggling patches one key and shows the merged result, and failure shows Retry.
- [ ] **Step 2: Implement**, run tests, analyze, commit in two commits: `feat: add the security, two-factor, and sessions screens`, then `feat: add the notification preferences screen`.

---

### Task 7: Home entry point and routes

**Files:**
- Modify: `lib/app/router.dart`, `test/app/router_test.dart`

**Interfaces:** routes `/settings`, `/settings/profile`, `/settings/security`, `/settings/security/two-factor`, `/settings/security/sessions`, `/settings/notifications`, `/settings/appearance`; a `home-account` icon button on home.

- [ ] **Step 1: Failing router tests.** The account icon opens `/settings` showing the signed-in email; Profile, Security, Notifications, and Appearance rows each open their screens (repositories mocked).
- [ ] **Step 2: Implement**, run the full suite, analyze, commit `feat: add the account entry point and routes to home`.

---

### Task 8: Final verification

- [ ] `flutter analyze` is clean; `flutter test` passes in full; `flutter build apk --debug` succeeds; iOS verification stays deferred to macOS.

## Definition of done

Analyze is clean, the suite passes, the debug APK builds, and a manual run shows: the home account icon opens settings with the user's avatar, name, and email; profile edits and avatar changes persist and show immediately; two-factor can be turned on with a QR, verified, backup codes shown once, and turned off with a code; other devices can be listed and signed out; notification switches persist; the theme choice survives a restart; deleting the account requires the typed email and lands on login; sign out confirms first. Every failure shows a specific message with a working Retry.
