# Web Parity Round 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bring the mobile app back in step with the web backend: retire the accountant role, stop the phone from overwriting what the web saved on a draft, show and edit documents in their own currency, word customer messages the way the web does, and show readable signed-in devices.

**Architecture:** A new `Currency` type in `core/formatting` owns decimals, parsing, formatting and RWF conversion, so every screen asks one place how an amount reads. Models carry `currency` and `exchangeRate`; screens pass the document's currency to `MoneyText`. The editor gains a currency and rate section that reprices lines through RWF, mirroring the web form. Sessions gain a device name sent by the app in an `X-Billa-Device` header and shown with last-active time.

**Tech Stack:** Flutter, Riverpod (no code generation), freezed and json_serializable (generated files are committed), dio, mocktail, device_info_plus (already a dependency).

**Spec:** `docs/superpowers/specs/2026-09-30-web-parity-round-design.md` (Round 1, items 1 to 4). Executors read both files.

**Not in this plan:** the one-time "your session ended after a security update" message. The spec left it as an open decision, and the app cannot yet tell that case apart from a normal expiry, so it waits for a decision.

## Global Constraints

- Branch `web-parity-r1`, created from `r2e-a11y` in its own worktree (Task 1, Step 1). One PR with the commits below, based on `r2e-a11y`.
- Every commit is authored only as `Ange Aurele TUYISENGE <tuyisengeauris@gmail.com>`. No `Co-Authored-By` trailer, no mention of Claude, AI or an assistant in commits, code, comments, docs or the PR body. This rule overrides any attribution line a tool suggests.
- Commit messages: one lowercase conventional sentence, imperative, no period (for example `fix: stop offering the retired accountant role`). One logical change per commit.
- Comments explain why, never what. No plan or spec pointers in code. No em dashes anywhere (code, strings, docs, commit messages).
- Lines stay within 120 columns. Do not run the default `dart format`.
- Riverpod is used without code generation. freezed and json_serializable outputs are regenerated with `dart run build_runner build --delete-conflicting-outputs` and committed alongside the source that changed them.
- `PATCH /documents/:id` replaces the whole draft. A field left out is reset: `currency` falls back to RWF (the server's schema default), `installments` are deleted, `recurrence` is cleared. Anything the phone does not edit must therefore be sent back exactly as it was loaded.
- Amounts are whole numbers of the currency's smallest unit (francs for RWF, cents for USD, decimals 2). The exchange rate is RWF for one whole unit of the currency.
- No dead ends: every error says what happened and what to do next, with a working retry. Every loading state shows a skeleton, not a bare spinner.
- Money uses tabular figures through `MoneyText`.
- Each task ends with `flutter analyze` showing no issues and the tests named in the task passing. Task 9 runs the full suite.

## Review Focus

The spec is silent on these inputs, so each gets a test in the task that owns the code.

0. **A draft made on the web with a foreign currency, an instalment plan or a repeat schedule, opened and autosaved on the phone,** must come back unchanged. Owner: Task 2A. This is a live risk in the installed build: today the phone silently turns such a draft into an RWF draft and deletes its plan.

1. **A typed foreign-currency amount with odd text** (`12.999`, `1,250.5`, `.`, `abc`, empty) must round or be rejected, never crash. Owner: Task 2.
2. **A draft opened or created in a foreign currency with no rate** (rate null, or the rates request failed offline) must show a clear rate problem and refuse to save, not send a request the server rejects. Owner: Task 5.
3. **Switching currency when the rates request fails** must keep the typed prices and say so, not zero them. Owner: Task 5.
4. **An old or unknown server payload:** a document with no `currency`, a currency code the app does not know, and a session with no `deviceName` or `lastUsedAt` must all render sensibly (RWF, RWF, "Unknown device"). Owners: Tasks 3 and 8.
5. **A device model name with characters an HTTP header cannot carry** must be cleaned or replaced, never make every request fail. Owner: Task 8.

---

### Task 1: Retire the accountant role

**Files:**
- Modify: `lib/features/team/domain/team_role.dart`
- Modify: `lib/features/team/domain/team_repository.dart`
- Modify: `lib/features/team/data/team_repository_impl.dart`
- Modify: `lib/features/team/presentation/screens/team_screen.dart`
- Modify: `lib/core/errors/action_errors.dart` (remove the `read_only_role` line)
- Modify: `lib/features/businesses/presentation/providers/my_businesses_provider.dart` (doc comment)
- Test: `test/features/team/domain/team_models_test.dart`, `test/features/team/data/team_repository_impl_test.dart`, `test/features/team/presentation/screens/team_screen_test.dart`, `test/core/errors/action_errors_test.dart`

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces: `enum TeamRole { owner, member }`; `TeamRole teamRoleFromJson(String)` never throws (anything that is not `'owner'` is `member`); `TeamRepository.invite(String email)` (no role); `TeamRepository.updateRole` is removed.

The server dropped the accountant role and the role-change route (web commit `5cca95c`). Invites default to `MEMBER`, and `BUSINESS_MEMBER_ROLES` is only `["MEMBER"]`.

- [ ] **Step 1: Create the worktree and confirm a clean baseline**

Run from the main checkout `C:/Users/user/OneDrive/Documents/Projects/Flutter/billa-mobile`:

```bash
git worktree add .claude/worktrees/web-parity-r1 -b web-parity-r1 r2e-a11y
cd .claude/worktrees/web-parity-r1
flutter pub get
flutter test test/features/team test/core/errors
```

Expected: the team and action error tests pass.

- [ ] **Step 2: Write the failing model tests**

Replace the first three tests in `test/features/team/domain/team_models_test.dart` (the two role-format tests and the unknown-role test) with these, and change the invite fixture at the bottom to use `'role': 'member'` and expect `TeamRole.member`:

```dart
  test('roles are lowercase in responses', () {
    expect(teamRoleFromJson('owner'), TeamRole.owner);
    expect(teamRoleFromJson('member'), TeamRole.member);
    expect(teamRoleToJson(TeamRole.member), 'member');
    expect(teamRoleToJson(TeamRole.owner), 'owner');
  });

  test('a retired or unknown role reads as a plain member instead of failing the whole team list', () {
    expect(teamRoleFromJson('accountant'), TeamRole.member);
    expect(teamRoleFromJson('admin'), TeamRole.member);
  });
```

In `test/features/team/data/team_repository_impl_test.dart` delete the `updateRole sends the uppercase role` test, and replace the invite test with:

```dart
  test('invite posts only the email, because the server makes every invitee a member', () async {
    when(() => dio.post<Map<String, dynamic>>('/business/invites', data: {'email': 'n@x.com'}))
        .thenAnswer((_) async => _response(201, {'invite': {'id': 'i1'}, 'link': 'l'}, '/business/invites'));

    await repository.invite('n@x.com');

    verify(() => dio.post<Map<String, dynamic>>('/business/invites', data: {'email': 'n@x.com'})).called(1);
  });
```

In `test/features/team/presentation/screens/team_screen_test.dart`: change `_invite` to `role: TeamRole.member`; delete the `changing a member role calls updateRole` test and add:

```dart
  testWidgets('members carry no role controls, only a remove action', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.byType(DropdownButton<TeamRole>), findsNothing);
    expect(find.byType(SegmentedButton<TeamRole>), findsNothing);
    expect(find.text('Accountant'), findsNothing);
  });
```

Change the two invite tests to `repository.invite('friend@x.com')` and `repository.invite('member@x.com')` (no role argument), and rename the first to `inviting someone sends the email, then reloads`.

In `test/core/errors/action_errors_test.dart` delete the line that expects `read_only_role` to map to `Your role on this business is read-only`.

- [ ] **Step 3: Run the tests to verify they fail**

Run: `flutter test test/features/team test/core/errors`
Expected: FAIL with compile errors (`invite` takes two arguments, `TeamRole.accountant` used by the old signatures).

- [ ] **Step 4: Implement**

`lib/features/team/domain/team_role.dart` becomes:

```dart
enum TeamRole { owner, member }

// A saved row can still carry a role the server has since retired (accountant), and
// failing the whole team list over a label would be worse than showing a plain member.
TeamRole teamRoleFromJson(String value) => value == 'owner' ? TeamRole.owner : TeamRole.member;

String teamRoleToJson(TeamRole value) => switch (value) {
      TeamRole.owner => 'owner',
      TeamRole.member => 'member',
    };
```

`lib/features/team/domain/team_repository.dart`: delete the `updateRole` line and change the invite line to `Future<void> invite(String email);`. Remove the `team_role.dart` import there.

`lib/features/team/data/team_repository_impl.dart`: delete the whole `updateRole` method, remove the `team_role.dart` import, and replace `invite` with:

```dart
  @override
  Future<void> invite(String email) async {
    await _dio.post<Map<String, dynamic>>('/business/invites', data: {'email': email});
  }
```

`lib/features/team/presentation/screens/team_screen.dart`:

1. Replace `teamRoleLabel` and delete `_assignableRoles`:

```dart
String teamRoleLabel(TeamRole role) => switch (role) {
      TeamRole.owner => 'Owner',
      TeamRole.member => 'Member',
    };
```

2. Delete the `_changeRole` method.
3. Replace `_promptInvite` and `_invite`:

```dart
  Future<String?> _promptInvite() {
    return showAppSheet<String>(context, builder: (context) => const _InviteSheet());
  }

  Future<void> _invite() async {
    final email = await _promptInvite();
    if (email == null) return;
    await _runAction(() async {
      await ref.read(teamRepositoryProvider).invite(email);
      _reloadAll();
    });
  }
```

4. In the members `ListTile`, replace `subtitle` and `trailing` with:

```dart
                      subtitle: Text(teamRoleLabel(member.role)),
                      trailing: member.role == TeamRole.owner
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.person_remove),
                              tooltip: 'Remove',
                              onPressed: _actionInProgress ? null : () => _remove(member),
                            ),
```

5. In `_InviteSheetState` delete `var _role = TeamRole.member;`, change the confirm callback to `onConfirm: email.contains('@') ? () => Navigator.pop(context, email) : null,`, and delete the `const SizedBox(height: 16),` and the `SegmentedButton<TeamRole>(...)` that follow the email field.

`lib/core/errors/action_errors.dart`: delete the `'read_only_role' => ...` line.

`lib/features/businesses/presentation/providers/my_businesses_provider.dart`: change the doc comment above `isOwnerOfActiveBusinessProvider` to:

```dart
/// The only signal the backend exposes for ownership, so owner-only UI keys off this.
```

- [ ] **Step 5: Run the tests to verify they pass**

Run: `flutter test test/features/team test/core/errors && flutter analyze`
Expected: all pass, no analyzer issues. Then run `grep -rn "accountant\|Accountant" lib test` and expect no matches except the model test that proves `'accountant'` reads as a member.

- [ ] **Step 6: Commit**

```bash
git add lib/features/team lib/core/errors/action_errors.dart lib/features/businesses/presentation/providers/my_businesses_provider.dart test/features/team test/core/errors/action_errors_test.dart
git commit -m "fix: stop offering the retired accountant role"
```

---

### Task 2: Currency core and money formatting

**Files:**
- Create: `lib/core/formatting/currency.dart`
- Modify: `lib/core/formatting/money.dart`
- Modify: `lib/core/widgets/money_text.dart`
- Test: `test/core/formatting/currency_test.dart` (create), `test/core/formatting/money_test.dart`, `test/core/widgets/money_text_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces (exact names later tasks use):
  - `enum Currency { rwf, usd, eur, gbp, kes, ugx, tzs }` with `String code`, `String label`, `int decimals`, `int get minorPerMajor`, `static Currency fromCode(Object? value)` (unknown reads as `rwf`).
  - `Currency currencyFromJson(Object? value)`, `String currencyToJson(Currency value)`, `double? rateFromJson(Object? value)`.
  - `int? parseMajorAmount(String text, Currency currency)`, `String minorToMajorText(int minor, Currency currency)`.
  - `int toRwf(int minor, Currency currency, double? rate)`, `int fromRwf(int rwf, Currency currency, double? rate)`.
  - `int? convertMinor(int minor, {required Currency from, required double? fromRate, required Currency to, required double? toRate})`.
  - `String? rateProblem(Currency currency, double? rate)`.
  - `typedef MoneyAmount = ({Currency currency, int amount})`, `List<MoneyAmount> sumByCurrency(Iterable<MoneyAmount> items)`.
  - `String formatMoney(int amount, {Currency currency = Currency.rwf, String? symbol})`.
  - `MoneyText(int amount, {Key? key, TextStyle? style, Currency currency = Currency.rwf, String? currencySymbol})`.

The rules mirror the web's `shared/src/currency.ts`, so a rate typed on either app means the same thing.

- [ ] **Step 1: Write the failing tests**

Create `test/core/formatting/currency_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/formatting/currency.dart';

void main() {
  test('each currency knows how many decimals it has', () {
    expect(Currency.rwf.decimals, 0);
    expect(Currency.usd.decimals, 2);
    expect(Currency.ugx.decimals, 0);
    expect(Currency.usd.minorPerMajor, 100);
    expect(Currency.rwf.minorPerMajor, 1);
  });

  test('an unknown or missing code reads as RWF instead of breaking a screen', () {
    expect(Currency.fromCode('USD'), Currency.usd);
    expect(Currency.fromCode('JPY'), Currency.rwf);
    expect(Currency.fromCode(null), Currency.rwf);
    expect(currencyFromJson(42), Currency.rwf);
    expect(currencyToJson(Currency.kes), 'KES');
  });

  test('a rate parses from a number, a numeric string or null', () {
    expect(rateFromJson(1450.5), 1450.5);
    expect(rateFromJson(1450), 1450.0);
    expect(rateFromJson('1450.25'), 1450.25);
    expect(rateFromJson(null), isNull);
    expect(rateFromJson('abc'), isNull);
  });

  group('parseMajorAmount', () {
    test('turns typed whole units into the smallest unit', () {
      expect(parseMajorAmount('12.50', Currency.usd), 1250);
      expect(parseMajorAmount('1,250.5', Currency.usd), 125050);
      expect(parseMajorAmount('5000', Currency.rwf), 5000);
      expect(parseMajorAmount(' 7 ', Currency.rwf), 7);
    });

    test('rounds extra decimals instead of failing', () {
      expect(parseMajorAmount('12.999', Currency.usd), 1300);
      expect(parseMajorAmount('12.5', Currency.rwf), 13);
    });

    test('rejects text that is not an amount', () {
      expect(parseMajorAmount('', Currency.usd), isNull);
      expect(parseMajorAmount('.', Currency.usd), isNull);
      expect(parseMajorAmount('abc', Currency.usd), isNull);
      expect(parseMajorAmount('1.2.3', Currency.usd), isNull);
      expect(parseMajorAmount('-5', Currency.usd), isNull);
    });

    test('accepts a trailing or leading dot while the user is still typing', () {
      expect(parseMajorAmount('12.', Currency.usd), 1200);
      expect(parseMajorAmount('.5', Currency.usd), 50);
    });
  });

  test('minorToMajorText drops trailing zeros and keeps zero readable', () {
    expect(minorToMajorText(1250, Currency.usd), '12.5');
    expect(minorToMajorText(1200, Currency.usd), '12');
    expect(minorToMajorText(1205, Currency.usd), '12.05');
    expect(minorToMajorText(10000, Currency.usd), '100');
    expect(minorToMajorText(0, Currency.usd), '0');
    expect(minorToMajorText(5000, Currency.rwf), '5000');
  });

  test('toRwf and fromRwf go through the rate, RWF for one whole unit', () {
    expect(toRwf(1000, Currency.usd, 1400), 14000);
    expect(fromRwf(14000, Currency.usd, 1400), 1000);
    expect(toRwf(5000, Currency.rwf, null), 5000);
    expect(toRwf(1000, Currency.usd, null), 0);
    expect(fromRwf(14000, Currency.usd, 0), 0);
  });

  test('convertMinor reprices through RWF and gives up when a rate is missing', () {
    expect(convertMinor(14000, from: Currency.rwf, fromRate: null, to: Currency.usd, toRate: 1400), 1000);
    expect(convertMinor(1000, from: Currency.usd, fromRate: 1400, to: Currency.rwf, toRate: null), 14000);
    expect(convertMinor(1000, from: Currency.usd, fromRate: 1400, to: Currency.eur, toRate: 1500), 933);
    expect(convertMinor(1000, from: Currency.usd, fromRate: null, to: Currency.rwf, toRate: null), isNull);
    expect(convertMinor(1000, from: Currency.rwf, fromRate: null, to: Currency.usd, toRate: null), isNull);
    expect(convertMinor(1000, from: Currency.usd, fromRate: null, to: Currency.usd, toRate: null), 1000);
  });

  test('rateProblem asks for a rate on foreign currencies only', () {
    expect(rateProblem(Currency.rwf, null), isNull);
    expect(rateProblem(Currency.usd, 1400), isNull);
    expect(rateProblem(Currency.usd, null), 'Enter the exchange rate for USD');
    expect(rateProblem(Currency.usd, 0), 'Enter the exchange rate for USD');
    expect(rateProblem(Currency.usd, 2000000), 'That exchange rate looks too high');
  });

  test('sumByCurrency never adds dollars to francs and lists RWF first', () {
    final totals = sumByCurrency([
      (currency: Currency.usd, amount: 500),
      (currency: Currency.rwf, amount: 4000),
      (currency: Currency.usd, amount: 250),
      (currency: Currency.rwf, amount: 1000),
    ]);

    expect(totals, [
      (currency: Currency.rwf, amount: 5000),
      (currency: Currency.usd, amount: 750),
    ]);
  });
}
```

Append to `test/core/formatting/money_test.dart` inside `main()`:

```dart
  test('shows the decimals a currency has', () {
    expect(formatMoney(125050, currency: Currency.usd), 'USD 1,250.50');
    expect(formatMoney(5, currency: Currency.usd), 'USD 0.05');
    expect(formatMoney(0, currency: Currency.usd), 'USD 0.00');
    expect(formatMoney(-1205, currency: Currency.usd), 'USD -12.05');
    expect(formatMoney(2500000, currency: Currency.ugx), 'UGX 2,500,000');
  });
```

and add `import 'package:billa_mobile/core/formatting/currency.dart';` at the top. Append to `test/core/widgets/money_text_test.dart` inside `main()` (same import added):

```dart
  testWidgets('writes the amount in its own currency', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MoneyText(125050, currency: Currency.usd)));
    expect(find.text('USD 1,250.50'), findsOneWidget);
  });

  testWidgets('hides a foreign amount in privacy mode with its own code', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PrivacyScope(hidden: true, child: MoneyText(125050, currency: Currency.usd))),
    );
    expect(find.text('USD \u2022\u2022\u2022\u2022'), findsOneWidget);
    expect(find.text('USD 1,250.50'), findsNothing);
  });
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `flutter test test/core/formatting test/core/widgets/money_text_test.dart`
Expected: FAIL (`currency.dart` does not exist).

