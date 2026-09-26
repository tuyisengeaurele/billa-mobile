import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/formatting/relative_time.dart';
import '../../../../core/widgets/action_error_banner.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../domain/app_notification.dart';
import '../../domain/notification_route.dart';
import '../providers/notifications_provider.dart';
import '../providers/notifications_repository_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _actionInProgress = false;
  String? _actionError;
  Future<void> Function()? _lastAction;

  Future<void> _runAction(Future<void> Function() action) async {
    _lastAction = action;
    setState(() {
      _actionInProgress = true;
      _actionError = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => _actionError = describeActionError(e));
    } finally {
      if (mounted) setState(() => _actionInProgress = false);
    }
  }

  Future<void> _open(AppNotification notification) => _runAction(() async {
        if (notification.isUnread) {
          await ref.read(notificationsRepositoryProvider).markRead(notification.id);
          ref.invalidate(notificationsProvider);
        }
        final route = notificationRoute(notification.link);
        if (route != null && mounted) context.push(route);
      });

  Future<void> _markAllRead() => _runAction(() async {
        await ref.read(notificationsRepositoryProvider).markAllRead();
        ref.invalidate(notificationsProvider);
      });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final page = ref.watch(notificationsProvider);
    final value = page.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (value != null && value.unreadCount > 0)
            TextButton(
              key: const Key('notifications-mark-all'),
              onPressed: _actionInProgress ? null : _markAllRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: value != null
          ? RefreshIndicator(
              onRefresh: () async => ref.refresh(notificationsProvider.future),
              child: value.results.isEmpty
                  ? ListView(children: const [
                      SizedBox(height: 120),
                      EmptyState(
                        icon: Icons.notifications_none,
                        message: "You're all caught up. Payments, overdue invoices, and replies to your documents show up here.",
                      ),
                    ])
                  : ListView(
                      children: [
                        if (_actionError != null)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: ActionErrorBanner(
                              message: _actionError!,
                              onRetry: _lastAction == null || _actionInProgress ? null : () => _runAction(_lastAction!),
                            ),
                          ),
                        for (final notification in value.results)
                          ListTile(
                            key: Key('notification-${notification.id}'),
                            leading: Icon(
                              notification.isUnread ? Icons.circle : Icons.circle_outlined,
                              size: 12,
                              color: notification.isUnread ? colors.accent : colors.neutral300,
                            ),
                            title: Text(
                              notification.title,
                              style: TextStyle(fontWeight: notification.isUnread ? FontWeight.w600 : FontWeight.w400),
                            ),
                            subtitle: Text([
                              if (notification.body != null) notification.body!,
                              relativeTime(notification.createdAt),
                            ].join('\n')),
                            isThreeLine: notification.body != null,
                            trailing: notificationRoute(notification.link) != null ? const Icon(Icons.chevron_right) : null,
                            onTap: _actionInProgress ? null : () => _open(notification),
                          ),
                      ],
                    ),
            )
          : page.hasError
              ? ErrorState(
                  message: "Couldn't load your notifications",
                  onRetry: () => ref.invalidate(notificationsProvider),
                )
              : const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(children: [
                    LoadingSkeleton(height: 56),
                    SizedBox(height: 12),
                    LoadingSkeleton(height: 56),
                    SizedBox(height: 12),
                    LoadingSkeleton(height: 56),
                  ]),
                ),
    );
  }
}
