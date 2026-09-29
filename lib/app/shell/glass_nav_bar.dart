import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/widgets/glass_surface.dart';
import '../theme/app_colors.dart';

class NavDestination {
  const NavDestination({required this.icon, required this.selectedIcon, required this.label, this.badge = 0});

  final IconData icon;
  final IconData selectedIcon;
  final String label;

  /// Zero hides the badge.
  final int badge;
}

/// A floating capsule tab bar. The selected tab sits in a soft capsule that
/// slides between tabs and its icon fills in. Tabs are icon-only, so the label
/// lives in the accessibility semantics instead.
class GlassNavBar extends StatelessWidget {
  const GlassNavBar({super.key, required this.destinations, required this.currentIndex, required this.onSelected});

  static const height = 64.0;
  static const _inset = 6.0;

  final List<NavDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return SizedBox(
      height: height,
      child: GlassSurface(
        padding: const EdgeInsets.all(_inset),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / destinations.length;
            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  left: itemWidth * currentIndex,
                  top: 0,
                  bottom: 0,
                  width: itemWidth,
                  child: DecoratedBox(
                    key: const Key('nav-highlight'),
                    decoration: BoxDecoration(
                      color: colors.primary500.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < destinations.length; i++)
                      Expanded(
                        child: _NavItem(
                          key: Key('nav-tab-$i'),
                          destination: destinations[i],
                          selected: i == currentIndex,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onSelected(i);
                          },
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({super.key, required this.destination, required this.selected, required this.onTap});

  final NavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final color = selected ? colors.accent : colors.neutral600;
    final label = destination.badge > 0
        ? '${destination.label}, ${destination.badge} overdue'
        : destination.label;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: Center(
          child: Badge(
            isLabelVisible: destination.badge > 0,
            label: Text(destination.badge > 99 ? '99+' : '${destination.badge}'),
            child: Icon(selected ? destination.selectedIcon : destination.icon, size: 26, color: color),
          ),
        ),
      ),
    );
  }
}
