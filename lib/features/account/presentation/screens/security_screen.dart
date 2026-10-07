import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/widgets/action_error_banner.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../../../core/widgets/text_prompt_dialog.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../providers/current_user_provider.dart';
import '../providers/security_repository_provider.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
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

  Future<void> _turnOffTwoFactor() async {
    final code = await showTextPromptDialog(
      context,
      title: 'Turn off two-factor?',
      label: 'Authenticator or backup code',
      confirmLabel: 'Turn off',
    );
    if (code == null) return;
    await _runAction(() async {
      await ref.read(securityRepositoryProvider).disableTwoFactor(code);
      ref.read(authControllerProvider.notifier).updateUser((user) => user.copyWith(totpEnabled: false));
    });
  }

  Future<void> _deleteAccount() async {
    final email = ref.read(currentUserProvider)?.email;
    if (email == null) return;
    final confirmed = await showAppSheet<bool>(
      context,
      builder: (context) => _DeleteAccountSheet(email: email),
    );
    if (confirmed != true) return;
    await _runAction(() async {
      await ref.read(securityRepositoryProvider).deleteAccount();
      ref.read(authControllerProvider.notifier).clearSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final twoFactorOn = user?.totpEnabled ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Two-factor authentication'),
            subtitle: Text(twoFactorOn ? 'On' : 'Off'),
            trailing: TextButton(
              key: const Key('security-two-factor'),
              onPressed: _actionInProgress
                  ? null
                  : (twoFactorOn ? _turnOffTwoFactor : () => context.push('/settings/security/two-factor')),
              child: Text(twoFactorOn ? 'Turn off' : 'Turn on'),
            ),
          ),
          ListTile(
            key: const Key('security-sessions'),
            title: const Text('Signed-in devices'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/security/sessions'),
          ),
          if (_actionError != null) ...[
            const SizedBox(height: 8),
            ActionErrorBanner(
              message: _actionError!,
              onRetry: _lastAction == null || _actionInProgress ? null : () => _runAction(_lastAction!),
            ),
          ],
          const Divider(height: 32),
          ListTile(
            key: const Key('security-delete'),
            leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
            title: Text('Delete account', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            enabled: !_actionInProgress,
            onTap: _deleteAccount,
          ),
        ],
      ),
    );
  }
}

/// Typing the address is the only guard: deletion is irreversible, so a stray
/// tap on a confirm button must not be enough.
class _DeleteAccountSheet extends StatefulWidget {
  const _DeleteAccountSheet({required this.email});

  final String email;

  @override
  State<_DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<_DeleteAccountSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matches = _controller.text.trim().toLowerCase() == widget.email.toLowerCase();
    return AppSheetContent(
      title: 'Delete your account?',
      message: 'This permanently deletes your account and cannot be undone. Type ${widget.email} to confirm.',
      actions: SheetActions(
        confirmKey: const Key('delete-confirm'),
        confirmLabel: 'Delete account',
        destructive: true,
        onCancel: () => Navigator.pop(context, false),
        onConfirm: matches ? () => Navigator.pop(context, true) : null,
      ),
      children: [
        TextField(
          key: const Key('delete-email'),
          controller: _controller,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Your email'),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }
}