- [ ] **Step 3: Implement**

Create `lib/core/formatting/currency.dart`:

```dart
import 'dart:math' as math;

/// The currencies a document can be written in. Amounts are whole numbers of a
/// currency's smallest unit (francs for RWF, cents for USD), exactly as the API stores them.
enum Currency {
  rwf('RWF', 'Rwandan franc', 0),
  usd('USD', 'US dollar', 2),
  eur('EUR', 'Euro', 2),
  gbp('GBP', 'British pound', 2),
  kes('KES', 'Kenyan shilling', 2),
  ugx('UGX', 'Ugandan shilling', 0),
  tzs('TZS', 'Tanzanian shilling', 2);

  const Currency(this.code, this.label, this.decimals);

  final String code;
  final String label;
  final int decimals;

  int get minorPerMajor => math.pow(10, decimals).toInt();

  /// A code the app does not know reads as RWF, as on the web, so a currency added
  /// on the server never breaks a screen that has not learned it yet.
  static Currency fromCode(Object? value) {
    for (final currency in values) {
      if (currency.code == value) return currency;
    }
    return Currency.rwf;
  }
}

Currency currencyFromJson(Object? value) => Currency.fromCode(value);

String currencyToJson(Currency value) => value.code;

double? rateFromJson(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

/// "12.50" typed in a price box becomes 1250 for USD and 13 for RWF. Null for text that is not an amount.
int? parseMajorAmount(String text, Currency currency) {
  final cleaned = text.replaceAll(RegExp(r'[\s,]'), '');
  if (cleaned.isEmpty || cleaned == '.' || !RegExp(r'^\d*\.?\d*$').hasMatch(cleaned)) return null;
  return (double.parse(cleaned) * currency.minorPerMajor).round();
}

/// 1250 for USD becomes "12.5" for a price box; whole units for RWF.
String minorToMajorText(int minor, Currency currency) {
  if (currency.decimals == 0) return minor.toString();
  final text = (minor / currency.minorPerMajor).toStringAsFixed(currency.decimals);
  return text.replaceFirst(RegExp(r'\.?0+$'), '');
}

/// What an amount in [currency] is worth in RWF at [rate] (RWF for one whole unit).
int toRwf(int minor, Currency currency, double? rate) {
  if (currency == Currency.rwf) return minor;
  if (rate == null || rate <= 0) return 0;
  return (minor / currency.minorPerMajor * rate).round();
}

/// What an RWF amount comes to in [currency] at [rate], in that currency's smallest unit.
int fromRwf(int rwf, Currency currency, double? rate) {
  if (currency == Currency.rwf) return rwf;
  if (rate == null || rate <= 0) return 0;
  return (rwf / rate * currency.minorPerMajor).round();
}

/// Re-prices an amount when a draft changes currency, going through RWF. Null when a rate is missing.
int? convertMinor(
  int minor, {
  required Currency from,
  required double? fromRate,
  required Currency to,
  required double? toRate,
}) {
  if (from == to) return minor;
  if (from != Currency.rwf && !(fromRate != null && fromRate > 0)) return null;
  if (to != Currency.rwf && !(toRate != null && toRate > 0)) return null;
  return fromRwf(toRwf(minor, from, fromRate), to, toRate);
}

/// A rate has to be a positive number; RWF documents have none.
String? rateProblem(Currency currency, double? rate) {
  if (currency == Currency.rwf) return null;
  if (rate == null || !rate.isFinite || rate <= 0) return 'Enter the exchange rate for ${currency.code}';
  if (rate > 1000000) return 'That exchange rate looks too high';
  return null;
}

typedef MoneyAmount = ({Currency currency, int amount});

/// Adds amounts one currency at a time, RWF first, so a total never adds dollars to francs.
List<MoneyAmount> sumByCurrency(Iterable<MoneyAmount> items) {
  final totals = <Currency, int>{};
  for (final item in items) {
    totals[item.currency] = (totals[item.currency] ?? 0) + item.amount;
  }
  return [
    for (final currency in Currency.values)
      if (totals.containsKey(currency)) (currency: currency, amount: totals[currency]!),
  ];
}
```

Replace `lib/core/formatting/money.dart` with:

```dart
import 'currency.dart';

/// "RWF 1,234,567" or "USD 1,250.50": grouped by thousands, with as many decimals as the currency has.
/// [symbol] replaces the currency code, and may be empty for chart labels that carry no code.
String formatMoney(int amount, {Currency currency = Currency.rwf, String? symbol}) {
  final per = currency.minorPerMajor;
  final absolute = amount.abs();
  final digits = (absolute ~/ per).toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  final fraction = currency.decimals == 0 ? '' : '.${(absolute % per).toString().padLeft(currency.decimals, '0')}';
  return '${symbol ?? currency.code} ${amount < 0 ? '-' : ''}$buffer$fraction';
}
```

Replace `lib/core/widgets/money_text.dart` with:

```dart
import 'package:flutter/material.dart';
import '../formatting/currency.dart';
import '../formatting/money.dart';
import '../privacy/privacy_scope.dart';

class MoneyText extends StatelessWidget {
  const MoneyText(this.amount, {super.key, this.style, this.currency = Currency.rwf, this.currencySymbol});

  final int amount;
  final TextStyle? style;
  final Currency currency;
  final String? currencySymbol;

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;
    final hidden = PrivacyScope.hiddenOf(context);
    final symbol = currencySymbol ?? currency.code;
    final text = Text(
      hidden ? '$symbol \u2022\u2022\u2022\u2022' : formatMoney(amount, currency: currency, symbol: symbol),
      style: base.copyWith(fontFeatures: [const FontFeature.tabularFigures()]),
    );
    // Dots read aloud as noise; say what they mean.
    return hidden ? Semantics(label: 'Amount hidden', excludeSemantics: true, child: text) : text;
  }
}
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `flutter test test/core && flutter analyze`
Expected: PASS, no issues. The existing `currencySymbol: ''` caller in `monthly_bars.dart` still compiles.

- [ ] **Step 5: Commit**

```bash
git add lib/core/formatting lib/core/widgets/money_text.dart test/core/formatting test/core/widgets/money_text_test.dart
git commit -m "feat: add a currency type with decimals, parsing and rate conversion"
```

---

### Task 2A: Keep web-only fields when a draft is saved from the phone

**Files:**
- Modify: `lib/features/documents/domain/document.dart` (+ regenerate `document.freezed.dart`, `document.g.dart`)
- Modify: `lib/features/documents/domain/document_draft_input.dart` (+ regenerate)
- Modify: `lib/features/documents/domain/duplicate_draft.dart`
- Modify: `lib/features/documents/presentation/providers/document_editor_controller.dart`
- Modify: `lib/features/documents/presentation/screens/document_editor_screen.dart`
- Modify: `lib/core/errors/action_errors.dart`
- Test: `test/features/documents/domain/document_test.dart`, `test/features/documents/domain/document_draft_input_test.dart`, `test/features/documents/domain/duplicate_draft_test.dart`, `test/features/documents/presentation/providers/document_editor_controller_test.dart`, `test/features/documents/presentation/screens/document_editor_screen_test.dart`, `test/core/errors/action_errors_test.dart`

**Interfaces:**
- Consumes: `Currency`, `currencyFromJson`, `currencyToJson`, `rateFromJson`, `rateProblem` from Task 2.
- Produces:
  - `Document.currency` (`Currency`, default `rwf`), `.exchangeRate` (`double?`), `.installments` (`List<DocumentInstallment>`), `.recurrenceInterval` and `.recurrenceEndDate` (`String?`), `.nextInstallment` (`DocumentNextInstallment?`), `.business` (`DocumentBusinessRef?`).
  - `DocumentInstallment({String? label, required int amount, required String dueDate})`, `DocumentNextInstallment({String? label, required int remaining, required String dueDate})`, `DocumentBusinessRef({bool momoEnabled = false})`.
  - `InstallmentInput({String? label, required int amount, required String dueDate})` and `RecurrenceInput({required String interval, String? endDate})`.
  - `DocumentDraftInput.currency`, `.exchangeRate`, `.installments` (`List<InstallmentInput>?`), `.recurrence` (`RecurrenceInput?`).
  - `DocumentEditorState.currency`, `.exchangeRate`, `.installments`, `.recurrence`, and `String? get preservedPlanNote`.

**Why this is first:** the server's `PATCH /documents/:id` deletes the draft's lines and instalments and rewrites every column from the request. The phone does not send `currency`, so the server's schema default makes the draft RWF with no rate, and its cent amounts read as francs. It does not send `installments`, so the plan is deleted, and it does not send `recurrence`, so the schedule is cleared. Opening and editing any web-made draft of that kind on the current app corrupts it. The server also refuses a plan whose instalments no longer add up to the total, with the error `invalid_installments` and a plain message that the phone must show.

The phone does not edit instalments or repeat schedules in Round 1. It carries them through untouched and says so.

- [ ] **Step 1: Write the failing tests**

Add to `test/features/documents/domain/document_test.dart` (import `package:billa_mobile/core/formatting/currency.dart`):

```dart
  test('a document with no currency reads as RWF, as older responses have none', () {
    final document = Document.fromJson(_documentJson());

    expect(document.currency, Currency.rwf);
    expect(document.exchangeRate, isNull);
    expect(document.installments, isEmpty);
    expect(document.recurrenceInterval, isNull);
    expect(document.nextInstallment, isNull);
    expect(document.business, isNull);
  });

  test('a foreign document carries its currency and the rate saved with it', () {
    final document = Document.fromJson(_documentJson(extra: {'currency': 'USD', 'exchangeRate': 1450.5}));

    expect(document.currency, Currency.usd);
    expect(document.exchangeRate, 1450.5);
  });

  test('a currency the app does not know reads as RWF', () {
    expect(Document.fromJson(_documentJson(extra: {'currency': 'JPY'})).currency, Currency.rwf);
  });

  test('reads a payment plan, the next instalment and whether the business takes MoMo', () {
    final document = Document.fromJson(_documentJson(extra: {
      'installments': [
        {'id': 'i1', 'sortOrder': 0, 'label': 'Deposit', 'amount': 4000, 'dueDate': '2026-10-01T00:00:00.000Z'},
        {'id': 'i2', 'sortOrder': 1, 'label': null, 'amount': 7800, 'dueDate': '2026-11-01T00:00:00.000Z'},
      ],
      'nextInstallment': {
        'label': 'Deposit',
        'amount': 4000,
        'dueDate': '2026-10-01',
        'paid': 1000,
        'remaining': 3000,
        'status': 'PARTIALLY_PAID',
      },
      'business': {'momoEnabled': true},
    }));

    expect(document.installments.map((step) => step.amount), [4000, 7800]);
    expect(document.installments.first.label, 'Deposit');
    expect(document.installments.last.label, isNull);
    expect(document.nextInstallment!.remaining, 3000);
    expect(document.business!.momoEnabled, isTrue);
  });

  test('reads a repeat schedule', () {
    final document = Document.fromJson(
      _documentJson(extra: {'recurrenceInterval': 'MONTHLY', 'recurrenceEndDate': '2027-01-01T00:00:00.000Z'}),
    );

    expect(document.recurrenceInterval, 'MONTHLY');
    expect(document.recurrenceEndDate, '2027-01-01T00:00:00.000Z');
  });
