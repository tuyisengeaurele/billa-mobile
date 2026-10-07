import 'package:dio/dio.dart';
import '../domain/notifications_page.dart';
import '../domain/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<NotificationsPage> list() async {
    final response = await _dio.get<Map<String, dynamic>>('/notifications');
    return NotificationsPage.fromJson(response.data!);
  }

  @override
  Future<void> markRead(String id) async {
    await _dio.post<Map<String, dynamic>>('/notifications/$id/read');
  }

  @override
  Future<void> markAllRead() async {
    await _dio.post<Map<String, dynamic>>('/notifications/mark-all-read');
  }
}
