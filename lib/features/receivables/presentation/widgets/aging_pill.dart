import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class AgingPill extends StatelessWidget {
  const AgingPill({super.key, required this.bucket});

  final String bucket;

  String get _label => switch (bucket) {
        'current' => 'Current',
        '0-30' => '0-30 days',
        '31-60' => '31-60 days',
        '61-90' => '61-90 days',
        _ => '90+ days',
      };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final (background, foreground) = switch (bucket) {
      'current' => (colors.neutral200, colors.neutral600),
      '0-30' || '31-60' => (colors.warningBg, colors.warning),
      _ => (colors.errorBg, colors.error),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(_label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: foreground)),
    );
  }
}
