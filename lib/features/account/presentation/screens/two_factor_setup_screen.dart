import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/widgets/action_error_banner.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../domain/two_factor_setup.dart';
import '../providers/security_repository_provider.dart';

class TwoFactorSetupScreen extends ConsumerStatefulWidget {
  const TwoFactorSetupScreen({super.key});

  @override
  ConsumerState<TwoFactorSetupScreen> createState() => _TwoFactorSetupScreenState();
}

class _TwoFactorSetupScreenState extends ConsumerState<TwoFactorSetupScreen> {
  late Future<TwoFactorSetup> _setup;
  final _code = TextEditingController();
  List<String>? _backupCodes;
  bool _saved = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _setup = ref.read(securityRepositoryProvider).setUpTwoFactor();
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final codes = await ref.read(securityRepositoryProvider).verifyTwoFactor(_code.text.trim());
      // The server has turned 2FA on as of this response, so the local user
      // reflects it now rather than when the codes are dismissed.
      ref.read(authControllerProvider.notifier).updateUser((user) => user.copyWith(totpEnabled: true));
      if (mounted) setState(() => _backupCodes = codes);
    } catch (e) {
      if (mounted) setState(() => _error = describeActionError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _copy(String text, String what) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$what copied')));
    }
  }

  void _done() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/settings/security');
    }
  }

  @override
  Widget build(BuildContext context) {
    final codes = _backupCodes;
    return Scaffold(
      appBar: AppBar(title: const Text('Two-factor authentication')),
      body: codes != null ? _backupCodesView(codes) : _setupView(),
    );
  }

  Widget _backupCodesView(List<String> codes) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Two-factor is on', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text(
          'Save these backup codes somewhere safe. Each works once if you lose your authenticator, '
          "and they won't be shown again.",
        ),
        const SizedBox(height: 16),
        for (final code in codes) SelectableText(code, style: const TextStyle(fontFamily: 'monospace', fontSize: 18)),
        const SizedBox(height: 8),
        TextButton(
          key: const Key('two-factor-copy-codes'),
          onPressed: () => _copy(codes.join('\n'), 'Backup codes'),
          child: const Text('Copy codes'),
        ),
        CheckboxListTile(
          key: const Key('two-factor-saved'),
          value: _saved,
          onChanged: (value) => setState(() => _saved = value ?? false),
          title: const Text("I've saved these codes"),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        FilledButton(
          key: const Key('two-factor-done'),
          onPressed: _saved ? _done : null,
          child: const Text('Done'),
        ),
      ],
    );
  }

  Widget _setupView() {
    return FutureBuilder<TwoFactorSetup>(
      future: _setup,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorState(
            message: describeActionError(snapshot.error!),
            onRetry: () => setState(() {
              _setup = ref.read(securityRepositoryProvider).setUpTwoFactor();
            }),
          );
        }
        if (!snapshot.hasData) {
          return const Padding(padding: EdgeInsets.all(24), child: LoadingSkeleton(height: 220));
        }
        final setup = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text('Scan this QR code with an authenticator app, then enter the 6-digit code it shows.'),
            const SizedBox(height: 16),
            Center(child: _QrImage(dataUri: setup.qrCodeDataUri)),
            const SizedBox(height: 16),
            const Text("Can't scan it? Enter this key instead:"),
            SelectableText(setup.secret, style: const TextStyle(fontFamily: 'monospace', fontSize: 16)),
            TextButton(
              key: const Key('two-factor-copy-secret'),
              onPressed: () => _copy(setup.secret, 'Key'),
              child: const Text('Copy key'),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('two-factor-code'),
              controller: _code,
              decoration: const InputDecoration(labelText: '6-digit code'),
              keyboardType: TextInputType.number,
              maxLength: 6,
              onChanged: (_) => setState(() {}),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              ActionErrorBanner(message: _error!, onRetry: _busy ? null : _verify),
            ],
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('two-factor-verify'),
              onPressed: (_busy || _code.text.trim().length != 6) ? null : _verify,
              child: const Text('Verify'),
            ),
          ],
        );
      },
    );
  }
}

class _QrImage extends StatelessWidget {
  const _QrImage({required this.dataUri});

  final String dataUri;

  @override
  Widget build(BuildContext context) {
    try {
      final bytes = base64Decode(dataUri.substring(dataUri.indexOf(',') + 1));
      return Image.memory(
        bytes,
        width: 220,
        height: 220,
        errorBuilder: (context, error, stackTrace) => const Text('QR code unavailable — use the key below'),
      );
    } on FormatException {
      return const Text('QR code unavailable — use the key below');
    }
  }
}
