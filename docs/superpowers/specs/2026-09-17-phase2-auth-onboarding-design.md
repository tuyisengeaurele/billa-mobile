# Phase 2: Auth and Onboarding — Design

## Context

Builds directly on Phase 1's foundation (theme, cookie-authenticated `ApiClient`
with single-flight refresh, shared widgets). This phase adds Firebase-backed
sign-in, the 2FA challenge, session bootstrap on launch, and the two-step
onboarding wizard a brand-new business goes through after signup. No feature
screens beyond onboarding — after finishing (or skipping) onboarding, the
user lands on the Phase 1 placeholder home screen, which Phase 3 fills in.

This branch stacks on top of the still-unmerged Phase 1 branch
(`worktree-phase1-foundation`), since it needs that scaffold to exist.

## Facts this design depends on

All confirmed by reading the live web client (`client/src/pages/Login.tsx`,
`Register.tsx`, `AuthContext.tsx`, `firebaseAuth.ts`), not assumed:

- **Login and signup are separate screens**, not a toggling form. Login has
  an *internal* state swap (`challengeId`) that replaces the form with a
  2FA code field when `POST /auth/session` returns
  `{ twoFactorRequired: true, challengeId }` — it never navigates away.
- **Signup collects no business name.** Fields are email, password, confirm
  password only. A placeholder `businessName: "My Business"` is sent
  implicitly; the real name is set in onboarding step 1. Password rules
  (exact, shown live as a checklist): **≥8 characters, one lowercase, one
  uppercase, one number, one special character.**
- **Google Sign-In is used for both login and signup**, rendered below the
  email/password form after a plain "or" divider.
- **"Forgot password?" appears only on login**, inline (no route change),
  and calls Firebase's `sendPasswordResetEmail` directly — no backend call.
  The UI shows the same success message whether or not the email exists
  (deliberate non-disclosure), so the mobile version must not distinguish
  either.
- **The backend session exchange is one call for all four paths**
  (login/signup × email/Google): `POST /auth/session` with `{ idToken }`
  for login, `{ idToken, businessName }` for signup. Response is always
  `{ user, business }` or the 2FA-challenge shape.
- **Onboarding is exactly two steps**, not three: business **details**
  (name, TIN, industry, phone, email, address, RRA EBM number — via
  `PATCH /business`, `businessProfileSchema`) then **logo** (the 4-call
  pipeline from Phase 1's backend survey: upload → remove-background →
  extract-colors → confirm). Each step is individually skippable, and
  there's a top-level "Skip onboarding." Finishing (or skipping) either way
  calls `POST /business/onboarding/complete`, which is the single point
  that sets `onboardingCompletedAt`.
- **Document template and numbering are not part of onboarding** — the web
  app exposes them later, in a `BusinessSettings` screen that isn't
  scoped to any phase yet. Explicitly out of scope here; revisit alongside
  Phase 6 (business switcher) in `features/businesses/`.
- **Cookie names/refresh contract**: unchanged from Phase 1 — `AuthInterceptor`
  already handles `401` → refresh → retry transparently. This phase adds the
  *first* callers that actually depend on that behavior mattering.

## Architecture

```
lib/
  features/
    auth/
      domain/
        auth_repository.dart      # interface
        auth_user.dart            # freezed data class
        auth_status.dart          # freezed union: unauthenticated / twoFactorRequired / authenticated
      data/
        auth_repository_impl.dart
        firebase_auth_service.dart   # wraps firebase_auth + google_sign_in, maps error codes
      presentation/
        providers/
          auth_controller.dart     # AsyncNotifier<AuthStatus>, bootstraps via GET /auth/me
        screens/
          login_screen.dart        # includes inline 2FA + forgot-password states
          register_screen.dart
        widgets/
          password_requirements_list.dart
    onboarding/
      domain/
        business_repository.dart   # interface (also used later by features/businesses)
        business.dart              # freezed data class (subset of fields needed now)
      data/
        business_repository_impl.dart
        logo_pipeline_service.dart # the 4-call chain as one cohesive unit
      presentation/
        providers/
          onboarding_controller.dart
        screens/
          onboarding_screen.dart   # hosts both internal steps
        widgets/
          details_step.dart
          logo_step.dart
  app/
    router.dart                    # modified: redirect guard reads authControllerProvider
    theme/
      bootstrap_screen.dart        # shown while the initial /auth/me check is pending
```

`AuthRepository` and `BusinessRepository` are the only things that call
`ApiClient.dio` for their domain; `FirebaseAuthService` is the only thing
that touches `firebase_auth`/`google_sign_in` directly.

### Auth state

```dart
sealed class AuthStatus {
  const factory AuthStatus.unauthenticated() = Unauthenticated;
  const factory AuthStatus.twoFactorRequired(String challengeId) = TwoFactorRequired;
  const factory AuthStatus.authenticated(AuthUser user, Business business) = Authenticated;
}
```

