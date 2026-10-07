import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/widgets/action_error_banner.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../domain/session_info.dart';
import '../providers/security_repository_provider.dart';

class SessionsScreen extends ConsumerStatefulWidget {
  const SessionsScreen({super.key});

  @override
  ConsumerState<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends ConsumerState<SessionsScreen> {
  late Future<List<SessionInfo>> _future;
  bool _actionInProgress = false;
  String? _actionError;
  Future<void> Function()? _lastAction;

  @override
  void initState() {
    super.initState();
    _future = ref.read(securityRepositoryProvider).sessions();
  }

  void _reload() {
    setState(() {
      _future = ref.read(securityRepositoryProvider).sessions();
    });
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

  Future<void> _revoke(SessionInfo session) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Sign out this device?',
      content: 'It will need to sign in again.',
      confirmLabel: 'Sign out',
    );
    if (!confirmed) return;
    await _runAction(() async {
      await ref.read(securityRepositoryProvider).revokeSession(session.id);
      _reload();
    });
  }

  Future<void> _revokeOthers() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Sign out other devices?',
      content: 'Every device except this one will need to sign in again.',
      confirmLabel: 'Sign out others',
    );
    if (!confirmed) return;
    await _runAction(() async {
      await ref.read(securityRepositoryProvider).revokeOtherSessions();
      _reload();
    });
  }

  String _date(String iso) => iso.split('T').first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signed-in devices')),
      body: FutureBuilder<List<SessionInfo>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorState(message: "Couldn't load your devices", onRetry: _reload);
          }
          if (!snapshot.hasData) {
            return const Padding(padding: EdgeInsets.all(16), child: LoadingSkeleton(height: 64));
          }
          final sessions = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final session in sessions)
                ListTile(
                  title: Text(session.isCurrent ? 'This device' : 'Signed in ${_date(session.createdAt)}'),
                  subtitle: Text('Started ${_date(session.createdAt)} · expires ${_date(session.expiresAt)}'),
                  trailing: session.isCurrent
                      ? null
                      : TextButton(
                          key: Key('session-revoke-${session.id}'),
                          onPressed: _actionInProgress ? null : () => _revoke(session),
                          child: const Text('Sign out'),
                        ),
                ),
              if (_actionError != null) ...[
                const SizedBox(height: 8),
                ActionErrorBanner(
                  message: _actionError!,
                  onRetry: _lastAction == null || _actionInProgress ? null : () => _runAction(_lastAction!),
                ),
              ],
              if (sessions.length > 1) ...[
                const SizedBox(height: 16),
                OutlinedButton(
                  key: const Key('sessions-revoke-others'),
                  onPressed: _actionInProgress ? null : _revokeOthers,
                  child: const Text('Sign out other devices'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
