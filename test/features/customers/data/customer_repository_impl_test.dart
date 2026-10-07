import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/customers/data/customer_repository_impl.dart';

class _MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _response(int statusCode, Map<String, dynamic> data, RequestOptions options) {
  return Response(statusCode: statusCode, data: data, requestOptions: options);
}

void main() {
  late _MockDio dio;
  late CustomerRepositoryImpl repository;

  setUp(() {
    dio = _MockDio();
    repository = CustomerRepositoryImpl(dio);
  });

  test('list sends search/includeInactive/page/pageSize and maps results', () async {
    final options = RequestOptions(path: '/customers');
    when(() => dio.get<Map<String, dynamic>>('/customers', queryParameters: {
          'search': 'acme',
          'includeInactive': 'false',
          'page': 1,
          'pageSize': 20,
        })).thenAnswer((_) async => _response(200, {
          'results': [
            {
              'id': 'c1',
              'name': 'Acme',
              'tin': null,
              'address': null,
              'phone': null,
              'email': null,
              'isActive': true,
              'createdAt': '2026-01-01T00:00:00.000Z',
            },
          ],
          'total': 1,
          'page': 1,
          'pageSize': 20,
        }, options));

    final result = await repository.list(search: 'acme');

    expect(result.results.single.name, 'Acme');
    expect(result.total, 1);
  });

  test('list omits the search param when null', () async {
    final options = RequestOptions(path: '/customers');
    when(() => dio.get<Map<String, dynamic>>('/customers', queryParameters: {
          'includeInactive': 'false',
          'page': 1,
          'pageSize': 20,
        })).thenAnswer((_) async => _response(200, {'results': [], 'total': 0, 'page': 1, 'pageSize': 20}, options));

    final result = await repository.list();

    expect(result.results, isEmpty);
  });

  test('create omits null optional fields from the payload', () async {
    final options = RequestOptions(path: '/customers');
    when(() => dio.post<Map<String, dynamic>>('/customers', data: {'name': 'Acme'})).thenAnswer(
      (_) async => _response(201, {
        'customer': {
          'id': 'c1',
          'name': 'Acme',
          'tin': null,
          'address': null,
          'phone': null,
          'email': null,
          'isActive': true,
          'createdAt': '2026-01-01T00:00:00.000Z',
        },
      }, options),
    );

    final customer = await repository.create(name: 'Acme');

    expect(customer.id, 'c1');
  });

  test('update sends isActive: false to deactivate', () async {
    final options = RequestOptions(path: '/customers/c1');
    when(() => dio.patch<Map<String, dynamic>>('/customers/c1', data: {'isActive': false})).thenAnswer(
      (_) async => _response(200, {
        'customer': {
          'id': 'c1',
          'name': 'Acme',
          'tin': null,
          'address': null,
          'phone': null,
          'email': null,
          'isActive': false,
          'createdAt': '2026-01-01T00:00:00.000Z',
        },
      }, options),
    );

    final customer = await repository.update('c1', isActive: false);

    expect(customer.isActive, isFalse);
  });

  test('paymentStats maps the bare response with no envelope', () async {
    final options = RequestOptions(path: '/customers/c1/payment-stats');
    when(() => dio.get<Map<String, dynamic>>('/customers/c1/payment-stats')).thenAnswer(
      (_) async => _response(200, {'paidInvoiceCount': 3, 'averageDaysToPay': -2, 'onTimeRate': 67}, options),
    );

    final stats = await repository.paymentStats('c1');

    expect(stats.paidInvoiceCount, 3);
    expect(stats.averageDaysToPay, -2);
  });
}
