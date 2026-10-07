import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/providers/dashboard_provider.dart';
import 'glass_nav_bar.dart';
import 'quick_create.dart';

/// Hosts the five tab roots under a floating glass tab bar, with the
/// quick-create button beside it. Screens pushed on top (details, editors,
/// forms) are routes outside this shell, so they cover the bar entirely.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _profileIndex = 4;
  static const _gap = 12.0;
  static const _margin = 16.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overdue = ref.watch(overdueCountProvider);
    final media = MediaQuery.of(context);
    final index = navigationShell.currentIndex;
    final keyboardOpen = media.viewInsets.bottom > 0;

    final destinations = [
      const NavDestination(icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: 'Home'),
      const NavDestination(icon: Icons.description_outlined, selectedIcon: Icons.description, label: 'Documents'),
      const NavDestination(icon: Icons.people_outline, selectedIcon: Icons.people, label: 'Customers'),
      NavDestination(
        icon: Icons.account_balance_wallet_outlined,
        selectedIcon: Icons.account_balance_wallet,
        label: 'Payments',
        badge: overdue,
      ),
      const NavDestination(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profile'),
    ];

    // Screens scroll under the bar, so they are told the bar's footprint as
    // bottom padding and can keep their last row clear of it.
    final barBottom = media.padding.bottom + _margin;
    final reserved = barBottom + GlassNavBar.height + _gap;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          MediaQuery(
            data: media.copyWith(padding: media.padding.copyWith(bottom: keyboardOpen ? media.padding.bottom : reserved)),
            child: navigationShell,
          ),
          Positioned(
            left: _margin,
            right: _margin,
            bottom: barBottom,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              offset: keyboardOpen ? const Offset(0, 2) : Offset.zero,
              child: Row(
                children: [
                  Expanded(
                    child: GlassNavBar(
                      destinations: destinations,
                      currentIndex: index,
                      // Reselecting the tab you are on returns it to its root,
                      // the way every tabbed phone app behaves.
                      onSelected: (i) => navigationShell.goBranch(i, initialLocation: i == index),
                    ),
                  ),
                  if (index != _profileIndex) ...[
                    const SizedBox(width: _gap),
                    const QuickCreateButton(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
