import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/receivables/data/receivables_repository_impl.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late ReceivablesRepositoryImpl repository;

  setUp(() {
    dio = _MockDio();
    repository = ReceivablesRepositoryImpl(dio);
  });

  test('list fetches and maps the outstanding invoices', () async {
    final options = RequestOptions(path: '/receivables');
    when(() => dio.get<Map<String, dynamic>>('/receivables')).thenAnswer(
      (_) async => Response(
        statusCode: 200,
        requestOptions: options,
        data: {
          'results': [
            {
              'id': 'd1',
              'number': 'INV-0001',
              'customerName': 'Acme',
              'total': 10000,
              'amountOwed': 4000,
              'dueDate': '2026-01-01',
              'daysOverdue': 12,
              'agingBucket': '0-30',
            },
          ],
          'total': 1,
        },
      ),
    );

    final results = await repository.list();

    expect(results.single.id, 'd1');
  });
}
