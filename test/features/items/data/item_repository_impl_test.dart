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
