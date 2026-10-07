import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/activity/data/activity_repository_impl.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  test('asks for one page and maps the entries', () async {
    final dio = _MockDio();
    final options = RequestOptions(path: '/business/activity');
    when(() => dio.get<Map<String, dynamic>>('/business/activity', queryParameters: {'page': 2, 'pageSize': 20}))
        .thenAnswer(
      (_) async => Response(
        statusCode: 200,
        requestOptions: options,
        data: {
          'results': [
            {
              'id': 'e1',
              'action': 'MEMBER_JOINED',
              'entityType': null,
              'metadata': null,
              'createdAt': '2026-01-02T10:00:00.000Z',
              'actor': {'id': 'u1', 'name': 'Ada', 'email': 'ada@example.com'},
            },
          ],
          'total': 21,
          'page': 2,
          'pageSize': 20,
        },
      ),
    );

    final page = await ActivityRepositoryImpl(dio).list(page: 2, pageSize: 20);

    expect(page.results.single.id, 'e1');
    expect(page.total, 21);
    expect(page.page, 2);
  });
}
