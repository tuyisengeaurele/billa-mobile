# Phase 6: Team and Multi-Business — Design

## Context

Until now the app assumes one business per account and one person per
business. The backend already supports both a user belonging to several
businesses and a business having a team with roles. Phase 6 exposes that:
switching between and creating businesses, managing the team, and joining
a business from an invite.

As with every prior phase, the contract was read directly from the sibling
`billa` repo (not vendored into billa-mobile):

- `server/src/routes/businesses.ts` — `GET /businesses` (owned then member
  businesses, each `{id, name, isOwner}`), `POST /businesses` (`{name}`;
  409 `business_limit_reached` at `BUSINESS_LIMIT = 3` owned; re-issues the
  session for the new business; returns `{business: {id, name}}`).
- `server/src/routes/auth.ts` — `POST /auth/switch-business` (`{businessId}`;
  403 `no_access`; re-issues the session; returns `{business: {id, name,
  onboardingCompletedAt}}`). `GET /auth/me` returns only `{user, business,
  impersonating}` — never a role.
- `server/src/routes/business.ts` — owner-only: `GET /business/members`
  (`{members: [{id, email, role, joinedAt}]}`, role lowercase, owner row
  first), `PATCH /business/members/:userId/role` (`{role}`, uppercase,
  404 `not_found`), `DELETE /business/members/:userId`, `GET /business/
  invites` (`{invites: [{id, email, role, expiresAt, createdAt, link}]}`),
  `POST /business/invites` (`{email, role}` uppercase, role defaults
  `MEMBER`; 409 `already_member`; 201 `{invite, link}`), `DELETE /business/
  invites/:id`, `POST /business/invites/:id/resend`. Not owner-only:
  `POST /business/leave` — acts on the *session's current* business, 400
  `owner_cannot_leave`, 404 `not_a_member`; moves the user to another
  business (or creates "My Business" if it was their only one), re-issues
  the session, returns `{business: {id, name}, createdReplacement}`.
- `server/src/routes/invites.ts` — `GET /invites/:token` (public;
  `{email, businessName, expired, alreadyAccepted}`, 404 `not_found`) and
  `POST /invites/:token/accept` (authenticated; 404 `not_found`, 409
  `already_accepted`, 410 `expired`, 403 `email_mismatch`; re-issues the
  session; returns `{business: {id, name, onboardingCompletedAt}}`).
- `server/src/middleware/block-accountant-mutations.ts` — an accountant's
  non-`GET` request on business data returns 403 `read_only_role`.

Two facts shape the design. First, a non-owner client cannot learn whether
it is a member or an accountant: `isOwner` is the only signal exposed, and
`GET /business/members` is owner-only. The web app doesn't try to hide
anything for accountants either, so mobile does the same and maps the 403.
Second, role strings are lowercase on the way out (`"member"`) and
uppercase on the way in (`"MEMBER"`); the models keep those two directions
explicit rather than sharing one converter.

Two decisions were made explicitly with the project owner:

1. **One phase, without the activity log.** Multi-business and team share
   the same business-context plumbing and every call is a one-shot action
   in the shape phases 4c and 5 proved; the activity feed is a separate
   read-only surface that wasn't part of this phase's name.
2. **Invites are accepted by pasting the emailed link into the app**, not
   through deep links. Deep links depend on the web host serving app-link
   verification files, which is outside a mobile-only phase and can't be
   exercised end to end here.

## Non-goals

- The activity log, and any notifications feed.
- Deep links from the invite email.
- Transferring or deleting a business, and MoMo/billing settings.
- Pre-hiding actions for accountants (the backend gives no way to know the
  role of a non-owner; the 403 is mapped instead).
- Changing the existing onboarding `BusinessRepository`.

## Active business as a single source of truth

`AuthStatus.authenticated(user, business)` already holds the current
business, so no second store is introduced. Two additions:

- `AuthController.setBusiness(Business)` replaces the business inside the
  current authenticated state, used after switch, create, join, and leave
  (each of which re-issues the session cookies, which the existing cookie
  jar already stores).
- `activeBusinessIdProvider` — a `Provider<String?>` derived from
  `authControllerProvider` with `select`, so it only notifies when the id
  actually changes, not on every auth-state update.

`PaginatedListController.build()` watches `activeBusinessIdProvider`, so
the customer, item, and document list controllers rebuild and refetch when
the business changes. Screens backed by one-shot futures (detail,
receivables, team) are not kept alive across a switch: every switch,
create, join, or leave ends by navigating to `/` with `go`, which drops the
pushed stack. This is a small, explicit set of things to keep in step; the
alternative of rebuilding the whole provider tree would also drop the
in-memory cookie jar and the API client.

A newly created business has `onboardingCompletedAt == null`, so the
existing router redirect sends the user through onboarding for it — the
desired behavior, with no new code.

`myBusinessesProvider` (`FutureProvider.autoDispose`, watches
`activeBusinessIdProvider`) loads `GET /businesses`;
`isOwnerOfActiveBusinessProvider` derives from it. The home screen uses
both.

## Domain models