```

Add to `document_draft_input_test.dart` (import `Currency`, and update any existing exact-map expectation in this file so it includes `'currency': 'RWF'`):

```dart
  test('a foreign draft sends its currency and rate, an RWF draft sends no rate', () {
    final usd = const DocumentDraftInput(
      type: DocumentType.invoice,
      customerId: 'c1',
      issueDate: '2026-01-01',
      currency: Currency.usd,
      exchangeRate: 1450.5,
    ).toJson();
    final rwf = const DocumentDraftInput(type: DocumentType.invoice, customerId: 'c1', issueDate: '2026-01-01').toJson();

    expect(usd['currency'], 'USD');
    expect(usd['exchangeRate'], 1450.5);
    expect(rwf['currency'], 'RWF');
    expect(rwf.containsKey('exchangeRate'), isFalse);
    expect(rwf.containsKey('installments'), isFalse);
    expect(rwf.containsKey('recurrence'), isFalse);
  });

  test('a plan and a repeat schedule are written the way the server reads them', () {
    final plan = const DocumentDraftInput(
      type: DocumentType.invoice,
      customerId: 'c1',
      issueDate: '2026-01-01',
      installments: [
        InstallmentInput(label: 'Deposit', amount: 4000, dueDate: '2026-10-01'),
        InstallmentInput(amount: 7800, dueDate: '2026-11-01'),
      ],
    ).toJson();
    final repeat = const DocumentDraftInput(
      type: DocumentType.invoice,
      customerId: 'c1',
      issueDate: '2026-01-01',
      recurrence: RecurrenceInput(interval: 'MONTHLY', endDate: '2027-01-01'),
    ).toJson();

    expect(plan['installments'], [
      {'label': 'Deposit', 'amount': 4000, 'dueDate': '2026-10-01'},
      {'amount': 7800, 'dueDate': '2026-11-01'},
    ]);
    expect(repeat['recurrence'], {'interval': 'MONTHLY', 'endDate': '2027-01-01'});
  });
```

Also update exact-map expectations in `document_repository_impl_test.dart` that compare a whole request body so they include `'currency': 'RWF'`.

Add to `duplicate_draft_test.dart` (use that file's existing source-document helper, and give it `currency`, `exchangeRate`, `installments` and `recurrenceInterval` as needed):

```dart
  test('a repeat of a foreign document stays in that currency at the same rate', () {
    final draft = draftFromDocument(_source(currency: Currency.usd, exchangeRate: 1450.5));

    expect(draft.currency, Currency.usd);
    expect(draft.exchangeRate, 1450.5);
  });

  test('a repeat starts without the original payment plan or repeat schedule', () {
    final draft = draftFromDocument(_source(
      installments: [const DocumentInstallment(amount: 4000, dueDate: '2026-10-01T00:00:00.000Z')],
      recurrenceInterval: 'MONTHLY',
    ));

    expect(draft.installments, isNull);
    expect(draft.recurrence, isNull);
  });
```

Add to `document_editor_controller_test.dart` (imports for `Currency`, `InstallmentInput`, `RecurrenceInput`, `DocumentInstallment`):

```dart
  group('a draft made on the web', () {
    Document webDraft({
      Currency currency = Currency.rwf,
      double? rate,
      List<DocumentInstallment> installments = const [],
      String? interval,
    }) =>
        Document(
          id: 'd1',
          type: DocumentType.invoice,
          status: DocumentStatus.draft,
          customerId: 'c1',
          customer: _customer,
          issueDate: '2026-01-01T00:00:00.000Z',
          dueDate: '2026-11-01T00:00:00.000Z',
          subtotal: 11800,
          taxTotal: 0,
          total: 11800,
          currency: currency,
          exchangeRate: rate,
          installments: installments,
          recurrenceInterval: interval,
          recurrenceEndDate: interval == null ? null : '2027-01-01T00:00:00.000Z',
          amountPaid: 0,
          createdAt: '2026-01-01T00:00:00.000Z',
          updatedAt: '2026-01-01T00:00:00.000Z',
        );

    Future<DocumentEditorState> open(Document document) async {
      when(() => repository.get('d1')).thenAnswer((_) async => document);
      const arg = DocumentEditorArgs.edit('d1');
      container.listen(documentEditorControllerProvider(arg), (_, _) {});
      return container.read(documentEditorControllerProvider(arg).future);
    }

    test('keeps its currency and rate when saved', () async {
      final state = await open(webDraft(currency: Currency.usd, rate: 1450.5));

      expect(state.currency, Currency.usd);
      expect(state.exchangeRate, 1450.5);
      expect(state.toInput().currency, Currency.usd);
      expect(state.toInput().exchangeRate, 1450.5);
    });

    test('keeps its payment plan, with dates as plain dates, when saved', () async {
      final state = await open(webDraft(installments: const [
        DocumentInstallment(label: 'Deposit', amount: 4000, dueDate: '2026-10-01T00:00:00.000Z'),
        DocumentInstallment(amount: 7800, dueDate: '2026-11-01T00:00:00.000Z'),
      ]));

      expect(state.toInput().installments, const [
        InstallmentInput(label: 'Deposit', amount: 4000, dueDate: '2026-10-01'),
        InstallmentInput(amount: 7800, dueDate: '2026-11-01'),
      ]);
      expect(state.preservedPlanNote, contains('instalments'));
    });

    test('keeps its repeat schedule when saved', () async {
      final state = await open(webDraft(interval: 'MONTHLY'));

      expect(state.toInput().recurrence, const RecurrenceInput(interval: 'MONTHLY', endDate: '2027-01-01'));
      expect(state.toInput().installments, isNull);
      expect(state.preservedPlanNote, 'This draft repeats every month. Change how often on the web.');
    });

    test('a plain RWF draft sends neither a plan nor a schedule', () async {
      final state = await open(webDraft());

      expect(state.toInput().installments, isNull);
      expect(state.toInput().recurrence, isNull);
      expect(state.preservedPlanNote, isNull);
    });

    test('a foreign draft with no saved rate is not savable until one is typed', () async {
      final state = await open(webDraft(currency: Currency.usd));

      expect(state.isSavable, isFalse);
    });
  });
```

Add to `test/core/errors/action_errors_test.dart`:

```dart
  test('a payment plan that no longer adds up shows the server reason and what to do', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 400,
        data: {
          'error': 'invalid_installments',
          'message': 'The instalments add up to RWF 10,000 but the total is RWF 12,000.',
        },
      ),
    );

    expect(
      describeActionError(error),
      'The instalments add up to RWF 10,000 but the total is RWF 12,000. '
      'Change the amounts back, or update the instalments on the web.',
    );
  });

  test('a payment plan error without a reason still says what to do', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response(requestOptions: RequestOptions(path: '/x'), data: {'error': 'invalid_installments'}),
    );

    expect(describeActionError(error), contains('Change the amounts back'));
  });
```

Add to `document_editor_screen_test.dart` (its `_savedDocument()` and `buildApp` exist):

```dart
  testWidgets('a draft with a payment plan says the plan is kept and where to change it', (tester) async {
    when(() => documentRepository.get('d1')).thenAnswer((_) async => _savedDocument().copyWith(
          installments: const [
            DocumentInstallment(amount: 4000, dueDate: '2026-10-01T00:00:00.000Z'),
            DocumentInstallment(amount: 7800, dueDate: '2026-11-01T00:00:00.000Z'),
          ],
        ));

    await tester.pumpWidget(buildApp(DocumentEditorScreen.edit(documentId: 'd1')));
    await tester.pumpAndSettle();

    expect(find.textContaining('paid in instalments set up on the web'), findsOneWidget);
  });
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `flutter test test/features/documents test/core/errors`
Expected: FAIL (`Document` has no `currency`, `InstallmentInput` does not exist).

- [ ] **Step 3: Implement the read models**

In `lib/features/documents/domain/document.dart` add `import '../../../core/formatting/currency.dart';`, then add these classes next to `DocumentRef`:

```dart
@freezed
class DocumentInstallment with _$DocumentInstallment {
  const factory DocumentInstallment({String? label, required int amount, required String dueDate}) =
      _DocumentInstallment;

  factory DocumentInstallment.fromJson(Map<String, dynamic> json) => _$DocumentInstallmentFromJson(json);
}

/// The step of a payment plan the customer should pay next, as the server works it out from what is paid.
@freezed
class DocumentNextInstallment with _$DocumentNextInstallment {
  const factory DocumentNextInstallment({String? label, required int remaining, required String dueDate}) =
      _DocumentNextInstallment;

  factory DocumentNextInstallment.fromJson(Map<String, dynamic> json) => _$DocumentNextInstallmentFromJson(json);
}

@freezed
class DocumentBusinessRef with _$DocumentBusinessRef {
  const factory DocumentBusinessRef({@Default(false) bool momoEnabled}) = _DocumentBusinessRef;

  factory DocumentBusinessRef.fromJson(Map<String, dynamic> json) => _$DocumentBusinessRefFromJson(json);
}
```

and in the `Document` factory, after `required int total,`:

```dart
    @JsonKey(fromJson: currencyFromJson, toJson: currencyToJson) @Default(Currency.rwf) Currency currency,
    @JsonKey(fromJson: rateFromJson) double? exchangeRate,
    @Default(<DocumentInstallment>[]) List<DocumentInstallment> installments,
    String? recurrenceInterval,
    String? recurrenceEndDate,
    DocumentNextInstallment? nextInstallment,
    DocumentBusinessRef? business,
```

Regenerate: `dart run build_runner build --delete-conflicting-outputs`. Run `git status` and keep only `document.freezed.dart` and `document.g.dart` among generated files; restore any other generated file the run touched with `git checkout -- <path>`.

- [ ] **Step 4: Implement the request models**

In `lib/features/documents/domain/document_draft_input.dart` add `import '../../../core/formatting/currency.dart';`, add next to `DocumentLineInput`:

```dart
@freezed
class InstallmentInput with _$InstallmentInput {
  @JsonSerializable(includeIfNull: false)
  const factory InstallmentInput({String? label, required int amount, required String dueDate}) = _InstallmentInput;

  factory InstallmentInput.fromJson(Map<String, dynamic> json) => _$InstallmentInputFromJson(json);
}

@freezed
class RecurrenceInput with _$RecurrenceInput {
  @JsonSerializable(includeIfNull: false)
  const factory RecurrenceInput({required String interval, String? endDate}) = _RecurrenceInput;

  factory RecurrenceInput.fromJson(Map<String, dynamic> json) => _$RecurrenceInputFromJson(json);
}
```

and in `DocumentDraftInput`, after the `language` field:

```dart
    @JsonKey(fromJson: currencyFromJson, toJson: currencyToJson) @Default(Currency.rwf) Currency currency,
    double? exchangeRate,
    List<InstallmentInput>? installments,
    RecurrenceInput? recurrence,
```

Regenerate and keep only `document_draft_input.freezed.dart` and `document_draft_input.g.dart`.

In `duplicate_draft.dart` add to the returned `DocumentDraftInput`, with the reason as a comment above them:

```dart
    // A repeat is a new document in the same currency, but it starts without the original plan (its dates
    // are in the past) and without a repeat schedule (the original keeps repeating by itself).
    currency: source.currency,
    exchangeRate: source.exchangeRate,
```

- [ ] **Step 5: Carry the fields through the editor**

In `document_editor_controller.dart` add imports for `core/formatting/currency.dart`. In `DocumentEditorState`:

1. Constructor: add `this.currency = Currency.rwf, this.exchangeRate, this.installments = const [], this.recurrence,` and the matching fields:

```dart
  final Currency currency;
  final double? exchangeRate;

  // Set up on the web and sent back exactly as loaded, because saving replaces the whole draft.
  final List<InstallmentInput> installments;
  final RecurrenceInput? recurrence;
```

2. `fromDocument` sets:

```dart
        currency: document.currency,
        exchangeRate: document.exchangeRate,
        installments: [
          for (final step in document.installments)
            InstallmentInput(label: step.label, amount: step.amount, dueDate: step.dueDate.split('T').first),
        ],
        recurrence: document.recurrenceInterval == null
            ? null
            : RecurrenceInput(
                interval: document.recurrenceInterval!,
                endDate: document.recurrenceEndDate?.split('T').first,
              ),
```

3. `isSavable` gains `&& rateProblem(currency, exchangeRate) == null` (a foreign draft with no rate would be refused by the server).
4. `toInput` gains:

```dart
        currency: currency,
        exchangeRate: currency == Currency.rwf ? null : exchangeRate,
        // The server refuses an empty plan, so no plan is sent as no field at all.
        installments: installments.isEmpty ? null : installments,
        recurrence: recurrence,
```

5. `copyWith` gains `Currency? currency, Object? exchangeRate = _unset,` and passes them through (`currency: currency ?? this.currency`, `exchangeRate: identical(exchangeRate, _unset) ? this.exchangeRate : exchangeRate as double?`, and `installments: installments, recurrence: recurrence`).
6. Add the note getter:

```dart
  // These are kept but not editable on the phone, so the phone says so instead of hiding them.
  String? get preservedPlanNote {
    if (installments.isNotEmpty) {
      return 'This draft is paid in instalments set up on the web. Keep the total the same, or change the plan there.';
    }
    final interval = recurrence?.interval;
    if (interval == null) return null;
    return 'This draft repeats ${_recurrenceWords(interval)}. Change how often on the web.';
  }
```

