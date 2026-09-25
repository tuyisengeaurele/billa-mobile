import 'package:freezed_annotation/freezed_annotation.dart';
import 'app_notification.dart';

part 'notifications_page.freezed.dart';
part 'notifications_page.g.dart';

@freezed
class NotificationsPage with _$NotificationsPage {
  const factory NotificationsPage({
    required List<AppNotification> results,
    required int unreadCount,
  }) = _NotificationsPage;

  factory NotificationsPage.fromJson(Map<String, dynamic> json) => _$NotificationsPageFromJson(json);
}
