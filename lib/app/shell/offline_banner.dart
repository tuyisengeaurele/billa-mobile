import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/connectivity_provider.dart';
import '../theme/app_colors.dart';

/// A slim strip under the status bar that explains why the data on screen may
/// be old, so a stale figure is never mistaken for a current one.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key, required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notice = ref.watch(connectionNoticeProvider);
    final colors = Theme.of(context).extension<AppColors>()!;

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: notice == ConnectionNotice.none
          ? const SizedBox(width: double.infinity)
          : Material(
              color: colors.warningBg,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        notice == ConnectionNotice.offline ? Icons.cloud_off_outlined : Icons.history,
                        size: 18,
                        color: colors.neutral800,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          notice == ConnectionNotice.offline ? "You're offline. Showing saved data." : 'Showing saved data',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: colors.neutral800),
                        ),
                      ),
                      if (notice == ConnectionNotice.saved)
                        TextButton(
                          onPressed: onRefresh,
                          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                          child: const Text('Refresh'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