with, at file level:

```dart
String _recurrenceWords(String interval) => switch (interval) {
      'WEEKLY' => 'every week',
      'MONTHLY' => 'every month',
      'QUARTERLY' => 'every quarter',
      'ANNUALLY' => 'every year',
      _ => 'on a schedule',
    };
```

In `document_editor_screen.dart`, at the top of the `_DocumentEditorForm` column (before the autosave error banner), add:

```dart
          if (state.preservedPlanNote case final note?) ...[
            Card(
              key: const Key('editor-plan-note'),
              child: Padding(padding: const EdgeInsets.all(12), child: Text(note)),
            ),
            const SizedBox(height: 16),
          ],
```

In `lib/core/errors/action_errors.dart`, after the `invalid_body` line and before the `return switch`, add:

```dart
  // The server says exactly how the plan and the total disagree; the phone adds the way out, because
  // it cannot edit the plan itself.
  if (code == 'invalid_installments') {
    final detail = data is Map ? data['message'] as String? : null;
    return '${detail ?? 'The instalments no longer match the total.'} '
        'Change the amounts back, or update the instalments on the web.';
  }
```

- [ ] **Step 6: Run the tests to verify they pass**

Run: `flutter test test/features/documents test/core/errors && flutter analyze`
Expected: PASS, no analyzer issues.

- [ ] **Step 7: Commit**

```bash
git add lib/features/documents lib/core/errors/action_errors.dart test/features/documents test/core/errors/action_errors_test.dart
git commit -m "fix: keep a draft's currency, plan and repeat schedule when saving from the phone"
```

---

### Task 3: Documents show their own currency, and messages read like the web's

**Files:**
- Create: `lib/core/formatting/short_date.dart`
- Modify: `lib/features/documents/domain/share_message.dart`
- Modify: `lib/features/documents/presentation/providers/document_contact.dart`
- Modify: `lib/features/documents/presentation/widgets/document_list_tile.dart`
- Modify: `lib/features/documents/presentation/screens/document_detail_screen.dart`
- Test: `test/core/formatting/short_date_test.dart` (create), `test/features/documents/domain/share_message_test.dart`, `test/features/documents/presentation/providers/document_contact_test.dart`, `test/features/documents/presentation/widgets/document_list_tile_test.dart`, `test/features/documents/presentation/screens/document_detail_screen_test.dart`

**Interfaces:**
- Consumes: `Currency`, `formatMoney`, `MoneyText(currency:)` from Task 2; `Document.currency`, `.installments`, `.nextInstallment`, `.business` from Task 2A.
- Produces:
  - `String formatShortDate(String iso)`, for example `1 Oct 2026`, read as a UTC calendar day.
  - `String? dueDateLabel(DocumentType type)`: `Due date` for an invoice, `Valid until` for a proforma or quote, none for the rest.
  - `reminderMessage({customer, business, number, amountOwed, dueDate, link, currency, payable, instalment})` and `shareMessage({customer, business, type, typeLabel, number, total, dueDate, link, currency, payable})`.

The web changed how its WhatsApp text reads (`shared/src/whatsapp-message.ts`): it names the business, adds a due date line, says "View and pay it here" only when the invoice can really be paid online (the business takes MoMo, the invoice is RWF), and for an invoice on a payment plan says which instalment is due now. The phone should send the same words, so customers get one voice from both apps. The web text is:

```
Hello {customer}, a reminder from {business} that invoice {number} has {amount} outstanding[, of which {amount} ({label}) is due now].
Due date: {short date}.
View and pay it here: {link}
```

and for sharing `Hello {customer}, {business} sent you {type} {number} for {amount}.` in place of the first line. The due line appears only when the document type has one and a date is set. "View it here" replaces "View and pay it here" when payment is not possible.

- [ ] **Step 1: Write the failing tests**

Create `test/core/formatting/short_date_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/formatting/short_date.dart';

void main() {
  test('writes a day, a three letter month and the year', () {
    expect(formatShortDate('2026-10-01'), '1 Oct 2026');
    expect(formatShortDate('2026-09-30T00:00:00.000Z'), '30 Sep 2026');
    expect(formatShortDate('2027-01-05T00:00:00.000Z'), '5 Jan 2027');
  });

  test('reads the calendar day it was written for, whatever the phone timezone', () {
    expect(formatShortDate('2026-10-01T23:59:59.000Z'), '1 Oct 2026');
  });

  test('returns the text unchanged when it is not a date', () {
    expect(formatShortDate('soon'), 'soon');
  });
}
```

Replace the message tests in `test/features/documents/domain/share_message_test.dart` after the first (`publicDocumentUrl`) test with:

```dart
  test('a reminder names the customer, the business, the invoice, the amount, the due date and the link', () {
    final message = reminderMessage(
      customer: 'Acme Ltd',
      business: 'Kigali Traders',
      number: 'INV-0001',
      amountOwed: 4000,
      dueDate: '2026-10-01T00:00:00.000Z',
      link: 'https://x/view/t',
      payable: true,
    );

    expect(
      message,
      'Hello Acme Ltd, a reminder from Kigali Traders that invoice INV-0001 has RWF 4,000 outstanding.\n'
      'Due date: 1 Oct 2026.\n'
      'View and pay it here: https://x/view/t',
    );
  });

  test('a reminder for an unnumbered invoice still reads naturally', () {
    final message = reminderMessage(
      customer: 'Acme',
      business: 'Kigali Traders',
      number: null,
      amountOwed: 500,
      dueDate: null,
      link: 'l',
    );

    expect(message, contains('that invoice has RWF 500 outstanding.'));
    expect(message, isNot(contains('null')));
    expect(message, isNot(contains('Due date')));
  });

  test('a reminder for an invoice on a plan says which instalment is due now', () {
    final message = reminderMessage(
      customer: 'Acme',
      business: 'Kigali Traders',
      number: 'INV-1',
      amountOwed: 10000,
      dueDate: '2026-10-01',
      link: 'l',
      instalment: (label: 'Deposit', amount: 3000),
    );

    expect(message, contains('has RWF 10,000 outstanding, of which RWF 3,000 (Deposit) is due now.'));
  });

  test('an unnamed instalment is called the next instalment', () {
    final message = reminderMessage(
      customer: 'Acme',
      business: 'B',
      number: 'INV-1',
      amountOwed: 10000,
      dueDate: null,
      link: 'l',
      instalment: (label: '  ', amount: 3000),
    );

    expect(message, contains('(the next instalment) is due now'));
  });

  test('a foreign invoice is written in its own currency and is not offered online payment', () {
    final message = reminderMessage(
      customer: 'Acme',
      business: 'B',
      number: 'INV-1',
      amountOwed: 125050,
      dueDate: null,
      link: 'https://x/view/t',
      currency: Currency.usd,
      payable: true,
    );

    expect(message, contains('USD 1,250.50 outstanding'));
    expect(message, contains('View it here: https://x/view/t'));
    expect(message, isNot(contains('pay')));
  });

  test('an invoice the business cannot take payment for says view it', () {
    final message = reminderMessage(
      customer: 'Acme',
      business: 'B',
      number: 'INV-1',
      amountOwed: 4000,
      dueDate: null,
      link: 'l',
    );

    expect(message, contains('View it here: l'));
  });

  test('a share message names the business, the document and the total', () {
    final message = shareMessage(
      customer: 'Acme',
      business: 'Kigali Traders',
      type: DocumentType.quote,
      typeLabel: 'quote',
      number: 'QUO-1',
      total: 12000,
      dueDate: '2026-10-15',
      link: 'https://x/view/t',
    );

    expect(
      message,
      'Hello Acme, Kigali Traders sent you quote QUO-1 for RWF 12,000.\n'
      'Valid until: 15 Oct 2026.\n'
      'View it here: https://x/view/t',
    );
  });

  test('only an invoice is offered online payment, and a delivery note has no due line', () {
    final invoice = shareMessage(
      customer: 'A',
      business: 'B',
      type: DocumentType.invoice,
      typeLabel: 'invoice',
      number: 'INV-1',
      total: 1000,
      dueDate: '2026-10-01',
      link: 'l',
      payable: true,
    );
    final note = shareMessage(
      customer: 'A',
      business: 'B',
      type: DocumentType.deliveryNote,
      typeLabel: 'delivery note',
      number: 'DN-1',
      total: 1000,
      dueDate: '2026-10-01',
      link: 'l',
      payable: true,
    );

    expect(invoice, contains('View and pay it here: l'));
    expect(note, contains('View it here: l'));
    expect(note, isNot(contains('Due date')));
    expect(note, isNot(contains('Valid until')));
  });

  test('messages contain no em dashes', () {
    final all = [
      reminderMessage(customer: 'A', business: 'B', number: 'N', amountOwed: 1, dueDate: null, link: 'l'),
      shareMessage(
        customer: 'A',
        business: 'B',
        type: DocumentType.invoice,
        typeLabel: 'invoice',
        number: 'N',
        total: 1,
        dueDate: null,
        link: 'l',
      ),
    ];

    for (final message in all) {
      expect(message.contains('\u2014'), isFalse);
    }
  });
```

Keep the file's closing `}` and add imports for `Currency` and `DocumentType` (`document_enums.dart`).

In `test/features/documents/presentation/providers/document_contact_test.dart`, give `pressGo` the signed-in business by adding this override (import `auth_controller.dart` and `../../../account/support.dart`, which provides `FakeAuthController` with a business named `Acme`):

```dart
        authControllerProvider.overrideWith(FakeAuthController.new),
```

Update the existing expectations that read the old wording: `here is quote INV-0001` becomes `Acme sent you quote INV-0001`. The two `... RWF 4,000 outstanding` expectations still hold. Add:

```dart
  testWidgets('a reminder names the business and takes payment only when MoMo is on and the invoice is RWF', (tester) async {
    await start(
      tester,
      _document().copyWith(business: const DocumentBusinessRef(momoEnabled: true), dueDate: '2026-10-01T00:00:00.000Z'),
    );

    expect(find.textContaining('a reminder from Acme that invoice INV-0001'), findsOneWidget);
    expect(find.textContaining('Due date: 1 Oct 2026.'), findsOneWidget);
    expect(find.textContaining('View and pay it here'), findsOneWidget);
  });

  testWidgets('a foreign invoice reminder is in its currency and does not invite payment', (tester) async {
    await start(
      tester,
      _document(total: 125050, amountPaid: 25000).copyWith(
        currency: Currency.usd,
        exchangeRate: 1450,
        business: const DocumentBusinessRef(momoEnabled: true),
      ),
    );

    expect(find.textContaining('USD 1,000.50 outstanding'), findsOneWidget);
    expect(find.textContaining('View it here'), findsOneWidget);
    expect(find.textContaining('View and pay'), findsNothing);
  });

  testWidgets('a reminder for an invoice on a plan says which instalment is due now', (tester) async {
    await start(
      tester,
      _document().copyWith(nextInstallment: const DocumentNextInstallment(label: 'Deposit', remaining: 1500, dueDate: '2026-10-01')),
    );

    expect(find.textContaining('of which RWF 1,500 (Deposit) is due now'), findsOneWidget);
  });
```

(import `Currency`, `DocumentBusinessRef`, `DocumentNextInstallment`). If `document_detail_actions_test.dart` or `receivables_swipe_test.dart` open the contact sheet, add the same `authControllerProvider` override to their provider list so the business name is present; their `outstanding` expectations still hold.

Add to `document_list_tile_test.dart` (import `Currency`):

```dart
  testWidgets('shows a foreign total in its own currency', (tester) async {
    const usd = Document(
      id: 'd3',
      type: DocumentType.invoice,
      number: 'INV-0002',
      status: DocumentStatus.finalized,
      customerId: 'c1',
      customer: _customer,
      issueDate: '2026-01-01T00:00:00.000Z',
      subtotal: 125050,
      taxTotal: 0,
      total: 125050,
      currency: Currency.usd,
      exchangeRate: 1450,
      amountPaid: 0,
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
    );

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: DocumentListTile(document: usd, onTap: () {})),
    ));

    expect(find.text('USD 1,250.50'), findsOneWidget);
    expect(find.textContaining('RWF'), findsNothing);
  });
```

Add to `document_detail_screen_test.dart` (import `Currency`):

```dart
  testWidgets('a foreign invoice shows lines, totals and payments in its own currency', (tester) async {
    const usdLine = DocumentLine(
      id: 'l2',
      description: 'Consulting',
      quantity: 1.0,
      unitPrice: 125050,
      taxRate: 0.0,
      lineTotal: 125050,
      sortOrder: 0,
    );
    const usd = Document(
      id: 'd1',
      type: DocumentType.invoice,
      number: 'INV-0002',
      status: DocumentStatus.finalized,
      customerId: 'c1',
      customer: _customer,
      issueDate: '2026-01-01T00:00:00.000Z',
      subtotal: 125050,
      taxTotal: 0,
      total: 125050,
      currency: Currency.usd,
      exchangeRate: 1450,
      amountPaid: 25050,
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
      lines: [usdLine],
    );
    when(() => repository.get('d1')).thenAnswer((_) async => usd);
    when(() => repository.listPayments('d1')).thenAnswer((_) async => [
          const Payment(
            id: 'p1',
            amount: 25050,
            method: PaymentMethod.cash,
            paidOn: '2026-01-05',
            createdAt: '2026-01-05T00:00:00.000Z',
          ),
        ]);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('1.00 × USD 1,250.50'), findsOneWidget);
    expect(find.text('USD 1,250.50'), findsWidgets);
    expect(find.text('USD 250.50'), findsOneWidget);
    expect(find.textContaining('RWF'), findsNothing);
  });
```

If the payments section needs a scroll to build, scroll it into view the way the existing payments test in this file does (search the file for `listPayments` with a non-empty list and copy its pump and scroll steps).

- [ ] **Step 2: Run the tests to verify they fail**

Run: `flutter test test/core/formatting test/features/documents`
Expected: FAIL (`short_date.dart` does not exist, the message functions have new parameters).

- [ ] **Step 3: Implement the date helper**

Create `lib/core/formatting/short_date.dart`:

