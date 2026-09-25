import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/search/data/search_repository_impl.dart';
import 'package:billa_mobile/features/search/domain/search_result.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late SearchRepositoryImpl repository;

  setUp(() {
    dio = _MockDio();
    repository = SearchRepositoryImpl(dio);
  });

  test('sends the query and parses every result type, skipping unknown ones', () async {
    when(() => dio.get<Map<String, dynamic>>('/search', queryParameters: {'q': 'ac'})).thenAnswer(
      (_) async => Response(
        statusCode: 200,
        requestOptions: RequestOptions(path: '/search'),
        data: {
          'results': [
            {'type': 'customer', 'id': 'c1', 'label': 'Acme', 'sublabel': '0788', 'href': '/customers/c1/statement'},
            {'type': 'item', 'id': 'i1', 'label': 'Acme widget', 'sublabel': 'RWF 500', 'href': '/items'},
            {
              'type': 'document',
              'id': 'd1',
              'label': 'INV-1',
              'sublabel': 'Acme',
              'documentType': 'INVOICE',
              'href': '/documents/d1',
            },
            {'type': 'something-new', 'id': 'x', 'label': 'x', 'sublabel': ''},
          ],
        },
      ),
    );

    final results = await repository.search('ac');

    expect(results.map((r) => r.type), [SearchResultType.customer, SearchResultType.item, SearchResultType.document]);
    expect(results.last.documentType, DocumentType.invoice);
  });

  test('each result type maps to its own mobile route', () {
    SearchResult make(SearchResultType type) => SearchResult(type: type, id: 'z', label: 'l', sublabel: '');

    expect(make(SearchResultType.customer).route, '/customers/z');
    expect(make(SearchResultType.item).route, '/items');
    expect(make(SearchResultType.document).route, '/documents/z');
  });
}
