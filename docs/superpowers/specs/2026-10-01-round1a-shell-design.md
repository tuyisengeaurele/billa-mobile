# Round 1A: Navigation Shell, Liquid Glass, Home, Profile, OTP, and Persistent Login

## Context

First slice of the mobile-native roadmap. The app has been a stack of screens
reached from buttons on the home screen. This round gives it the structure of
a modern phone app: a persistent glass tab bar, a home organised around the
job (see what is owed, act on it), a profile hub, a proper verification-code
screen, and a login that survives the way Instagram's does.

References analysed (screenshots from the founder): WhatsApp on iOS 26 (a
floating capsule tab bar over blurred content, selected tab in a soft
capsule, badges, round glass header buttons, large title with a search field),
a shoe app (floating icon pill, greeting header with search and bell), a
delivery app (greeting header, search field, balance card with trend chip and
three quick actions, small stat tiles), and an OTP screen (masked email with
Change, focused boxes, shake on error, countdown, Confirm, Resend).

Backend facts that shape the design:

- The access token lasts 15 minutes; the refresh token slides for 30 days
  (each refresh issues a new one, cookie persisted by the jar). `GET /auth/me`
  is exempt from the interceptor's refresh-on-401, so at launch after 15
  idle minutes the app reads the 401 as "logged out" although a valid refresh
  token is stored. That is the real reason logins do not stick.
- The two-factor sign-in challenge expires 5 minutes after it is issued.
- The API exposes no member versus accountant role (only ownership).

Decisions taken with the founder: five tabs (Home, Documents, Customers,
Payments, Profile); the quick-create "+" is a separate glass circle docked
beside the tab bar; the login stays 30 days sliding, fixing the launch bug
only (no backend change).

## Non-goals

- Apple sign-in, "keep me signed in" switch, multi-account switching.
- A longer mobile refresh window (a later backend change if wanted).
- The Payments call/WhatsApp actions (Round 1B) and other later rounds.
- Real refraction shaders: on the target low-end Android they cost too much.

## Persistent login

- `AuthRepositoryImpl.me()`: on a 401, call `POST /auth/refresh` once and
  retry `/auth/me`; only a failed refresh means unauthenticated. Network
  errors stay errors (the launch retry screen already handles them).
- The cookie jar already persists the refresh cookie (it carries a max age).
- On app resume, if signed in and the last refresh was over 10 minutes ago,
  refresh quietly so an idle session never reaches a 401 in front of the user.
  A refresh that fails with 401 signs out; a network failure changes nothing.

## Glass

`GlassSurface` is a translucent material: a blur of what is behind it
(`BackdropFilter`), a tint (white at 70% in light, the surface colour at 55% in
dark), a 1 px hairline highlight border, and a soft shadow. A
`glassBlurEnabledProvider` decides whether to blur: off on Android below API 29
and when the platform reports reduced transparency, where the tint alone (a
little more opaque) is used. Everything is wrapped in a `RepaintBoundary`.

## Navigation shell

`StatefulShellRoute.indexedStack` with five branches whose roots keep their
paths: `/` Home, `/documents`, `/customers`, `/receivables` (Payments),
`/settings` (Profile). Detail, editor, and form routes stay top-level, so they
cover the shell and the bar disappears with the normal transition.

- `AppShell` hosts the branches with `extendBody`, so lists scroll under the
  bar and reserve bottom padding for it.
- `GlassNavBar`: a floating capsule inset 16 px from the edges and above the
  safe area, icon over a short label, a sliding highlight capsule under the
  selected item (220 ms ease), outline to filled icon, a selection haptic,
  and a badge on Payments showing the overdue count from the dashboard
  summary. Tapping the selected tab returns that branch to its root.
- `QuickCreateButton`: a glass circle with "+" docked to the right of the bar,
  shown on the four work tabs (not Profile). It opens the quick-create sheet:
  New invoice, quote, proforma, delivery note, receipt, credit note, New
  customer, Record payment (choose an outstanding invoice, then the existing
  payment screen). The Documents FAB is removed.
- Query parameters on a tab root (the dashboard's filtered links) use `go`,
  and `DocumentListScreen` re-applies its initial filters when they change.

## Home

Header: avatar (opens Profile), "Good morning/afternoon/evening" over the
business name (tap to switch), round glass search and bell buttons.
Then, in order: a hero card with "Invoiced this month", the trend chip, and
three actions (New invoice, Record payment, Add customer); Collected and
Outstanding tiles; Needs attention; the six-month bars; Recent documents with
"See all". The shortcut buttons and the account icon are removed; their
destinations live in the tab bar and Profile.

## Profile tab

The settings screen becomes the Profile tab root: a header (avatar, name,
email, current business with a switch action), a Business section (Business
settings for owners, Team for owners, Items, Businesses), an Account section
(Profile, Security, Notifications, Appearance), and Sign out.

## Payments tab

The receivables list becomes the Payments tab root: a summary card (total
outstanding, number of overdue invoices), aging filter chips, then the list.

## Verification code

`CodeInput`: six boxes with a focus ring, paste and one-time-code autofill,
auto-submit on the sixth digit, a shake and error haptic on a wrong code, a
success check, and keyboard entry through one hidden field so paste works.
The login verification screen shows the masked email with "Change" (back to
login), a countdown from 5:00 (the server's challenge lifetime; at zero it
returns to login with "This sign-in expired. Log in again"), a Confirm button,
and a "Use a backup code" toggle that swaps the boxes for a text field. The
two-factor setup and turn-off flows reuse `CodeInput`.

## Errors and testing

No new error codes. Tests first for each task: the refresh-on-launch and
resume behaviour with a mocked repository; `GlassSurface` fallback; the
navigation shell (tab switching keeps state, tapping the selected tab pops to
root, the bar hides on pushed routes, the badge); the quick-create sheet
routes; each redesigned screen; and `CodeInput` (typing, paste, auto-submit,
shake on error, countdown expiry).
