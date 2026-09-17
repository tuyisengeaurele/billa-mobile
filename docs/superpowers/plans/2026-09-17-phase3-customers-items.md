# Phase 3 Customers and Items Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Customer and Item catalogs — searchable, paginated lists with a "show inactive" filter, create/edit, and deactivate — wired into the router and reachable from the placeholder home screen.

**Architecture:** One shared generic `PaginatedListController<T>` in `core/pagination/` (both lists share the identical page/search/includeInactive mechanics), consumed by two feature modules (`features/customers/`, `features/items/`) each with the usual domain/data/presentation layers behind a repository interface.

**Tech Stack:** `flutter_riverpod` (`AsyncNotifier`, no codegen — consistent with Phases 1–2), `freezed`/`json_serializable` for domain models, `go_router` for the new routes, `mocktail` for repository/controller tests.

**Spec:** [docs/superpowers/specs/2026-09-17-phase3-customers-items-design.md](../specs/2026-09-17-phase3-customers-items-design.md)

## Global Constraints

- Customers: `tin`/`address`/`phone`/`email` are optional-but-not-nullable on the server — an empty field must be **omitted** from the request payload, never sent as `null`.
- Items: `unitPrice` must be a positive integer (>0); `taxRate` defaults to `18`, clamped 0–100; `category` is genuinely nullable server-side, but this phase omits empty category rather than sending an explicit `null` to clear it (a known, deliberate scope cut — clearing an already-set category isn't supported from mobile yet).
- No hard delete anywhere — "delete" in the UI is always phrased as deactivate/reactivate (`PATCH isActive`), never destructive language.
- Items have no `GET /:id` — never introduce a fetch-by-id call for items; edit screens receive the tapped `Item` via `state.extra`.
- List response envelope: `{ results, total, page, pageSize }`. Customer detail/create/update envelope: `{ customer }`. Item create/update envelope: `{ item }`. Payment-stats is a **bare** response (`{ paidInvoiceCount, averageDaysToPay, onTimeRate }`, no wrapper).
- Comments explain *why*, never *what*; no AI-narration comments; conventional-commit messages, no trailing period.
- Every task ends with `flutter analyze` clean and `flutter test` passing for files touched so far.

---

### Task 1: Shared pagination core

**Files:**
- Create: `lib/core/pagination/paginated_result.dart`
- Create: `lib/core/pagination/paginated_state.dart`
- Create: `lib/core/pagination/paginated_list_controller.dart`
- Test: `test/core/pagination/paginated_list_controller_test.dart`

**Interfaces:**
- Produces: `class PaginatedResult<T> { final List<T> results; final int total; final int page; final int pageSize; }`, `class PaginatedState<T> { final List<T> items; final bool hasMore; final bool isLoadingMore; PaginatedState<T> copyWith(...); }`, `abstract class PaginatedListController<T> extends AsyncNotifier<PaginatedState<T>> { Future<PaginatedResult<T>> fetchPage({required String search, required bool includeInactive, required int page}); void setSearch(String value); Future<void> setIncludeInactive(bool value); Future<void> loadMore(); Future<void> refresh(); static const pageSize = 20; }`.

- [ ] **Step 1: Write `PaginatedResult` and `PaginatedState`**

```dart
// lib/core/pagination/paginated_result.dart
class PaginatedResult<T> {
  const PaginatedResult({required this.results, required this.total, required this.page, required this.pageSize});

  final List<T> results;
  final int total;
  final int page;
  final int pageSize;
}
```

```dart
// lib/core/pagination/paginated_state.dart
class PaginatedState<T> {
  const PaginatedState({required this.items, required this.hasMore, required this.isLoadingMore});

  final List<T> items;
  final bool hasMore;
  final bool isLoadingMore;

  PaginatedState<T> copyWith({List<T>? items, bool? hasMore, bool? isLoadingMore}) {
    return PaginatedState<T>(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
```

- [ ] **Step 2: Write the failing controller test**

```dart
// test/core/pagination/paginated_list_controller_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/pagination/paginated_list_controller.dart';
import 'package:billa_mobile/core/pagination/paginated_result.dart';

class _Item {
  const _Item(this.id);
  final int id;
}

typedef _Fetch = Future<PaginatedResult<_Item>> Function({
  required String search,
  required bool includeInactive,
  required int page,
});

class _FakeController extends PaginatedListController<_Item> {
  _FakeController(this._fetch);
  final _Fetch _fetch;

  @override
  Future<PaginatedResult<_Item>> fetchPage({
    required String search,
    required bool includeInactive,
    required int page,
  }) {
    return _fetch(search: search, includeInactive: includeInactive, page: page);
  }
}

final _testProvider = AsyncNotifierProvider<_FakeController, PaginatedState<_Item>>(
  () => throw UnimplementedError('override in each test'),
);

void main() {
  test('build() fetches page 1 and sets hasMore when more results exist', () async {
    final calls = <Map<String, Object?>>[];
    final container = ProviderContainer(overrides: [
      _testProvider.overrideWith(() => _FakeController(({required search, required includeInactive, required page}) async {
            calls.add({'search': search, 'includeInactive': includeInactive, 'page': page});
            return PaginatedResult(results: const [_Item(1), _Item(2)], total: 5, page: page, pageSize: 2);
          })),
    ]);
    addTearDown(container.dispose);

    final state = await container.read(_testProvider.future);

    expect(state.items.map((i) => i.id), [1, 2]);
    expect(state.hasMore, isTrue);
    expect(calls, [{'search': '', 'includeInactive': false, 'page': 1}]);
  });

  test('loadMore appends the next page and updates hasMore', () async {
    final container = ProviderContainer(overrides: [
      _testProvider.overrideWith(() => _FakeController(({required search, required includeInactive, required page}) async {
            if (page == 1) {
              return const PaginatedResult(results: [_Item(1), _Item(2)], total: 3, page: 1, pageSize: 2);
            }
            return const PaginatedResult(results: [_Item(3)], total: 3, page: 2, pageSize: 2);
          })),
    ]);
    addTearDown(container.dispose);
    await container.read(_testProvider.future);

    await container.read(_testProvider.notifier).loadMore();

    final state = container.read(_testProvider).value!;
    expect(state.items.map((i) => i.id), [1, 2, 3]);
    expect(state.hasMore, isFalse);
  });

  test('setSearch debounces and fetches once with the final term', () async {
    final calls = <String>[];
    final container = ProviderContainer(overrides: [
      _testProvider.overrideWith(() => _FakeController(({required search, required includeInactive, required page}) async {
            calls.add(search);
            return const PaginatedResult(results: <_Item>[], total: 0, page: 1, pageSize: 20);
          })),
    ]);
    addTearDown(container.dispose);
    await container.read(_testProvider.future);
    calls.clear();

    final notifier = container.read(_testProvider.notifier);
    notifier.setSearch('a');
    notifier.setSearch('ac');
    notifier.setSearch('acme');
    await Future<void>.delayed(const Duration(milliseconds: 400));

    expect(calls, ['acme']);
  });

  test('setIncludeInactive refetches immediately from page 1', () async {
    final calls = <bool>[];
    final container = ProviderContainer(overrides: [
      _testProvider.overrideWith(() => _FakeController(({required search, required includeInactive, required page}) async {
            calls.add(includeInactive);
            return const PaginatedResult(results: <_Item>[], total: 0, page: 1, pageSize: 20);
          })),
    ]);
    addTearDown(container.dispose);
    await container.read(_testProvider.future);
    calls.clear();

    await container.read(_testProvider.notifier).setIncludeInactive(true);

    expect(calls, [true]);
  });
}
```

- [ ] **Step 3: Run it to confirm it fails**

```bash
flutter test test/core/pagination/paginated_list_controller_test.dart
```

Expected: FAIL — `paginated_list_controller.dart` doesn't exist yet.

- [ ] **Step 4: Implement `PaginatedListController`**

```dart
// lib/core/pagination/paginated_list_controller.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'paginated_result.dart';
import 'paginated_state.dart';

abstract class PaginatedListController<T> extends AsyncNotifier<PaginatedState<T>> {
  static const pageSize = 20;
  static const _searchDebounce = Duration(milliseconds: 300);

  String _search = '';
  bool _includeInactive = false;
  int _page = 1;
  Timer? _debounceTimer;

  Future<PaginatedResult<T>> fetchPage({
    required String search,
    required bool includeInactive,
    required int page,
  });

  @override
  Future<PaginatedState<T>> build() async {
    ref.onDispose(() => _debounceTimer?.cancel());
    return _fetchFresh();
  }

  Future<PaginatedState<T>> _fetchFresh() async {
    _page = 1;
    final result = await fetchPage(search: _search, includeInactive: _includeInactive, page: _page);
    return PaginatedState<T>(
      items: result.results,
      hasMore: result.results.length < result.total,
      isLoadingMore: false,
    );
  }

  void setSearch(String value) {
    _debounceTimer?.cancel();
    // Debounced so a fast typist doesn't fire one request per keystroke.
    _debounceTimer = Timer(_searchDebounce, () {
      if (!ref.mounted) return;
      _search = value;
      state = const AsyncLoading();
      _fetchFresh().then((next) {
        if (ref.mounted) state = AsyncData(next);
      });
    });
  }

  Future<void> setIncludeInactive(bool value) async {
    _includeInactive = value;
    state = const AsyncLoading();
    state = AsyncData(await _fetchFresh());
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    _page += 1;
    final result = await fetchPage(search: _search, includeInactive: _includeInactive, page: _page);
    final items = [...current.items, ...result.results];
    state = AsyncData(PaginatedState<T>(
      items: items,
      hasMore: items.length < result.total,
      isLoadingMore: false,
    ));
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _fetchFresh());
  }
}
```

- [ ] **Step 5: Run it to confirm it passes**

```bash
flutter test test/core/pagination/paginated_list_controller_test.dart
```

Expected: PASS (4 tests).

- [ ] **Step 6: Commit**

```bash
git add lib/core/pagination/ test/core/pagination/
git commit -m "feat: add generic paginated list controller"
```

---

### Task 2: Customer domain models

**Files:**
- Create: `lib/features/customers/domain/customer.dart`
- Create: `lib/features/customers/domain/customer_payment_stats.dart`
- Test: `test/features/customers/domain/customer_test.dart`

**Interfaces:**
- Produces: `Customer({required String id, required String name, String? tin, String? address, String? phone, String? email, required bool isActive, required String createdAt})`, `Customer.fromJson(...)`; `CustomerPaymentStats({required int paidInvoiceCount, int? averageDaysToPay, int? onTimeRate})`, `CustomerPaymentStats.fromJson(...)`.

- [ ] **Step 1: Write `Customer`**

```dart
// lib/features/customers/domain/customer.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer.freezed.dart';
part 'customer.g.dart';

@freezed
class Customer with _$Customer {
  const factory Customer({
    required String id,
    required String name,
    String? tin,
    String? address,
    String? phone,
    String? email,
    required bool isActive,
    required String createdAt,
  }) = _Customer;

  factory Customer.fromJson(Map<String, dynamic> json) => _$CustomerFromJson(json);
}
```

- [ ] **Step 2: Write `CustomerPaymentStats`**

```dart
// lib/features/customers/domain/customer_payment_stats.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_payment_stats.freezed.dart';
part 'customer_payment_stats.g.dart';

@freezed
class CustomerPaymentStats with _$CustomerPaymentStats {
  const factory CustomerPaymentStats({
    required int paidInvoiceCount,
    int? averageDaysToPay,
    int? onTimeRate,
  }) = _CustomerPaymentStats;

  factory CustomerPaymentStats.fromJson(Map<String, dynamic> json) => _$CustomerPaymentStatsFromJson(json);
}
```

- [ ] **Step 3: Run code generation**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: generates the `.freezed.dart`/`.g.dart` parts for both files with no errors.

- [ ] **Step 4: Write the failing test**

```dart
// test/features/customers/domain/customer_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/customers/domain/customer.dart';
import 'package:billa_mobile/features/customers/domain/customer_payment_stats.dart';

void main() {
  test('Customer.fromJson maps optional fields', () {
    final customer = Customer.fromJson({
      'id': 'c1',
      'name': 'Acme',
      'tin': null,
      'address': null,
      'phone': null,
      'email': null,
      'isActive': true,
      'createdAt': '2026-01-01T00:00:00.000Z',
    });

    expect(customer.name, 'Acme');
    expect(customer.tin, isNull);
    expect(customer.isActive, isTrue);
  });

  test('CustomerPaymentStats.fromJson handles a customer with no paid invoices yet', () {
    final stats = CustomerPaymentStats.fromJson({
      'paidInvoiceCount': 0,
      'averageDaysToPay': null,
      'onTimeRate': null,
    });

    expect(stats.paidInvoiceCount, 0);
    expect(stats.averageDaysToPay, isNull);
    expect(stats.onTimeRate, isNull);
  });
}
```

- [ ] **Step 5: Run it to confirm it passes**

```bash
flutter test test/features/customers/domain/customer_test.dart
```

Expected: PASS (2 tests). If it fails on missing generated files, re-run Step 3.

- [ ] **Step 6: Commit**

```bash
git add lib/features/customers/domain/ test/features/customers/domain/
git commit -m "feat: add customer and customer payment stats domain models"
```

---

### Task 3: `CustomerRepository`

**Files:**
- Create: `lib/features/customers/domain/customer_repository.dart`
- Create: `lib/features/customers/data/customer_repository_impl.dart`
- Test: `test/features/customers/data/customer_repository_impl_test.dart`

**Interfaces:**
- Consumes: `Customer`, `CustomerPaymentStats` (Task 2), `PaginatedResult` (Task 1), `Dio`.
- Produces: `abstract class CustomerRepository { Future<PaginatedResult<Customer>> list({String? search, bool includeInactive, int page, int pageSize}); Future<Customer> get(String id); Future<CustomerPaymentStats> paymentStats(String id); Future<Customer> create({required String name, String? tin, String? address, String? phone, String? email}); Future<Customer> update(String id, {String? name, String? tin, String? address, String? phone, String? email, bool? isActive}); }`.

- [ ] **Step 1: Write the interface**

```dart
// lib/features/customers/domain/customer_repository.dart
import '../../../core/pagination/paginated_result.dart';
import 'customer.dart';
import 'customer_payment_stats.dart';

abstract class CustomerRepository {
  Future<PaginatedResult<Customer>> list({
    String? search,
    bool includeInactive = false,
    int page = 1,
    int pageSize = 20,
  });

  Future<Customer> get(String id);
  Future<CustomerPaymentStats> paymentStats(String id);

  Future<Customer> create({
    required String name,
    String? tin,
    String? address,
    String? phone,
    String? email,
  });

  Future<Customer> update(
    String id, {
    String? name,
    String? tin,
    String? address,
    String? phone,
    String? email,
    bool? isActive,
  });
}
```

- [ ] **Step 2: Write the failing test**

```dart
// test/features/customers/data/customer_repository_impl_test.dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/customers/data/customer_repository_impl.dart';

class _MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _response(int statusCode, Map<String, dynamic> data, RequestOptions options) {
  return Response(statusCode: statusCode, data: data, requestOptions: options);
}

void main() {
  late _MockDio dio;
  late CustomerRepositoryImpl repository;

  setUp(() {
    dio = _MockDio();
    repository = CustomerRepositoryImpl(dio);
  });

  test('list sends search/includeInactive/page/pageSize and maps results', () async {
    final options = RequestOptions(path: '/customers');
    when(() => dio.get<Map<String, dynamic>>('/customers', queryParameters: {
          'search': 'acme',
          'includeInactive': 'false',
          'page': 1,
          'pageSize': 20,
        })).thenAnswer((_) async => _response(200, {
          'results': [
            {
              'id': 'c1',
              'name': 'Acme',
              'tin': null,
              'address': null,
              'phone': null,
              'email': null,
              'isActive': true,
              'createdAt': '2026-01-01T00:00:00.000Z',
            },
          ],
          'total': 1,
          'page': 1,
          'pageSize': 20,
        }, options));

    final result = await repository.list(search: 'acme');

    expect(result.results.single.name, 'Acme');
    expect(result.total, 1);
  });

  test('list omits the search param when null', () async {
    final options = RequestOptions(path: '/customers');
    when(() => dio.get<Map<String, dynamic>>('/customers', queryParameters: {
          'includeInactive': 'false',
          'page': 1,
          'pageSize': 20,
        })).thenAnswer((_) async => _response(200, {'results': [], 'total': 0, 'page': 1, 'pageSize': 20}, options));

    final result = await repository.list();

    expect(result.results, isEmpty);
  });

  test('create omits null optional fields from the payload', () async {
    final options = RequestOptions(path: '/customers');
    when(() => dio.post<Map<String, dynamic>>('/customers', data: {'name': 'Acme'})).thenAnswer(
      (_) async => _response(201, {
        'customer': {
          'id': 'c1',
          'name': 'Acme',
          'tin': null,
          'address': null,
          'phone': null,
          'email': null,
          'isActive': true,
          'createdAt': '2026-01-01T00:00:00.000Z',
        },
      }, options),
    );

    final customer = await repository.create(name: 'Acme');

    expect(customer.id, 'c1');
  });

  test('update sends isActive: false to deactivate', () async {
    final options = RequestOptions(path: '/customers/c1');
    when(() => dio.patch<Map<String, dynamic>>('/customers/c1', data: {'isActive': false})).thenAnswer(
      (_) async => _response(200, {
        'customer': {
          'id': 'c1',
          'name': 'Acme',
          'tin': null,
          'address': null,
          'phone': null,
          'email': null,
          'isActive': false,
          'createdAt': '2026-01-01T00:00:00.000Z',
        },
      }, options),
    );

    final customer = await repository.update('c1', isActive: false);

    expect(customer.isActive, isFalse);
  });

  test('paymentStats maps the bare response with no envelope', () async {
    final options = RequestOptions(path: '/customers/c1/payment-stats');
    when(() => dio.get<Map<String, dynamic>>('/customers/c1/payment-stats')).thenAnswer(
      (_) async => _response(200, {'paidInvoiceCount': 3, 'averageDaysToPay': -2, 'onTimeRate': 67}, options),
    );

    final stats = await repository.paymentStats('c1');

    expect(stats.paidInvoiceCount, 3);
    expect(stats.averageDaysToPay, -2);
  });
}
```

- [ ] **Step 3: Run it to confirm it fails**

```bash
flutter test test/features/customers/data/customer_repository_impl_test.dart
```

Expected: FAIL — `customer_repository_impl.dart` doesn't exist yet.

- [ ] **Step 4: Implement `CustomerRepositoryImpl`**

```dart
// lib/features/customers/data/customer_repository_impl.dart
import 'package:dio/dio.dart';
import '../../../core/pagination/paginated_result.dart';
import '../domain/customer.dart';
import '../domain/customer_payment_stats.dart';
import '../domain/customer_repository.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  CustomerRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<PaginatedResult<Customer>> list({
    String? search,
    bool includeInactive = false,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>('/customers', queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
      'includeInactive': includeInactive.toString(),
      'page': page,
      'pageSize': pageSize,
    });
    final data = response.data!;
    final results = (data['results'] as List)
        .map((json) => Customer.fromJson(json as Map<String, dynamic>))
        .toList();
    return PaginatedResult(
      results: results,
      total: data['total'] as int,
      page: data['page'] as int,
      pageSize: data['pageSize'] as int,
    );
  }

  @override
  Future<Customer> get(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/customers/$id');
    return Customer.fromJson(response.data!['customer'] as Map<String, dynamic>);
  }

  @override
  Future<CustomerPaymentStats> paymentStats(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/customers/$id/payment-stats');
    return CustomerPaymentStats.fromJson(response.data!);
  }

  @override
  Future<Customer> create({
    required String name,
    String? tin,
    String? address,
    String? phone,
    String? email,
  }) async {
    final data = <String, dynamic>{'name': name};
    if (tin != null) data['tin'] = tin;
    if (address != null) data['address'] = address;
    if (phone != null) data['phone'] = phone;
    if (email != null) data['email'] = email;

    final response = await _dio.post<Map<String, dynamic>>('/customers', data: data);
    return Customer.fromJson(response.data!['customer'] as Map<String, dynamic>);
  }

  @override
  Future<Customer> update(
    String id, {
    String? name,
    String? tin,
    String? address,
    String? phone,
    String? email,
    bool? isActive,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (tin != null) data['tin'] = tin;
    if (address != null) data['address'] = address;
    if (phone != null) data['phone'] = phone;
    if (email != null) data['email'] = email;
    if (isActive != null) data['isActive'] = isActive;

    final response = await _dio.patch<Map<String, dynamic>>('/customers/$id', data: data);
    return Customer.fromJson(response.data!['customer'] as Map<String, dynamic>);
  }
}
```

- [ ] **Step 5: Run it to confirm it passes**

```bash
flutter test test/features/customers/data/customer_repository_impl_test.dart
```

Expected: PASS (5 tests).

- [ ] **Step 6: Commit**

```bash
git add lib/features/customers/domain/customer_repository.dart lib/features/customers/data/ test/features/customers/data/
git commit -m "feat: add customer repository"
```

---

### Task 4: Item domain model

**Files:**
- Create: `lib/features/items/domain/item.dart`
- Test: `test/features/items/domain/item_test.dart`

**Interfaces:**
- Produces: `Item({required String id, required String description, required int unitPrice, required String unit, required double taxRate, String? category, required bool isActive})`, `Item.fromJson(...)`.

- [ ] **Step 1: Write `Item`**

```dart
// lib/features/items/domain/item.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'item.freezed.dart';
part 'item.g.dart';

@freezed
class Item with _$Item {
  const factory Item({
    required String id,
    required String description,
    required int unitPrice,
    required String unit,
    required double taxRate,
    String? category,
    required bool isActive,
  }) = _Item;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
}
```

- [ ] **Step 2: Run code generation**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 3: Write the failing test**

```dart
// test/features/items/domain/item_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/items/domain/item.dart';

void main() {
  test('Item.fromJson handles an integer-valued taxRate (JSON numbers can decode as int)', () {
    final item = Item.fromJson({
      'id': 'i1',
      'description': 'Exported goods',
      'unitPrice': 5000,
      'unit': 'piece',
      'taxRate': 0,
      'category': null,
      'isActive': true,
    });

    expect(item.taxRate, 0.0);
    expect(item.category, isNull);
  });

  test('Item.fromJson handles a decimal taxRate and a category', () {
    final item = Item.fromJson({
      'id': 'i2',
      'description': 'Cement',
      'unitPrice': 13000,
      'unit': 'bag',
      'taxRate': 18.0,
      'category': 'Materials',
      'isActive': true,
    });

    expect(item.taxRate, 18.0);
    expect(item.category, 'Materials');
  });
}
```

- [ ] **Step 4: Run it to confirm it passes**

```bash
flutter test test/features/items/domain/item_test.dart
```

Expected: PASS (2 tests). If it fails on missing generated files, re-run Step 2.

- [ ] **Step 5: Commit**

```bash
git add lib/features/items/domain/item.dart lib/features/items/domain/item.freezed.dart lib/features/items/domain/item.g.dart test/features/items/domain/
git commit -m "feat: add item domain model"
```

---

### Task 5: `ItemRepository`

**Files:**
- Create: `lib/features/items/domain/item_repository.dart`
- Create: `lib/features/items/data/item_repository_impl.dart`
- Test: `test/features/items/data/item_repository_impl_test.dart`

**Interfaces:**
- Consumes: `Item` (Task 4), `PaginatedResult` (Task 1), `Dio`.
- Produces: `abstract class ItemRepository { Future<PaginatedResult<Item>> list({String? search, String? category, bool includeInactive, int page, int pageSize}); Future<Item> create({required String description, required int unitPrice, required String unit, double taxRate, String? category}); Future<Item> update(String id, {String? description, int? unitPrice, String? unit, double? taxRate, String? category, bool? isActive}); }`.

- [ ] **Step 1: Write the interface**

```dart
// lib/features/items/domain/item_repository.dart
import '../../../core/pagination/paginated_result.dart';
import 'item.dart';

abstract class ItemRepository {
  Future<PaginatedResult<Item>> list({
    String? search,
    String? category,
    bool includeInactive = false,
    int page = 1,
    int pageSize = 20,
  });

  Future<Item> create({
    required String description,
    required int unitPrice,
    required String unit,
    double taxRate = 18,
    String? category,
  });

  Future<Item> update(
    String id, {
    String? description,
    int? unitPrice,
    String? unit,
    double? taxRate,
    String? category,
    bool? isActive,
  });
}
```

- [ ] **Step 2: Write the failing test**

```dart
// test/features/items/data/item_repository_impl_test.dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/items/data/item_repository_impl.dart';

class _MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _response(int statusCode, Map<String, dynamic> data, RequestOptions options) {
  return Response(statusCode: statusCode, data: data, requestOptions: options);
}

void main() {
  late _MockDio dio;
  late ItemRepositoryImpl repository;

  setUp(() {
    dio = _MockDio();
    repository = ItemRepositoryImpl(dio);
  });

  test('list sends search/category/includeInactive/page/pageSize and maps results', () async {
    final options = RequestOptions(path: '/items');
    when(() => dio.get<Map<String, dynamic>>('/items', queryParameters: {
          'search': 'cement',
          'category': 'Materials',
          'includeInactive': 'false',
          'page': 1,
          'pageSize': 20,
        })).thenAnswer((_) async => _response(200, {
          'results': [
            {'id': 'i1', 'description': 'Cement', 'unitPrice': 13000, 'unit': 'bag', 'taxRate': 18.0, 'category': 'Materials', 'isActive': true},
          ],
          'total': 1,
          'page': 1,
          'pageSize': 20,
        }, options));

    final result = await repository.list(search: 'cement', category: 'Materials');

    expect(result.results.single.description, 'Cement');
  });

  test('create sends the default taxRate and omits a null category', () async {
    final options = RequestOptions(path: '/items');
    when(() => dio.post<Map<String, dynamic>>('/items', data: {
          'description': 'Cement',
          'unitPrice': 13000,
          'unit': 'bag',
          'taxRate': 18.0,
        })).thenAnswer(
      (_) async => _response(201, {
        'item': {'id': 'i1', 'description': 'Cement', 'unitPrice': 13000, 'unit': 'bag', 'taxRate': 18.0, 'category': null, 'isActive': true},
      }, options),
    );

    final item = await repository.create(description: 'Cement', unitPrice: 13000, unit: 'bag');

    expect(item.id, 'i1');
  });

  test('update sends isActive: false to deactivate', () async {
    final options = RequestOptions(path: '/items/i1');
    when(() => dio.patch<Map<String, dynamic>>('/items/i1', data: {'isActive': false})).thenAnswer(
      (_) async => _response(200, {
        'item': {'id': 'i1', 'description': 'Cement', 'unitPrice': 13000, 'unit': 'bag', 'taxRate': 18.0, 'category': null, 'isActive': false},
      }, options),
    );

    final item = await repository.update('i1', isActive: false);

    expect(item.isActive, isFalse);
  });
}
```

- [ ] **Step 3: Run it to confirm it fails**

```bash
flutter test test/features/items/data/item_repository_impl_test.dart
```

Expected: FAIL — `item_repository_impl.dart` doesn't exist yet.

- [ ] **Step 4: Implement `ItemRepositoryImpl`**

```dart
// lib/features/items/data/item_repository_impl.dart
import 'package:dio/dio.dart';
import '../../../core/pagination/paginated_result.dart';
import '../domain/item.dart';
import '../domain/item_repository.dart';

class ItemRepositoryImpl implements ItemRepository {
  ItemRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<PaginatedResult<Item>> list({
    String? search,
    String? category,
    bool includeInactive = false,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>('/items', queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (category != null && category.isNotEmpty) 'category': category,
      'includeInactive': includeInactive.toString(),
      'page': page,
      'pageSize': pageSize,
    });
    final data = response.data!;
    final results = (data['results'] as List)
        .map((json) => Item.fromJson(json as Map<String, dynamic>))
        .toList();
    return PaginatedResult(
      results: results,
      total: data['total'] as int,
      page: data['page'] as int,
      pageSize: data['pageSize'] as int,
    );
  }

  @override
  Future<Item> create({
    required String description,
    required int unitPrice,
    required String unit,
    double taxRate = 18,
    String? category,
  }) async {
    final data = <String, dynamic>{
      'description': description,
      'unitPrice': unitPrice,
      'unit': unit,
      'taxRate': taxRate,
    };
    // Deliberately omitted rather than sent as null — see the plan's global
    // constraints for why clearing an already-set category isn't supported yet.
    if (category != null) data['category'] = category;

    final response = await _dio.post<Map<String, dynamic>>('/items', data: data);
    return Item.fromJson(response.data!['item'] as Map<String, dynamic>);
  }

  @override
  Future<Item> update(
    String id, {
    String? description,
    int? unitPrice,
    String? unit,
    double? taxRate,
    String? category,
    bool? isActive,
  }) async {
    final data = <String, dynamic>{};
    if (description != null) data['description'] = description;
    if (unitPrice != null) data['unitPrice'] = unitPrice;
    if (unit != null) data['unit'] = unit;
    if (taxRate != null) data['taxRate'] = taxRate;
    if (category != null) data['category'] = category;
    if (isActive != null) data['isActive'] = isActive;

    final response = await _dio.patch<Map<String, dynamic>>('/items/$id', data: data);
    return Item.fromJson(response.data!['item'] as Map<String, dynamic>);
  }
}
```

- [ ] **Step 5: Run it to confirm it passes**

```bash
flutter test test/features/items/data/item_repository_impl_test.dart
```

Expected: PASS (3 tests).

- [ ] **Step 6: Commit**

```bash
git add lib/features/items/domain/item_repository.dart lib/features/items/data/ test/features/items/data/
git commit -m "feat: add item repository"
```

---

### Task 6: Customer repository provider and list controller

**Files:**
- Create: `lib/features/customers/presentation/providers/customer_repository_provider.dart`
- Create: `lib/features/customers/presentation/providers/customer_list_controller.dart`
- Test: `test/features/customers/presentation/providers/customer_list_controller_test.dart`

**Interfaces:**
- Consumes: `CustomerRepository`/`CustomerRepositoryImpl` (Task 3), `apiClientProvider` (Phase 1/2), `PaginatedListController` (Task 1).
- Produces: `customerRepositoryProvider` (`Provider<CustomerRepository>`), `customerListControllerProvider` (`AsyncNotifierProvider<CustomerListController, PaginatedState<Customer>>`).

- [ ] **Step 1: Write the repository provider**

```dart
// lib/features/customers/presentation/providers/customer_repository_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/customer_repository_impl.dart';
import '../../domain/customer_repository.dart';
import '../../../../core/network/api_client_provider.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepositoryImpl(ref.watch(apiClientProvider).dio);
});
```

- [ ] **Step 2: Write the failing test**

```dart
// test/features/customers/presentation/providers/customer_list_controller_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/core/pagination/paginated_result.dart';
import 'package:billa_mobile/features/customers/domain/customer.dart';
import 'package:billa_mobile/features/customers/domain/customer_repository.dart';
import 'package:billa_mobile/features/customers/presentation/providers/customer_list_controller.dart';
import 'package:billa_mobile/features/customers/presentation/providers/customer_repository_provider.dart';

class _MockCustomerRepository extends Mock implements CustomerRepository {}

void main() {
  test('fetchPage delegates to CustomerRepository.list with the given params', () async {
    final repository = _MockCustomerRepository();
    when(() => repository.list(search: 'acme', includeInactive: false, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(
        results: [Customer(id: 'c1', name: 'Acme', isActive: true, createdAt: '2026-01-01T00:00:00.000Z')],
        total: 1,
        page: 1,
        pageSize: 20,
      ),
    );
    final container = ProviderContainer(overrides: [
      customerRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);

    final notifier = container.read(customerListControllerProvider.notifier);
    await container.read(customerListControllerProvider.future);
    notifier.setSearch('acme');
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final state = container.read(customerListControllerProvider).value!;
    expect(state.items.single.name, 'Acme');
  });
}
```

- [ ] **Step 3: Run it to confirm it fails**

```bash
flutter test test/features/customers/presentation/providers/customer_list_controller_test.dart
```

Expected: FAIL — `customer_list_controller.dart` doesn't exist yet.

- [ ] **Step 4: Implement `CustomerListController`**

```dart
// lib/features/customers/presentation/providers/customer_list_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/pagination/paginated_list_controller.dart';
import '../../../../core/pagination/paginated_result.dart';
import '../../../../core/pagination/paginated_state.dart';
import '../../domain/customer.dart';
import 'customer_repository_provider.dart';

class CustomerListController extends PaginatedListController<Customer> {
  @override
  Future<PaginatedResult<Customer>> fetchPage({
    required String search,
    required bool includeInactive,
    required int page,
  }) {
    return ref.read(customerRepositoryProvider).list(
          search: search.isEmpty ? null : search,
          includeInactive: includeInactive,
          page: page,
          pageSize: PaginatedListController.pageSize,
        );
  }
}

final customerListControllerProvider =
    AsyncNotifierProvider<CustomerListController, PaginatedState<Customer>>(CustomerListController.new);
```

- [ ] **Step 5: Run it to confirm it passes**

```bash
flutter test test/features/customers/presentation/providers/customer_list_controller_test.dart
```

Expected: PASS (1 test).

- [ ] **Step 6: Commit**

```bash
git add lib/features/customers/presentation/providers/ test/features/customers/presentation/providers/
git commit -m "feat: add customer list controller"
```

---

### Task 7: Item repository provider and list controller

**Files:**
- Create: `lib/features/items/presentation/providers/item_repository_provider.dart`
- Create: `lib/features/items/presentation/providers/item_list_controller.dart`
- Test: `test/features/items/presentation/providers/item_list_controller_test.dart`

**Interfaces:**
- Consumes: `ItemRepository`/`ItemRepositoryImpl` (Task 5), `apiClientProvider`, `PaginatedListController` (Task 1).
- Produces: `itemRepositoryProvider` (`Provider<ItemRepository>`), `itemListControllerProvider` (`AsyncNotifierProvider<ItemListController, PaginatedState<Item>>`), `ItemListController.setCategory(String?)`.

- [ ] **Step 1: Write the repository provider**

```dart
// lib/features/items/presentation/providers/item_repository_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/item_repository_impl.dart';
import '../../domain/item_repository.dart';
import '../../../../core/network/api_client_provider.dart';

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepositoryImpl(ref.watch(apiClientProvider).dio);
});
```

- [ ] **Step 2: Write the failing test**

```dart
// test/features/items/presentation/providers/item_list_controller_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/core/pagination/paginated_result.dart';
import 'package:billa_mobile/features/items/domain/item.dart';
import 'package:billa_mobile/features/items/domain/item_repository.dart';
import 'package:billa_mobile/features/items/presentation/providers/item_list_controller.dart';
import 'package:billa_mobile/features/items/presentation/providers/item_repository_provider.dart';

class _MockItemRepository extends Mock implements ItemRepository {}

void main() {
  test('setCategory refetches from page 1 with the given category', () async {
    final repository = _MockItemRepository();
    when(() => repository.list(search: null, category: null, includeInactive: false, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: <Item>[], total: 0, page: 1, pageSize: 20),
    );
    when(() => repository.list(search: null, category: 'Materials', includeInactive: false, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(
        results: [Item(id: 'i1', description: 'Cement', unitPrice: 13000, unit: 'bag', taxRate: 18, category: 'Materials', isActive: true)],
        total: 1,
        page: 1,
        pageSize: 20,
      ),
    );
    final container = ProviderContainer(overrides: [
      itemRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);
    await container.read(itemListControllerProvider.future);

    await container.read(itemListControllerProvider.notifier).setCategory('Materials');

    final state = container.read(itemListControllerProvider).value!;
    expect(state.items.single.description, 'Cement');
  });
}
```

- [ ] **Step 3: Run it to confirm it fails**

```bash
flutter test test/features/items/presentation/providers/item_list_controller_test.dart
```

Expected: FAIL — `item_list_controller.dart` doesn't exist yet.

- [ ] **Step 4: Implement `ItemListController`**

```dart
// lib/features/items/presentation/providers/item_list_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/pagination/paginated_list_controller.dart';
import '../../../../core/pagination/paginated_result.dart';
import '../../../../core/pagination/paginated_state.dart';
import '../../domain/item.dart';
import 'item_repository_provider.dart';

class ItemListController extends PaginatedListController<Item> {
  String? _category;

  Future<void> setCategory(String? category) {
    _category = category;
    return refresh();
  }

  @override
  Future<PaginatedResult<Item>> fetchPage({
    required String search,
    required bool includeInactive,
    required int page,
  }) {
    return ref.read(itemRepositoryProvider).list(
          search: search.isEmpty ? null : search,
          category: _category,
          includeInactive: includeInactive,
          page: page,
          pageSize: PaginatedListController.pageSize,
        );
  }
}

final itemListControllerProvider =
    AsyncNotifierProvider<ItemListController, PaginatedState<Item>>(ItemListController.new);
```

- [ ] **Step 5: Run it to confirm it passes**

```bash
flutter test test/features/items/presentation/providers/item_list_controller_test.dart
```

Expected: PASS (1 test).

- [ ] **Step 6: Commit**

```bash
git add lib/features/items/presentation/providers/ test/features/items/presentation/providers/
git commit -m "feat: add item list controller"
```

---

### Task 8: `CustomerListTile` and `CustomerListScreen`

**Files:**
- Create: `lib/features/customers/presentation/widgets/customer_list_tile.dart`
- Create: `lib/features/customers/presentation/screens/customer_list_screen.dart`
- Test: `test/features/customers/presentation/screens/customer_list_screen_test.dart`

**Interfaces:**
- Consumes: `customerListControllerProvider` (Task 6), `customerRepositoryProvider` (Task 6), `EmptyState`/`ErrorState`/`LoadingSkeleton` (Phase 1).
- Produces: `class CustomerListTile extends StatelessWidget`, `class CustomerListScreen extends ConsumerStatefulWidget`.

- [ ] **Step 1: Write `CustomerListTile`**

```dart
// lib/features/customers/presentation/widgets/customer_list_tile.dart
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/customer.dart';

class CustomerListTile extends StatelessWidget {
  const CustomerListTile({super.key, required this.customer, required this.onTap});

  final Customer customer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return ListTile(
      onTap: onTap,
      title: Text(customer.name),
      subtitle: customer.phone != null ? Text(customer.phone!) : null,
      trailing: customer.isActive
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: colors.neutral200, borderRadius: BorderRadius.circular(999)),
              child: Text('Inactive', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.neutral600)),
            ),
    );
  }
}
```

- [ ] **Step 2: Write the failing screen test**

```dart
// test/features/customers/presentation/screens/customer_list_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/pagination/paginated_result.dart';
import 'package:billa_mobile/features/customers/domain/customer.dart';
import 'package:billa_mobile/features/customers/domain/customer_repository.dart';
import 'package:billa_mobile/features/customers/presentation/providers/customer_repository_provider.dart';
import 'package:billa_mobile/features/customers/presentation/screens/customer_list_screen.dart';

class _MockCustomerRepository extends Mock implements CustomerRepository {}

void main() {
  late _MockCustomerRepository repository;

  setUp(() {
    repository = _MockCustomerRepository();
  });

  Widget buildApp() {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => const CustomerListScreen()),
      GoRoute(path: '/customers/new', builder: (context, state) => const Scaffold(body: Text('new customer screen'))),
    ]);
    return ProviderScope(
      overrides: [customerRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  testWidgets('shows the empty state with a working add-customer action', (tester) async {
    when(() => repository.list(search: null, includeInactive: false, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: <Customer>[], total: 0, page: 1, pageSize: 20),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('No customers yet'), findsOneWidget);
    await tester.tap(find.text('Add customer'));
    await tester.pumpAndSettle();

    expect(find.text('new customer screen'), findsOneWidget);
  });

  testWidgets('typing in search debounces to a single repository call', (tester) async {
    when(() => repository.list(search: null, includeInactive: false, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: <Customer>[], total: 0, page: 1, pageSize: 20),
    );
    when(() => repository.list(search: 'acme', includeInactive: false, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(
        results: [Customer(id: 'c1', name: 'Acme', isActive: true, createdAt: '2026-01-01T00:00:00.000Z')],
        total: 1,
        page: 1,
        pageSize: 20,
      ),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('customer-search')), 'acme');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    verify(() => repository.list(search: 'acme', includeInactive: false, page: 1, pageSize: 20)).called(1);
  });
}
```

- [ ] **Step 3: Run it to confirm it fails**

```bash
flutter test test/features/customers/presentation/screens/customer_list_screen_test.dart
```

Expected: FAIL — `customer_list_screen.dart` doesn't exist yet.

- [ ] **Step 4: Implement `CustomerListScreen`**

```dart
// lib/features/customers/presentation/screens/customer_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../providers/customer_list_controller.dart';
import '../widgets/customer_list_tile.dart';

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  final _scrollController = ScrollController();
  bool _includeInactive = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(customerListControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/customers/new'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('customer-search'),
                    decoration: const InputDecoration(hintText: 'Search customers', prefixIcon: Icon(Icons.search)),
                    onChanged: (value) => ref.read(customerListControllerProvider.notifier).setSearch(value),
                  ),
                ),
                const SizedBox(width: 12),
                FilterChip(
                  key: const Key('customer-show-inactive'),
                  label: const Text('Show inactive'),
                  selected: _includeInactive,
                  onSelected: (value) {
                    setState(() => _includeInactive = value);
                    ref.read(customerListControllerProvider.notifier).setIncludeInactive(value);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: switch (state) {
              AsyncData(value: final data) when data.items.isEmpty => EmptyState(
                  icon: Icons.people_outline,
                  message: 'No customers yet',
                  actionLabel: 'Add customer',
                  onAction: () => context.push('/customers/new'),
                ),
              AsyncData(value: final data) => ListView.builder(
                  controller: _scrollController,
                  itemCount: data.items.length + (data.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= data.items.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    }
                    final customer = data.items[index];
                    return CustomerListTile(
                      customer: customer,
                      onTap: () => context.push('/customers/${customer.id}'),
                    );
                  },
                ),
              AsyncError() => ErrorState(
                  message: "Couldn't load your customers",
                  onRetry: () => ref.read(customerListControllerProvider.notifier).refresh(),
                ),
              _ => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(children: [LoadingSkeleton(height: 64), SizedBox(height: 12), LoadingSkeleton(height: 64)]),
                ),
            },
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Run it to confirm it passes**

```bash
flutter test test/features/customers/presentation/screens/customer_list_screen_test.dart
```

Expected: PASS (2 tests).

- [ ] **Step 6: Commit**

```bash
git add lib/features/customers/presentation/widgets/customer_list_tile.dart lib/features/customers/presentation/screens/customer_list_screen.dart test/features/customers/presentation/screens/customer_list_screen_test.dart
git commit -m "feat: add customer list screen with search and inactive filter"
```

---

### Task 9: `CustomerDetailScreen`

**Files:**
- Create: `lib/features/customers/presentation/screens/customer_detail_screen.dart`
- Test: `test/features/customers/presentation/screens/customer_detail_screen_test.dart`

**Interfaces:**
- Consumes: `customerRepositoryProvider` (Task 6), `Customer`/`CustomerPaymentStats` (Task 2), `AppButton`/`ErrorState`/`LoadingSkeleton` (Phase 1).
- Produces: `class CustomerDetailScreen extends ConsumerStatefulWidget { const CustomerDetailScreen({required String customerId}); }`.

- [ ] **Step 1: Write the failing test**

```dart
// test/features/customers/presentation/screens/customer_detail_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/customers/domain/customer.dart';
import 'package:billa_mobile/features/customers/domain/customer_payment_stats.dart';
import 'package:billa_mobile/features/customers/domain/customer_repository.dart';
import 'package:billa_mobile/features/customers/presentation/providers/customer_repository_provider.dart';
import 'package:billa_mobile/features/customers/presentation/screens/customer_detail_screen.dart';

class _MockCustomerRepository extends Mock implements CustomerRepository {}

const _customer = Customer(id: 'c1', name: 'Acme', phone: '0788000000', isActive: true, createdAt: '2026-01-01T00:00:00.000Z');
const _stats = CustomerPaymentStats(paidInvoiceCount: 3, averageDaysToPay: -2, onTimeRate: 67);

void main() {
  late _MockCustomerRepository repository;

  setUp(() {
    repository = _MockCustomerRepository();
    when(() => repository.get('c1')).thenAnswer((_) async => _customer);
    when(() => repository.paymentStats('c1')).thenAnswer((_) async => _stats);
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [customerRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(theme: AppTheme.light, home: CustomerDetailScreen(customerId: 'c1')),
    );
  }

  testWidgets('shows the customer profile and payment stats', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Acme'), findsOneWidget);
    expect(find.text('0788000000'), findsOneWidget);
    expect(find.text('3 paid invoices'), findsOneWidget);
    expect(find.text('67% paid on time'), findsOneWidget);
  });

  testWidgets('deactivate asks for confirmation, then calls update', (tester) async {
    when(() => repository.update('c1', isActive: false)).thenAnswer(
      (_) async => const Customer(id: 'c1', name: 'Acme', phone: '0788000000', isActive: false, createdAt: '2026-01-01T00:00:00.000Z'),
    );
    when(() => repository.get('c1')).thenAnswer((_) async => _customer);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('customer-toggle-active')));
    await tester.pumpAndSettle();
    expect(find.text('Deactivate Acme?'), findsOneWidget);

    await tester.tap(find.text('Deactivate'));
    await tester.pumpAndSettle();

    verify(() => repository.update('c1', isActive: false)).called(1);
  });
}
```

- [ ] **Step 2: Run it to confirm it fails**

```bash
flutter test test/features/customers/presentation/screens/customer_detail_screen_test.dart
```

Expected: FAIL — `customer_detail_screen.dart` doesn't exist yet.

- [ ] **Step 3: Implement `CustomerDetailScreen`**

```dart
// lib/features/customers/presentation/screens/customer_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../domain/customer.dart';
import '../../domain/customer_payment_stats.dart';
import '../providers/customer_repository_provider.dart';