```dart
const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// "1 Oct 2026". Spelled out by hand so it reads the same on every phone and in the web app, and read as
/// the UTC calendar day because a due date is a day, not a moment.
String formatShortDate(String iso) {
  final parsed = DateTime.tryParse(iso);
  if (parsed == null) return iso;
  // A date with no zone is a calendar day and is kept as written; a value with a zone is already in UTC.
  final date = parsed.isUtc ? parsed : DateTime.utc(parsed.year, parsed.month, parsed.day);
  return '${date.day} ${_months[date.month - 1]} ${date.year}';
}
```

- [ ] **Step 4: Implement the messages**

Replace the two message functions in `lib/features/documents/domain/share_message.dart` (keep `publicDocumentUrl`), with imports for `Currency`, `formatShortDate` and `document_enums.dart`:

```dart
/// The label before a document's date, or none for a type that has no date to show.
String? dueDateLabel(DocumentType type) => switch (type) {
      DocumentType.invoice => 'Due date',
      DocumentType.proforma || DocumentType.quote => 'Valid until',
      _ => null,
    };

String _lines(String opening, DocumentType type, String? dueDate, String link, bool payable) {
  final label = dueDateLabel(type);
  final canPay = payable && type == DocumentType.invoice;
  return [
    opening,
    if (label != null && dueDate != null) '$label: ${formatShortDate(dueDate)}.',
    '${canPay ? 'View and pay it here' : 'View it here'}: $link',
  ].join('\n');
}

/// Worded like the web app's WhatsApp reminder, so a customer hears the same thing from either app.
/// [payable] is whether the public page can take a MoMo payment, and it never can for a foreign invoice.
String reminderMessage({
  required String customer,
  required String business,
  required String? number,
  required int amountOwed,
  required String? dueDate,
  required String link,
  Currency currency = Currency.rwf,
  bool payable = false,
  ({String? label, int amount})? instalment,
}) {
  final reference = number == null ? 'invoice' : 'invoice $number';
  String money(int amount) => formatMoney(amount, currency: currency);
  final name = instalment?.label?.trim();
  final due = instalment == null
      ? ''
      : ', of which ${money(instalment.amount)} (${name == null || name.isEmpty ? 'the next instalment' : name}) is due now';
  final opening = 'Hello $customer, a reminder from $business that $reference has ${money(amountOwed)} outstanding$due.';
  return _lines(opening, DocumentType.invoice, dueDate, link, payable && currency == Currency.rwf);
}

String shareMessage({
  required String customer,
  required String business,
  required DocumentType type,
  required String typeLabel,
  required String? number,
  required int total,
  required String? dueDate,
  required String link,
  Currency currency = Currency.rwf,
  bool payable = false,
}) {
  final reference = number == null ? typeLabel : '$typeLabel $number';
  final opening = 'Hello $customer, $business sent you $reference for ${formatMoney(total, currency: currency)}.';
  return _lines(opening, type, dueDate, link, payable && currency == Currency.rwf);
}
```

In `document_contact.dart` add imports for `core/formatting/currency.dart`, `../../../auth/domain/auth_status.dart` and `../../../auth/presentation/providers/auth_controller.dart`, then replace the message construction:

```dart
    final status = ref.read(authControllerProvider).valueOrNull;
    final business = status is Authenticated ? status.business.name : '';
    final payable = document.business?.momoEnabled == true && document.currency == Currency.rwf;
    final next = document.nextInstallment;
    // Only a plan with something already covered has a smaller amount due now than the whole balance.
    final instalment = next != null && next.remaining < owed ? (label: next.label, amount: next.remaining) : null;
```

and:

```dart
      message: isChase
          ? reminderMessage(
              customer: customer.name,
              business: business,
              number: document.number,
              amountOwed: owed,
              dueDate: document.dueDate,
              link: link,
              currency: document.currency,
              payable: payable,
              instalment: instalment,
            )
          : shareMessage(
              customer: customer.name,
              business: business,
              type: document.type,
              typeLabel: documentTypeLabel(document.type).toLowerCase(),
              number: document.number,
              total: document.total,
              dueDate: document.dueDate,
              link: link,
              currency: document.currency,
              payable: payable,
            ),
```

- [ ] **Step 5: Implement the screens**

`document_list_tile.dart`: `trailing: MoneyText(document.total, currency: document.currency),`.

`document_detail_screen.dart`:

1. Add imports `../../../../core/formatting/currency.dart` and `../../../../core/formatting/money.dart`, and replace `_lineDiscountLabel` so it takes the currency:

```dart
String _lineDiscountLabel(DocumentLine line, Currency currency) {
  if (line.discountType == null || line.discountValue == null) return '';
  return line.discountType == DiscountType.percent
      ? '${line.discountValue!.toStringAsFixed(0)}% off'
      : '${formatMoney(line.discountValue!.round(), currency: currency)} off';
}
```

2. In the lines list replace the quantity text and line total (wrap the long string across lines to stay within 120 columns):

```dart
                              Text(
                                '${line.quantity.toStringAsFixed(2)} × '
                                '${formatMoney(line.unitPrice, currency: document.currency)}'
                                '${_lineDiscountLabel(line, document.currency).isEmpty ? '' : ' · ${_lineDiscountLabel(line, document.currency)}'}',
                              ),
```

and `MoneyText(line.lineTotal, currency: document.currency),`.

3. Add `currency: document.currency` to the `MoneyText` calls for `document.subtotal`, `document.taxTotal`, `document.total`, and `payment.amount` in the payments list.

- [ ] **Step 6: Run the tests and fix the expectations that read the old text**

Run: `flutter test test/core test/features/documents test/features/receivables && flutter analyze`. The old unit price text was `RWF 5000`; it is now `RWF 5,000`. The old share wording (`here is quote ...`) is now `Acme sent you quote ...`. Update those expectations in the tests that still carry them, then re-run. Expected: PASS.

- [ ] **Step 7: Commit**

Two commits:

```bash
git add lib/core/formatting/short_date.dart lib/features/documents/domain/share_message.dart lib/features/documents/presentation/providers/document_contact.dart test/core/formatting/short_date_test.dart test/features/documents/domain/share_message_test.dart test/features/documents/presentation/providers/document_contact_test.dart
git commit -m "feat: word customer messages the way the web app does"
git add lib/features/documents test/features/documents
git commit -m "feat: show documents in the currency they were written in"
```

---

### Task 4: Receivables and payment picker by currency

**Files:**
- Modify: `lib/features/receivables/domain/outstanding_invoice.dart` (+ regenerate freezed and json)
- Modify: `lib/features/receivables/presentation/screens/receivables_screen.dart`
- Modify: `lib/app/shell/quick_create.dart`
- Test: `test/features/receivables/domain/outstanding_invoice_test.dart`, `test/features/receivables/presentation/screens/receivables_screen_test.dart`, `test/app/shell/quick_create_test.dart`

**Interfaces:**
- Consumes: `Currency`, `currencyFromJson`, `sumByCurrency`, `MoneyAmount`, `MoneyText(currency:)`.
- Produces: `OutstandingInvoice.currency` (`Currency`, default `rwf`) and `OutstandingInvoice.amountOwedRwf` (`int`, default 0).

The phone computes no overdue rule: the list already uses the server's `daysOverdue` and `agingBucket`, and Home uses the server's `overdueInvoiceCount`. The server changed the rule to "the day after the due date" and instalment aware, so nothing on the phone needs to change for that. The only phone-side arithmetic is the summary total, which must not add different currencies together.

- [ ] **Step 1: Write the failing tests**

Add to `test/features/receivables/domain/outstanding_invoice_test.dart` (import `Currency`):

```dart
  test('carries the invoice currency and the balance in RWF', () {
    final invoice = OutstandingInvoice.fromJson({
      'id': 'd1',
      'number': 'INV-0002',
      'customerName': 'Acme',
      'total': 125050,
      'amountOwed': 100000,
      'currency': 'USD',
      'amountOwedRwf': 1450000,
      'dueDate': '2026-01-01',
      'daysOverdue': 0,
      'agingBucket': 'current',
    });

    expect(invoice.currency, Currency.usd);
    expect(invoice.amountOwedRwf, 1450000);
  });

  test('an older response with no currency reads as RWF', () {
    final invoice = OutstandingInvoice.fromJson({
      'id': 'd1',
      'number': null,
      'customerName': 'Acme',
      'total': 10000,
      'amountOwed': 10000,
      'dueDate': null,
      'daysOverdue': 0,
      'agingBucket': 'current',
    });

    expect(invoice.currency, Currency.rwf);
    expect(invoice.amountOwedRwf, 0);
  });
```

Add to `test/features/receivables/presentation/screens/receivables_screen_test.dart` (import `package:billa_mobile/core/formatting/currency.dart`):

```dart
  testWidgets('totals each currency on its own and shows each row in its own currency', (tester) async {
    when(() => repository.list()).thenAnswer((_) async => [
          const OutstandingInvoice(
            id: 'd1',
            number: 'INV-0001',
            customerName: 'Acme',
            total: 10000,
            amountOwed: 4000,
            dueDate: '2026-12-01',
            daysOverdue: 0,
            agingBucket: 'current',
          ),
          const OutstandingInvoice(
            id: 'd2',
            number: 'INV-0002',
            customerName: 'Beta',
            total: 300000,
            amountOwed: 250050,
            currency: Currency.usd,
            amountOwedRwf: 3625725,
            dueDate: '2026-12-01',
            daysOverdue: 0,
            agingBucket: 'current',
          ),
        ]);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final summary = find.byKey(const Key('payments-summary'));
    expect(find.descendant(of: summary, matching: find.text('RWF 4,000')), findsOneWidget);
    expect(find.descendant(of: summary, matching: find.text('USD 2,500.50')), findsOneWidget);
    expect(find.text('USD 2,500.50'), findsNWidgets(2));
    expect(find.text('RWF 4,000'), findsNWidgets(2));
    expect(find.text('RWF 254,050'), findsNothing);
  });
```

Add to `test/app/shell/quick_create_test.dart` (same import):

```dart
  testWidgets('the invoice picker shows a foreign balance in its own currency', (tester) async {
    when(() => receivables.list()).thenAnswer((_) async => [
          const OutstandingInvoice(
            id: 'd1',
            number: 'INV-1',
            customerName: 'Acme Ltd',
            total: 300000,
            amountOwed: 250050,
            currency: Currency.usd,
            amountOwedRwf: 3625725,
            dueDate: '2026-02-01',
            daysOverdue: 0,
            agingBucket: 'current',
          ),
        ]);

    await open(tester);
    await tester.tap(find.byKey(const Key('quick-create-payment')));
    await tester.pumpAndSettle();

    expect(find.text('USD 2,500.50'), findsOneWidget);
  });
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `flutter test test/features/receivables test/app/shell/quick_create_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement**

`outstanding_invoice.dart`: add `import '../../../core/formatting/currency.dart';` and in the factory, after `required int amountOwed,`:

```dart
    @JsonKey(fromJson: currencyFromJson, toJson: currencyToJson) @Default(Currency.rwf) Currency currency,
    @Default(0) int amountOwedRwf,
```

Regenerate as in Task 3 and keep only `outstanding_invoice.freezed.dart` and `outstanding_invoice.g.dart`.

`receivables_screen.dart`:

1. Replace the `owed` line with totals per currency:

```dart
          final totals = sumByCurrency(
            invoices.map((invoice) => (currency: invoice.currency, amount: invoice.amountOwed)),
          );
```

(import `../../../../core/formatting/currency.dart`), and pass `owed: totals` to the card: `_SummaryCard(totals: totals, count: invoices.length, overdue: overdue)`.

2. Row trailing: `trailing: MoneyText(invoice.amountOwed, currency: invoice.currency),`.
3. `_SummaryCard` takes `final List<MoneyAmount> totals;` instead of `owed`, and shows one line per currency:

```dart
          for (final total in totals)
            MoneyText(
              total.amount,
              currency: total.currency,
              style: textTheme.headlineMedium?.copyWith(color: colors.neutral900),
            ),
```

in place of the single `MoneyText(owed, ...)`.

`quick_create.dart` line 255: `trailing: MoneyText(invoice.amountOwed, currency: invoice.currency),`.

- [ ] **Step 4: Run the tests to verify they pass**

Run: `flutter test test/features/receivables test/app && flutter analyze`
Expected: PASS. The existing summary test that expects `RWF 9,000` still passes because RWF-only lists produce one RWF line.

- [ ] **Step 5: Commit**

```bash
git add lib/features/receivables lib/app/shell/quick_create.dart test/features/receivables test/app/shell/quick_create_test.dart
git commit -m "feat: total what is owed one currency at a time"
```

---

### Task 5: Draft currency, rate and repricing (state and controller)

**Files:**
- Create: `lib/features/documents/domain/exchange_rates.dart`
- Modify: `lib/features/documents/domain/document_repository.dart`
- Modify: `lib/features/documents/data/document_repository_impl.dart`
- Modify: `lib/features/documents/presentation/providers/document_editor_controller.dart`
- Test: `test/features/documents/domain/exchange_rates_test.dart` (create), `test/features/documents/data/document_repository_impl_test.dart`, `test/features/documents/presentation/providers/document_editor_controller_test.dart`

**Interfaces:**
- Consumes: everything from Task 2; `DocumentDraftInput.currency`, `DocumentEditorState.currency` and `.exchangeRate`, `toInput` and `isSavable` from Task 2A.
- Produces:
  - `class RateQuote { const RateQuote({required double rate, required String source, String? date}) }` and `class ExchangeRates { const ExchangeRates(Map<Currency, RateQuote> quotes); factory ExchangeRates.fromJson(Map<String, dynamic>); RateQuote? operator [](Currency currency) }`, plus `String? rateHint(RateQuote? quote)`.
  - `DocumentRepository.rates()` returning `Future<ExchangeRates>` (`GET /documents/rates`).
  - `DocumentEditorState.rateHint`, `.repriceNote`, `.currencyLocked`; controller methods `Future<void> setCurrency(Currency next)`, `void setExchangeRate(double? rate)`, and `setReferencedDocument(DocumentRef?, {Currency? currency, double? exchangeRate})`.

- [ ] **Step 1: Write the failing tests**

