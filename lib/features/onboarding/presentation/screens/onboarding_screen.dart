import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/widgets/action_error_banner.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../providers/business_repository_provider.dart';
import '../providers/logo_pipeline_provider.dart';
import '../widgets/details_step.dart';
import '../widgets/logo_step.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  bool _busy = false;
  String? _error;
  Future<void> Function()? _lastAction;

  // Every onboarding action goes through here: a failure becomes a message
  // with a Retry that repeats the same action, instead of an unhandled error
  // that leaves the user on a screen that did nothing.
  Future<void> _guard(Future<void> Function() action) async {
    _lastAction = action;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => _error = describeActionError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _completeAndRefresh() async {
    await ref.read(businessRepositoryProvider).completeOnboarding();
    ref.invalidate(authControllerProvider);
    await ref.read(authControllerProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step ${_step + 1} of 2'),
        actions: [
          TextButton(
            onPressed: _busy ? null : () => _guard(_completeAndRefresh),
            child: const Text('Skip onboarding', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null) ...[
                ActionErrorBanner(
                  message: _error!,
                  onRetry: _lastAction == null || _busy ? null : () => _guard(_lastAction!),
                ),
                const SizedBox(height: 16),
              ],
              if (_step == 0)
                DetailsStep(
                  onSaved: (name, tin, industry, phone, email, address, rraEbmNumber) => _guard(() async {
                    await ref.read(businessRepositoryProvider).updateProfile(
                          name: name,
                          tin: tin,
                          industry: industry,
                          phone: phone,
                          email: email,
                          address: address,
                          rraEbmNumber: rraEbmNumber,
                        );
                    setState(() => _step = 1);
                  }),
                  onSkip: () => setState(() => _step = 1),
                )
              else
                LogoStep(
                  service: ref.watch(logoPipelineServiceProvider),
                  onDone: _completeAndRefresh,
                  onSkip: () => _guard(_completeAndRefresh),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
