# Phase 6: Team and Multi-Business Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Switch between, create, join, and leave businesses, and let an
owner manage the team (members, roles, invites).

**Architecture:** The active business stays where it already lives, inside
`AuthStatus.authenticated`; a derived `activeBusinessIdProvider` exposes just
its id, and the list controllers rebuild when it changes. Two new
repositories split by URL scope (`BusinessesRepository` user-scoped,
`TeamRepository` current-business owner-only). Screens reuse the
`_runAction`/error-banner/confirm shape from phases 4c and 5, with the
shared pieces extracted into `core/` now that a third and fourth screen
need them.

**Tech Stack:** Flutter, `flutter_riverpod` 2.6.1, `go_router`, `dio`,
`freezed`/`json_serializable`, `mocktail`.

**Spec:** `docs/superpowers/specs/2026-09-24-phase6-team-multi-business-design.md`

## Global Constraints

- Commits authored solely as `Ange Aurele TUYISENGE <tuyisengeauris@gmail.com>`; no trailers and no tooling attribution anywhere.
- Small, single-sentence, conventional-commit-style messages, one logical change per commit.
- Comments explain *why*, never *what*, and never point at plan or spec documents.
- No dead ends: every action has a specific error message and a retry path.
- Every task ends with `flutter analyze` clean and `flutter test` passing.
- Read auth state with `.valueOrNull`, never `.value`: in this Riverpod version `AsyncValue.value` throws on an errored state, and any test that doesn't override auth has an errored auth provider.
- `build_runner`'s pinned analyzer can't parse null-aware map-entry syntax (`'key': ?value`); keep the `if (x != null) 'key': x` form.
- The activity log, invite deep links, and transferring/deleting a business are out of scope — see the spec's Non-goals.

---

### Task 1: Move the error helper to `core/` and add the new codes

**Files:**
- Move: `lib/features/documents/presentation/document_action_errors.dart` → `lib/core/errors/action_errors.dart`
- Move: `test/features/documents/presentation/document_action_errors_test.dart` → `test/core/errors/action_errors_test.dart`
- Modify: `lib/features/documents/presentation/screens/document_detail_screen.dart`, `lib/features/documents/presentation/screens/record_payment_screen.dart`

**Interfaces:**
- Produces: `String describeActionError(Object error)` (the renamed helper, plus ten new codes).

- [ ] **Step 1: Move and rename**

```bash
mkdir -p lib/core/errors test/core/errors
git mv lib/features/documents/presentation/document_action_errors.dart lib/core/errors/action_errors.dart
git mv test/features/documents/presentation/document_action_errors_test.dart test/core/errors/action_errors_test.dart
sed -i 's/describeDocumentActionError/describeActionError/g' lib/core/errors/action_errors.dart test/core/errors/action_errors_test.dart lib/features/documents/presentation/screens/document_detail_screen.dart lib/features/documents/presentation/screens/record_payment_screen.dart
sed -i "s#package:billa_mobile/features/documents/presentation/document_action_errors.dart#package:billa_mobile/core/errors/action_errors.dart#" test/core/errors/action_errors_test.dart
sed -i "s#import '../document_action_errors.dart';#import '../../../../core/errors/action_errors.dart';#" lib/features/documents/presentation/screens/document_detail_screen.dart lib/features/documents/presentation/screens/record_payment_screen.dart
```

- [ ] **Step 2: Confirm nothing broke, then commit the move alone**

```bash
flutter analyze
flutter test test/core/errors/action_errors_test.dart test/features/documents
git add -A lib/core/errors test/core/errors lib/features/documents/presentation/screens
git commit -m "refactor: move the action error helper to core and rename it"
```

Expected: analyze clean, tests pass (the move is behavior-neutral).

- [ ] **Step 3: Write the failing test cases for the new codes**

Add to the first test in `test/core/errors/action_errors_test.dart`:

```dart
    expect(describeActionError(_error('read_only_role')), 'Your role on this business is read-only');
    expect(describeActionError(_error('business_limit_reached')), "You've reached the limit of 3 businesses");
    expect(describeActionError(_error('already_member')), 'That person is already on this team');
    expect(describeActionError(_error('no_access')), "You don't have access to that business");
    expect(describeActionError(_error('owner_cannot_leave')), "Owners can't leave their own business");
    expect(describeActionError(_error('not_a_member')), "You're not a member of this business");
    expect(
      describeActionError(_error('email_mismatch')),
      'This invite was sent to a different email address',
    );
    expect(describeActionError(_error('expired')), 'This invite has expired');
    expect(describeActionError(_error('already_accepted')), 'This invite was already accepted');
    expect(describeActionError(_error('not_found')), "We couldn't find that — it may have been removed");
```

- [ ] **Step 4: Run it to confirm it fails**

```bash
flutter test test/core/errors/action_errors_test.dart
```

Expected: FAIL — the new codes fall through to the generic message.

- [ ] **Step 5: Add the cases**

Add to the `switch` in `lib/core/errors/action_errors.dart`, before the `_ =>` fallback:

```dart
    'read_only_role' => 'Your role on this business is read-only',
    'business_limit_reached' => "You've reached the limit of 3 businesses",
    'already_member' => 'That person is already on this team',
    'no_access' => "You don't have access to that business",
    'owner_cannot_leave' => "Owners can't leave their own business",
    'not_a_member' => "You're not a member of this business",
    'email_mismatch' => 'This invite was sent to a different email address',
    'expired' => 'This invite has expired',
    'already_accepted' => 'This invite was already accepted',
    'not_found' => "We couldn't find that — it may have been removed",
```

- [ ] **Step 6: Run it, analyze, commit**

```bash
flutter test test/core/errors/action_errors_test.dart
flutter analyze
git add lib/core/errors test/core/errors
git commit -m "feat: map team, business, and invite error codes to user-facing messages"
```

Expected: PASS (3 tests), analyze clean.

---

### Task 2: Team and business domain models

**Files:**
- Create: `lib/features/team/domain/team_role.dart`, `team_member.dart`, `pending_invite.dart`
- Create: `lib/features/businesses/domain/business_summary.dart`, `invite_preview.dart`, `leave_result.dart`, `invite_token.dart`
- Test: `test/features/team/domain/team_models_test.dart`, `test/features/businesses/domain/businesses_models_test.dart`, `test/features/businesses/domain/invite_token_test.dart`

**Interfaces:**
- Produces: `enum TeamRole`; `teamRoleFromJson`/`teamRoleToJson` (lowercase, responses) and `teamRoleToRequest` (uppercase, requests; throws for `owner`); `TeamMember`, `PendingInvite`, `BusinessSummary`, `InvitePreview`, `LeaveResult`; `String? extractInviteToken(String input)`.

- [ ] **Step 1: Write the failing tests**

```dart
// test/features/team/domain/team_models_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/team/domain/pending_invite.dart';
import 'package:billa_mobile/features/team/domain/team_member.dart';
import 'package:billa_mobile/features/team/domain/team_role.dart';

void main() {
  test('roles are lowercase in responses and uppercase in requests', () {
    expect(teamRoleFromJson('accountant'), TeamRole.accountant);
    expect(teamRoleToJson(TeamRole.member), 'member');
    expect(teamRoleToRequest(TeamRole.member), 'MEMBER');
    expect(teamRoleToRequest(TeamRole.accountant), 'ACCOUNTANT');
  });

  test('an owner can never be assigned or invited', () {
    expect(() => teamRoleToRequest(TeamRole.owner), throwsArgumentError);
  });

  test('an unknown role is rejected', () {
    expect(() => teamRoleFromJson('admin'), throwsArgumentError);
  });

  test('TeamMember.fromJson parses the owner row', () {
    final member = TeamMember.fromJson({
      'id': 'u1',
      'email': 'owner@example.com',
      'role': 'owner',
      'joinedAt': '2026-01-01T00:00:00.000Z',
    });

    expect(member.role, TeamRole.owner);
    expect(member.email, 'owner@example.com');
  });

  test('PendingInvite.fromJson parses an invite with its link', () {
    final invite = PendingInvite.fromJson({
      'id': 'i1',
      'email': 'new@example.com',
      'role': 'accountant',
      'expiresAt': '2026-02-01T00:00:00.000Z',
      'createdAt': '2026-01-25T00:00:00.000Z',
      'link': 'https://app.example.com/invite/tok123',
    });

    expect(invite.role, TeamRole.accountant);
    expect(invite.link, endsWith('/invite/tok123'));
  });
}
```

```dart
// test/features/businesses/domain/businesses_models_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/businesses/domain/business_summary.dart';
import 'package:billa_mobile/features/businesses/domain/invite_preview.dart';
import 'package:billa_mobile/features/businesses/domain/leave_result.dart';

void main() {
  test('BusinessSummary.fromJson parses ownership', () {
    final summary = BusinessSummary.fromJson({'id': 'b1', 'name': 'Acme', 'isOwner': true});

    expect(summary.name, 'Acme');
    expect(summary.isOwner, isTrue);
  });

  test('InvitePreview.fromJson parses the public preview', () {
    final preview = InvitePreview.fromJson({
      'email': 'new@example.com',
      'businessName': 'Acme',
      'expired': false,
      'alreadyAccepted': true,
    });

    expect(preview.businessName, 'Acme');
    expect(preview.alreadyAccepted, isTrue);
  });

  test('LeaveResult.fromJson tolerates a partial business', () {
    final result = LeaveResult.fromJson({
      'business': {'id': 'b2', 'name': 'My Business'},
      'createdReplacement': true,
    });

    expect(result.business.id, 'b2');
    expect(result.business.onboardingCompletedAt, isNull);
    expect(result.createdReplacement, isTrue);
  });
}
```