class CustomerDetailScreen extends ConsumerStatefulWidget {
  const CustomerDetailScreen({super.key, required this.customerId});

  final String customerId;

  @override
  ConsumerState<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen> {
  late Future<(Customer, CustomerPaymentStats)> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(Customer, CustomerPaymentStats)> _load() async {
    final repository = ref.read(customerRepositoryProvider);
    final customer = await repository.get(widget.customerId);
    final stats = await repository.paymentStats(widget.customerId);
    return (customer, stats);
  }

  Future<void> _toggleActive(Customer customer) async {
    final action = customer.isActive ? 'Deactivate' : 'Reactivate';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$action ${customer.name}?'),
        content: Text(
          customer.isActive
              ? 'Hidden from lists. Their existing documents are not affected.'
              : 'They will appear in lists again.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(action)),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(customerRepositoryProvider).update(customer.id, isActive: !customer.isActive);
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer')),
      body: FutureBuilder<(Customer, CustomerPaymentStats)>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorState(
              message: "Couldn't load this customer",
              onRetry: () => setState(() => _future = _load()),
            );
          }
          if (!snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Column(children: [LoadingSkeleton(height: 24), SizedBox(height: 12), LoadingSkeleton(height: 100)]),
            );
          }
          final (customer, stats) = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(customer.name, style: Theme.of(context).textTheme.headlineSmall),
                if (customer.phone != null) Text(customer.phone!),
                if (customer.email != null) Text(customer.email!),
                if (customer.address != null) Text(customer.address!),
                const SizedBox(height: 24),
                Text('Payment history', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('${stats.paidInvoiceCount} paid invoices'),
                if (stats.averageDaysToPay != null) Text('Average ${stats.averageDaysToPay} days to pay'),
                if (stats.onTimeRate != null) Text('${stats.onTimeRate}% paid on time'),
                const SizedBox(height: 24),
                AppButton(
                  key: const Key('customer-toggle-active'),
                  label: customer.isActive ? 'Deactivate customer' : 'Reactivate customer',
                  onPressed: () => _toggleActive(customer),
                ),
                TextButton(
                  onPressed: () => context.push('/customers/${customer.id}/edit', extra: customer),
                  child: const Text('Edit'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 4: Run it to confirm it passes**

```bash
flutter test test/features/customers/presentation/screens/customer_detail_screen_test.dart
```

Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/features/customers/presentation/screens/customer_detail_screen.dart test/features/customers/presentation/screens/customer_detail_screen_test.dart
git commit -m "feat: add customer detail screen with payment stats and deactivate"
```

---

### Task 10: `CustomerFormScreen`

**Files:**
- Create: `lib/features/customers/presentation/screens/customer_form_screen.dart`
- Test: `test/features/customers/presentation/screens/customer_form_screen_test.dart`

**Interfaces:**
- Consumes: `customerRepositoryProvider` (Task 6), `Customer` (Task 2), `AppButton` (Phase 1).
- Produces: `class CustomerFormScreen extends ConsumerStatefulWidget { const CustomerFormScreen({Customer? existing}); }`.

- [ ] **Step 1: Write the failing test**

```dart
// test/features/customers/presentation/screens/customer_form_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/customers/domain/customer.dart';
import 'package:billa_mobile/features/customers/domain/customer_repository.dart';
import 'package:billa_mobile/features/customers/presentation/providers/customer_repository_provider.dart';
import 'package:billa_mobile/features/customers/presentation/screens/customer_form_screen.dart';

class _MockCustomerRepository extends Mock implements CustomerRepository {}

void main() {
  late _MockCustomerRepository repository;

  setUp(() {
    repository = _MockCustomerRepository();
  });

  Widget buildApp(Widget home) {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => home),
    ]);
    return ProviderScope(
      overrides: [customerRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  testWidgets('create sends only the filled-in fields', (tester) async {
    when(() => repository.create(name: 'Acme', tin: null, address: null, phone: null, email: null)).thenAnswer(
      (_) async => const Customer(id: 'c1', name: 'Acme', isActive: true, createdAt: '2026-01-01T00:00:00.000Z'),
    );

    await tester.pumpWidget(buildApp(const CustomerFormScreen()));
    await tester.enterText(find.byKey(const Key('customer-form-name')), 'Acme');
    await tester.tap(find.byKey(const Key('customer-form-save')));
    await tester.pumpAndSettle();

    verify(() => repository.create(name: 'Acme', tin: null, address: null, phone: null, email: null)).called(1);
  });

  testWidgets('edit pre-fills the existing customer and calls update with its id', (tester) async {
    const existing = Customer(id: 'c1', name: 'Acme', phone: '0788000000', isActive: true, createdAt: '2026-01-01T00:00:00.000Z');
    when(() => repository.update('c1', name: 'Acme Ltd', tin: null, address: null, phone: '0788000000', email: null)).thenAnswer(
      (_) async => existing,
    );

    await tester.pumpWidget(buildApp(const CustomerFormScreen(existing: existing)));
    expect(find.text('0788000000'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('customer-form-name')), 'Acme Ltd');
    await tester.tap(find.byKey(const Key('customer-form-save')));
    await tester.pumpAndSettle();

    verify(() => repository.update('c1', name: 'Acme Ltd', tin: null, address: null, phone: '0788000000', email: null)).called(1);
  });
}
```

- [ ] **Step 2: Run it to confirm it fails**

```bash
flutter test test/features/customers/presentation/screens/customer_form_screen_test.dart
```

Expected: FAIL — `customer_form_screen.dart` doesn't exist yet.

- [ ] **Step 3: Implement `CustomerFormScreen`**

```dart
// lib/features/customers/presentation/screens/customer_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/customer.dart';
import '../providers/customer_repository_provider.dart';

class CustomerFormScreen extends ConsumerStatefulWidget {
  const CustomerFormScreen({super.key, this.existing});

  final Customer? existing;

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  late final _nameController = TextEditingController(text: widget.existing?.name ?? '');
  late final _tinController = TextEditingController(text: widget.existing?.tin ?? '');
  late final _addressController = TextEditingController(text: widget.existing?.address ?? '');
  late final _phoneController = TextEditingController(text: widget.existing?.phone ?? '');
  late final _emailController = TextEditingController(text: widget.existing?.email ?? '');
  String? _errorMessage;
  bool _isSaving = false;

  String? _orNull(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Enter a customer name');
      return;
    }
    setState(() {
      _errorMessage = null;
      _isSaving = true;
    });
    try {
      final repository = ref.read(customerRepositoryProvider);
      if (widget.existing == null) {
        await repository.create(
          name: _nameController.text.trim(),
          tin: _orNull(_tinController),
          address: _orNull(_addressController),
          phone: _orNull(_phoneController),
          email: _orNull(_emailController),
        );
      } else {
        await repository.update(
          widget.existing!.id,
          name: _nameController.text.trim(),
          tin: _orNull(_tinController),
          address: _orNull(_addressController),
          phone: _orNull(_phoneController),
          email: _orNull(_emailController),
        );
      }
      if (mounted) context.pop();
    } catch (_) {
      setState(() => _errorMessage = "Couldn't save this customer");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? 'Add customer' : 'Edit customer')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(key: const Key('customer-form-name'), controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 12),
              TextField(controller: _tinController, decoration: const InputDecoration(labelText: 'TIN (optional)')),
              const SizedBox(height: 12),
              TextField(controller: _addressController, decoration: const InputDecoration(labelText: 'Address (optional)')),
              const SizedBox(height: 12),
              TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone (optional)')),
              const SizedBox(height: 12),
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email (optional)')),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(_errorMessage!),
              ],
              const SizedBox(height: 16),
              AppButton(key: const Key('customer-form-save'), label: 'Save', onPressed: _save, isLoading: _isSaving),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run it to confirm it passes**

```bash
flutter test test/features/customers/presentation/screens/customer_form_screen_test.dart
```

Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/features/customers/presentation/screens/customer_form_screen.dart test/features/customers/presentation/screens/customer_form_screen_test.dart
git commit -m "feat: add customer create and edit form screen"
```

---

### Task 11: `ItemListTile` and `ItemListScreen`

**Files:**
- Create: `lib/features/items/presentation/widgets/item_list_tile.dart`
- Create: `lib/features/items/presentation/screens/item_list_screen.dart`
- Test: `test/features/items/presentation/screens/item_list_screen_test.dart`

**Interfaces:**
- Consumes: `itemListControllerProvider`/`itemRepositoryProvider` (Task 7), `MoneyText`/`EmptyState`/`ErrorState`/`LoadingSkeleton` (Phase 1).
- Produces: `class ItemListTile extends StatelessWidget`, `class ItemListScreen extends ConsumerStatefulWidget`.

- [ ] **Step 1: Write `ItemListTile`**

```dart
// lib/features/items/presentation/widgets/item_list_tile.dart
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/money_text.dart';
import '../../domain/item.dart';

class ItemListTile extends StatelessWidget {
  const ItemListTile({super.key, required this.item, required this.onTap});

  final Item item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return ListTile(
      onTap: onTap,
      title: Text(item.description),
      subtitle: Text(item.unit),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MoneyText(item.unitPrice),
          if (!item.isActive) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: colors.neutral200, borderRadius: BorderRadius.circular(999)),
              child: Text('Inactive', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.neutral600)),
            ),
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Write the failing screen test**

```dart
// test/features/items/presentation/screens/item_list_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/pagination/paginated_result.dart';
import 'package:billa_mobile/features/items/domain/item.dart';
import 'package:billa_mobile/features/items/domain/item_repository.dart';
import 'package:billa_mobile/features/items/presentation/providers/item_repository_provider.dart';
import 'package:billa_mobile/features/items/presentation/screens/item_list_screen.dart';

class _MockItemRepository extends Mock implements ItemRepository {}

void main() {
  late _MockItemRepository repository;

  setUp(() {
    repository = _MockItemRepository();
  });

  Widget buildApp() {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => const ItemListScreen()),
      GoRoute(path: '/items/new', builder: (context, state) => const Scaffold(body: Text('new item screen'))),
      GoRoute(path: '/items/:id/edit', builder: (context, state) => const Scaffold(body: Text('edit item screen'))),
    ]);
    return ProviderScope(
      overrides: [itemRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  testWidgets('shows the empty state with a working add-item action', (tester) async {
    when(() => repository.list(search: null, category: null, includeInactive: false, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: <Item>[], total: 0, page: 1, pageSize: 20),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('No items yet'), findsOneWidget);
    await tester.tap(find.text('Add item'));
    await tester.pumpAndSettle();

    expect(find.text('new item screen'), findsOneWidget);
  });

  testWidgets('tapping a row opens the edit screen with the item passed through', (tester) async {
    const item = Item(id: 'i1', description: 'Cement', unitPrice: 13000, unit: 'bag', taxRate: 18, isActive: true);
    when(() => repository.list(search: null, category: null, includeInactive: false, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: [item], total: 1, page: 1, pageSize: 20),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cement'));
    await tester.pumpAndSettle();

    expect(find.text('edit item screen'), findsOneWidget);
  });
}
```

- [ ] **Step 3: Run it to confirm it fails**

```bash
flutter test test/features/items/presentation/screens/item_list_screen_test.dart
```

Expected: FAIL — `item_list_screen.dart` doesn't exist yet.

- [ ] **Step 4: Implement `ItemListScreen`**

```dart
// lib/features/items/presentation/screens/item_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../providers/item_list_controller.dart';
import '../widgets/item_list_tile.dart';

class ItemListScreen extends ConsumerStatefulWidget {
  const ItemListScreen({super.key});

  @override
  ConsumerState<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends ConsumerState<ItemListScreen> {
  final _scrollController = ScrollController();
  final _categoryController = TextEditingController();
  bool _includeInactive = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(itemListControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(itemListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Items')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/items/new'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('item-search'),
                        decoration: const InputDecoration(hintText: 'Search items', prefixIcon: Icon(Icons.search)),
                        onChanged: (value) => ref.read(itemListControllerProvider.notifier).setSearch(value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilterChip(
                      key: const Key('item-show-inactive'),
                      label: const Text('Show inactive'),
                      selected: _includeInactive,
                      onSelected: (value) {
                        setState(() => _includeInactive = value);
                        ref.read(itemListControllerProvider.notifier).setIncludeInactive(value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  key: const Key('item-category-filter'),
                  controller: _categoryController,
                  decoration: const InputDecoration(hintText: 'Filter by category (optional)'),
                  onSubmitted: (value) => ref
                      .read(itemListControllerProvider.notifier)
                      .setCategory(value.trim().isEmpty ? null : value.trim()),
                ),
              ],
            ),
          ),
          Expanded(
            child: switch (state) {
              AsyncData(value: final data) when data.items.isEmpty => EmptyState(
                  icon: Icons.inventory_2_outlined,
                  message: 'No items yet',
                  actionLabel: 'Add item',
                  onAction: () => context.push('/items/new'),
                ),
              AsyncData(value: final data) => ListView.builder(
                  controller: _scrollController,
                  itemCount: data.items.length + (data.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= data.items.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    }
                    final item = data.items[index];
                    return ItemListTile(
                      item: item,
                      onTap: () => context.push('/items/${item.id}/edit', extra: item),
                    );
                  },
                ),
              AsyncError() => ErrorState(
                  message: "Couldn't load your items",
                  onRetry: () => ref.read(itemListControllerProvider.notifier).refresh(),
                ),
              _ => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(children: [LoadingSkeleton(height: 64), SizedBox(height: 12), LoadingSkeleton(height: 64)]),
                ),
            },
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Run it to confirm it passes**

```bash
flutter test test/features/items/presentation/screens/item_list_screen_test.dart
```

Expected: PASS (2 tests).

- [ ] **Step 6: Commit**

```bash
git add lib/features/items/presentation/widgets/item_list_tile.dart lib/features/items/presentation/screens/item_list_screen.dart test/features/items/presentation/screens/item_list_screen_test.dart
git commit -m "feat: add item list screen with search and category filter"
```

---

### Task 12: `ItemFormScreen`

**Files:**
- Create: `lib/features/items/presentation/screens/item_form_screen.dart`
- Test: `test/features/items/presentation/screens/item_form_screen_test.dart`

**Interfaces:**
- Consumes: `itemRepositoryProvider` (Task 7), `Item` (Task 4), `AppButton` (Phase 1).
- Produces: `class ItemFormScreen extends ConsumerStatefulWidget { const ItemFormScreen({Item? existing}); }`.

- [ ] **Step 1: Write the failing test**

```dart
// test/features/items/presentation/screens/item_form_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/items/domain/item.dart';
import 'package:billa_mobile/features/items/domain/item_repository.dart';
import 'package:billa_mobile/features/items/presentation/providers/item_repository_provider.dart';
import 'package:billa_mobile/features/items/presentation/screens/item_form_screen.dart';

class _MockItemRepository extends Mock implements ItemRepository {}

void main() {
  late _MockItemRepository repository;

  setUp(() {
    repository = _MockItemRepository();
  });

  Widget buildApp(Widget home) {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => home),
    ]);
    return ProviderScope(
      overrides: [itemRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  testWidgets('create parses numeric fields and defaults the tax rate', (tester) async {
    when(() => repository.create(description: 'Cement', unitPrice: 13000, unit: 'bag', taxRate: 18, category: null)).thenAnswer(
      (_) async => const Item(id: 'i1', description: 'Cement', unitPrice: 13000, unit: 'bag', taxRate: 18, isActive: true),
    );

    await tester.pumpWidget(buildApp(const ItemFormScreen()));
    await tester.enterText(find.byKey(const Key('item-form-description')), 'Cement');
    await tester.enterText(find.byKey(const Key('item-form-unit-price')), '13000');
    await tester.enterText(find.byKey(const Key('item-form-unit')), 'bag');
    await tester.tap(find.byKey(const Key('item-form-save')));
    await tester.pumpAndSettle();

    verify(() => repository.create(description: 'Cement', unitPrice: 13000, unit: 'bag', taxRate: 18, category: null)).called(1);
  });

  testWidgets('rejects a zero unit price instead of submitting', (tester) async {
    await tester.pumpWidget(buildApp(const ItemFormScreen()));
    await tester.enterText(find.byKey(const Key('item-form-description')), 'Cement');
    await tester.enterText(find.byKey(const Key('item-form-unit-price')), '0');
    await tester.enterText(find.byKey(const Key('item-form-unit')), 'bag');
    await tester.tap(find.byKey(const Key('item-form-save')));
    await tester.pumpAndSettle();

    expect(find.text('Check the highlighted fields'), findsOneWidget);
    verifyNever(() => repository.create(description: any(named: 'description'), unitPrice: any(named: 'unitPrice'), unit: any(named: 'unit')));
  });
}
```

- [ ] **Step 2: Run it to confirm it fails**

```bash
flutter test test/features/items/presentation/screens/item_form_screen_test.dart
```

Expected: FAIL — `item_form_screen.dart` doesn't exist yet.

- [ ] **Step 3: Implement `ItemFormScreen`**

```dart
// lib/features/items/presentation/screens/item_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/item.dart';
import '../providers/item_repository_provider.dart';

class ItemFormScreen extends ConsumerStatefulWidget {
  const ItemFormScreen({super.key, this.existing});

  final Item? existing;

  @override
  ConsumerState<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends ConsumerState<ItemFormScreen> {
  late final _descriptionController = TextEditingController(text: widget.existing?.description ?? '');
  late final _unitPriceController = TextEditingController(text: widget.existing?.unitPrice.toString() ?? '');
  late final _unitController = TextEditingController(text: widget.existing?.unit ?? '');
  late final _taxRateController = TextEditingController(text: (widget.existing?.taxRate ?? 18).toString());
  late final _categoryController = TextEditingController(text: widget.existing?.category ?? '');
  String? _errorMessage;
  bool _isSaving = false;

  String? _orNull(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _save() async {
    final unitPrice = int.tryParse(_unitPriceController.text.trim());
    final taxRate = double.tryParse(_taxRateController.text.trim());
    final hasValidFields = _descriptionController.text.trim().isNotEmpty &&
        unitPrice != null &&
        unitPrice > 0 &&
        _unitController.text.trim().isNotEmpty &&
        taxRate != null;
    if (!hasValidFields) {
      setState(() => _errorMessage = 'Check the highlighted fields');
      return;
    }
    setState(() {
      _errorMessage = null;
      _isSaving = true;
    });
    try {
      final repository = ref.read(itemRepositoryProvider);
      if (widget.existing == null) {
        await repository.create(
          description: _descriptionController.text.trim(),
          unitPrice: unitPrice,
          unit: _unitController.text.trim(),
          taxRate: taxRate,
          category: _orNull(_categoryController),
        );
      } else {
        await repository.update(
          widget.existing!.id,
          description: _descriptionController.text.trim(),
          unitPrice: unitPrice,
          unit: _unitController.text.trim(),
          taxRate: taxRate,
          category: _orNull(_categoryController),
        );
      }
      if (mounted) context.pop();
    } catch (_) {
      setState(() => _errorMessage = "Couldn't save this item");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? 'Add item' : 'Edit item')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(key: const Key('item-form-description'), controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 12),
              TextField(
                key: const Key('item-form-unit-price'),
                controller: _unitPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Unit price (RWF)'),
              ),
              const SizedBox(height: 12),
              TextField(key: const Key('item-form-unit'), controller: _unitController, decoration: const InputDecoration(labelText: 'Unit (e.g. piece, hour)')),
              const SizedBox(height: 12),
              TextField(
                controller: _taxRateController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Tax rate (%)'),
              ),
              const SizedBox(height: 12),
              TextField(controller: _categoryController, decoration: const InputDecoration(labelText: 'Category (optional)')),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(_errorMessage!),
              ],
              const SizedBox(height: 16),
              AppButton(key: const Key('item-form-save'), label: 'Save', onPressed: _save, isLoading: _isSaving),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run it to confirm it passes**

```bash
flutter test test/features/items/presentation/screens/item_form_screen_test.dart
```

Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/features/items/presentation/screens/item_form_screen.dart test/features/items/presentation/screens/item_form_screen_test.dart
git commit -m "feat: add item create and edit form screen"
```

---

### Task 13: Router wiring and home navigation

**Files:**
- Modify: `lib/app/router.dart`
- Modify: `test/app/router_test.dart`

**Interfaces:**
- Consumes: every screen from Tasks 8–12, `customerRepositoryProvider`/`itemRepositoryProvider`.
- Produces: routes `/customers`, `/customers/new`, `/customers/:id/edit`, `/customers/:id`, `/items`, `/items/new`, `/items/:id/edit`; two keyed buttons on the placeholder home screen.

- [ ] **Step 1: Add the new routes and home navigation buttons to `router.dart`**

```dart
// lib/app/router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/providers/auth_controller.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/customers/domain/customer.dart';
import '../features/customers/presentation/screens/customer_detail_screen.dart';
import '../features/customers/presentation/screens/customer_form_screen.dart';
import '../features/customers/presentation/screens/customer_list_screen.dart';
import '../features/items/domain/item.dart';
import '../features/items/presentation/screens/item_form_screen.dart';
import '../features/items/presentation/screens/item_list_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import 'theme/bootstrap_screen.dart';

const _authRoutes = {'/login', '/register'};

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshNotifier(ref),
    redirect: (context, state) {
      final status = ref.read(authControllerProvider).value;
      final path = state.uri.path;
      if (status == null) return path == '/bootstrap' ? null : '/bootstrap';

      return status.when(
        unauthenticated: () => _authRoutes.contains(path) ? null : '/login',
        // Handled inline by login_screen.dart — never a route-level redirect.
        twoFactorRequired: (challengeId) => null,
        authenticated: (user, business) {
          final needsOnboarding = business.onboardingCompletedAt == null;
          if (needsOnboarding) return path == '/onboarding' ? null : '/onboarding';
          return (_authRoutes.contains(path) || path == '/onboarding') ? '/' : null;
        },
      );
    },
    routes: [
      GoRoute(path: '/bootstrap', builder: (context, state) => const BootstrapScreen()),
      GoRoute(path: '/', builder: (context, state) => const _PlaceholderHomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/customers', builder: (context, state) => const CustomerListScreen()),
      GoRoute(path: '/customers/new', builder: (context, state) => const CustomerFormScreen()),
      GoRoute(
        path: '/customers/:id/edit',
        builder: (context, state) => CustomerFormScreen(existing: state.extra as Customer?),
      ),
      GoRoute(
        path: '/customers/:id',
        builder: (context, state) => CustomerDetailScreen(customerId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/items', builder: (context, state) => const ItemListScreen()),
      GoRoute(path: '/items/new', builder: (context, state) => const ItemFormScreen()),
      GoRoute(
        path: '/items/:id/edit',
        builder: (context, state) => ItemFormScreen(existing: state.extra as Item?),
      ),
    ],
  );
});

class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(Ref ref) {
    ref.listen(authControllerProvider, (_, _) => notifyListeners());
  }
}

class _PlaceholderHomeScreen extends StatelessWidget {
  const _PlaceholderHomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Billa', style: Theme.of(context).textTheme.displayMedium),
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
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Add a home-navigation test case to `router_test.dart`**

Add these imports to the top of the existing `test/app/router_test.dart` (alongside what's already there):

```dart
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/core/pagination/paginated_result.dart';
import 'package:billa_mobile/features/customers/domain/customer_repository.dart';
import 'package:billa_mobile/features/customers/presentation/providers/customer_repository_provider.dart';
import 'package:billa_mobile/features/items/domain/item_repository.dart';
import 'package:billa_mobile/features/items/presentation/providers/item_repository_provider.dart';
```

Add these two mock classes near `_FakeAuthController`:

```dart
class _MockCustomerRepository extends Mock implements CustomerRepository {}
class _MockItemRepository extends Mock implements ItemRepository {}
```

Add this test case inside `main()`, alongside the existing three:

```dart
  testWidgets('home screen navigates to the customers list', (tester) async {
    final customerRepository = _MockCustomerRepository();
    when(() => customerRepository.list(search: null, includeInactive: false, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: [], total: 0, page: 1, pageSize: 20),
    );
    const business = Business(id: 'b1', name: 'Acme', onboardingCompletedAt: '2026-01-01T00:00:00.000Z');
    final container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(() => _FakeAuthController(const AuthStatus.authenticated(_user, business))),
      customerRepositoryProvider.overrideWithValue(customerRepository),
    ]);
    addTearDown(container.dispose);

    await _pumpRouter(tester, container);
    await tester.tap(find.byKey(const Key('home-nav-customers')));
    await tester.pumpAndSettle();

    expect(find.text('No customers yet'), findsOneWidget);
  });

  testWidgets('home screen navigates to the items list', (tester) async {
    final itemRepository = _MockItemRepository();
    when(() => itemRepository.list(search: null, category: null, includeInactive: false, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: [], total: 0, page: 1, pageSize: 20),
    );
    const business = Business(id: 'b1', name: 'Acme', onboardingCompletedAt: '2026-01-01T00:00:00.000Z');
    final container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(() => _FakeAuthController(const AuthStatus.authenticated(_user, business))),
      itemRepositoryProvider.overrideWithValue(itemRepository),
    ]);
    addTearDown(container.dispose);

    await _pumpRouter(tester, container);
    await tester.tap(find.byKey(const Key('home-nav-items')));
    await tester.pumpAndSettle();

    expect(find.text('No items yet'), findsOneWidget);
  });
```

- [ ] **Step 3: Run it to confirm it passes, then the full suite**

```bash
flutter test test/app/router_test.dart
flutter test
```

Expected: router test passes (5 cases total); full suite green.

- [ ] **Step 4: Commit**

```bash
git add lib/app/router.dart test/app/router_test.dart
git commit -m "feat: wire customer and item routes into the router"
```

---

### Task 14: Final verification

**Files:** none created — this task only runs checks and fixes anything they surface.

- [ ] **Step 1: Static analysis**

```bash
flutter analyze
```

Expected: "No issues found!" — fix anything reported and re-run until clean.

- [ ] **Step 2: Full test suite**

```bash
flutter test
```

Expected: every test from Tasks 1–13 passes, plus all of Phase 1 and Phase 2's existing tests still pass unchanged.

- [ ] **Step 3: Android debug build**

```bash
flutter build apk --debug
```

Expected: builds successfully.

- [ ] **Step 4: Note the iOS build status**

Same as Phases 1–2: iOS build verification is deferred to macOS (this branch is built on Windows).

- [ ] **Step 5: Commit any fixes from Steps 1–2**

Only if something needed fixing:

```bash
git add -A
git commit -m "fix: resolve analyzer warnings from phase 3 verification"
```

If nothing needed fixing, this step is a no-op.

---

## Definition of done for this plan

`flutter analyze` is clean, `flutter test` passes in full, `flutter build apk --debug` succeeds, and a manual run shows: home screen → Customers button → list with search, "Show inactive," infinite scroll, and a working empty state → tap a row → detail with payment stats → deactivate with a confirming dialog that says exactly what will happen; home screen → Items button → list with search, category filter, and "Show inactive" → tap a row → edit form pre-filled from the tapped item (no network round-trip) → save.
