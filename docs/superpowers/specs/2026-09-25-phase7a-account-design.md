# Phase 7a: Account — Design

## Context

Phase 7 (account and polish) is split three ways, as phase 4 was:

- **7a — Account** (this document): settings hub, profile, security,
  notification preferences, appearance, sign out.
- **7b — Business settings**: owner-only business profile, numbering
  sequences, logo, read-only subscription status.
- **7c — Polish**: real home dashboard, global search, notifications inbox
  with an unread badge, and an empty/loading/error consistency pass.

The contract was read from the sibling `billa` repo:

- `server/src/routes/profile.ts` — `PATCH /profile` (`{name, phone?}`,
  phone is nullable so `null` clears it; returns `{user: {id, name, phone,
  email, avatarUrl}}`), `POST /profile/avatar` (multipart field `avatar`,
  5 MB, images only; 400 `invalid_file_type` / `upload_failed` / `no_file`;
  201 `{url}` where `url` is a relative `/uploads/...` path), `DELETE
  /profile/avatar`, `GET /profile/sessions` (`{results: [{id, createdAt,
  expiresAt, isCurrent}]}`), `POST /profile/sessions/:id/revoke` (404
  `not_found`), `POST /profile/sessions/revoke-others`, `GET|PATCH
  /profile/notification-preferences` (`{preferences: {TYPE: bool}}` for six
  types; PATCH body `{preferences: {...partial}}`, returns the merged set).
- `server/src/routes/auth.ts` — `POST /auth/2fa/setup` (`{secret,
  otpauthUrl, qrCodeDataUri}`), `POST /auth/2fa/verify` (`{code}` six digits;
  400 `invalid_code`; returns `{backupCodes}` exactly once), `POST
  /auth/2fa/disable` (`{code}` TOTP or backup code; 400 `invalid_code`, 409
  `not_enabled`), `DELETE /auth/me` (409 `has_admin_history`; clears the auth
  cookies), `POST /auth/logout`.
- `/auth/me` already returns `name`, `phone`, `avatarUrl`, `totpEnabled`,
  and the mobile `AuthUser` already models all of them, so no second user
  store is needed.

## Non-goals

- Business settings, sequences, logo, subscription (7b).
- Dashboard, search, notifications inbox (7c).
- Changing email or password: sign-in is delegated to Firebase, and the
  backend has no endpoint for either.
- Impersonation and admin surfaces.

## Architecture

Everything new lives under `lib/features/account/`, with two repositories
split by backend router rather than by screen:

```dart
abstract class ProfileRepository {                 // /profile/*
  Future<UserProfile> updateProfile({required String name, String? phone});
  Future<String> uploadAvatar(List<int> bytes, String filename);
  Future<void> removeAvatar();
  Future<Map<NotificationType, bool>> notificationPreferences();
  Future<Map<NotificationType, bool>> setNotificationPreference(NotificationType type, bool enabled);
}

abstract class SecurityRepository {                // /auth/2fa/*, sessions, /auth/me
  Future<TwoFactorSetup> setUpTwoFactor();
  Future<List<String>> verifyTwoFactor(String code);
  Future<void> disableTwoFactor(String code);
  Future<List<SessionInfo>> sessions();
  Future<void> revokeSession(String id);
  Future<void> revokeOtherSessions();
  Future<void> deleteAccount();
}
```

`AuthController` gains two methods. `updateUser(AuthUser Function(AuthUser))`
patches the signed-in user in place (profile edits, avatar changes, 2FA
turning on or off) so every screen reading the auth state sees it without a
refetch. `clearSession()` moves to unauthenticated without a network call,
used after account deletion because the server has already cleared the
cookies and a `/auth/logout` round trip would only 401.

Avatar URLs are relative on the server, so `resolveAssetUrl` in
`core/network` prefixes `apiBaseUrl` to anything that isn't already
absolute.

### Theme choice

`themeModeProvider` becomes a `Notifier<ThemeMode>` backed by a small
`ThemePreferenceStore` (read/write of one string). The default store is
in-memory so tests and previews need no setup; `main.dart` overrides it with
a `shared_preferences`-backed store so the choice survives restarts. The
theme is a device preference, deliberately not stored on the account: the
backend has no field for it and a shared account can reasonably look
different on different devices.

## Screens

- **Home** gains an account icon in its header opening `/settings`.
- **`SettingsScreen`** (`/settings`): header with avatar, name, and email,
  then rows Profile, Security, Notifications, Appearance, and Sign out
  (confirmation first). Sign out uses the existing `logout()` and the router
  redirect does the rest.
- **`ProfileScreen`** (`/settings/profile`): name (required) and phone
  (optional; clearing it sends `null`), Save; avatar with Change (gallery
  picker, upload, then update the user) and Remove. Errors use the shared
  banner with Retry.
- **`SecurityScreen`** (`/settings/security`): a two-factor row (Turn on, or
  Turn off when enabled), Signed-in devices (`/settings/security/sessions`),
  and a Delete account row at the bottom.
- **`TwoFactorSetupScreen`** (`/settings/security/two-factor`): shows the QR
  from the returned data URI with the manual secret beneath it (selectable
  and copyable), a six-digit code field, and Verify. On success the backup
  codes are shown once, with Copy, and Done stays disabled until "I've saved
  these codes" is checked, because that response cannot be fetched again.
  Turning 2FA off is a dialog asking for a code, mapping `invalid_code`.
- **`SessionsScreen`**: each session with created and expiry dates, the
  current one labelled and not revocable; Revoke per row (confirm) and
  "Sign out other devices" when more than one exists.
- **Delete account**: a dialog that requires typing the account email; on
  success `clearSession()` sends the user to login. `has_admin_history` gets
  a specific message.
- **`NotificationPreferencesScreen`**: one switch per notification type with
  a human label; each toggle patches that one key and reflects the merged
  result the server returns, with Retry on failure.
- **`AppearanceScreen`**: System, Light, Dark radio choices.

## Errors

The shared `describeActionError` gains `invalid_code`, `not_enabled`,
`has_admin_history`, `upload_failed`, `invalid_file_type`, and `no_file`.

## Testing strategy

One task at a time, tests first:

1. Error codes, `resolveAssetUrl`, and `AuthController.updateUser` /
   `clearSession`.
2. Domain models and the notification-type enum.
3. `ProfileRepository` and `SecurityRepository` with a mocked `Dio`
   (multipart upload, nullable phone, partial preferences).
4. Theme store and `themeModeProvider`, plus the `shared_preferences`
   wiring in `main.dart`.
5. `SettingsScreen`, `ProfileScreen`, and `AppearanceScreen`.
6. `SecurityScreen`, `TwoFactorSetupScreen`, `SessionsScreen`, delete
   account, and `NotificationPreferencesScreen`.
7. Home entry point and routes, with router tests through the real
   `appRouterProvider`.
8. Final verification: `flutter analyze`, `flutter test`, `flutter build
   apk --debug`.