```dart
// test/features/businesses/domain/invite_token_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/businesses/domain/invite_token.dart';

void main() {
  test('takes the last path segment of a pasted link', () {
    expect(extractInviteToken('https://app.example.com/invite/tok123'), 'tok123');
  });

  test('ignores a trailing slash, query string, and surrounding whitespace', () {
    expect(extractInviteToken('  https://app.example.com/invite/tok123/  '), 'tok123');
    expect(extractInviteToken('https://app.example.com/invite/tok123?ref=email'), 'tok123');
  });

  test('accepts a bare token', () {
    expect(extractInviteToken('tok123'), 'tok123');
  });

  test('returns null for empty input', () {
    expect(extractInviteToken('   '), isNull);
  });
}
```

- [ ] **Step 2: Run them to confirm they fail**

```bash
flutter test test/features/team/domain test/features/businesses/domain
```

Expected: FAIL — none of the files exist yet.

- [ ] **Step 3: Implement**

```dart
// lib/features/team/domain/team_role.dart
enum TeamRole { owner, member, accountant }

TeamRole teamRoleFromJson(String value) => switch (value) {
      'owner' => TeamRole.owner,
      'member' => TeamRole.member,
      'accountant' => TeamRole.accountant,
      _ => throw ArgumentError('Unknown team role: $value'),
    };

String teamRoleToJson(TeamRole value) => switch (value) {
      TeamRole.owner => 'owner',
      TeamRole.member => 'member',
      TeamRole.accountant => 'accountant',
    };

// Requests use the backend's uppercase enum, unlike its lowercase responses,
// and the owner is never assignable — failing loudly here beats sending a
// request the server would reject.
String teamRoleToRequest(TeamRole role) => switch (role) {
      TeamRole.member => 'MEMBER',
      TeamRole.accountant => 'ACCOUNTANT',
      TeamRole.owner => throw ArgumentError('An owner role can never be assigned or invited'),
    };
```

```dart
// lib/features/team/domain/team_member.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'team_role.dart';

part 'team_member.freezed.dart';
part 'team_member.g.dart';

@freezed
class TeamMember with _$TeamMember {
  const factory TeamMember({
    required String id,
    required String email,
    @JsonKey(fromJson: teamRoleFromJson, toJson: teamRoleToJson) required TeamRole role,
    required String joinedAt,
  }) = _TeamMember;

  factory TeamMember.fromJson(Map<String, dynamic> json) => _$TeamMemberFromJson(json);
}
```

```dart
// lib/features/team/domain/pending_invite.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'team_role.dart';

part 'pending_invite.freezed.dart';
part 'pending_invite.g.dart';

@freezed
class PendingInvite with _$PendingInvite {
  const factory PendingInvite({
    required String id,
    required String email,
    @JsonKey(fromJson: teamRoleFromJson, toJson: teamRoleToJson) required TeamRole role,
    required String expiresAt,
    required String createdAt,
    required String link,
  }) = _PendingInvite;

  factory PendingInvite.fromJson(Map<String, dynamic> json) => _$PendingInviteFromJson(json);
}
```

```dart
// lib/features/businesses/domain/business_summary.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'business_summary.freezed.dart';
part 'business_summary.g.dart';

@freezed
class BusinessSummary with _$BusinessSummary {
  const factory BusinessSummary({
    required String id,
    required String name,
    required bool isOwner,
  }) = _BusinessSummary;

  factory BusinessSummary.fromJson(Map<String, dynamic> json) => _$BusinessSummaryFromJson(json);
}
```

```dart
// lib/features/businesses/domain/invite_preview.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'invite_preview.freezed.dart';
part 'invite_preview.g.dart';

@freezed
class InvitePreview with _$InvitePreview {
  const factory InvitePreview({
    required String email,
    required String businessName,
    required bool expired,
    required bool alreadyAccepted,
  }) = _InvitePreview;

  factory InvitePreview.fromJson(Map<String, dynamic> json) => _$InvitePreviewFromJson(json);
}
```

```dart
// lib/features/businesses/domain/leave_result.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../onboarding/domain/business.dart';

part 'leave_result.freezed.dart';
part 'leave_result.g.dart';

@freezed
class LeaveResult with _$LeaveResult {
  const factory LeaveResult({
    required Business business,
    required bool createdReplacement,
  }) = _LeaveResult;

  factory LeaveResult.fromJson(Map<String, dynamic> json) => _$LeaveResultFromJson(json);
}
```

```dart
// lib/features/businesses/domain/invite_token.dart
/// Accepts either the emailed link or a bare token; the token is always the
/// last non-empty path segment, so a trailing slash or query string is harmless.
String? extractInviteToken(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;
  final uri = Uri.tryParse(trimmed);
  final segments = (uri != null && uri.pathSegments.isNotEmpty) ? uri.pathSegments : [trimmed];
  return segments.where((segment) => segment.isNotEmpty).lastOrNull;
}
```

- [ ] **Step 4: Generate code and run**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/team/domain test/features/businesses/domain
```

Expected: PASS (12 tests).

- [ ] **Step 5: Analyze and commit**

```bash
flutter analyze
git add lib/features/team lib/features/businesses test/features/team test/features/businesses
git commit -m "feat: add team and business domain models"
```

---

### Task 3: Repositories and providers

**Files:**
- Create: `lib/features/businesses/domain/businesses_repository.dart`, `lib/features/businesses/data/businesses_repository_impl.dart`, `lib/features/businesses/presentation/providers/businesses_repository_provider.dart`
- Create: `lib/features/team/domain/team_repository.dart`, `lib/features/team/data/team_repository_impl.dart`, `lib/features/team/presentation/providers/team_repository_provider.dart`
- Test: `test/features/businesses/data/businesses_repository_impl_test.dart`, `test/features/team/data/team_repository_impl_test.dart`

**Interfaces:**
- Consumes: Task 2's models, `Business` (Phase 2).
- Produces: the two abstract repositories and their `Impl`s exactly as listed in the spec; `businessesRepositoryProvider`, `teamRepositoryProvider`.

- [ ] **Step 1: Write the failing tests**

```dart
// test/features/businesses/data/businesses_repository_impl_test.dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/businesses/data/businesses_repository_impl.dart';

class _MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _response(int status, Map<String, dynamic> data, String path) =>
    Response(statusCode: status, data: data, requestOptions: RequestOptions(path: path));

void main() {
  late _MockDio dio;
  late BusinessesRepositoryImpl repository;

  setUp(() {
    dio = _MockDio();
    repository = BusinessesRepositoryImpl(dio);
  });

  test('list maps owned and member businesses', () async {
    when(() => dio.get<Map<String, dynamic>>('/businesses')).thenAnswer((_) async => _response(200, {
          'businesses': [
            {'id': 'b1', 'name': 'Acme', 'isOwner': true},
            {'id': 'b2', 'name': 'Other', 'isOwner': false},
          ],
        }, '/businesses'));

    final businesses = await repository.list();

    expect(businesses.map((b) => b.isOwner), [true, false]);
  });

  test('create posts the name and returns the new business', () async {
    when(() => dio.post<Map<String, dynamic>>('/businesses', data: {'name': 'New Co'})).thenAnswer(
      (_) async => _response(201, {'business': {'id': 'b3', 'name': 'New Co'}}, '/businesses'),
    );

    final business = await repository.create('New Co');

    expect(business.id, 'b3');
    expect(business.onboardingCompletedAt, isNull);
  });

  test('switchTo posts the business id', () async {
    when(() => dio.post<Map<String, dynamic>>('/auth/switch-business', data: {'businessId': 'b2'})).thenAnswer(
      (_) async => _response(200, {
        'business': {'id': 'b2', 'name': 'Other', 'onboardingCompletedAt': '2026-01-01T00:00:00.000Z'},
      }, '/auth/switch-business'),
    );

    final business = await repository.switchTo('b2');

    expect(business.name, 'Other');
    expect(business.onboardingCompletedAt, isNotNull);
  });

  test('previewInvite fetches the public preview', () async {
    when(() => dio.get<Map<String, dynamic>>('/invites/tok123')).thenAnswer((_) async => _response(200, {
          'email': 'a@b.com',
          'businessName': 'Acme',
          'expired': false,
          'alreadyAccepted': false,
        }, '/invites/tok123'));

    final preview = await repository.previewInvite('tok123');

    expect(preview.businessName, 'Acme');
  });

  test('acceptInvite posts to the token and returns the joined business', () async {
    when(() => dio.post<Map<String, dynamic>>('/invites/tok123/accept')).thenAnswer(
      (_) async => _response(200, {'business': {'id': 'b2', 'name': 'Acme'}}, '/invites/tok123/accept'),
    );

    final business = await repository.acceptInvite('tok123');

    expect(business.id, 'b2');
  });

  test('leaveCurrent posts to /business/leave', () async {
    when(() => dio.post<Map<String, dynamic>>('/business/leave')).thenAnswer((_) async => _response(200, {
          'business': {'id': 'b9', 'name': 'My Business'},
          'createdReplacement': true,
        }, '/business/leave'));

    final result = await repository.leaveCurrent();

    expect(result.createdReplacement, isTrue);
  });
}
```

```dart
// test/features/team/data/team_repository_impl_test.dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/team/data/team_repository_impl.dart';
import 'package:billa_mobile/features/team/domain/team_role.dart';

