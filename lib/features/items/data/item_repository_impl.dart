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
    // Omitted rather than sent as null: null here means "not provided", so it
    // can't express clearing an already-set category, which mobile doesn't support yet.
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