Create `test/features/documents/domain/exchange_rates_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/formatting/currency.dart';
import 'package:billa_mobile/features/documents/domain/exchange_rates.dart';

void main() {
  test('reads the rate and where it came from for each currency', () {
    final rates = ExchangeRates.fromJson({
      'rates': {'USD': 1450.5, 'EUR': 1600},
      'info': {
        'USD': {'source': 'BNR', 'date': '2026-09-29'},
        'EUR': {'source': 'LAST_USED', 'date': null},
      },
    });

    expect(rates[Currency.usd]!.rate, 1450.5);
    expect(rates[Currency.usd]!.source, 'BNR');
    expect(rates[Currency.eur]!.rate, 1600.0);
    expect(rates[Currency.gbp], isNull);
    expect(rates[Currency.rwf], isNull);
  });

  test('ignores a currency code the app does not know and tolerates missing info', () {
    final rates = ExchangeRates.fromJson({
      'rates': {'JPY': 9.5, 'USD': 1450},
    });

    expect(rates[Currency.usd]!.rate, 1450.0);
    expect(rates[Currency.usd]!.source, 'UNKNOWN');
  });

  test('says where a prefilled rate came from', () {
    expect(
      rateHint(const RateQuote(rate: 1450, source: 'BNR', date: '2026-09-29')),
      'National Bank of Rwanda reference rate, 29 Sep 2026.',
    );
    expect(rateHint(const RateQuote(rate: 1450, source: 'LAST_USED')), 'The rate you used last.');
    expect(rateHint(null), isNull);
  });
}
```