class _MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _response(int status, Map<String, dynamic> data, String path) =>
    Response(statusCode: status, data: data, requestOptions: RequestOptions(path: path));

void main() {
  late _MockDio dio;
  late TeamRepositoryImpl repository;

  setUp(() {
    dio = _MockDio();
    repository = TeamRepositoryImpl(dio);
  });

  test('members maps the owner row and members', () async {
    when(() => dio.get<Map<String, dynamic>>('/business/members')).thenAnswer((_) async => _response(200, {
          'members': [
            {'id': 'u1', 'email': 'o@x.com', 'role': 'owner', 'joinedAt': '2026-01-01T00:00:00.000Z'},
            {'id': 'u2', 'email': 'm@x.com', 'role': 'member', 'joinedAt': '2026-01-02T00:00:00.000Z'},
          ],
        }, '/business/members'));

    final members = await repository.members();

    expect(members.map((m) => m.role), [TeamRole.owner, TeamRole.member]);
  });

  test('updateRole sends the uppercase role', () async {
    when(() => dio.patch<Map<String, dynamic>>('/business/members/u2/role', data: {'role': 'ACCOUNTANT'}))
        .thenAnswer((_) async => _response(200, {'ok': true}, '/business/members/u2/role'));

    await repository.updateRole('u2', TeamRole.accountant);

    verify(() => dio.patch<Map<String, dynamic>>('/business/members/u2/role', data: {'role': 'ACCOUNTANT'}))
        .called(1);
  });

  test('removeMember sends a DELETE', () async {
    when(() => dio.delete<Map<String, dynamic>>('/business/members/u2'))
        .thenAnswer((_) async => _response(200, {'ok': true}, '/business/members/u2'));

    await repository.removeMember('u2');

    verify(() => dio.delete<Map<String, dynamic>>('/business/members/u2')).called(1);
  });

  test('invites maps pending invites with their links', () async {
    when(() => dio.get<Map<String, dynamic>>('/business/invites')).thenAnswer((_) async => _response(200, {
          'invites': [
            {
              'id': 'i1',
              'email': 'n@x.com',
              'role': 'member',
              'expiresAt': '2026-02-01T00:00:00.000Z',
              'createdAt': '2026-01-25T00:00:00.000Z',
              'link': 'https://app.example.com/invite/tok',
            },
          ],
        }, '/business/invites'));

    final invites = await repository.invites();

    expect(invites.single.email, 'n@x.com');
  });

  test('invite posts the email and uppercase role', () async {
    when(() => dio.post<Map<String, dynamic>>('/business/invites', data: {'email': 'n@x.com', 'role': 'MEMBER'}))
        .thenAnswer((_) async => _response(201, {'invite': {'id': 'i1'}, 'link': 'l'}, '/business/invites'));

    await repository.invite('n@x.com', TeamRole.member);

    verify(() => dio.post<Map<String, dynamic>>('/business/invites', data: {'email': 'n@x.com', 'role': 'MEMBER'}))
        .called(1);
  });

  test('resendInvite and revokeInvite hit their endpoints', () async {
    when(() => dio.post<Map<String, dynamic>>('/business/invites/i1/resend'))
        .thenAnswer((_) async => _response(200, {'ok': true}, '/business/invites/i1/resend'));
    when(() => dio.delete<Map<String, dynamic>>('/business/invites/i1'))
        .thenAnswer((_) async => _response(200, {'ok': true}, '/business/invites/i1'));

    await repository.resendInvite('i1');
    await repository.revokeInvite('i1');

    verify(() => dio.post<Map<String, dynamic>>('/business/invites/i1/resend')).called(1);
    verify(() => dio.delete<Map<String, dynamic>>('/business/invites/i1')).called(1);
  });
}
```

- [ ] **Step 2: Run them to confirm they fail**

```bash
flutter test test/features/businesses/data test/features/team/data
```

Expected: FAIL — the implementations don't exist yet.

- [ ] **Step 3: Implement the repositories and providers**

```dart
// lib/features/businesses/domain/businesses_repository.dart
import '../../onboarding/domain/business.dart';
import 'business_summary.dart';
import 'invite_preview.dart';
import 'leave_result.dart';

abstract class BusinessesRepository {
  Future<List<BusinessSummary>> list();
  Future<Business> create(String name);
  Future<Business> switchTo(String businessId);
  Future<InvitePreview> previewInvite(String token);
  Future<Business> acceptInvite(String token);
  Future<LeaveResult> leaveCurrent();
}
```

```dart
// lib/features/businesses/data/businesses_repository_impl.dart
import 'package:dio/dio.dart';
import '../../onboarding/domain/business.dart';
import '../domain/business_summary.dart';
import '../domain/businesses_repository.dart';
import '../domain/invite_preview.dart';
import '../domain/leave_result.dart';

