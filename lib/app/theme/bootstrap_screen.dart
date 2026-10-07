import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/action_errors.dart';
import '../../core/widgets/error_state.dart';
import '../../features/auth/presentation/providers/auth_controller.dart';

class BootstrapScreen extends ConsumerWidget {
  const BootstrapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

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
            Text('Billa', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 24),
            const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(height: 16),
            Text('Checking your session…', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
