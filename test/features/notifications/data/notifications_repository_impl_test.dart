import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/notifications/data/notifications_repository_impl.dart';

class _MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _ok(Map<String, dynamic> data, String path) =>
    Response(statusCode: 200, data: data, requestOptions: RequestOptions(path: path));

void main() {
  late _MockDio dio;
  late NotificationsRepositoryImpl repository;

  setUp(() {
    dio = _MockDio();
    repository = NotificationsRepositoryImpl(dio);
  });

  test('list parses the results and unread count', () async {
    when(() => dio.get<Map<String, dynamic>>('/notifications')).thenAnswer(
      (_) async => _ok({
        'results': [
          {'id': 'n1', 'type': 'INVOICE_OVERDUE', 'title': 'Overdue', 'createdAt': '2026-01-01T10:00:00.000Z'},
        ],
        'unreadCount': 3,
      }, '/notifications'),
    );

    final page = await repository.list();

    expect(page.unreadCount, 3);
    expect(page.results.single.id, 'n1');
  });

  test('markRead and markAllRead hit their endpoints', () async {
    when(() => dio.post<Map<String, dynamic>>('/notifications/n1/read'))
        .thenAnswer((_) async => _ok({'ok': true}, '/notifications/n1/read'));
    when(() => dio.post<Map<String, dynamic>>('/notifications/mark-all-read'))
        .thenAnswer((_) async => _ok({'ok': true}, '/notifications/mark-all-read'));

    await repository.markRead('n1');
    await repository.markAllRead();

    verify(() => dio.post<Map<String, dynamic>>('/notifications/n1/read')).called(1);
    verify(() => dio.post<Map<String, dynamic>>('/notifications/mark-all-read')).called(1);
  });
}