class BusinessesRepositoryImpl implements BusinessesRepository {
  BusinessesRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<BusinessSummary>> list() async {
    final response = await _dio.get<Map<String, dynamic>>('/businesses');
    return (response.data!['businesses'] as List)
        .map((json) => BusinessSummary.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Business> create(String name) async {
    final response = await _dio.post<Map<String, dynamic>>('/businesses', data: {'name': name});
    return Business.fromJson(response.data!['business'] as Map<String, dynamic>);
  }

  @override
  Future<Business> switchTo(String businessId) async {
    final response = await _dio.post<Map<String, dynamic>>('/auth/switch-business', data: {'businessId': businessId});
    return Business.fromJson(response.data!['business'] as Map<String, dynamic>);
  }

  @override
  Future<InvitePreview> previewInvite(String token) async {
    final response = await _dio.get<Map<String, dynamic>>('/invites/${Uri.encodeComponent(token)}');
    return InvitePreview.fromJson(response.data!);
  }

  @override
  Future<Business> acceptInvite(String token) async {
    final response = await _dio.post<Map<String, dynamic>>('/invites/${Uri.encodeComponent(token)}/accept');
    return Business.fromJson(response.data!['business'] as Map<String, dynamic>);
  }

  @override
  Future<LeaveResult> leaveCurrent() async {
    final response = await _dio.post<Map<String, dynamic>>('/business/leave');
    return LeaveResult.fromJson(response.data!);
  }
}
```

```dart
// lib/features/businesses/presentation/providers/businesses_repository_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client_provider.dart';
import '../../data/businesses_repository_impl.dart';
import '../../domain/businesses_repository.dart';

final businessesRepositoryProvider = Provider<BusinessesRepository>((ref) {
  return BusinessesRepositoryImpl(ref.watch(apiClientProvider).dio);
});
```

```dart
// lib/features/team/domain/team_repository.dart
import 'pending_invite.dart';
import 'team_member.dart';
import 'team_role.dart';

abstract class TeamRepository {
  Future<List<TeamMember>> members();
  Future<void> updateRole(String userId, TeamRole role);
  Future<void> removeMember(String userId);
  Future<List<PendingInvite>> invites();
  Future<void> invite(String email, TeamRole role);
  Future<void> resendInvite(String inviteId);
  Future<void> revokeInvite(String inviteId);
}
```

```dart
// lib/features/team/data/team_repository_impl.dart
import 'package:dio/dio.dart';
import '../domain/pending_invite.dart';
import '../domain/team_member.dart';
import '../domain/team_repository.dart';
import '../domain/team_role.dart';

class TeamRepositoryImpl implements TeamRepository {
  TeamRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<TeamMember>> members() async {
    final response = await _dio.get<Map<String, dynamic>>('/business/members');
    return (response.data!['members'] as List)
        .map((json) => TeamMember.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> updateRole(String userId, TeamRole role) async {
    await _dio.patch<Map<String, dynamic>>('/business/members/$userId/role', data: {'role': teamRoleToRequest(role)});
  }

  @override
  Future<void> removeMember(String userId) async {
    await _dio.delete<Map<String, dynamic>>('/business/members/$userId');
  }

  @override
  Future<List<PendingInvite>> invites() async {
    final response = await _dio.get<Map<String, dynamic>>('/business/invites');
    return (response.data!['invites'] as List)
        .map((json) => PendingInvite.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> invite(String email, TeamRole role) async {
    await _dio.post<Map<String, dynamic>>('/business/invites', data: {'email': email, 'role': teamRoleToRequest(role)});
  }

  @override
  Future<void> resendInvite(String inviteId) async {
    await _dio.post<Map<String, dynamic>>('/business/invites/$inviteId/resend');
  }

  @override
  Future<void> revokeInvite(String inviteId) async {
    await _dio.delete<Map<String, dynamic>>('/business/invites/$inviteId');
  }
}
```

```dart
// lib/features/team/presentation/providers/team_repository_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client_provider.dart';
import '../../data/team_repository_impl.dart';
import '../../domain/team_repository.dart';

final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  return TeamRepositoryImpl(ref.watch(apiClientProvider).dio);
});
```

- [ ] **Step 4: Run, analyze, commit**

```bash
flutter test test/features/businesses/data test/features/team/data
flutter analyze
git add lib/features/businesses lib/features/team test/features/businesses/data test/features/team/data
git commit -m "feat: add businesses and team repositories"
```

Expected: PASS (12 tests).

---

### Task 4: Active-business plumbing

**Files:**
- Modify: `lib/features/auth/presentation/providers/auth_controller.dart`
- Create: `lib/features/auth/presentation/providers/active_business_provider.dart`
- Modify: `lib/core/pagination/paginated_list_controller.dart`
- Modify: `lib/features/customers/presentation/providers/customer_list_controller.dart`, `lib/features/items/presentation/providers/item_list_controller.dart`, `lib/features/documents/presentation/providers/document_list_controller.dart`
- Test: `test/features/auth/presentation/providers/auth_controller_test.dart` (modify), `test/features/auth/presentation/providers/active_business_provider_test.dart`, `test/features/customers/presentation/providers/customer_list_controller_test.dart` (modify)

**Interfaces:**
- Produces: `AuthController.setBusiness(Business)`; `activeBusinessIdProvider` (`Provider<String?>`); `PaginatedListController.rebuildOn` hook.

`rebuildOn` is a hook on the base class rather than a direct watch inside it
so `core/` never depends on `features/auth`; each concrete controller
declares its dependency in one line.

- [ ] **Step 1: Write the failing tests**

Add to `test/features/auth/presentation/providers/auth_controller_test.dart`:

```dart
  test('setBusiness swaps the business and keeps the user', () async {
    when(() => repository.me()).thenAnswer((_) async => const AuthStatus.authenticated(_user, _business));
    await container.read(authControllerProvider.future);

    container.read(authControllerProvider.notifier).setBusiness(const Business(id: 'b2', name: 'Other'));

    expect(
      container.read(authControllerProvider).value,
      const AuthStatus.authenticated(_user, Business(id: 'b2', name: 'Other')),
    );
  });

  test('setBusiness does nothing when not authenticated', () async {
    await container.read(authControllerProvider.future);

    container.read(authControllerProvider.notifier).setBusiness(const Business(id: 'b2', name: 'Other'));

    expect(container.read(authControllerProvider).value, const AuthStatus.unauthenticated());
  });
```

```dart
// test/features/auth/presentation/providers/active_business_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/auth/domain/auth_repository.dart';
import 'package:billa_mobile/features/auth/domain/auth_status.dart';
import 'package:billa_mobile/features/auth/domain/auth_user.dart';
import 'package:billa_mobile/features/auth/presentation/providers/active_business_provider.dart';
import 'package:billa_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:billa_mobile/features/onboarding/domain/business.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

const _user = AuthUser(id: 'u1', email: 'a@b.com', totpEnabled: false, isAdmin: false);

void main() {
  test('is null until authenticated, then follows the business', () async {
    final repository = _MockAuthRepository();
    when(() => repository.me()).thenAnswer(
      (_) async => const AuthStatus.authenticated(_user, Business(id: 'b1', name: 'Acme')),
    );
    final container = ProviderContainer(overrides: [authRepositoryProvider.overrideWithValue(repository)]);
    addTearDown(container.dispose);

    expect(container.read(activeBusinessIdProvider), isNull);
    await container.read(authControllerProvider.future);
    expect(container.read(activeBusinessIdProvider), 'b1');

    container.read(authControllerProvider.notifier).setBusiness(const Business(id: 'b2', name: 'Other'));
    expect(container.read(activeBusinessIdProvider), 'b2');
  });

  test('is null, not a crash, when the auth provider itself failed to build', () {
    // Screen and controller tests that never override auth leave it errored;
    // reading the id must stay safe there.
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(activeBusinessIdProvider), isNull);
  });
}
```

Add to `test/features/customers/presentation/providers/customer_list_controller_test.dart`:

```dart
  test('refetches when the active business changes', () async {
    final repository = _MockCustomerRepository();
    when(() => repository.list(search: null, includeInactive: false, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: <Customer>[], total: 0, page: 1, pageSize: 20),
    );
    final businessId = StateProvider<String?>((ref) => 'b1');
    final container = ProviderContainer(overrides: [
      customerRepositoryProvider.overrideWithValue(repository),
      activeBusinessIdProvider.overrideWith((ref) => ref.watch(businessId)),
    ]);
    addTearDown(container.dispose);

    await container.read(customerListControllerProvider.future);
    container.read(businessId.notifier).state = 'b2';
    await container.read(customerListControllerProvider.future);

    verify(() => repository.list(search: null, includeInactive: false, page: 1, pageSize: 20)).called(2);
  });
```

with the import `import 'package:billa_mobile/features/auth/presentation/providers/active_business_provider.dart';`.

- [ ] **Step 2: Run them to confirm they fail**

```bash
flutter test test/features/auth/presentation/providers test/features/customers/presentation/providers/customer_list_controller_test.dart
```

Expected: FAIL — `setBusiness`/`activeBusinessIdProvider` don't exist.

- [ ] **Step 3: Implement**

Add to `AuthController` (`auth_controller.dart`, plus `import '../../../onboarding/domain/business.dart';`):

```dart
  // Switch, create, join, and leave each re-issue the session server-side, so
  // the only client state to update is which business the session points at.
  void setBusiness(Business business) {
    final current = state.valueOrNull;
    if (current is Authenticated) {
      state = AsyncData(AuthStatus.authenticated(current.user, business));
    }
  }
```

```dart
// lib/features/auth/presentation/providers/active_business_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/auth_status.dart';
import 'auth_controller.dart';

/// Just the id, selected out of the auth state so dependents rebuild when the
/// business changes, not on every unrelated auth update. Reads with
/// `valueOrNull` because `.value` throws on an errored auth provider, which is
/// the normal state in tests that never override auth.
final activeBusinessIdProvider = Provider<String?>((ref) {
  return ref.watch(authControllerProvider.select((auth) {
    return switch (auth.valueOrNull) {
      Authenticated(:final business) => business.id,
      _ => null,
    };
  }));
});
```

In `PaginatedListController` (`paginated_list_controller.dart`), add the hook and use it first in `build()`:

```dart
  // Providers whose change should refetch this list from scratch (for
  // example the active business). A hook rather than a direct watch so this
  // core class never depends on a feature.
  List<ProviderListenable<Object?>> get rebuildOn => const [];
```

```dart
  @override
  Future<PaginatedState<T>> build() async {
    for (final provider in rebuildOn) {
      ref.watch(provider);
    }
    ref.onDispose(() {
```

Add to each of `CustomerListController`, `ItemListController`, and
`DocumentListController` (with the `active_business_provider.dart` import):

```dart
  @override
  List<ProviderListenable<Object?>> get rebuildOn => [activeBusinessIdProvider];
```

- [ ] **Step 4: Run, then the whole suite (existing list tests must be unaffected)**

```bash
flutter test test/features/auth/presentation/providers test/features/customers/presentation/providers/customer_list_controller_test.dart
flutter test
```

Expected: PASS; the full suite stays green — proof the errored-auth case is safe.

- [ ] **Step 5: Analyze and commit**

```bash
flutter analyze
git add lib/features/auth lib/core/pagination lib/features/customers lib/features/items lib/features/documents test/features/auth test/features/customers
git commit -m "feat: track the active business and refetch lists when it changes"
```

---

### Task 5: Shared dialog helpers, `BusinessesScreen`, and `JoinBusinessScreen`

**Files:**
- Create: `lib/core/widgets/confirm_dialog.dart`, `lib/core/widgets/text_prompt_dialog.dart`, `lib/core/widgets/action_error_banner.dart`
- Modify: `lib/features/documents/presentation/screens/document_detail_screen.dart` (delegate `_confirm`/`_promptText` to the shared helpers)
- Create: `lib/features/businesses/presentation/providers/my_businesses_provider.dart`, `lib/features/businesses/presentation/screens/businesses_screen.dart`, `join_business_screen.dart`
- Test: `test/core/widgets/dialogs_test.dart`, `test/features/businesses/presentation/screens/businesses_screen_test.dart`, `join_business_screen_test.dart`

**Interfaces:**
- Produces: `Future<bool> showConfirmDialog(BuildContext, {required String title, String? content, required String confirmLabel})`; `Future<String?> showTextPromptDialog(BuildContext, {required String title, required String label, required String confirmLabel})`; `ActionErrorBanner({required String message, required VoidCallback? onRetry})`; `myBusinessesProvider`; `isOwnerOfActiveBusinessProvider`; `BusinessesScreen`; `JoinBusinessScreen`.

- [ ] **Step 1: Write the failing helper tests**

```dart
// test/core/widgets/dialogs_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/widgets/confirm_dialog.dart';
import 'package:billa_mobile/core/widgets/text_prompt_dialog.dart';

Widget _host(Future<void> Function(BuildContext) onTap) => MaterialApp(
      theme: AppTheme.light,
      home: Builder(
        builder: (context) => ElevatedButton(onPressed: () => onTap(context), child: const Text('Open')),
      ),
    );

void main() {
  testWidgets('confirm dialog returns true on confirm and false on cancel', (tester) async {
    bool? result;
    await tester.pumpWidget(_host((context) async {
      result = await showConfirmDialog(context, title: 'Sure?', confirmLabel: 'Yes');
    }));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    expect(result, isTrue);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('text prompt keeps confirm disabled until something is typed, then returns the trimmed text',
      (tester) async {
    String? result;
    await tester.pumpWidget(_host((context) async {
      result = await showTextPromptDialog(context, title: 'Name', label: 'Business name', confirmLabel: 'Create');
    }));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextButton>(find.widgetWithText(TextButton, 'Create')).onPressed, isNull);

    await tester.enterText(find.byType(TextField), '  New Co  ');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(result, 'New Co');
  });

  testWidgets('text prompt returns null on cancel', (tester) async {
    String? result = 'unset';
    await tester.pumpWidget(_host((context) async {
      result = await showTextPromptDialog(context, title: 'Name', label: 'Business name', confirmLabel: 'Create');
    }));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });
}
```

- [ ] **Step 2: Run it to confirm it fails, then implement the helpers**

```bash
flutter test test/core/widgets/dialogs_test.dart
```

Expected: FAIL — the helper files don't exist.

```dart
// lib/core/widgets/confirm_dialog.dart
import 'package:flutter/material.dart';

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  String? content,
  required String confirmLabel,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: content == null ? null : Text(content),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: Text(confirmLabel)),
      ],
    ),
  );
  return confirmed == true;
}
```

```dart
// lib/core/widgets/text_prompt_dialog.dart
import 'package:flutter/material.dart';

/// Asks for one required line of text; confirm stays disabled while it's
/// empty, so an empty submission is impossible rather than silently ignored.
Future<String?> showTextPromptDialog(
  BuildContext context, {
  required String title,
  required String label,
  required String confirmLabel,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _TextPromptDialog(title: title, label: label, confirmLabel: confirmLabel),
  );
}

class _TextPromptDialog extends StatefulWidget {
  const _TextPromptDialog({required this.title, required this.label, required this.confirmLabel});

  final String title;
  final String label;
  final String confirmLabel;

  @override
  State<_TextPromptDialog> createState() => _TextPromptDialogState();
}

class _TextPromptDialogState extends State<_TextPromptDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(labelText: widget.label),
        autofocus: true,
        onChanged: (_) => setState(() {}),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: _controller.text.trim().isEmpty ? null : () => Navigator.pop(context, _controller.text.trim()),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
```

```dart
// lib/core/widgets/action_error_banner.dart
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';

class ActionErrorBanner extends StatelessWidget {
  const ActionErrorBanner({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: colors.errorBg, borderRadius: BorderRadius.circular(AppRadii.small)),
      child: Row(
        children: [
          Expanded(child: Text(message, style: TextStyle(color: colors.error))),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
```

```bash
flutter test test/core/widgets/dialogs_test.dart
```

Expected: PASS (3 tests).

- [ ] **Step 3: Point `DocumentDetailScreen` at the shared helpers**

Replace the bodies of `_confirm` and `_promptText` in
`document_detail_screen.dart` so every existing call site keeps working,
and add the two imports:

```dart
  Future<bool> _confirm(String title, String? content, String confirmLabel) =>
      showConfirmDialog(context, title: title, content: content, confirmLabel: confirmLabel);

  Future<String?> _promptText(String title, String label, String confirmLabel) =>
      showTextPromptDialog(context, title: title, label: label, confirmLabel: confirmLabel);
```

```bash
flutter test test/features/documents/presentation/screens/document_detail_screen_test.dart
```

Expected: PASS (15 tests) — the existing screen tests are the safety net for the swap.

- [ ] **Step 4: Commit the helpers**

```bash
flutter analyze
git add lib/core/widgets test/core/widgets lib/features/documents/presentation/screens/document_detail_screen.dart
git commit -m "refactor: extract shared confirm, text prompt, and error banner widgets"
```

- [ ] **Step 5: Write the failing `BusinessesScreen` tests**

```dart
// test/features/businesses/presentation/screens/businesses_screen_test.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/auth/domain/auth_status.dart';
import 'package:billa_mobile/features/auth/domain/auth_user.dart';
import 'package:billa_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:billa_mobile/features/businesses/domain/business_summary.dart';
import 'package:billa_mobile/features/businesses/domain/businesses_repository.dart';
import 'package:billa_mobile/features/businesses/domain/leave_result.dart';
import 'package:billa_mobile/features/businesses/presentation/providers/businesses_repository_provider.dart';
import 'package:billa_mobile/features/businesses/presentation/screens/businesses_screen.dart';
import 'package:billa_mobile/features/onboarding/domain/business.dart';

class _MockBusinessesRepository extends Mock implements BusinessesRepository {}

const _user = AuthUser(id: 'u1', email: 'a@b.com', totpEnabled: false, isAdmin: false);

class _FakeAuthController extends AuthController {
  _FakeAuthController(this._status);
  final AuthStatus _status;

  @override
  Future<AuthStatus> build() async => _status;
}

DioException _error(String code) => DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response(requestOptions: RequestOptions(path: '/x'), data: {'error': code}),
    );

void main() {
  late _MockBusinessesRepository repository;

  setUp(() {
    repository = _MockBusinessesRepository();
    when(() => repository.list()).thenAnswer((_) async => [
          const BusinessSummary(id: 'b1', name: 'Acme', isOwner: true),
          const BusinessSummary(id: 'b2', name: 'Other Co', isOwner: false),
        ]);
  });

  Widget buildApp({String activeId = 'b1'}) {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => const Scaffold(body: Text('home screen'))),
      GoRoute(path: '/businesses', builder: (context, state) => const BusinessesScreen()),
      GoRoute(path: '/businesses/join', builder: (context, state) => const Scaffold(body: Text('join screen'))),
    ]);
    router.go('/businesses');
    return ProviderScope(
      overrides: [
        businessesRepositoryProvider.overrideWithValue(repository),
        authControllerProvider.overrideWith(
          () => _FakeAuthController(AuthStatus.authenticated(_user, Business(id: activeId, name: 'x'))),
        ),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  testWidgets('lists every business with ownership labels and marks the active one', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Acme'), findsOneWidget);
    expect(find.text('Other Co'), findsOneWidget);
    expect(find.text('Owner'), findsOneWidget);
    expect(find.text('Member'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('tapping another business switches to it and goes home', (tester) async {
    when(() => repository.switchTo('b2')).thenAnswer((_) async => const Business(id: 'b2', name: 'Other Co'));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Other Co'));
    await tester.pumpAndSettle();

    verify(() => repository.switchTo('b2')).called(1);
    expect(find.text('home screen'), findsOneWidget);
  });

  testWidgets('creating a business prompts for a name and goes home', (tester) async {
    when(() => repository.create('New Co')).thenAnswer((_) async => const Business(id: 'b3', name: 'New Co'));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('businesses-new')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'New Co');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    verify(() => repository.create('New Co')).called(1);
    expect(find.text('home screen'), findsOneWidget);
  });

  testWidgets('hitting the business limit shows the specific message', (tester) async {
    when(() => repository.create('New Co')).thenThrow(_error('business_limit_reached'));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('businesses-new')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'New Co');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text("You've reached the limit of 3 businesses"), findsOneWidget);
  });

  testWidgets('leave is offered only for a business you do not own, and confirms', (tester) async {
    when(() => repository.leaveCurrent()).thenAnswer(
      (_) async => const LeaveResult(business: Business(id: 'b1', name: 'Acme'), createdReplacement: false),
    );

    await tester.pumpWidget(buildApp(activeId: 'b1'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('businesses-leave')), findsNothing);

    await tester.pumpWidget(buildApp(activeId: 'b2'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('businesses-leave')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Leave').last);
    await tester.pumpAndSettle();

    verify(() => repository.leaveCurrent()).called(1);
    expect(find.text('home screen'), findsOneWidget);
  });

  testWidgets('join opens the join screen', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('businesses-join')));
    await tester.pumpAndSettle();

    expect(find.text('join screen'), findsOneWidget);
  });
}
```

- [ ] **Step 6: Run it to confirm it fails, then implement**

```bash
flutter test test/features/businesses/presentation/screens/businesses_screen_test.dart
```

Expected: FAIL — the screen and provider don't exist.

```dart
// lib/features/businesses/presentation/providers/my_businesses_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/active_business_provider.dart';
import '../../domain/business_summary.dart';
import 'businesses_repository_provider.dart';

/// `GET /businesses`, refetched whenever the active business changes so the
/// ownership flags never describe a business you've since left.
final myBusinessesProvider = FutureProvider.autoDispose<List<BusinessSummary>>((ref) {
  ref.watch(activeBusinessIdProvider);
  return ref.watch(businessesRepositoryProvider).list();
});

/// The only signal the backend exposes for ownership; it says nothing about
/// member versus accountant, so owner-only UI keys off this and nothing finer.
final isOwnerOfActiveBusinessProvider = Provider.autoDispose<bool>((ref) {
  final activeId = ref.watch(activeBusinessIdProvider);
  final businesses = ref.watch(myBusinessesProvider).valueOrNull;
  return businesses?.any((b) => b.id == activeId && b.isOwner) ?? false;
});
```

```dart
// lib/features/businesses/presentation/screens/businesses_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/widgets/action_error_banner.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/text_prompt_dialog.dart';
import '../../../auth/presentation/providers/active_business_provider.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../onboarding/domain/business.dart';
import '../../domain/business_summary.dart';
import '../providers/businesses_repository_provider.dart';
import '../providers/my_businesses_provider.dart';

class BusinessesScreen extends ConsumerStatefulWidget {
  const BusinessesScreen({super.key});

  @override
  ConsumerState<BusinessesScreen> createState() => _BusinessesScreenState();
}

class _BusinessesScreenState extends ConsumerState<BusinessesScreen> {
  bool _actionInProgress = false;
  String? _actionError;
  Future<void> Function()? _lastAction;

  Future<void> _runAction(Future<void> Function() action) async {
    _lastAction = action;
    setState(() {
      _actionInProgress = true;
      _actionError = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => _actionError = describeActionError(e));
    } finally {
      if (mounted) setState(() => _actionInProgress = false);
    }
  }

  // Every path here re-issued the session server-side. Going to `/` drops the
  // pushed stack so no screen holding the previous business's data survives.
  void _enter(Business business) {
    ref.read(authControllerProvider.notifier).setBusiness(business);
    context.go('/');
  }

  Future<void> _switchTo(BusinessSummary target) => _runAction(() async {
        final business = await ref.read(businessesRepositoryProvider).switchTo(target.id);
        if (mounted) _enter(business);
      });

  Future<void> _create() async {
    final name = await showTextPromptDialog(
      context,
      title: 'New business',
      label: 'Business name',
      confirmLabel: 'Create',
    );
    if (name == null) return;
    await _runAction(() async {
      final business = await ref.read(businessesRepositoryProvider).create(name);
      if (mounted) _enter(business);
    });
  }

  Future<void> _leave() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Leave this business?',
      content: "You'll lose access until someone invites you again.",
      confirmLabel: 'Leave',
    );
    if (!confirmed) return;
    await _runAction(() async {
      final result = await ref.read(businessesRepositoryProvider).leaveCurrent();
      if (mounted) _enter(result.business);
    });
  }

  @override
  Widget build(BuildContext context) {
    final businesses = ref.watch(myBusinessesProvider);
    final activeId = ref.watch(activeBusinessIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Businesses')),
      body: switch (businesses) {
        AsyncData(:final value) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final business in value)
                ListTile(
                  title: Text(business.name),
                  subtitle: Text(business.isOwner ? 'Owner' : 'Member'),
                  trailing: business.id == activeId ? const Icon(Icons.check) : null,
                  onTap: (business.id == activeId || _actionInProgress) ? null : () => _switchTo(business),
                ),
              if (_actionError != null) ...[
                const SizedBox(height: 8),
                ActionErrorBanner(
                  message: _actionError!,
                  onRetry: _lastAction == null ? null : () => _runAction(_lastAction!),
                ),
              ],
              const SizedBox(height: 16),
              OutlinedButton(
                key: const Key('businesses-new'),
                onPressed: _actionInProgress ? null : _create,
                child: const Text('New business'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                key: const Key('businesses-join'),
                onPressed: _actionInProgress ? null : () => context.push('/businesses/join'),
                child: const Text('Join a business'),
              ),
              if (value.any((b) => b.id == activeId && !b.isOwner)) ...[
                const SizedBox(height: 8),
                TextButton(
                  key: const Key('businesses-leave'),
                  onPressed: _actionInProgress ? null : _leave,
                  child: const Text('Leave this business'),
                ),
              ],
            ],
          ),
        AsyncError() => ErrorState(
            message: "Couldn't load your businesses",
            onRetry: () => ref.invalidate(myBusinessesProvider),
          ),
        _ => const Padding(
            padding: EdgeInsets.all(16),
            child: Column(children: [LoadingSkeleton(height: 56), SizedBox(height: 12), LoadingSkeleton(height: 56)]),
          ),
      },
    );
  }
}
```

```bash
flutter test test/features/businesses/presentation/screens/businesses_screen_test.dart
```

Expected: PASS (6 tests). If a `find.text('Leave')` is ambiguous, target the dialog with `.last` as the test already does.

- [ ] **Step 7: Write the failing `JoinBusinessScreen` tests**

```dart
// test/features/businesses/presentation/screens/join_business_screen_test.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/auth/domain/auth_status.dart';
import 'package:billa_mobile/features/auth/domain/auth_user.dart';
import 'package:billa_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:billa_mobile/features/businesses/domain/businesses_repository.dart';
import 'package:billa_mobile/features/businesses/domain/invite_preview.dart';
import 'package:billa_mobile/features/businesses/presentation/providers/businesses_repository_provider.dart';
import 'package:billa_mobile/features/businesses/presentation/screens/join_business_screen.dart';
import 'package:billa_mobile/features/onboarding/domain/business.dart';

