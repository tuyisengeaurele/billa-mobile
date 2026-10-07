import 'package:dio/dio.dart';
import '../domain/search_repository.dart';
import '../domain/search_result.dart';

class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<SearchResult>> search(String query) async {
    final response = await _dio.get<Map<String, dynamic>>('/search', queryParameters: {'q': query});
    return (response.data!['results'] as List)
        .map((json) => SearchResult.fromJson(json as Map<String, dynamic>))
        .whereType<SearchResult>()
        .toList();
  }
}
