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
