import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/widgets/action_error_banner.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../businesses/presentation/providers/my_businesses_provider.dart';
import '../providers/current_user_provider.dart';
import '../widgets/user_avatar.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _signingOut = false;
  String? _error;

  Future<void> _signOut() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Sign out?',
      content: 'You will need to sign in again to use Billa.',
      confirmLabel: 'Sign out',
    );
    if (!confirmed) return;
    setState(() {
      _signingOut = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).logout();
    } catch (e) {
      if (mounted) setState(() => _error = describeActionError(e));
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isOwner = ref.watch(isOwnerOfActiveBusinessProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (user != null)
            ListTile(
              leading: UserAvatar(user: user),
              title: Text(user.name?.isNotEmpty == true ? user.name! : user.email),
              subtitle: user.name?.isNotEmpty == true ? Text(user.email) : null,
            ),
          const Divider(),
          if (isOwner)
            ListTile(
              key: const Key('settings-business'),
              leading: const Icon(Icons.storefront_outlined),
              title: const Text('Business settings'),
              onTap: () => context.push('/settings/business'),
            ),
          ListTile(
            key: const Key('settings-profile'),
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            onTap: () => context.push('/settings/profile'),
          ),
          ListTile(
            key: const Key('settings-security'),
            leading: const Icon(Icons.lock_outline),
            title: const Text('Security'),
            onTap: () => context.push('/settings/security'),
          ),
          ListTile(
            key: const Key('settings-notifications'),
            leading: const Icon(Icons.notifications_none),
            title: const Text('Notifications'),
            onTap: () => context.push('/settings/notifications'),
          ),
          ListTile(
            key: const Key('settings-appearance'),
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Appearance'),
            onTap: () => context.push('/settings/appearance'),
          ),
          const Divider(),
          ListTile(
            key: const Key('settings-sign-out'),
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            enabled: !_signingOut,
            onTap: _signOut,
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            ActionErrorBanner(message: _error!, onRetry: _signingOut ? null : _signOut),
          ],
        ],
      ),
    );
  }
}
