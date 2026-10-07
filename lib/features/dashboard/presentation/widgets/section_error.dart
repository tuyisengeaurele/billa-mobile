import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';

/// An inline failure for one home section. It stays small and local so a
/// failing section never takes the rest of the dashboard down with it.
class SectionError extends StatelessWidget {
  const SectionError({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: colors.errorBg, borderRadius: BorderRadius.circular(AppRadii.small)),
      child: Row(
        children: [
          Expanded(child: Text(message, style: TextStyle(color: colors.error))),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
