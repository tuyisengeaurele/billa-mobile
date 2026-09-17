import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client_provider.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../data/logo_pipeline_service.dart';
import '../providers/business_repository_provider.dart';
import '../widgets/details_step.dart';
import '../widgets/logo_step.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;

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
            onPressed: _completeAndRefresh,
            child: const Text('Skip onboarding', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _step == 0
              ? DetailsStep(
                  onSaved: (name, tin, industry, phone, email, address, rraEbmNumber) async {
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
                  },
                  onSkip: () => setState(() => _step = 1),
                )
              : LogoStep(
                  service: LogoPipelineService(ref.watch(apiClientProvider).dio),
                  onDone: _completeAndRefresh,
                  onSkip: _completeAndRefresh,
                ),
        ),
      ),
    );
  }
}
