import 'package:dio/dio.dart';
import '../../../core/pagination/paginated_result.dart';
import '../domain/activity_entry.dart';
import '../domain/activity_repository.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  ActivityRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<PaginatedResult<ActivityEntry>> list({int page = 1, int pageSize = 20}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/business/activity',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    final data = response.data!;
    return PaginatedResult(
      results: (data['results'] as List).map((json) => ActivityEntry.fromJson(json as Map<String, dynamic>)).toList(),
      total: data['total'] as int,
      page: data['page'] as int,
      pageSize: data['pageSize'] as int,
    );
  }
}