```dart
enum TeamRole { owner, member, accountant }
// lowercase on the wire in responses; write requests use uppercase.
TeamRole teamRoleFromJson(String value);          // 'owner'|'member'|'accountant'
String teamRoleToRequest(TeamRole role);          // MEMBER | ACCOUNTANT (never owner)

class BusinessSummary { String id; String name; bool isOwner; }
class TeamMember { String id; String email; TeamRole role; String joinedAt; }
class PendingInvite { String id; String email; TeamRole role; String expiresAt; String createdAt; String link; }
class InvitePreview { String email; String businessName; bool expired; bool alreadyAccepted; }
class LeaveResult { Business business; bool createdReplacement; }
```

`teamRoleToRequest` throws for `owner`: an owner can never be assigned or
invited, so the type system's one impossible input fails loudly instead of
sending a request the backend would reject.

## Repositories

Two, split by URL scope rather than by entity:

```dart
abstract class BusinessesRepository {          // user-scoped
  Future<List<BusinessSummary>> list();                 // GET /businesses
  Future<Business> create(String name);                 // POST /businesses
  Future<Business> switchTo(String businessId);         // POST /auth/switch-business
  Future<InvitePreview> previewInvite(String token);    // GET /invites/:token
  Future<Business> acceptInvite(String token);          // POST /invites/:token/accept
  Future<LeaveResult> leaveCurrent();                   // POST /business/leave
}

abstract class TeamRepository {                // current business, owner-only
  Future<List<TeamMember>> members();
  Future<void> updateRole(String userId, TeamRole role);
  Future<void> removeMember(String userId);
  Future<List<PendingInvite>> invites();
  Future<void> invite(String email, TeamRole role);
  Future<void> resendInvite(String inviteId);
  Future<void> revokeInvite(String inviteId);
}
```

`invite` returns nothing because the create response omits `createdAt`; the
screen reloads the list, which is also the single place list state is
produced. Three of the responses (`create`, `acceptInvite`, `switchTo`)
carry a partial business (`id`, `name`, and sometimes
`onboardingCompletedAt`); `Business.fromJson` already tolerates that since
every other field is nullable.

## Error mapping

The document-specific helper becomes a shared one:
`lib/features/documents/presentation/document_action_errors.dart` moves to
`lib/core/errors/action_errors.dart` and `describeDocumentActionError`
becomes `describeActionError`, since team and business screens now use it
too and reaching across a feature boundary for an error helper would be the
wrong dependency. New codes: `read_only_role` ("Your role on this business
is read-only"), `business_limit_reached` ("You've reached the limit of 3
businesses"), `already_member`, `no_access`, `owner_cannot_leave`,
`not_a_member`, `email_mismatch` ("This invite was sent to a different
email address"), `expired` ("This invite has expired"), `already_accepted`,
and `not_found`.

## Screens

- **Home** gains a header showing the active business's name with a switch
  affordance to `/businesses`, and a `Team` button (`/team`) shown only
  when `isOwnerOfActiveBusinessProvider` is true. While the list loads, the
  Team button is simply absent; the businesses screen has its own retry.
- **`BusinessesScreen`** (`/businesses`): every business with an Owner
  badge and a check on the active one; tapping another switches (loading
  state on that row, error banner with retry). "New business" opens a name
  dialog; at the cap the backend's 409 is surfaced through the shared
  helper rather than hiding the action. "Join a business" opens
  `/businesses/join`. "Leave this business" appears only when the active
  business isn't owned by the user, behind a confirmation. After any
  success the screen calls `setBusiness` then `go('/')`.
- **`JoinBusinessScreen`** (`/businesses/join`): a paste field for the
  invite link. The token is the last non-empty path segment of the link
  (or the whole input if it has no `/`), which accepts both a pasted link
  and a bare token. "Continue" calls `previewInvite` and shows the business
  name and invited email; an expired or already-accepted preview disables
  Accept with the reason shown. "Accept" calls `acceptInvite`; the
  `email_mismatch`/`expired`/`already_accepted` errors each show their own
  message. Success does `setBusiness` then `go('/')`.
- **`TeamScreen`** (`/team`): two sections, members and pending invites,
  each loaded by its own future so one failing doesn't blank the other. The
  owner row has no actions. Other members get a role dropdown
  (member/accountant) and a remove action behind a confirmation. Pending
  invites show email, role, expiry, resend, and revoke. An "Invite someone"
  form takes an email and a role. Every mutation goes through one
  `_runAction` wrapper with an inline error banner and Retry, the same
  shape as phases 4c and 5.

## Testing strategy

Following the established rhythm, one task at a time:

1. Move the error helper to `core/` and rename it, adding the new codes;
   update every existing import and test in the same commit so the suite
   stays green.
2. `TeamRole` and the five new models, with JSON tests including the
   lowercase-in/uppercase-out role asymmetry.
3. `BusinessesRepository` and `TeamRepository` implementations, their
   providers, and repository tests with a mocked `Dio`.
4. `setBusiness`, `activeBusinessIdProvider`, and the list controllers
   watching it — a test that changing the business refetches a list.
5. `BusinessesScreen` and `JoinBusinessScreen`, including the token
   extraction cases.
6. `TeamScreen`.
7. Home header, Team button, and routes, plus end-to-end `router_test.dart`
   cases through the real `appRouterProvider`.
8. Final verification: `flutter analyze`, `flutter test`, `flutter build
   apk --debug`.
