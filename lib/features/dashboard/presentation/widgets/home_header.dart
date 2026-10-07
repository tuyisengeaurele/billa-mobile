import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../account/presentation/widgets/user_avatar.dart';
import '../../../auth/domain/auth_status.dart';
import '../../../auth/presentation/providers/active_business_provider.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';

final homeClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

String greetingFor(DateTime now) {
  if (now.hour < 12) return 'Good morning';
  if (now.hour < 17) return 'Good afternoon';
  return 'Good evening';
}

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final auth = ref.watch(authControllerProvider).valueOrNull;
    final user = auth is Authenticated ? auth.user : null;
    final business = ref.watch(currentBusinessProvider);
    final unread = ref.watch(notificationsProvider).valueOrNull?.unreadCount ?? 0;
    final fullName = user?.name?.trim() ?? '';
    final firstName = fullName.isEmpty ? null : fullName.split(RegExp(r'\s+')).first;
    final greeting = greetingFor(ref.watch(homeClockProvider)());

    return Row(
      children: [
        Semantics(
          button: true,
          label: 'Profile',
          excludeSemantics: true,
          child: GestureDetector(
            key: const Key('home-avatar'),
            onTap: () => context.go('/settings'),
            child: user == null ? const CircleAvatar(radius: 22) : UserAvatar(user: user, radius: 22),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            key: const Key('home-business-switcher'),
            borderRadius: BorderRadius.circular(8),
            onTap: () => context.push('/businesses'),
            child: Padding(
              // Comfortable to tap: the row is only as tall as its two lines
              // otherwise, which is under the 48 dp minimum for a target.
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    firstName == null ? greeting : '$greeting, $firstName',
                    style: textTheme.labelMedium?.copyWith(color: colors.neutral500),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Text(business?.name ?? 'Billa', style: textTheme.titleMedium, overflow: TextOverflow.ellipsis),
                      ),
                      Icon(Icons.keyboard_arrow_down, size: 20, color: colors.neutral500),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _RoundButton(
          key: const Key('home-search'),
          icon: const Icon(Icons.search),
          tooltip: 'Search',
          onPressed: () => context.push('/search'),
        ),
        const SizedBox(width: 8),
        _RoundButton(
          key: const Key('home-bell'),
          icon: Badge(
            isLabelVisible: unread > 0,
            label: Text(unread > 99 ? '99+' : '$unread'),
            child: const Icon(Icons.notifications_none),
          ),
          tooltip: unread > 0 ? 'Notifications, $unread unread' : 'Notifications',
          onPressed: () => context.push('/notifications'),
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({super.key, required this.icon, required this.tooltip, required this.onPressed});

  final Widget icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return IconButton(
      icon: icon,
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: colors.neutral100,
        foregroundColor: colors.neutral800,
        fixedSize: const Size(44, 44),
      ),
    );
  }
}
