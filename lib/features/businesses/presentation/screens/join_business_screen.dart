import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/widgets/action_error_banner.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../domain/invite_preview.dart';
import '../../domain/invite_token.dart';
import '../providers/businesses_repository_provider.dart';

class JoinBusinessScreen extends ConsumerStatefulWidget {
  const JoinBusinessScreen({super.key});

  @override
  ConsumerState<JoinBusinessScreen> createState() => _JoinBusinessScreenState();
}

class _JoinBusinessScreenState extends ConsumerState<JoinBusinessScreen> {
  final _linkController = TextEditingController();
  String? _token;
  InvitePreview? _preview;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _loadPreview() async {
    final token = extractInviteToken(_linkController.text);
    if (token == null) {
      setState(() => _error = 'Paste the invite link from your email');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _preview = null;
    });
    try {
      final preview = await ref.read(businessesRepositoryProvider).previewInvite(token);
      if (mounted) {
        setState(() {
          _token = token;
          _preview = preview;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = describeActionError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _accept() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final business = await ref.read(businessesRepositoryProvider).acceptInvite(_token!);
      if (!mounted) return;
      ref.read(authControllerProvider.notifier).setBusiness(business);
      context.go('/');
    } catch (e) {
      if (mounted) setState(() => _error = describeActionError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = _preview;
    final blockedReason = preview == null
        ? null
        : preview.alreadyAccepted
            ? 'This invite was already accepted'
            : preview.expired
                ? 'This invite has expired'
                : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Join a business')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const Key('invite-link'),
              controller: _linkController,
              decoration: const InputDecoration(labelText: 'Invite link'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: const Key('invite-continue'),
              onPressed: (_busy || _linkController.text.trim().isEmpty) ? null : _loadPreview,
              child: const Text('Continue'),
            ),
            if (preview != null) ...[
              const SizedBox(height: 24),
              Text('Join ${preview.businessName}', style: Theme.of(context).textTheme.titleMedium),
              Text('Invited: ${preview.email}'),
              if (blockedReason != null) ...[
                const SizedBox(height: 8),
                Text(blockedReason),
              ],
              const SizedBox(height: 16),
              FilledButton(
                key: const Key('invite-accept'),
                onPressed: (_busy || blockedReason != null) ? null : _accept,
                child: const Text('Accept'),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              ActionErrorBanner(message: _error!, onRetry: _busy ? null : (preview == null ? _loadPreview : _accept)),
            ],
          ],
        ),
      ),
    );
  }
}
