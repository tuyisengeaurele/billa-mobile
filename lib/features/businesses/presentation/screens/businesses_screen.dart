import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/widgets/action_error_banner.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/text_prompt_dialog.dart';
import '../../../auth/presentation/providers/active_business_provider.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../onboarding/domain/business.dart';
import '../../domain/business_summary.dart';
import '../providers/businesses_repository_provider.dart';
import '../providers/my_businesses_provider.dart';

class BusinessesScreen extends ConsumerStatefulWidget {
  const BusinessesScreen({super.key});

  @override
  ConsumerState<BusinessesScreen> createState() => _BusinessesScreenState();
}

class _BusinessesScreenState extends ConsumerState<BusinessesScreen> {
  bool _actionInProgress = false;
  String? _actionError;
  Future<void> Function()? _lastAction;

  Future<void> _runAction(Future<void> Function() action) async {
    _lastAction = action;
    setState(() {
      _actionInProgress = true;
      _actionError = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => _actionError = describeActionError(e));
    } finally {
      if (mounted) setState(() => _actionInProgress = false);
    }
  }

  // Every path here re-issued the session server-side. Going to `/` drops the
  // pushed stack so no screen holding the previous business's data survives.
  void _enter(Business business) {
    ref.read(authControllerProvider.notifier).setBusiness(business);
    context.go('/');
  }

  Future<void> _switchTo(BusinessSummary target) => _runAction(() async {
        final business = await ref.read(businessesRepositoryProvider).switchTo(target.id);
        if (mounted) _enter(business);
      });

  Future<void> _create() async {
    final name = await showTextPromptDialog(
      context,
      title: 'New business',
      label: 'Business name',
      confirmLabel: 'Create',
    );
    if (name == null) return;
    await _runAction(() async {
      final business = await ref.read(businessesRepositoryProvider).create(name);
      if (mounted) _enter(business);
    });
  }

  Future<void> _leave() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Leave this business?',
      content: "You'll lose access until someone invites you again.",
      confirmLabel: 'Leave',
    );
    if (!confirmed) return;
    await _runAction(() async {
      final result = await ref.read(businessesRepositoryProvider).leaveCurrent();
      if (mounted) _enter(result.business);
    });
  }

  @override
  Widget build(BuildContext context) {
    final businesses = ref.watch(myBusinessesProvider);
    final activeId = ref.watch(activeBusinessIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Businesses')),
      body: switch (businesses) {
        AsyncData(:final value) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final business in value)
                ListTile(
                  title: Text(business.name),
                  subtitle: Text(business.isOwner ? 'Owner' : 'Member'),
                  trailing: business.id == activeId ? const Icon(Icons.check) : null,
                  onTap: (business.id == activeId || _actionInProgress) ? null : () => _switchTo(business),
                ),
              if (_actionError != null) ...[
                const SizedBox(height: 8),
                ActionErrorBanner(
                  message: _actionError!,
                  onRetry: _lastAction == null ? null : () => _runAction(_lastAction!),
                ),
              ],
              const SizedBox(height: 16),
              OutlinedButton(
                key: const Key('businesses-new'),
                onPressed: _actionInProgress ? null : _create,
                child: const Text('New business'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                key: const Key('businesses-join'),
                onPressed: _actionInProgress ? null : () => context.push('/businesses/join'),
                child: const Text('Join a business'),
              ),
              if (value.any((b) => b.id == activeId && !b.isOwner)) ...[
                const SizedBox(height: 8),
                TextButton(
                  key: const Key('businesses-leave'),
                  onPressed: _actionInProgress ? null : _leave,
                  child: const Text('Leave this business'),
                ),
              ],
            ],
          ),
        AsyncError() => ErrorState(
            message: "Couldn't load your businesses",
            onRetry: () => ref.invalidate(myBusinessesProvider),
          ),
        _ => const Padding(
            padding: EdgeInsets.all(16),
            child: Column(children: [LoadingSkeleton(height: 56), SizedBox(height: 12), LoadingSkeleton(height: 56)]),
          ),
      },
    );
  }
}
