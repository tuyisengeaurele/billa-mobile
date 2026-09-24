import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/pagination/paginated_list_controller.dart';
import 'package:billa_mobile/core/pagination/paginated_result.dart';
import 'package:billa_mobile/core/pagination/paginated_state.dart';

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