`authControllerProvider` is an `AsyncNotifier<AuthStatus>`. On build, it calls
`AuthRepository.me()` (`GET /auth/me`); a `401` there means "no valid
session," resolved to `AuthStatus.unauthenticated()` rather than surfaced as
an error — that's the expected outcome for a first-ever launch, not a
failure. While the `AsyncNotifier` is loading, `router.dart`'s redirect
callback shows nothing yet (the router itself waits); `main.dart` renders
`BootstrapScreen` (logo + subtle indicator, brief and native-feeling, echoing
the native splash rather than a generic spinner) until the first value
resolves.

### Router guard

`GoRouter`'s `redirect` reads `authControllerProvider` via `ref.read` inside
a `Listenable` bridge (`GoRouterRefreshStream` pattern — rebuilds the router
whenever the provider's state changes, e.g. after login or logout):

- Loading → stay put, `BootstrapScreen` is what's on screen anyway.
- `Unauthenticated` and not already on `/login` or `/register` → redirect to `/login`.
- `Authenticated` with `business.onboardingCompletedAt == null` and not
  already on `/onboarding` → redirect to `/onboarding`.
- `Authenticated` with onboarding complete, but sitting on `/login`,
  `/register`, or `/onboarding` → redirect to `/` (no dead-ending on an
  auth screen after already being signed in).
- `TwoFactorRequired` never redirects anywhere — it's rendered inline by
  `login_screen.dart`, not a router-level state.

### Login screen

Email + password fields, "Forgot password?" between password and submit
(calls `FirebaseAuthService.sendPasswordResetEmail` directly, always shows
"Check your email for a link to reset your password" regardless of outcome),
submit button, divider, "Continue with Google." On submit:
`FirebaseAuthService.signInWithEmailAndPassword` → on success, take the
`idToken` → `AuthRepository.exchangeSession(idToken)` → if the response is
the 2FA shape, set local `challengeId` state and swap to the code-entry form
(single field, "6-digit code, or use a backup code" — one input handles
both, matching the web copy exactly); otherwise the repository call updates
`authControllerProvider`, and the router redirect takes over from there.
Firebase error codes map to specific inline messages (wrong password, no
such user, network error, too many attempts) — never a bare failure state.

### Register screen

Email, password, confirm password, with the live requirements checklist
under the password field (each of the 5 rules shown with a met/unmet
indicator as the user types). "Continue with Google" below a divider, same
placement as login. On submit: `createUserWithEmailAndPassword` →
`AuthRepository.exchangeSession(idToken, businessName: "My Business")`. A
2FA-required response here would be a backend contract violation (a
brand-new signup can't have 2FA enabled yet) — treated as an unexpected
error, not a state this screen designs around.

### Onboarding

One screen, one `PageView`-backed internal step index (not two routes,
matching the web's single `/onboarding` route with component-level step
state). Step indicator reads "Step 1 of 2" / "Step 2 of 2." Details step is
a form (name required, everything else optional) submitting via
`BusinessRepository.updateProfile(...)` → `PATCH /business`. Logo step
chains the four calls from the Phase 1 backend survey as one
`LogoPipelineService.run(imageFile)` call that emits progress events
(uploaded → background-checked → colors-extracted), rendered as a short
animated checklist rather than a spinner; extracted colors are shown for
the user to confirm/adjust before the final `confirm` call persists them.
Each step has its own "Skip this step," and the screen's app bar has "Skip
onboarding." All three paths (finish step 2, skip step 2, skip onboarding
entirely) converge on the same `BusinessRepository.completeOnboarding()`
call (`POST /business/onboarding/complete`), after which the router redirect
takes the user to `/`.

## Testing

- `AuthStatus`: union equality/pattern-matching tests.
- `AuthRepository`/`BusinessRepository`: unit tests against a mocked `Dio`
  (via `mocktail`), covering the session-exchange 2FA branch, the `/auth/me`
  401-means-unauthenticated mapping, and the onboarding-complete call.
- `FirebaseAuthService`'s error mapper: a table-driven test over the known
  Firebase error codes.
- Widget tests: the password-requirements checklist reacting to typed input,
  and the login screen's swap into the 2FA code form when the controller
  reports `twoFactorRequired`.
- Router redirect logic: tested via `GoRouter`'s own test harness with a
  fake `authControllerProvider` override per state.

## Out of scope for this phase

Business Settings (template, numbering, banking info, MoMo setup — all
real web features, none of them in onboarding), team invites
(`inviteToken`), 2FA *setup* (enabling it from scratch — only the
*challenge* at login is handled here, since setup requires an already
-authenticated settings screen that doesn't exist until Phase 7), active
session management, and anything past the Phase 1 placeholder home screen.
