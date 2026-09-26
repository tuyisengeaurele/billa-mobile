import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/security/app_lock.dart';
import '../../../core/widgets/app_button.dart';

/// Covers the whole app until the phone's owner is confirmed. It shows no
/// business data of its own, only the logo and a way to try again.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  bool _failed = false;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
  }

  Future<void> _unlock() async {
    if (_checking || !mounted) return;
    setState(() {
      _checking = true;
      _failed = false;
    });
    final proven = await ref.read(appLockProvider.notifier).unlock();
    if (mounted) {
      setState(() {
        _checking = false;
        _failed = !proven;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      key: const Key('lock-screen'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Image.asset('assets/logo.png', height: 72, semanticLabel: 'Billa')),
              const SizedBox(height: 32),
              Text('Billa is locked', textAlign: TextAlign.center, style: textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Use your fingerprint, face or screen lock to continue.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: colors.neutral600),
              ),
              if (_failed) ...[
                const SizedBox(height: 16),
                Text("Couldn't confirm it's you. Try again", textAlign: TextAlign.center, style: TextStyle(color: colors.error)),
              ],
              const SizedBox(height: 32),
              AppButton(key: const Key('lock-unlock'), label: 'Unlock', onPressed: _unlock, isLoading: _checking),
            ],
          ),
        ),
      ),
    );
  }
}