class _MockBusinessesRepository extends Mock implements BusinessesRepository {}

const _user = AuthUser(id: 'u1', email: 'a@b.com', totpEnabled: false, isAdmin: false);

class _FakeAuthController extends AuthController {
  @override
  Future<AuthStatus> build() async => const AuthStatus.authenticated(_user, Business(id: 'b1', name: 'Mine'));
}

DioException _error(String code) => DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response(requestOptions: RequestOptions(path: '/x'), data: {'error': code}),
    );

void main() {
  late _MockBusinessesRepository repository;

  setUp(() {
    repository = _MockBusinessesRepository();
  });

  Widget buildApp() {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => const Scaffold(body: Text('home screen'))),
      GoRoute(path: '/join', builder: (context, state) => const JoinBusinessScreen()),
    ]);
    router.go('/join');
    return ProviderScope(
      overrides: [
        businessesRepositoryProvider.overrideWithValue(repository),
        authControllerProvider.overrideWith(_FakeAuthController.new),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  Future<void> pasteAndContinue(WidgetTester tester) async {
    await tester.enterText(find.byKey(const Key('invite-link')), 'https://app.example.com/invite/tok123');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('invite-continue')));
    await tester.pumpAndSettle();
  }

  testWidgets('previews the business and email, then accepts and goes home', (tester) async {
    when(() => repository.previewInvite('tok123')).thenAnswer((_) async => const InvitePreview(
          email: 'a@b.com',
          businessName: 'Acme',
          expired: false,
          alreadyAccepted: false,
        ));
    when(() => repository.acceptInvite('tok123')).thenAnswer((_) async => const Business(id: 'b2', name: 'Acme'));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await pasteAndContinue(tester);

    expect(find.textContaining('Acme'), findsWidgets);
    await tester.tap(find.byKey(const Key('invite-accept')));
    await tester.pumpAndSettle();

    verify(() => repository.acceptInvite('tok123')).called(1);
    expect(find.text('home screen'), findsOneWidget);
  });

  testWidgets('an expired invite disables Accept and says why', (tester) async {
    when(() => repository.previewInvite('tok123')).thenAnswer((_) async => const InvitePreview(
          email: 'a@b.com',
          businessName: 'Acme',
          expired: true,
          alreadyAccepted: false,
        ));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await pasteAndContinue(tester);

    expect(find.text('This invite has expired'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byKey(const Key('invite-accept'))).onPressed, isNull);
  });

  testWidgets('an unknown link shows the not-found message', (tester) async {
    when(() => repository.previewInvite('tok123')).thenThrow(_error('not_found'));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await pasteAndContinue(tester);

    expect(find.text("We couldn't find that — it may have been removed"), findsOneWidget);
  });

  testWidgets('a different-email invite shows the mismatch message on accept', (tester) async {
    when(() => repository.previewInvite('tok123')).thenAnswer((_) async => const InvitePreview(
          email: 'other@b.com',
          businessName: 'Acme',
          expired: false,
          alreadyAccepted: false,
        ));
    when(() => repository.acceptInvite('tok123')).thenThrow(_error('email_mismatch'));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await pasteAndContinue(tester);
    await tester.tap(find.byKey(const Key('invite-accept')));
    await tester.pumpAndSettle();

    expect(find.text('This invite was sent to a different email address'), findsOneWidget);
  });
}
```

- [ ] **Step 8: Run it to confirm it fails, then implement**

```bash
flutter test test/features/businesses/presentation/screens/join_business_screen_test.dart
```

Expected: FAIL — `join_business_screen.dart` doesn't exist.

```dart
// lib/features/businesses/presentation/screens/join_business_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/widgets/action_error_banner.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../domain/invite_preview.dart';
import '../../domain/invite_token.dart';
import '../providers/businesses_repository_provider.dart';

