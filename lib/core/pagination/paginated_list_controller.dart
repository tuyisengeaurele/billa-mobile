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
  bool _disposed = false;

  Future<PaginatedResult<T>> fetchPage({
    required String search,
    required bool includeInactive,
    required int page,
  });

  @override
  Future<PaginatedState<T>> build() async {
    ref.onDispose(() {
      _disposed = true;
      _debounceTimer?.cancel();
    });
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
      if (_disposed) return;
      _search = value;
      state = const AsyncLoading();
      _fetchFresh().then((next) {
        if (!_disposed) state = AsyncData(next);
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
