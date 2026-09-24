import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/widgets/action_error_banner.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../domain/notification_type.dart';
import '../providers/profile_repository_provider.dart';

class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  ConsumerState<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends ConsumerState<NotificationPreferencesScreen> {
  late Future<Map<NotificationType, bool>> _future;
  Map<NotificationType, bool>? _preferences;
  bool _actionInProgress = false;
  String? _actionError;
  Future<void> Function()? _lastAction;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<NotificationType, bool>> _load() async {
    final loaded = await ref.read(profileRepositoryProvider).notificationPreferences();
    _preferences = loaded;
    return loaded;
  }

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

  Future<void> _toggle(NotificationType type, bool enabled) => _runAction(() async {
        final merged = await ref.read(profileRepositoryProvider).setNotificationPreference(type, enabled);
        if (mounted) setState(() => _preferences = merged);
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: FutureBuilder<Map<NotificationType, bool>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorState(
              message: "Couldn't load your notification settings",
              onRetry: () => setState(() {
                _future = _load();
              }),
            );
          }
          if (!snapshot.hasData) {
            return const Padding(padding: EdgeInsets.all(16), child: LoadingSkeleton(height: 64));
          }
          final preferences = _preferences ?? snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final type in NotificationType.values)
                SwitchListTile(
                  key: Key('notification-${type.wireName}'),
                  title: Text(type.label),
                  value: preferences[type] ?? true,
                  onChanged: _actionInProgress ? null : (value) => _toggle(type, value),
                ),
              if (_actionError != null) ...[
                const SizedBox(height: 8),
                ActionErrorBanner(
                  message: _actionError!,
                  onRetry: _lastAction == null || _actionInProgress ? null : () => _runAction(_lastAction!),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