In `test/features/documents/data/document_repository_impl_test.dart` add (follow the file's existing dio mock helpers for the response):

```dart
  test('rates reads the bank and last used rates', () async {
    when(() => dio.get<Map<String, dynamic>>('/documents/rates')).thenAnswer(
      (_) async => _response(200, {
        'rates': {'USD': 1450.5},
        'info': {'USD': {'source': 'BNR', 'date': '2026-09-29'}},
      }, RequestOptions(path: '/documents/rates')),
    );

    final rates = await repository.rates();

    expect(rates[Currency.usd]!.rate, 1450.5);
  });
```

Add `import 'package:billa_mobile/core/formatting/currency.dart';` to that file. It builds the repository in `setUp` as `repository = DocumentRepositoryImpl(dio)` with a `_MockDio dio`; use whatever those variables are named at the top of `main()`.

In `document_editor_controller_test.dart` (which mocks `DocumentRepository`), add:

```dart
  group('currency', () {
    const usdRates = ExchangeRates({Currency.usd: RateQuote(rate: 1400, source: 'BNR', date: '2026-09-29')});

    Future<DocumentEditorController> open() async {
      const arg = DocumentEditorArgs.create(DocumentType.invoice);
      container.listen(documentEditorControllerProvider(arg), (_, _) {});
      await container.read(documentEditorControllerProvider(arg).future);
      return container.read(documentEditorControllerProvider(arg).notifier);
    }

    DocumentEditorState current() =>
        container.read(documentEditorControllerProvider(const DocumentEditorArgs.create(DocumentType.invoice))).requireValue;

    test('switching to a foreign currency prefills the bank rate and reprices the lines through RWF', () async {
      when(() => repository.rates()).thenAnswer((_) async => usdRates);
      final notifier = await open();
      notifier.addLine();
      notifier.setLineUnitPrice(0, 14000);

      await notifier.setCurrency(Currency.usd);

      expect(current().currency, Currency.usd);
      expect(current().exchangeRate, 1400);
      expect(current().lines.single.unitPrice, 1000);
      expect(current().rateHint, 'National Bank of Rwanda reference rate, 29 Sep 2026.');
      expect(current().repriceNote, isFalse);
    });

    test('a flat discount is repriced with the prices, a percent discount is left alone', () async {
      when(() => repository.rates()).thenAnswer((_) async => usdRates);
      final notifier = await open();
      notifier.addLine();
      notifier.addLine();
      notifier.setLineDiscount(0, DiscountType.flat, 1400);
      notifier.setLineDiscount(1, DiscountType.percent, 10);

      await notifier.setCurrency(Currency.usd);

      expect(current().lines[0].discountValue, 100);
      expect(current().lines[1].discountValue, 10);
    });

    test('when the rates cannot be loaded the prices stay as typed and the user is told', () async {
      when(() => repository.rates()).thenAnswer((_) async => throw Exception('offline'));
      final notifier = await open();
      notifier.addLine();
      notifier.setLineUnitPrice(0, 14000);

      await notifier.setCurrency(Currency.usd);

      expect(current().currency, Currency.usd);
      expect(current().exchangeRate, isNull);
      expect(current().lines.single.unitPrice, 14000);
      expect(current().repriceNote, isTrue);
    });

    test('a foreign draft with no rate is not savable, and is once a rate is typed', () async {
      when(() => repository.rates()).thenAnswer((_) async => const ExchangeRates({}));
      final notifier = await open();
      notifier.setCustomer('c1', 'Acme');

      await notifier.setCurrency(Currency.usd);
      expect(current().isSavable, isFalse);

      notifier.setExchangeRate(1400);
      expect(current().isSavable, isTrue);
    });

    test('switching back to RWF clears the rate and reprices back', () async {
      when(() => repository.rates()).thenAnswer((_) async => usdRates);
      final notifier = await open();
      notifier.addLine();
      notifier.setLineUnitPrice(0, 14000);
      await notifier.setCurrency(Currency.usd);

      await notifier.setCurrency(Currency.rwf);

      expect(current().currency, Currency.rwf);
      expect(current().exchangeRate, isNull);
      expect(current().lines.single.unitPrice, 14000);
    });

    test('a document that refers to an invoice keeps the invoice currency and cannot change it', () async {
      final notifier = await open();

      notifier.setReferencedDocument(
        const DocumentRef(id: 'inv1', number: 'INV-1', type: DocumentType.invoice),
        currency: Currency.usd,
        exchangeRate: 1450,
      );
      expect(current().currency, Currency.usd);
      expect(current().exchangeRate, 1450);
      expect(current().currencyLocked, isTrue);

      await notifier.setCurrency(Currency.eur);
      expect(current().currency, Currency.usd);
    });

    test('picking a catalog item converts its RWF price into the draft currency', () async {
      when(() => repository.rates()).thenAnswer((_) async => usdRates);
      final notifier = await open();
      notifier.addLine();
      await notifier.setCurrency(Currency.usd);

      notifier.selectLineItem(0, itemId: 'i1', description: 'Printing', unitPrice: 14000, taxRate: 18);

      expect(current().lines.single.unitPrice, 1000);
    });

    test('the request carries the currency and rate, and none for RWF', () async {
      when(() => repository.rates()).thenAnswer((_) async => usdRates);
      final notifier = await open();
      notifier.setCustomer('c1', 'Acme');

      expect(current().toInput().currency, Currency.rwf);
      expect(current().toInput().exchangeRate, isNull);

      await notifier.setCurrency(Currency.usd);
      expect(current().toInput().currency, Currency.usd);
      expect(current().toInput().exchangeRate, 1400);
    });
  });
```

(add imports for `Currency`, `ExchangeRates`, `RateQuote`.)

- [ ] **Step 2: Run the tests to verify they fail**

Run: `flutter test test/features/documents`
Expected: FAIL (missing `exchange_rates.dart`, `rates()`, `setCurrency`).

- [ ] **Step 3: Implement rates**

Create `lib/features/documents/domain/exchange_rates.dart`:

```dart
import '../../../core/formatting/currency.dart';
import '../../../core/formatting/short_date.dart';

class RateQuote {
  const RateQuote({required this.rate, required this.source, this.date});

  /// RWF for one whole unit of the currency.
  final double rate;

  /// `BNR` for the bank's reference rate, `LAST_USED` for the rate this business used last.
  final String source;
  final String? date;
}

class ExchangeRates {
  const ExchangeRates(this._quotes);

  factory ExchangeRates.fromJson(Map<String, dynamic> json) {
    final rates = (json['rates'] as Map?) ?? const {};
    final info = (json['info'] as Map?) ?? const {};
    final quotes = <Currency, RateQuote>{};
    for (final entry in rates.entries) {
      final currency = Currency.values.where((c) => c.code == entry.key).firstOrNull;
      final rate = rateFromJson(entry.value);
      if (currency == null || currency == Currency.rwf || rate == null) continue;
      final detail = info[entry.key] as Map?;
      quotes[currency] = RateQuote(
        rate: rate,
        source: (detail?['source'] as String?) ?? 'UNKNOWN',
        date: detail?['date'] as String?,
      );
    }
    return ExchangeRates(quotes);
  }

  final Map<Currency, RateQuote> _quotes;

  RateQuote? operator [](Currency currency) => _quotes[currency];
}

/// Where a prefilled rate came from, shown until the user types their own.
String? rateHint(RateQuote? quote) {
  if (quote == null) return null;
  if (quote.source == 'BNR' && quote.date != null) {
    return 'National Bank of Rwanda reference rate, ${formatShortDate(quote.date!)}.';
  }
  return 'The rate you used last.';
}
```

`document_repository.dart`: add `import 'exchange_rates.dart';` and `Future<ExchangeRates> rates();`. `document_repository_impl.dart`: add the import and

```dart
  @override
  Future<ExchangeRates> rates() async {
    final response = await _dio.get<Map<String, dynamic>>('/documents/rates');
    return ExchangeRates.fromJson(response.data!);
  }
```

- [ ] **Step 4: Implement the editor state and controller**

In `document_editor_controller.dart` add imports for `core/formatting/currency.dart` and `../../domain/exchange_rates.dart`.

`DocumentEditorState`: `currency`, `exchangeRate`, `toInput` and the rate check in `isSavable` already exist from Task 2A. Add fields (constructor defaults `this.rateHint`, `this.repriceNote = false`), and:

```dart
  final String? rateHint;

  /// True when the currency changed but the prices could not be converted, so the user must check them.
  final bool repriceNote;

  // A document that refers to an invoice is always in the invoice's currency at its rate.
  bool get currencyLocked => referencedDocument != null;
```

`copyWith` gains `Object? rateHint = _unset, bool? repriceNote,` and passes them through (`rateHint: identical(rateHint, _unset) ? this.rateHint : rateHint as String?`, `repriceNote: repriceNote ?? this.repriceNote`).

Controller: add

```dart
  // Asked every time a currency is chosen, as the web form does: the server keeps the rates fresh, and a
  // long editing session should not keep using a rate from when the draft was opened. A failure is not
  // an error to show, it just means no rate could be prefilled, and the user types one.
  Future<ExchangeRates?> _loadRates() async {
    try {
      return await ref.read(documentRepositoryProvider).rates();
    } catch (_) {
      return null;
    }
  }

  Future<void> setCurrency(Currency next) async {
    final current = state.value;
    if (current == null || current.currencyLocked || next == current.currency) return;

    final quote = next == Currency.rwf ? null : (await _loadRates())?[next];
    final rate = quote?.rate;
    // The state may have moved on while the rates were loading.
    final latest = state.value;
    if (latest == null || latest.currencyLocked) return;

    final repriced = <DocumentLineDraft>[];
    var canConvert = true;
    for (final line in latest.lines) {
      final price = convertMinor(
        line.unitPrice,
        from: latest.currency,
        fromRate: latest.exchangeRate,
        to: next,
        toRate: rate,
      );
      final flat = line.discountType == DiscountType.flat;
      final discount = flat
          ? convertMinor(
              (line.discountValue ?? 0).round(),
              from: latest.currency,
              fromRate: latest.exchangeRate,
              to: next,
              toRate: rate,
            )
          : line.discountValue?.round();
      if (price == null || (flat && discount == null)) {
        canConvert = false;
        break;
      }
      repriced.add(_cloneLine(line, unitPrice: price, discountValue: flat ? discount!.toDouble() : line.discountValue));
    }

    _update((s) => s.copyWith(
          currency: next,
          exchangeRate: rate,
          rateHint: rateHint(quote),
          lines: canConvert ? repriced : s.lines,
          repriceNote: !canConvert && s.lines.any((line) => line.unitPrice > 0),
        ));
  }

  void setExchangeRate(double? rate) => _update((s) => s.copyWith(exchangeRate: rate, rateHint: null));
```

Note `_update` is synchronous and schedules autosave. `setReferencedDocument` becomes:

```dart
  void setReferencedDocument(DocumentRef? reference, {Currency? currency, double? exchangeRate}) =>
      _update((s) => s.copyWith(
            referencedDocument: reference,
            currency: reference == null ? null : currency,
            exchangeRate: reference == null || currency == null ? _unset : exchangeRate,
            repriceNote: false,
          ));
```

`selectLineItem` converts the catalog price (always RWF) into the draft currency, so picking an item never inserts francs into a dollar invoice:

```dart
  void selectLineItem(
    int localId, {
    required String itemId,
    required String description,
    required int unitPrice,
    required double taxRate,
  }) {
    final current = state.value;
    final price = current == null ? unitPrice : fromRwf(unitPrice, current.currency, current.exchangeRate);
    _updateLine(
      localId,
      (line) => _cloneLine(line, itemId: itemId, description: description, unitPrice: price, taxRate: taxRate),
    );
  }
```

Add the doc comment "unitPrice is the catalog price in RWF" above it.

- [ ] **Step 5: Run the tests to verify they pass**

Run: `flutter test test/features/documents && flutter analyze`
Expected: PASS. If a `copyWith`-based test in the file compares whole states, adjust it for the new fields.

- [ ] **Step 6: Commit**

Two commits, since the pieces are independent:

```bash
git add lib/features/documents/domain/exchange_rates.dart lib/features/documents/domain/document_repository.dart lib/features/documents/data test/features/documents/domain/exchange_rates_test.dart test/features/documents/data
git commit -m "feat: load the bank and last used exchange rates"
git add lib/features/documents test/features/documents
git commit -m "feat: let a draft carry a currency and reprice its lines"
```

---

### Task 6: Editor screen: currency, rate and decimal prices

**Files:**
- Create: `lib/features/documents/presentation/widgets/currency_section.dart`
- Modify: `lib/features/documents/presentation/screens/document_editor_screen.dart`
- Test: `test/features/documents/presentation/widgets/currency_section_test.dart` (create), `test/features/documents/presentation/screens/document_editor_screen_test.dart`

**Interfaces:**
- Consumes: `DocumentEditorState.currency/.exchangeRate/.rateHint/.repriceNote/.currencyLocked`, controller `setCurrency`, `setExchangeRate`, `parseMajorAmount`, `minorToMajorText`, `rateProblem`, `MoneyText(currency:)`.
- Produces: `CurrencySection` widget.

- [ ] **Step 1: Write the failing tests**

Create `test/features/documents/presentation/widgets/currency_section_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/formatting/currency.dart';
import 'package:billa_mobile/features/documents/presentation/widgets/currency_section.dart';

void main() {
  Widget host({
    Currency currency = Currency.rwf,
    double? rate,
    String? hint,
    bool repriceNote = false,
    bool locked = false,
    ValueChanged<Currency>? onCurrency,
    ValueChanged<double?>? onRate,
  }) =>
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: CurrencySection(
            currency: currency,
            exchangeRate: rate,
            rateHint: hint,
            repriceNote: repriceNote,
            locked: locked,
            onCurrencyChanged: onCurrency ?? (_) {},
            onRateChanged: onRate ?? (_) {},
          ),
        ),
      );

  testWidgets('RWF shows the currency and no rate field', (tester) async {
    await tester.pumpWidget(host());

    expect(find.text('RWF (Rwandan franc)'), findsOneWidget);
    expect(find.byKey(const Key('document-editor-rate')), findsNothing);
  });

  testWidgets('a foreign currency shows the rate with where it came from', (tester) async {
    await tester.pumpWidget(host(currency: Currency.usd, rate: 1450.5, hint: 'The rate you used last.'));

    expect(find.byKey(const Key('document-editor-rate')), findsOneWidget);
    expect(find.text('1450.5'), findsOneWidget);
    expect(find.textContaining('The rate you used last.'), findsOneWidget);
  });

  testWidgets('typing a rate reports a number, and clearing it reports none', (tester) async {
    final rates = <double?>[];
    await tester.pumpWidget(host(currency: Currency.usd, rate: 1450, onRate: rates.add));

    await tester.enterText(find.byKey(const Key('document-editor-rate')), '1500.25');
    await tester.enterText(find.byKey(const Key('document-editor-rate')), '');

    expect(rates, [1500.25, null]);
  });

  testWidgets('the rate box ignores letters, a second dot and more than six decimals', (tester) async {
    final rates = <double?>[];
    await tester.pumpWidget(host(currency: Currency.usd, rate: 1450, onRate: rates.add));

    await tester.enterText(find.byKey(const Key('document-editor-rate')), '14a5');
    await tester.enterText(find.byKey(const Key('document-editor-rate')), '1.2.3');
    await tester.enterText(find.byKey(const Key('document-editor-rate')), '1.1234567');

    expect(rates, isEmpty);
  });

  testWidgets('a foreign currency with no rate says what to do', (tester) async {
    await tester.pumpWidget(host(currency: Currency.usd));

    expect(find.text('Enter the exchange rate for USD'), findsOneWidget);
  });

  testWidgets('says when the prices were not converted', (tester) async {
    await tester.pumpWidget(host(currency: Currency.usd, rate: 1450, repriceNote: true));

    expect(find.textContaining('Check them in USD'), findsOneWidget);
  });

  testWidgets('a locked currency explains why it cannot change', (tester) async {
    await tester.pumpWidget(host(currency: Currency.usd, rate: 1450, locked: true));

    expect(find.text('Kept the same as the invoice this document is for.'), findsOneWidget);
    final field = tester.widget<TextField>(find.byKey(const Key('document-editor-rate')));
    expect(field.enabled, isFalse);
  });

  testWidgets('choosing another currency reports it', (tester) async {
    Currency? chosen;
    await tester.pumpWidget(host(onCurrency: (value) => chosen = value));

    await tester.tap(find.byKey(const Key('document-editor-currency')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('USD (US dollar)').last);
    await tester.pumpAndSettle();

    expect(chosen, Currency.usd);
  });
}
```

Add to `document_editor_screen_test.dart` (its `buildApp` and `_savedDocument` exist; add `when(() => documentRepository.rates())` in the test itself):

```dart
  testWidgets('choosing USD shows the bank rate, and a price is typed in dollars and cents', (tester) async {
    when(() => documentRepository.rates()).thenAnswer(
      (_) async => const ExchangeRates({Currency.usd: RateQuote(rate: 1400, source: 'BNR', date: '2026-09-29')}),
    );
    when(() => documentRepository.create(any())).thenAnswer((_) async => _savedDocument());
    tester.view.physicalSize = const Size(800, 2400);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(buildApp(DocumentEditorScreen.create(type: DocumentType.invoice)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('document-editor-currency')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('USD (US dollar)').last);
    await tester.pumpAndSettle();

    expect(find.text('1400'), findsOneWidget);
    expect(find.textContaining('National Bank of Rwanda reference rate, 29 Sep 2026.'), findsOneWidget);

    await tester.tap(find.text('Add line'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('line-unit-price-0')), '12.50');
    await tester.pumpAndSettle();

    expect(find.text('USD 12.50'), findsWidgets);
  });
```

(Use `tall_screen.dart`'s helper if the other tests do, and the same line key the existing tests use; check the existing test for the key of the first line and copy it. Add imports for `Currency`, `ExchangeRates`, `RateQuote`.)

- [ ] **Step 2: Run the tests to verify they fail**

Run: `flutter test test/features/documents/presentation`
Expected: FAIL (no `currency_section.dart`).

- [ ] **Step 3: Implement the section**

Create `lib/features/documents/presentation/widgets/currency_section.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/formatting/currency.dart';

/// The currency of a draft and, for a foreign one, the rate that turns it into RWF in reports.
class CurrencySection extends StatefulWidget {
  const CurrencySection({
    super.key,
    required this.currency,
    required this.exchangeRate,
    required this.onCurrencyChanged,
    required this.onRateChanged,
    this.rateHint,
    this.repriceNote = false,
    this.locked = false,
  });

  final Currency currency;
  final double? exchangeRate;
  final String? rateHint;
  final bool repriceNote;
  final bool locked;
  final ValueChanged<Currency> onCurrencyChanged;
  final ValueChanged<double?> onRateChanged;

  @override
  State<CurrencySection> createState() => _CurrencySectionState();
}

// The same rule as the web's rate box: digits, one dot, at most six decimals. A key press that would break it
// is ignored, so the box never holds text that cannot be a rate.
final _rateFormatter = TextInputFormatter.withFunction(
  (oldValue, newValue) => RegExp(r'^[0-9]*\.?[0-9]{0,6}$').hasMatch(newValue.text) ? newValue : oldValue,
);

class _CurrencySectionState extends State<CurrencySection> {
  late final _rateController = TextEditingController(text: _rateText(widget.exchangeRate));

  static String _rateText(double? rate) {
    if (rate == null) return '';
    return rate == rate.roundToDouble() ? rate.toInt().toString() : rate.toString();
  }

  @override
  void didUpdateWidget(covariant CurrencySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A rate that arrives from outside (the bank rate after switching currency) replaces the box,
    // but what the user is typing is never rewritten, so "12." is not turned into "12".
    if (double.tryParse(_rateController.text) != widget.exchangeRate) {
      _rateController.text = _rateText(widget.exchangeRate);
    }
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currency = widget.currency;
    final problem = rateProblem(currency, widget.exchangeRate);
    final notes = <String>[
      if (widget.locked) 'Kept the same as the invoice this document is for.',
      if (widget.repriceNote) 'The prices below are still the numbers you had. Check them in ${currency.code}.',
      if (currency != Currency.rwf && problem == null)
        '${widget.rateHint == null ? '' : '${widget.rateHint} '}'
            'The rate is saved with this document and used to show it in RWF in your reports.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The field only reads initialValue when it is built, so the currency in its key makes it
        // rebuild whenever the currency changes from outside (a reference invoice fixes it).
        KeyedSubtree(
          key: const Key('document-editor-currency'),
          child: DropdownButtonFormField<Currency>(
            key: ValueKey(currency),
            initialValue: currency,
            decoration: const InputDecoration(labelText: 'Currency'),
            items: [
              for (final option in Currency.values)
                DropdownMenuItem(value: option, child: Text('${option.code} (${option.label})')),
            ],
            onChanged: widget.locked
                ? null
                : (value) {
                    if (value != null && value != currency) widget.onCurrencyChanged(value);
                  },
          ),
        ),
        if (currency != Currency.rwf) ...[
          const SizedBox(height: 12),
          TextField(
            key: const Key('document-editor-rate'),
            controller: _rateController,
            enabled: !widget.locked,
            decoration: InputDecoration(labelText: '1 ${currency.code} = RWF', errorText: problem),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [_rateFormatter],
            onChanged: (value) => widget.onRateChanged(double.tryParse(value)),
          ),
        ],
        for (final note in notes) ...[
          const SizedBox(height: 4),
          Text(note, style: textTheme.bodySmall),
        ],
      ],
    );
  }
}
```

Note: the rate box is a `TextField`, so the test that reads `TextField.enabled` finds it. If the analyzer reports `initialValue` on `DropdownButtonFormField` as unavailable in this Flutter version, use `value:` (the record payment screen in this repo already uses `initialValue`, so it should compile as written).

- [ ] **Step 4: Wire the section and decimal fields into the editor**

In `document_editor_screen.dart`:

1. Add imports: `../../../../core/formatting/currency.dart`, `../widgets/currency_section.dart`.
2. In `_DocumentEditorForm.build`, after the language `SegmentedButton` and its following `SizedBox(height: 16)`, insert:

```dart
          CurrencySection(
            currency: state.currency,
            exchangeRate: state.exchangeRate,
            rateHint: state.rateHint,
            repriceNote: state.repriceNote,
            locked: state.currencyLocked,
            onCurrencyChanged: controller.setCurrency,
            onRateChanged: controller.setExchangeRate,
          ),
          const SizedBox(height: 16),
```

3. Pass `currency: state.currency` into every `MoneyText` in the footer (`totals.subtotal`, `totals.taxTotal`, `totals.total`).
4. Pass the currency to the line card: `_LineCard(args: args, line: state.lines[i], lineTotal: totals.lines[i], currency: state.currency)`, add `final Currency currency;` and the constructor parameter.
5. When the user picks a reference invoice, carry its currency: in the picker's `if (reference != null)` block call

```dart
                        controller.setReferencedDocument(
                          DocumentRef(id: reference.id, number: reference.number, type: reference.type),
                          currency: reference.currency,
                          exchangeRate: reference.exchangeRate,
                        );
```

6. In `_LineCardState`:
   - Replace the two price-related controllers' initial text: `_unitPriceController = TextEditingController(text: minorToMajorText(widget.line.unitPrice, widget.currency))` and `_discountValueController` with `text: _discountText(widget.line, widget.currency)` where

```dart
// A flat discount is money and reads in whole units of the currency; a percent discount is a plain number.
String _discountText(DocumentLineDraft line, Currency currency) {
  final value = line.discountValue ?? 0;
  return line.discountType == DiscountType.flat ? minorToMajorText(value.round(), currency) : value.toString();
}
```

   - In `didUpdateWidget`, replace the unit price resync with (parse first, so typing "12." is not clobbered):

```dart
    if (parseMajorAmount(_unitPriceController.text, widget.currency) != widget.line.unitPrice) {
      _unitPriceController.text = minorToMajorText(widget.line.unitPrice, widget.currency);
    }
    if (oldWidget.currency != widget.currency) {
      _discountValueController.text = _discountText(widget.line, widget.currency);
    }
```

   - Price field: `keyboardType: TextInputType.numberWithOptions(decimal: widget.currency.decimals > 0)`, `inputFormatters: [FilteringTextInputFormatter.allow(widget.currency.decimals > 0 ? RegExp(r'[0-9.,]') : RegExp(r'[0-9]'))]`, and

```dart
                    onChanged: (value) {
                      final parsed = parseMajorAmount(value, widget.currency);
                      if (parsed != null) controller.setLineUnitPrice(line.localId, parsed);
                    },
```

   - The flat discount option label: `DropdownMenuItem(value: DiscountType.flat, child: Text('${widget.currency.code} off'))`.
   - Discount `onChanged`: for a flat discount parse in whole units:

```dart
                      onChanged: (value) {
                        final parsed = line.discountType == DiscountType.flat
                            ? parseMajorAmount(value, widget.currency)?.toDouble()
                            : double.tryParse(value);
                        if (parsed != null) controller.setLineDiscount(line.localId, line.discountType, parsed);
                      },
```

   - The line total: `MoneyText(widget.lineTotal.lineTotal, currency: widget.currency)`.

- [ ] **Step 5: Run the tests to verify they pass**

Run: `flutter test test/features/documents && flutter analyze`
Expected: PASS. Existing editor tests that type `5000` into the RWF price box keep passing because RWF has no decimals.

- [ ] **Step 6: Commit**

```bash
git add lib/features/documents/presentation test/features/documents/presentation
git commit -m "feat: choose a currency and type decimal prices in the draft editor"
```

---

### Task 7: Record a payment in the invoice's currency

**Files:**
- Modify: `lib/features/documents/presentation/screens/record_payment_screen.dart`
- Test: `test/features/documents/presentation/screens/record_payment_screen_test.dart`

**Interfaces:**
- Consumes: `Document.currency`, `parseMajorAmount`, `minorToMajorText`, `MoneyText`-free formatting.
- Produces: payments recorded in the smallest unit of the document's currency.

- [ ] **Step 1: Write the failing tests**

Add to `record_payment_screen_test.dart` a `_usdInvoice` (a copy of `_invoice` with `currency: Currency.usd`, `total: 125050`, `amountPaid: 25050`, `subtotal: 125050`, `taxTotal: 0`) and a `buildApp` variant that takes the document (parameterise the existing `buildApp` with `Document document = _invoice`). Add:

```dart
  testWidgets('a foreign invoice defaults the amount to the balance in whole units and labels the currency', (tester) async {
    await tester.pumpWidget(buildApp(document: _usdInvoice));
    router.push('/payment');
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, '1000'), findsOneWidget);
    expect(find.text('Amount (USD)'), findsOneWidget);
  });

  testWidgets('a foreign amount typed with cents is saved in the smallest unit', (tester) async {
    when(() => repository.recordPayment('d1', any())).thenAnswer((_) async => _usdInvoice);
    await tester.pumpWidget(buildApp(document: _usdInvoice));
    router.push('/payment');
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('payment-amount')), '12.50');
    await tester.tap(find.byKey(const Key('payment-submit')));
    await tester.pumpAndSettle();

    final input = verify(() => repository.recordPayment('d1', captureAny())).captured.single as PaymentInput;
    expect(input.amount, 1250);
  });

  testWidgets('an amount that is not a number asks for a valid one and sends nothing', (tester) async {
    await tester.pumpWidget(buildApp(document: _usdInvoice));
    router.push('/payment');
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('payment-amount')), '1.2.3');
    await tester.tap(find.byKey(const Key('payment-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Enter an amount greater than zero'), findsOneWidget);
    verifyNever(() => repository.recordPayment(any(), any()));
  });
```

Match the navigation and helper style of the existing tests in the file; the snippet assumes `router.push('/payment')`, so copy the way an existing test opens the screen if it differs.

- [ ] **Step 2: Run the tests to verify they fail**

Run: `flutter test test/features/documents/presentation/screens/record_payment_screen_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement**

In `record_payment_screen.dart` add `import '../../../../core/formatting/currency.dart';` and:

1. Replace the amount controller initial text:

```dart
  late final _amountController = TextEditingController(
    text: minorToMajorText(widget.document.total - widget.document.amountPaid, widget.document.currency),
  );
```

2. In `_save` replace the parse:

```dart
    final amount = parseMajorAmount(_amountController.text, widget.document.currency);
    if (amount == null || amount <= 0) {
```

3. Replace the amount field:

```dart
            TextField(
              key: const Key('payment-amount'),
              controller: _amountController,
              decoration: InputDecoration(
                labelText: widget.document.currency == Currency.rwf ? 'Amount' : 'Amount (${widget.document.currency.code})',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: widget.document.currency.decimals > 0),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  widget.document.currency.decimals > 0 ? RegExp(r'[0-9.,]') : RegExp(r'[0-9]'),
                ),
              ],
            ),
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `flutter test test/features/documents && flutter analyze`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/documents/presentation/screens/record_payment_screen.dart test/features/documents/presentation/screens/record_payment_screen_test.dart
git commit -m "feat: record a payment in the invoice currency"
```

---

### Task 8: Readable signed-in devices

**Files:**
- Create: `lib/core/platform/device_name.dart`
- Modify: `lib/core/network/api_client.dart`
- Modify: `lib/main.dart`
- Modify: `lib/features/account/domain/session_info.dart` (+ regenerate)
- Modify: `lib/features/account/presentation/screens/sessions_screen.dart`
- Test: `test/core/platform/device_name_test.dart` (create), `test/core/network/api_client_test.dart` (create), `test/features/account/domain/account_models_test.dart`, `test/features/account/data/security_repository_impl_test.dart`, `test/features/account/presentation/screens/sessions_screen_test.dart`

**Interfaces:**
- Consumes: `relativeTime` from `lib/core/formatting/relative_time.dart`.
- Produces: `String sanitizeDeviceName(String raw)`, `Future<String> detectDeviceName({DeviceInfoPlugin? plugin})`, `BaseOptions buildApiOptions({required String deviceName})`, `ApiClient.create({..., required String deviceName})`, `SessionInfo.deviceName` (`String?`) and `SessionInfo.lastUsedAt` (`String?`).

The server names a session from an `X-Billa-Device` header, and otherwise calls this app "Billa app" because its HTTP client says `Dart/...`, which makes two phones look identical. The device identity itself is the year-long `device_id` cookie, which the persistent cookie jar already keeps, so nothing is needed for that.

- [ ] **Step 1: Write the failing tests**

Create `test/core/platform/device_name_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/platform/device_name.dart';

void main() {
  test('keeps a normal name as it is', () {
    expect(sanitizeDeviceName('TECNO CC7, Android 9'), 'TECNO CC7, Android 9');
  });

  test('removes characters an HTTP header cannot carry', () {
    expect(sanitizeDeviceName('Redmi Note 12 \u2013 5G\n'), 'Redmi Note 12  5G');
    expect(sanitizeDeviceName('T\u00e9l\u00e9phone'), 'Tlphone');
  });

  test('falls back to the app name when nothing usable is left', () {
    expect(sanitizeDeviceName(''), 'Billa app');
    expect(sanitizeDeviceName('   '), 'Billa app');
    expect(sanitizeDeviceName('\u2013\u2013'), 'Billa app');
  });

  test('stays within the length the server keeps', () {
    expect(sanitizeDeviceName('A' * 100).length, 60);
  });
}
```

Create `test/core/network/api_client_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/network/api_client.dart';

void main() {
  test('every request names the phone so the devices list can tell phones apart', () {
    final options = buildApiOptions(deviceName: 'TECNO CC7, Android 9');

    expect(options.headers['X-Billa-Device'], 'TECNO CC7, Android 9');
    expect(options.baseUrl, apiBaseUrl);
  });
}
```

In `account_models_test.dart` add:

```dart
  test('SessionInfo reads the device name and last active time, and copes without them', () {
    final named = SessionInfo.fromJson({
      'id': 's1',
      'deviceName': 'TECNO CC7, Android 9',
      'lastUsedAt': '2026-09-30T10:00:00.000Z',
      'createdAt': '2026-09-01T00:00:00.000Z',
      'expiresAt': '2026-10-01T00:00:00.000Z',
      'isCurrent': true,
    });
    final old = SessionInfo.fromJson({
      'id': 's2',
      'createdAt': '2026-09-01T00:00:00.000Z',
      'expiresAt': '2026-10-01T00:00:00.000Z',
      'isCurrent': false,
    });

    expect(named.deviceName, 'TECNO CC7, Android 9');
    expect(named.lastUsedAt, '2026-09-30T10:00:00.000Z');
    expect(old.deviceName, isNull);
    expect(old.lastUsedAt, isNull);
  });
```

Update `sessions_screen_test.dart`: give `_current` `deviceName: 'TECNO CC7, Android 9'` and `_other` `deviceName: 'Chrome on Windows', lastUsedAt` as a fixed old ISO date (for example `'2020-01-01T00:00:00.000Z'`), keep the existing tests, and add:

```dart
  testWidgets('names each device and says when the others were last active', (tester) async {
    when(() => repository.sessions()).thenAnswer((_) async => [_current, _other]);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('TECNO CC7, Android 9'), findsOneWidget);
    expect(find.text('This device'), findsOneWidget);
    expect(find.text('Active now'), findsOneWidget);
    expect(find.text('Chrome on Windows'), findsOneWidget);
    expect(find.textContaining('Last active 2020-01-01'), findsOneWidget);
  });

  testWidgets('a session from a server that sends no device name is still listed', (tester) async {
    const legacy = SessionInfo(
      id: 's3',
      createdAt: '2026-01-02T00:00:00.000Z',
      expiresAt: '2026-02-02T00:00:00.000Z',
      isCurrent: false,
    );
    when(() => repository.sessions()).thenAnswer((_) async => [_current, legacy]);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Unknown device'), findsOneWidget);
    expect(find.byKey(const Key('session-revoke-s3')), findsOneWidget);
  });
