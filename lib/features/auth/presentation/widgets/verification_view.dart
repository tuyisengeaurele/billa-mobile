import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/code_input.dart';
import 'auth_layout.dart';

/// "ada@example.com" becomes "a***@example.com", enough to recognise the
/// account without putting the whole address on screen.
String maskEmail(String email) {
  final at = email.indexOf('@');
  if (at < 1) return email;
  return '${email[0]}***${email.substring(at)}';
}

String _clock(int seconds) => '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

/// The sign-in code step: six boxes for the authenticator code, a switch to a
/// backup code, a countdown to when the server drops the pending sign-in, and
/// the retry paths for every failure.
class VerificationView extends StatefulWidget {
  const VerificationView({
    super.key,
    required this.controller,
    required this.isSubmitting,
    required this.onSubmit,
    required this.onBack,
    this.email,
    this.errorMessage,
    this.validFor = const Duration(minutes: 5),
  });

  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final VoidCallback onBack;
  final String? email;
  final String? errorMessage;

  /// How long the server keeps the pending sign-in open.
  final Duration validFor;

  @override
  State<VerificationView> createState() => _VerificationViewState();
}

class _VerificationViewState extends State<VerificationView> {
  late int _remaining = widget.validFor.inSeconds;
  Timer? _timer;
  bool _backup = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) timer.cancel();
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    _timer?.cancel();
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  bool get _canSubmit {
    final length = widget.controller.text.trim().length;
    return _backup ? length >= 6 : length == 6;
  }

  void _toggleBackup() {
    widget.controller.clear();
    setState(() => _backup = !_backup);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final email = widget.email;
    final hasError = widget.errorMessage != null;

    if (_remaining == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthError(message: 'This sign-in expired. Log in again to get a new code.'),
          const SizedBox(height: 24),
          AppButton(key: const Key('verification-expired-back'), label: 'Back to login', onPressed: widget.onBack),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (email != null && email.isNotEmpty)
          Row(
            children: [
              Flexible(child: Text(maskEmail(email), style: textTheme.titleSmall, overflow: TextOverflow.ellipsis)),
              TextButton(
                key: const Key('verification-change'),
                onPressed: widget.onBack,
                child: const Text('Change'),
              ),
            ],
          ),
        const SizedBox(height: 8),
        if (_backup)
          TextField(
            key: const Key('login-2fa-code'),
            controller: widget.controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            maxLength: 10,
            decoration: const InputDecoration(labelText: 'Backup code', counterText: ''),
          )
        else
          CodeInput(
            fieldKey: const Key('login-2fa-code'),
            controller: widget.controller,
            autofocus: true,
            hasError: hasError,
            enabled: !widget.isSubmitting,
          ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Code request expires in ${_clock(_remaining)}',
            key: const Key('verification-countdown'),
            style: textTheme.bodySmall?.copyWith(color: _remaining <= 60 ? colors.warning : colors.neutral500),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 12),
          AuthError(message: widget.errorMessage!),
        ],
        const SizedBox(height: 24),
        AppButton(
          key: const Key('verification-submit'),
          label: 'Verify',
          onPressed: _canSubmit ? widget.onSubmit : null,
          isLoading: widget.isSubmitting,
        ),
        const SizedBox(height: 8),
        TextButton(
          key: const Key('verification-toggle-backup'),
          onPressed: _toggleBackup,
          child: Text(_backup ? 'Use my authenticator app' : 'Use a backup code instead'),
        ),
        if (email == null || email.isEmpty)
          TextButton(key: const Key('verification-back'), onPressed: widget.onBack, child: const Text('Back to login')),
      ],
    );
  }
}