class JoinBusinessScreen extends ConsumerStatefulWidget {
  const JoinBusinessScreen({super.key});

  @override
  ConsumerState<JoinBusinessScreen> createState() => _JoinBusinessScreenState();
}

class _JoinBusinessScreenState extends ConsumerState<JoinBusinessScreen> {
  final _linkController = TextEditingController();
  String? _token;
  InvitePreview? _preview;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _loadPreview() async {
    final token = extractInviteToken(_linkController.text);
    if (token == null) {
      setState(() => _error = 'Paste the invite link from your email');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _preview = null;
    });
    try {
      final preview = await ref.read(businessesRepositoryProvider).previewInvite(token);
      if (mounted) {
        setState(() {
          _token = token;
          _preview = preview;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = describeActionError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _accept() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final business = await ref.read(businessesRepositoryProvider).acceptInvite(_token!);
      if (!mounted) return;
      ref.read(authControllerProvider.notifier).setBusiness(business);
      context.go('/');
    } catch (e) {
      if (mounted) setState(() => _error = describeActionError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = _preview;
    final blockedReason = preview == null
        ? null
        : preview.alreadyAccepted
            ? 'This invite was already accepted'
            : preview.expired
                ? 'This invite has expired'
                : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Join a business')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const Key('invite-link'),
              controller: _linkController,
              decoration: const InputDecoration(labelText: 'Invite link'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: const Key('invite-continue'),
              onPressed: (_busy || _linkController.text.trim().isEmpty) ? null : _loadPreview,
              child: const Text('Continue'),
            ),
            if (preview != null) ...[
              const SizedBox(height: 24),
              Text('Join ${preview.businessName}', style: Theme.of(context).textTheme.titleMedium),
              Text('Invited: ${preview.email}'),
              if (blockedReason != null) ...[
                const SizedBox(height: 8),
                Text(blockedReason),
              ],
              const SizedBox(height: 16),
              FilledButton(
                key: const Key('invite-accept'),
                onPressed: (_busy || blockedReason != null) ? null : _accept,
                child: const Text('Accept'),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              ActionErrorBanner(message: _error!, onRetry: _busy ? null : (preview == null ? _loadPreview : _accept)),
            ],
          ],
        ),
      ),
    );
  }
}
```


```bash
flutter test test/features/businesses/presentation/screens
```

Expected: PASS (10 tests).

- [ ] **Step 9: Analyze and commit**

```bash
flutter analyze
git add lib/features/businesses/presentation test/features/businesses/presentation
git commit -m "feat: add the businesses and join-business screens"
```

---

### Task 6: `TeamScreen`

**Files:**
- Create: `lib/features/team/presentation/screens/team_screen.dart`
- Test: `test/features/team/presentation/screens/team_screen_test.dart`

**Interfaces:**
- Consumes: `TeamRepository`/`teamRepositoryProvider` (Task 3), shared dialogs and banner (Task 5), `describeActionError` (Task 1).
- Produces: `class TeamScreen extends ConsumerStatefulWidget`, top-level `String teamRoleLabel(TeamRole role)`.

- [ ] **Step 1: Write the failing tests**

```dart
// test/features/team/presentation/screens/team_screen_test.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/team/domain/pending_invite.dart';
import 'package:billa_mobile/features/team/domain/team_member.dart';
import 'package:billa_mobile/features/team/domain/team_repository.dart';
import 'package:billa_mobile/features/team/domain/team_role.dart';
import 'package:billa_mobile/features/team/presentation/providers/team_repository_provider.dart';
import 'package:billa_mobile/features/team/presentation/screens/team_screen.dart';

class _MockTeamRepository extends Mock implements TeamRepository {}

const _owner = TeamMember(id: 'u1', email: 'owner@x.com', role: TeamRole.owner, joinedAt: '2026-01-01T00:00:00.000Z');
const _member = TeamMember(id: 'u2', email: 'member@x.com', role: TeamRole.member, joinedAt: '2026-01-02T00:00:00.000Z');
const _invite = PendingInvite(
  id: 'i1',
  email: 'new@x.com',
  role: TeamRole.accountant,
  expiresAt: '2026-02-01T00:00:00.000Z',
  createdAt: '2026-01-25T00:00:00.000Z',
  link: 'https://app.example.com/invite/tok',
);

DioException _error(String code) => DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response(requestOptions: RequestOptions(path: '/x'), data: {'error': code}),
    );

