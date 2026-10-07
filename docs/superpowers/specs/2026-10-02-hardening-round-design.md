# Hardening round design

Six stacked batches that close the gaps found in the mobile audit: security, speed, getting paid, privacy, accessibility. Backend changes are not part of this round.

## Batch 1: security foundation

- Android backups are turned off (`allowBackup=false`, empty data extraction rules), so neither the cookie jar nor app preferences can leave the phone through a backup.
- Login cookies move from a plain file to `flutter_secure_storage` through a `Storage` implementation that `PersistCookieJar` accepts. The old cookie file is deleted on first launch, which signs existing installs out once.
- The remembered session (user and business) moves from `SharedPreferences` to secure storage. Secure storage is asynchronous, so it is loaded once in `main()` and served from memory afterwards.
- Release builds are signed with a real key. The key and its passwords live outside the repository; `android/key.properties` is git-ignored. Without it the build falls back to the debug key so tests and CI still build.
- Release builds turn on code shrinking and resource shrinking, with keep rules for the plugins that need them. The tester APK is built per CPU architecture.
- The app name shown on the launcher is "Billa".

## Batch 2: speed foundation

- Fraunces and Plus Jakarta Sans are bundled as assets and runtime font downloads are disabled.
- Startup work that does not gate the first frame runs concurrently instead of in sequence.
- Network images (avatar, logo) go through a disk-backed image cache.
- A response cache stores successful GET responses per business. When a read fails because the phone is offline or the request times out, the cached response is returned and marked stale. The cache is cleared on sign-out and on a rejected session.
- A connectivity banner sits above the tab content: "You're offline. Showing saved data." while offline, and "Showing saved data" when a stale response was served.
- Forms keep what was typed when a save fails, with the specific reason and a working retry. This is verified by tests on the customer, item, document and payment forms.
- Out of scope: creating documents while offline (needs server-owned numbering and totals; its own round).

## Batch 3: getting paid and fast capture

- Call, SMS and WhatsApp actions on overdue invoice rows, receivable rows and the customer detail. Rwandan numbers are normalised to international format for WhatsApp. If the phone has no handler, a specific message appears.
- A WhatsApp reminder and a WhatsApp share of the document, prefilled with the amount and the public link (`<API origin>/view/<publicToken>`; the client and API share one origin).
- Swipe actions on document and receivable rows.
- Duplicate a document: a new draft created from an existing document's customer and lines through the existing create endpoint (the API has no duplicate route).
- Pick a customer from the phone's contacts with the system contact picker, which needs no contacts permission.
- Frequent items: the last items used are remembered per business and offered as chips on invoice lines.
- Home shows a Continue draft card for the newest draft, and Documents remembers recently opened documents.
- Input polish: numeric keyboards and formatters for money and quantity, phone keyboards, next-field actions, autofill hints, capitalisation rules.

## Batch 4: privacy

- Optional app lock with the device's biometrics or screen lock (`local_auth`), an auto-lock delay (immediately, 1 minute, 5 minutes), and a lock screen that does not leak content.
- Privacy mode hides money amounts behind dots until revealed, toggled from Home and Profile.
- Optional "hide app in recent apps and block screenshots" using `FLAG_SECURE` through a small platform channel.
- The three settings are stored locally per device.

## Batch 5: accessibility and polish

- Screen-reader labels on list rows, hero actions, status pills and icon buttons; minimum 48 dp touch targets.
- The app is checked at large system font sizes and layouts are fixed where text clips or overlaps.
- Shared-element transitions from list rows to their detail screens.
- Undo on reversible destructive actions (for example voiding or archiving) through a snackbar.
- Errors carry a short support code taken from the server response when present.
- Dark theme is reviewed screen by screen for the new shell, home and profile.

## Batch 6: verification

Analyzer with zero warnings, full test suite, release build (per architecture), install on the Tecno CC7, and a manual pass through login, idle reopen, offline, lock, and share flows.

## Decisions

- One PR per batch, each based on the previous batch's branch, with no attribution lines.
- No offline write queue and no push notifications in this round.
- The release key is generated on this PC, kept outside git, and the founder is told where it is and that it must be backed up.
