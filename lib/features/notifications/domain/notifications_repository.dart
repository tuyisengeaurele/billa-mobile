import 'notifications_page.dart';

abstract class NotificationsRepository {
  Future<NotificationsPage> list();
  Future<void> markRead(String id);
  Future<void> markAllRead();
}
