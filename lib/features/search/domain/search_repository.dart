import 'search_result.dart';

abstract class SearchRepository {
  Future<List<SearchResult>> search(String query);
}
