import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/action_errors.dart';
import '../../core/widgets/animated_brand_mark.dart';
import '../../core/widgets/error_state.dart';
import '../../features/auth/presentation/providers/auth_controller.dart';
import 'app_colors.dart';

class BootstrapScreen extends ConsumerWidget {
  const BootstrapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    // Without this the app sits on a spinner forever when it can't reach the
    // server at launch: the session check failed, so there is no next screen.
    if (auth.hasError) {
      return Scaffold(
        body: ErrorState(
          message: describeActionError(auth.error!),
          onRetry: () => ref.invalidate(authControllerProvider),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AnimatedBrandMark(),
            const SizedBox(height: 32),
            Text('Billa', style: textTheme.displayMedium),
            const SizedBox(height: 8),
            Text(
              'Invoices, quotes and receipts for your business',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: colors.neutral600),
            ),
            const SizedBox(height: 48),
            Text('Checking your session…', style: textTheme.labelMedium?.copyWith(color: colors.neutral500)),
          ],
        ),
      ),
    );
  }
}
