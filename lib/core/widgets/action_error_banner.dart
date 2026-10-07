import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';

class ActionErrorBanner extends StatelessWidget {
  const ActionErrorBanner({super.key, required this.message, required this.onRetry, this.retryKey});

  final String message;
  final VoidCallback? onRetry;
  final Key? retryKey;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: colors.errorBg, borderRadius: BorderRadius.circular(AppRadii.small)),
      child: Row(
        children: [
          Expanded(child: Text(message, style: TextStyle(color: colors.error))),
          TextButton(key: retryKey, onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
