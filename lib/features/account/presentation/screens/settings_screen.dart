import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/widgets/action_error_banner.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../auth/presentation/providers/active_business_provider.dart';
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
    final business = ref.watch(currentBusinessProvider);
    final isOwner = ref.watch(isOwnerOfActiveBusinessProvider);
    final media = MediaQuery.of(context);
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, media.padding.top + 16, 16, media.padding.bottom + 16),
        children: [
          Text('Profile', style: textTheme.headlineSmall),
          const SizedBox(height: 16),
          if (user != null)
            Row(
              children: [
                UserAvatar(user: user, radius: 30),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name?.isNotEmpty == true ? user.name! : user.email,
                        style: textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (user.name?.isNotEmpty == true)
                        Text(user.email, style: textTheme.bodyMedium?.copyWith(color: colors.neutral500), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          if (business != null) ...[
            const SizedBox(height: 16),
            _Row(
              rowKey: const Key('settings-switch-business'),
              icon: Icons.swap_horiz,
              title: business.name,
              subtitle: 'Switch business',
              onTap: () => context.push('/businesses'),
              highlighted: true,
            ),
          ],
          const _SectionLabel('Business'),
          if (isOwner)
            _Row(
              rowKey: const Key('settings-business'),
              icon: Icons.storefront_outlined,
              title: 'Business settings',
              onTap: () => context.push('/settings/business'),
            ),
          if (isOwner)
            _Row(
              rowKey: const Key('settings-team'),
              icon: Icons.group_outlined,
              title: 'Team',
              onTap: () => context.push('/team'),
            ),
          _Row(
            rowKey: const Key('settings-items'),
            icon: Icons.inventory_2_outlined,
            title: 'Items',
            onTap: () => context.push('/items'),
          ),
          const _SectionLabel('Account'),
          _Row(
            rowKey: const Key('settings-profile'),
            icon: Icons.person_outline,
            title: 'Your details',
            onTap: () => context.push('/settings/profile'),
          ),
          _Row(
            rowKey: const Key('settings-security'),
            icon: Icons.lock_outline,
            title: 'Security',
            onTap: () => context.push('/settings/security'),
          ),
          _Row(
            rowKey: const Key('settings-notifications'),
            icon: Icons.notifications_none,
            title: 'Notifications',
            onTap: () => context.push('/settings/notifications'),
          ),
          _Row(
            rowKey: const Key('settings-appearance'),
            icon: Icons.palette_outlined,
            title: 'Appearance',
            onTap: () => context.push('/settings/appearance'),
          ),
          const SizedBox(height: 16),
          _Row(
            rowKey: const Key('settings-sign-out'),
            icon: Icons.logout,
            title: 'Sign out',
            onTap: _signingOut ? null : _signOut,
            destructive: true,
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(text.toUpperCase(), style: Theme.of(context).textTheme.labelMedium?.copyWith(color: colors.neutral500)),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.rowKey,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.highlighted = false,
    this.destructive = false,
  });

  final Key rowKey;
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool highlighted;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final foreground = destructive ? colors.error : colors.neutral900;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: highlighted ? colors.primary100 : colors.neutral50,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          key: rowKey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          leading: Icon(icon, color: destructive ? colors.error : (highlighted ? colors.primary700 : colors.neutral700)),
          title: Text(title, style: TextStyle(color: foreground)),
          subtitle: subtitle == null ? null : Text(subtitle!),
          trailing: destructive ? null : Icon(Icons.chevron_right, color: colors.neutral400),
          enabled: onTap != null,
          onTap: onTap,
        ),
      ),
    );
  }
}
