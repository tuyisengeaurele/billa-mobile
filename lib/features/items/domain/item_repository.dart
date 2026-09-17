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
