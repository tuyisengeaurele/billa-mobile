import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/account/domain/notification_type.dart';
import 'package:billa_mobile/features/notifications/domain/app_notification.dart';
import 'package:billa_mobile/features/notifications/domain/notification_route.dart';
import 'package:billa_mobile/features/notifications/domain/notifications_page.dart';

void main() {
  test('AppNotification.fromJson parses a full notification', () {
    final notification = AppNotification.fromJson({
      'id': 'n1',
      'type': 'PAYMENT_RECEIVED',
      'title': 'Payment received',
      'body': 'RWF 5,000 from Ada',
      'link': '/documents/d1',
      'readAt': null,
      'createdAt': '2026-01-01T10:00:00.000Z',
    });

    expect(notification.type, NotificationType.paymentReceived);
    expect(notification.isUnread, isTrue);
    expect(notification.link, '/documents/d1');
  });

  test('an unknown type and missing body, link, and readAt still parse', () {
    final notification = AppNotification.fromJson({
      'id': 'n2',
      'type': 'SOMETHING_NEW',
      'title': 'Hello',
      'body': null,
      'link': null,
      'readAt': '2026-01-02T00:00:00.000Z',
      'createdAt': '2026-01-01T10:00:00.000Z',
    });

    expect(notification.type, isNull);
    expect(notification.isUnread, isFalse);
  });

  test('NotificationsPage.fromJson parses results and the unread count', () {
    final page = NotificationsPage.fromJson({
      'results': [
        {'id': 'n1', 'type': 'MEMBER_JOINED', 'title': 'Joined', 'createdAt': '2026-01-01T10:00:00.000Z'},
      ],
      'unreadCount': 1,
    });

    expect(page.results.single.title, 'Joined');
    expect(page.unreadCount, 1);
  });

  test('notificationRoute maps backend paths to mobile routes', () {
    expect(notificationRoute('/documents/abc'), '/documents/abc');
    expect(notificationRoute('/settings'), '/team');
    expect(notificationRoute('/admin/messages'), isNull);
    expect(notificationRoute('/documents/abc/extra'), isNull);
    expect(notificationRoute(null), isNull);
  });
}