```

The first existing test expects the current session title to be `This device`; with the new layout `This device` is a label beside the device name, so it still finds exactly one `This device`.

- [ ] **Step 2: Run the tests to verify they fail**

Run: `flutter test test/core test/features/account`
Expected: FAIL.

- [ ] **Step 3: Implement the device name**

Create `lib/core/platform/device_name.dart`:

```dart
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

const _fallbackName = 'Billa app';
// The server keeps at most this many characters of the name.
const _maxLength = 60;

/// An HTTP header only carries printable ASCII, and one bad character would fail every request, so
/// anything else is dropped rather than risked.
String sanitizeDeviceName(String raw) {
  final cleaned = raw.replaceAll(RegExp(r'[^\x20-\x7E]'), '').trim();
  if (cleaned.isEmpty) return _fallbackName;
  return cleaned.length > _maxLength ? cleaned.substring(0, _maxLength).trim() : cleaned;
}

/// "TECNO CC7, Android 9": what the signed-in devices list shows for this phone. Never throws, because
/// a name is not worth failing a launch for.
Future<String> detectDeviceName({DeviceInfoPlugin? plugin}) async {
  try {
    final info = plugin ?? DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final android = await info.androidInfo;
      return sanitizeDeviceName('${android.model}, Android ${android.version.release}');
    }
    if (Platform.isIOS) {
      final ios = await info.iosInfo;
      return sanitizeDeviceName('${ios.model}, iOS ${ios.systemVersion}');
    }
  } catch (_) {
    // Fall through to the generic name.
  }
  return _fallbackName;
}
```

- [ ] **Step 4: Send the header**

In `lib/core/network/api_client.dart` add:

```dart
BaseOptions buildApiOptions({required String deviceName}) => BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'X-Billa-Device': deviceName},
    );
```

and change `create` to take `required String deviceName` and build `final dio = Dio(buildApiOptions(deviceName: deviceName));`. In `lib/main.dart` add `import 'core/platform/device_name.dart';` (match the file's existing import style). The client needs the name, so it is read just before the parallel launch work; the platform call takes a few milliseconds:

```dart
  final cacheScope = CacheScope();
  final deviceName = await detectDeviceName();
  final (_, apiClient, glassBlur, sessionSnapshot, preferences) = await (
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    ApiClient.create(cache: responseCache, scope: cacheScope, deviceName: deviceName),
    detectGlassBlurSupport(),
    SharedPreferences.getInstance().then((preferences) => SecureSessionSnapshotStore.load(SecureStorage(), preferences)),
    SharedPreferences.getInstance(),
  ).wait;
```

Only the `deviceName` line and the `deviceName:` argument are new; everything else in `main` stays as it is today.

- [ ] **Step 5: Implement the model and screen**

`session_info.dart`: add `String? deviceName,` and `String? lastUsedAt,` before `required String createdAt,`. Regenerate and keep only `session_info.freezed.dart` and `session_info.g.dart`.

`sessions_screen.dart`: add `import '../../../../core/formatting/relative_time.dart';` and replace the `ListTile` for each session with:

```dart
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Row(
                    children: [
                      Flexible(child: Text(session.deviceName ?? 'Unknown device', overflow: TextOverflow.ellipsis)),
                      if (session.isCurrent) ...[
                        const SizedBox(width: 8),
                        Text('This device', style: Theme.of(context).textTheme.labelMedium),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    session.isCurrent
                        ? 'Active now'
                        : 'Last active ${relativeTime(session.lastUsedAt ?? session.createdAt)}'
                            ' · signed in ${_date(session.createdAt)}',
                  ),
                  trailing: session.isCurrent
                      ? null
                      : TextButton(
                          key: Key('session-revoke-${session.id}'),
                          onPressed: _actionInProgress ? null : () => _revoke(session),
                          child: const Text('Sign out'),
                        ),
                ),
```

- [ ] **Step 6: Run the tests to verify they pass**

Run: `flutter test test/core test/features/account && flutter analyze`
Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add lib/core/platform/device_name.dart lib/core/network/api_client.dart lib/main.dart test/core/platform/device_name_test.dart test/core/network/api_client_test.dart
git commit -m "feat: tell the server which phone this is"
git add lib/features/account test/features/account
git commit -m "feat: show each signed-in device by name and last activity"
```

---

### Task 9: Verify, run on the phone, open the PR

**Files:**
- Modify: none in `lib/` or `test/` unless verification finds a defect.

- [ ] **Step 1: Full checks**

```bash
flutter analyze
flutter test
flutter build apk --debug
```

Expected: analyze reports no issues, every test passes, the debug build succeeds. If any earlier task left a stale expectation (for example a `RWF 5000` string), fix it in a separate `test:` commit.

- [ ] **Step 2: Search for leftovers**

```bash
grep -rn "accountant\|Accountant\|read_only_role" lib
grep -rn "\bRWF\b" lib --include=*.dart | grep -v "core/formatting\|currency"
```

Expected: the first prints nothing. The second may list the catalog price label in `item_form_screen.dart` (`Unit price (RWF)`, correct because catalog prices are always RWF), the chart summary in `monthly_bars.dart` (Home figures are converted to RWF by the server), and `item_search_field.dart`. Any other hit is a hard-coded currency to fix.

- [ ] **Step 3: Release build and install on the phone**

```bash
flutter build apk --release --split-per-abi --dart-define=API_BASE_URL=https://billa-api-og7v.onrender.com
```

Then install `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` on the Tecno CC7 with `adb -s 051963303J008197 install -r`. Copy `android/key.properties` from the main checkout into the worktree first (it is git-ignored) or the release will be signed with the debug key and Google sign-in will fail.

- [ ] **Step 4: Device checklist**

Check on the phone with a business account, and report each result:

0. On the web, make three drafts: one in USD, one with an instalment plan (two or three steps), one that repeats monthly. Open each on the phone, change a note, wait for the saved tick, then reopen it on the web. The currency and rate, the plan, and the repeat schedule must all be unchanged. On the plan draft the phone shows the note about instalments set up on the web. Then change a line price on the plan draft: the phone must show the server's reason that the instalments no longer add up, with the way out, and not a bare error.
1. Profile, Security, Signed-in devices lists this phone by name (for example "TECNO CC7, Android 9"), marked "This device" and "Active now"; the web session shows as "Chrome on Windows".
2. Team: no role controls; inviting sends an email and the invite appears as "Member".
3. New invoice: change currency to USD, see the bank rate and its source, type a price of `12.50`, see `USD 12.50` and a `USD` total.
4. Change that draft back to RWF: prices convert back and the rate box disappears.
5. Turn airplane mode on, change currency to EUR: prices stay as typed, the note appears, and saving is blocked until a rate is typed.
6. Finalize a USD invoice, open it: detail, list row, and Payments show USD. Record a payment of `10.50`: the balance updates in USD.
7. Send a USD reminder on WhatsApp: the message names your business, says `USD ...`, has the due date line, and says `View it here`, not `View and pay it here`. Send an RWF reminder from a business with MoMo on: it says `View and pay it here`. For an invoice on a plan with a payment already made, the reminder says which instalment is due now.
8. Payments tab with one RWF and one USD invoice: the summary shows two separate totals.
9. Privacy mode on: the USD amounts show `USD ••••`.

- [ ] **Step 5: Push and open the PR**

```bash
git push -u origin web-parity-r1
gh pr create --base r2e-a11y --title "Bring the app back in step with the web backend" --body-file <(cat <<'EOF'
Retires the accountant role, shows and edits documents in their own currency, and shows signed-in devices by name.

- Team: no role controls; invites send only an email
- Currency: documents, lists, payments, receivables and reminders read in the invoice currency; the draft editor picks a currency, prefills the bank rate and reprices lines
- Devices: the app names the phone in a header and the devices list shows name and last activity

Checked with analyze, the full test suite and a debug build. Device checklist results are in the first comment.
EOF
)
```

The PR body carries no attribution line. Post the device checklist results from Step 4 as the first comment.

- [ ] **Step 6: Update the notes**

Ask the founder to confirm the notes to record, then update the memory notes: the accountant gap in `billa-mobile-known-gaps` is closed by the server change, and Round 1 of the web parity spec is built.
