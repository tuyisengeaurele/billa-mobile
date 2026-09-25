import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/active_business_provider.dart';
import '../../../businesses/presentation/providers/my_businesses_provider.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/revenue_section.dart';
import '../widgets/summary_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _shortcuts = [
    ('home-nav-customers', Icons.people_outline, 'Customers', '/customers'),
    ('home-nav-items', Icons.inventory_2_outlined, 'Items', '/items'),
    ('home-nav-documents', Icons.description_outlined, 'Documents', '/documents'),
    ('home-nav-receivables', Icons.payments_outlined, 'Receivables', '/receivables'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessName = ref.watch(currentBusinessProvider)?.name;
    final isOwner = ref.watch(isOwnerOfActiveBusinessProvider);
    final unread = ref.watch(notificationsProvider).valueOrNull?.unreadCount ?? 0;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        title: businessName == null
            ? const Text('Billa')
            : TextButton.icon(
                key: const Key('home-business-switcher'),
                onPressed: () => context.push('/businesses'),
                icon: const Icon(Icons.swap_horiz),
                label: Text(businessName, overflow: TextOverflow.ellipsis),
              ),
        actions: [
          IconButton(
            key: const Key('home-search'),
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            key: const Key('home-bell'),
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text(unread > 99 ? '99+' : '$unread'),
              child: const Icon(Icons.notifications_none),
            ),
            tooltip: unread > 0 ? 'Notifications, $unread unread' : 'Notifications',
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            key: const Key('home-account'),
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Account',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        // Failures are swallowed here on purpose: each section already shows
        // its own error with a Retry, so the refresh indicator only needs to
        // know when loading has finished.
        onRefresh: () async {
          ref.invalidate(notificationsProvider);
          ref.invalidate(dashboardSummaryProvider);
          ref.invalidate(revenueProvider);
          await Future.wait([
            ref.read(dashboardSummaryProvider.future).then<void>((_) {}, onError: (_) {}),
            ref.read(revenueProvider.future).then<void>((_) {}, onError: (_) {}),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RevenueSection(),
              const SizedBox(height: 24),
              const SummarySection(),
              const SizedBox(height: 24),
              Text('Shortcuts', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (key, icon, label, route) in _shortcuts)
                    OutlinedButton.icon(
                      key: Key(key),
                      onPressed: () => context.push(route),
                      icon: Icon(icon),
                      label: Text(label),
                    ),
                  if (isOwner)
                    OutlinedButton.icon(
                      key: const Key('home-nav-team'),
                      onPressed: () => context.push('/team'),
                      icon: const Icon(Icons.group_outlined),
                      label: const Text('Team'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
