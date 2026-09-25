import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/notifications_page.dart';
import 'notifications_repository_provider.dart';

/// One source for both the bell badge and the inbox, so the two can never
/// disagree about what is unread. Notifications belong to the user rather
/// than a business, so this deliberately does not watch the active business.
final notificationsProvider = FutureProvider.autoDispose<NotificationsPage>((ref) {
  return ref.watch(notificationsRepositoryProvider).list();
});