void main() {
  late _MockTeamRepository repository;

  setUp(() {
    repository = _MockTeamRepository();
    when(() => repository.members()).thenAnswer((_) async => [_owner, _member]);
    when(() => repository.invites()).thenAnswer((_) async => [_invite]);
  });

  Widget buildApp() => ProviderScope(
        overrides: [teamRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(theme: AppTheme.light, home: const TeamScreen()),
      );

  Future<void> sendInvite(WidgetTester tester, String email) async {
    await tester.tap(find.byKey(const Key('team-invite-button')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('invite-email')), email);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send invite'));
    await tester.pumpAndSettle();
  }

  testWidgets('lists members and pending invites, with no actions on the owner', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('owner@x.com'), findsOneWidget);
    expect(find.text('member@x.com'), findsOneWidget);
    expect(find.text('new@x.com'), findsOneWidget);
    expect(find.byIcon(Icons.person_remove), findsOneWidget);
  });

  testWidgets('changing a member role calls updateRole', (tester) async {
    when(() => repository.updateRole('u2', TeamRole.accountant)).thenAnswer((_) async {});

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButton<TeamRole>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Accountant').last);
    await tester.pumpAndSettle();

    verify(() => repository.updateRole('u2', TeamRole.accountant)).called(1);
  });

  testWidgets('removing a member confirms first', (tester) async {
    when(() => repository.removeMember('u2')).thenAnswer((_) async {});

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.person_remove));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove').last);
    await tester.pumpAndSettle();

    verify(() => repository.removeMember('u2')).called(1);
  });

  testWidgets('inviting someone sends the email and role, then reloads', (tester) async {
    when(() => repository.invite('friend@x.com', TeamRole.member)).thenAnswer((_) async {});

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await sendInvite(tester, 'friend@x.com');

    verify(() => repository.invite('friend@x.com', TeamRole.member)).called(1);
    verify(() => repository.invites()).called(2);
  });

  testWidgets('an already-member error shows its specific message with a retry', (tester) async {
    when(() => repository.invite('member@x.com', TeamRole.member)).thenThrow(_error('already_member'));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await sendInvite(tester, 'member@x.com');

    expect(find.text('That person is already on this team'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('revoking an invite confirms first', (tester) async {
    when(() => repository.revokeInvite('i1')).thenAnswer((_) async {});

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Revoke'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Revoke').last);
    await tester.pumpAndSettle();

    verify(() => repository.revokeInvite('i1')).called(1);
  });
}
```

- [ ] **Step 2: Run it to confirm it fails, then implement**

```bash
flutter test test/features/team/presentation/screens/team_screen_test.dart
```

Expected: FAIL — `team_screen.dart` doesn't exist.

```dart
// lib/features/team/presentation/screens/team_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/widgets/action_error_banner.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../domain/pending_invite.dart';
import '../../domain/team_member.dart';
import '../../domain/team_role.dart';
import '../providers/team_repository_provider.dart';

String teamRoleLabel(TeamRole role) => switch (role) {
      TeamRole.owner => 'Owner',
      TeamRole.member => 'Member',
      TeamRole.accountant => 'Accountant',
    };

const _assignableRoles = [TeamRole.member, TeamRole.accountant];

class TeamScreen extends ConsumerStatefulWidget {
  const TeamScreen({super.key});

  @override
  ConsumerState<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends ConsumerState<TeamScreen> {
  late Future<List<TeamMember>> _membersFuture;
  late Future<List<PendingInvite>> _invitesFuture;
  bool _actionInProgress = false;
  String? _actionError;
  Future<void> Function()? _lastAction;

  @override
  void initState() {
    super.initState();
    _membersFuture = ref.read(teamRepositoryProvider).members();
    _invitesFuture = ref.read(teamRepositoryProvider).invites();
  }

  // Members and invites load independently so one failing doesn't blank the
  // other; every mutation can change both (a role edit, an accepted invite),
  // so mutations reload both.
  void _reloadAll() {
    setState(() {
      _membersFuture = ref.read(teamRepositoryProvider).members();
      _invitesFuture = ref.read(teamRepositoryProvider).invites();
    });
  }

  Future<void> _runAction(Future<void> Function() action) async {
    _lastAction = action;
    setState(() {
      _actionInProgress = true;
      _actionError = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => _actionError = describeActionError(e));
    } finally {
      if (mounted) setState(() => _actionInProgress = false);
    }
  }

  Future<void> _changeRole(TeamMember member, TeamRole role) => _runAction(() async {
        await ref.read(teamRepositoryProvider).updateRole(member.id, role);
        _reloadAll();
      });

  Future<void> _remove(TeamMember member) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Remove ${member.email}?',
      content: 'They lose access to this business immediately.',
      confirmLabel: 'Remove',
    );
    if (!confirmed) return;
    await _runAction(() async {
      await ref.read(teamRepositoryProvider).removeMember(member.id);
      _reloadAll();
    });
  }

  Future<(String, TeamRole)?> _promptInvite() {
    final emailController = TextEditingController();
    var role = TeamRole.member;
    return showDialog<(String, TeamRole)>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final email = emailController.text.trim();
          return AlertDialog(
            title: const Text('Invite someone'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  key: const Key('invite-email'),
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  onChanged: (_) => setDialogState(() {}),
                ),
                const SizedBox(height: 12),
                DropdownButton<TeamRole>(
                  value: role,
                  isExpanded: true,
                  items: [for (final r in _assignableRoles) DropdownMenuItem(value: r, child: Text(teamRoleLabel(r)))],
                  onChanged: (value) => setDialogState(() => role = value!),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                onPressed: email.contains('@') ? () => Navigator.pop(context, (email, role)) : null,
                child: const Text('Send invite'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _invite() async {
    final result = await _promptInvite();
    if (result == null) return;
    final (email, role) = result;
    await _runAction(() async {
      await ref.read(teamRepositoryProvider).invite(email, role);
      _reloadAll();
    });
  }

  Future<void> _resend(PendingInvite invite) => _runAction(() async {
        await ref.read(teamRepositoryProvider).resendInvite(invite.id);
        _reloadAll();
      });

  Future<void> _revoke(PendingInvite invite) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Revoke the invite to ${invite.email}?',
      confirmLabel: 'Revoke',
    );
    if (!confirmed) return;
    await _runAction(() async {
      await ref.read(teamRepositoryProvider).revokeInvite(invite.id);
      _reloadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Team')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Members', style: Theme.of(context).textTheme.titleMedium),
          FutureBuilder<List<TeamMember>>(
            future: _membersFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return ErrorState(message: "Couldn't load the team", onRetry: _reloadAll);
              }
              if (!snapshot.hasData) {
                return const Padding(padding: EdgeInsets.all(8), child: LoadingSkeleton(height: 56));
              }
              return Column(
                children: [
                  for (final member in snapshot.data!)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(member.email),
                      subtitle: member.role == TeamRole.owner ? const Text('Owner') : null,
                      trailing: member.role == TeamRole.owner
                          ? null
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                DropdownButton<TeamRole>(
                                  value: member.role,
                                  items: [
                                    for (final r in _assignableRoles)
                                      DropdownMenuItem(value: r, child: Text(teamRoleLabel(r))),
                                  ],
                                  onChanged: _actionInProgress
                                      ? null
                                      : (role) {
                                          if (role != null && role != member.role) _changeRole(member, role);
                                        },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.person_remove),
                                  tooltip: 'Remove',
                                  onPressed: _actionInProgress ? null : () => _remove(member),
                                ),
                              ],
                            ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Text('Pending invites', style: Theme.of(context).textTheme.titleMedium),
          FutureBuilder<List<PendingInvite>>(
            future: _invitesFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return ErrorState(message: "Couldn't load invites", onRetry: _reloadAll);
              }
              if (!snapshot.hasData) {
                return const Padding(padding: EdgeInsets.all(8), child: LoadingSkeleton(height: 56));
              }
              if (snapshot.data!.isEmpty) {
                return const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('No pending invites'));
              }
              return Column(
                children: [
                  for (final invite in snapshot.data!)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(invite.email),
                      subtitle: Text('${teamRoleLabel(invite.role)} · expires ${invite.expiresAt.split('T').first}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: _actionInProgress ? null : () => _resend(invite),
                            child: const Text('Resend'),
                          ),
                          TextButton(
                            onPressed: _actionInProgress ? null : () => _revoke(invite),
                            child: const Text('Revoke'),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
          if (_actionError != null) ...[
            const SizedBox(height: 16),
            ActionErrorBanner(
              message: _actionError!,
              onRetry: _lastAction == null ? null : () => _runAction(_lastAction!),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('team-invite-button'),
            onPressed: _actionInProgress ? null : _invite,
            child: const Text('Invite someone'),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Run, analyze, commit**

```bash
flutter test test/features/team/presentation/screens/team_screen_test.dart
flutter analyze
git add lib/features/team/presentation/screens test/features/team/presentation/screens
git commit -m "feat: add the team screen"
```

Expected: PASS (6 tests).

---

### Task 7: Home header, Team button, and routes

**Files:**
- Modify: `lib/app/router.dart`
- Modify: `test/app/router_test.dart`

**Interfaces:**
- Consumes: `BusinessesScreen`, `JoinBusinessScreen` (Task 5), `TeamScreen` (Task 6), `isOwnerOfActiveBusinessProvider` (Task 5).
- Produces: routes `/businesses`, `/businesses/join`, `/team`; a business-switcher header and an owner-only Team button on home.

- [ ] **Step 1: Write the failing router tests**

Add imports and mocks to `test/app/router_test.dart`:

```dart
import 'package:billa_mobile/features/businesses/domain/business_summary.dart';
import 'package:billa_mobile/features/businesses/domain/businesses_repository.dart';
import 'package:billa_mobile/features/businesses/presentation/providers/businesses_repository_provider.dart';
import 'package:billa_mobile/features/team/domain/team_repository.dart';
import 'package:billa_mobile/features/team/presentation/providers/team_repository_provider.dart';

class _MockBusinessesRepository extends Mock implements BusinessesRepository {}

class _MockTeamRepository extends Mock implements TeamRepository {}
```

Then add a shared helper and the tests:

```dart
ProviderContainer _homeContainer(
  List<BusinessSummary> summaries, {
  TeamRepository? teamRepository,
}) {
  final businessesRepository = _MockBusinessesRepository();
  when(() => businessesRepository.list()).thenAnswer((_) async => summaries);
  const business = Business(id: 'b1', name: 'Acme', onboardingCompletedAt: '2026-01-01T00:00:00.000Z');
  return ProviderContainer(overrides: [
    authControllerProvider.overrideWith(() => _FakeAuthController(const AuthStatus.authenticated(_user, business))),
    businessesRepositoryProvider.overrideWithValue(businessesRepository),
    if (teamRepository != null) teamRepositoryProvider.overrideWithValue(teamRepository),
  ]);
}
```

```dart
  testWidgets('home shows the business name and an owner-only Team button', (tester) async {
    final container = _homeContainer([const BusinessSummary(id: 'b1', name: 'Acme', isOwner: true)]);
    addTearDown(container.dispose);

    await _pumpRouter(tester, container);

    expect(find.text('Acme'), findsOneWidget);
    expect(find.byKey(const Key('home-nav-team')), findsOneWidget);
  });

  testWidgets('home hides the Team button for a non-owner', (tester) async {
    final container = _homeContainer([const BusinessSummary(id: 'b1', name: 'Acme', isOwner: false)]);
    addTearDown(container.dispose);

    await _pumpRouter(tester, container);

    expect(find.byKey(const Key('home-nav-team')), findsNothing);
  });

  testWidgets('the business switcher opens the businesses screen', (tester) async {
    final container = _homeContainer([
      const BusinessSummary(id: 'b1', name: 'Acme', isOwner: true),
      const BusinessSummary(id: 'b2', name: 'Other Co', isOwner: false),
    ]);
    addTearDown(container.dispose);

    await _pumpRouter(tester, container);
    await tester.tap(find.byKey(const Key('home-business-switcher')));
    await tester.pumpAndSettle();

    expect(find.text('Other Co'), findsOneWidget);
    expect(find.text('Join a business'), findsOneWidget);
  });

  testWidgets('the Team button opens the team screen for an owner', (tester) async {
    final teamRepository = _MockTeamRepository();
    when(() => teamRepository.members()).thenAnswer((_) async => []);
    when(() => teamRepository.invites()).thenAnswer((_) async => []);
    final container = _homeContainer(
      [const BusinessSummary(id: 'b1', name: 'Acme', isOwner: true)],
      teamRepository: teamRepository,
    );
    addTearDown(container.dispose);

    await _pumpRouter(tester, container);
    await tester.tap(find.byKey(const Key('home-nav-team')));
    await tester.pumpAndSettle();

    expect(find.text('No pending invites'), findsOneWidget);
  });
```

- [ ] **Step 2: Run it to confirm it fails**

```bash
flutter test test/app/router_test.dart
```

Expected: FAIL — no switcher, Team button, or routes exist yet.

- [ ] **Step 3: Wire the routes and the home screen**

Add imports to `lib/app/router.dart`:

```dart
import '../features/auth/domain/auth_status.dart';
import '../features/businesses/presentation/providers/my_businesses_provider.dart';
import '../features/businesses/presentation/screens/businesses_screen.dart';
import '../features/businesses/presentation/screens/join_business_screen.dart';
import '../features/team/presentation/screens/team_screen.dart';
```

Add routes (after `/receivables`):

```dart
      GoRoute(path: '/businesses', builder: (context, state) => const BusinessesScreen()),
      GoRoute(path: '/businesses/join', builder: (context, state) => const JoinBusinessScreen()),
      GoRoute(path: '/team', builder: (context, state) => const TeamScreen()),
```

Replace `_PlaceholderHomeScreen` with a `ConsumerWidget` (the four existing
buttons are kept exactly as they are):

```dart
class _PlaceholderHomeScreen extends ConsumerWidget {
  const _PlaceholderHomeScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider).valueOrNull;
    final businessName = auth is Authenticated ? auth.business.name : null;
    final isOwner = ref.watch(isOwnerOfActiveBusinessProvider);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Billa', style: Theme.of(context).textTheme.displayMedium),
            if (businessName != null)
              TextButton.icon(
                key: const Key('home-business-switcher'),
                onPressed: () => context.push('/businesses'),
                icon: const Icon(Icons.swap_horiz),
                label: Text(businessName),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              key: const Key('home-nav-customers'),
              onPressed: () => context.push('/customers'),
              child: const Text('Customers'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              key: const Key('home-nav-items'),
              onPressed: () => context.push('/items'),
              child: const Text('Items'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              key: const Key('home-nav-documents'),
              onPressed: () => context.push('/documents'),
              child: const Text('Documents'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              key: const Key('home-nav-receivables'),
              onPressed: () => context.push('/receivables'),
              child: const Text('Receivables'),
            ),
            if (isOwner) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                key: const Key('home-nav-team'),
                onPressed: () => context.push('/team'),
                child: const Text('Team'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run the router tests, then the whole suite**

```bash
flutter test test/app/router_test.dart
flutter test
```

Expected: PASS; the full suite stays green, which confirms the existing
home-navigation tests survive a home screen that now reads providers they
never override (the businesses list errors there, so the Team button is simply
absent).

- [ ] **Step 5: Analyze and commit**

```bash
flutter analyze
git add lib/app/router.dart test/app/router_test.dart
git commit -m "feat: add the business switcher, team entry, and routes to home"
```

---

### Task 8: Final verification

**Files:** none created — this task only runs checks and fixes anything they surface.

- [ ] **Step 1: Static analysis** — `flutter analyze`; expected "No issues found!".
- [ ] **Step 2: Full test suite** — `flutter test`; expected every test from Tasks 1–7 plus all of Phases 1–5 passing unchanged.
- [ ] **Step 3: Android debug build** — `flutter build apk --debug`; expected success.
- [ ] **Step 4: iOS** — build verification stays deferred to macOS, as in every prior phase.
- [ ] **Step 5: Commit any fixes** — only if something needed fixing, with a single-sentence message; otherwise nothing to commit.

---

## Definition of done

`flutter analyze` is clean, `flutter test` passes in full, `flutter build apk
--debug` succeeds, and a manual run shows: the home screen names the active
business; tapping it lists every business with Owner/Member labels and a check
on the current one; tapping another switches, lands on home, and the
Customers/Items/Documents lists show that business's data; New business
prompts for a name (a fourth shows the limit message) and routes through
onboarding; Join a business accepts a pasted invite link with clear messages
for expired, already-accepted, and wrong-email cases; as an owner, Team lists
members and pending invites, changes a role, removes a member, and sends,
resends, and revokes invites; a non-owner sees no Team button and can leave the
current business after a confirmation. Every failure path shows its specific
message with a working Retry.
