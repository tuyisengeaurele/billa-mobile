import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/google_sign_in_button.dart';
import '../../../../core/widgets/password_field.dart';
import '../../../../core/widgets/step_switcher.dart';
import '../../data/firebase_auth_error.dart';
import 'package:billa_mobile/features/auth/domain/auth_status.dart';
import '../providers/auth_controller.dart';
import '../providers/firebase_auth_service_provider.dart';
import '../widgets/auth_layout.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();

  String? _errorMessage;
  String? _infoMessage;
  String? _challengeId;
  bool _isSubmitting = false;

  Future<void> _submit() async {
    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });
    try {
      final idToken = await ref
          .read(firebaseAuthServiceProvider)
          .signInWithEmailAndPassword(_emailController.text.trim(), _passwordController.text);
      await ref.read(authControllerProvider.notifier).exchangeSession(idToken: idToken);
      final status = ref.read(authControllerProvider).value;
      if (status is TwoFactorRequired) {
        setState(() => _challengeId = status.challengeId);
      } else if (status is Authenticated) {
        HapticFeedback.lightImpact();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code != googleSignInCancelledCode) {
        setState(() => _errorMessage = mapFirebaseAuthError(e.code));
      }
    } catch (e) {
      // Firebase accepted the sign-in but our own session request failed
      // (offline, server error); that has its own cause and message.
      setState(() => _errorMessage = describeActionError(e));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitTwoFactorCode() async {
    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .submitTwoFactorChallenge(challengeId: _challengeId!, code: _codeController.text.trim());
      HapticFeedback.lightImpact();
    } catch (e) {
      // Every failure used to read as "incorrect or expired", which hid rate
      // limits and dropped connections behind a code that was actually right.
      debugPrint('Two-factor challenge failed: $e');
      final expired = e is DioException && e.response?.data is Map && (e.response!.data as Map)['error'] == 'invalid_challenge';
      setState(() {
        _errorMessage = describeActionError(e);
        if (expired) _challengeId = null;
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    try {
      await ref.read(firebaseAuthServiceProvider).sendPasswordResetEmail(email);
    } catch (_) {
      // Same message either way, so we don't reveal whether the email exists.
    }
    setState(() => _infoMessage = 'Check your email for a link to reset your password.');
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });
    try {
      final idToken = await ref.read(firebaseAuthServiceProvider).signInWithGoogle();
      await ref.read(authControllerProvider.notifier).exchangeSession(idToken: idToken);
      final status = ref.read(authControllerProvider).value;
      if (status is TwoFactorRequired) {
        setState(() => _challengeId = status.challengeId);
      } else if (status is Authenticated) {
        HapticFeedback.lightImpact();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code != googleSignInCancelledCode) {
        setState(() => _errorMessage = mapFirebaseAuthError(e.code));
      }
    } catch (e) {
      // Firebase accepted the sign-in but our own session request failed
      // (offline, server error); that has its own cause and message.
      setState(() => _errorMessage = describeActionError(e));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return StepSwitcher(
      child: _challengeId != null
          ? AuthLayout(
              key: const ValueKey('code'),
              title: 'Verification code',
              subtitle: 'Enter the 6-digit code from your authenticator app, or use a backup code.',
              children: [
                TextField(
                  key: const Key('login-2fa-code'),
                  controller: _codeController,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Code', prefixIcon: Icon(Icons.shield_outlined)),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  AuthError(message: _errorMessage!),
                ],
                const SizedBox(height: 24),
                AppButton(label: 'Verify', onPressed: _submitTwoFactorCode, isLoading: _isSubmitting),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => setState(() => _challengeId = null),
                  child: const Text('Back to login'),
                ),
              ],
            )
          : AuthLayout(
              key: const ValueKey('login'),
              title: 'Welcome back',
              subtitle: 'Log in to manage your invoices and payments.',
              children: [
                TextField(
                  key: const Key('login-email'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline)),
                ),
                const SizedBox(height: 12),
                PasswordField(key: const Key('login-password'), controller: _passwordController),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    key: const Key('login-forgot-password'),
                    onPressed: _forgotPassword,
                    child: const Text('Forgot password?'),
                  ),
                ),
                if (_infoMessage != null) ...[
                  Text(_infoMessage!, style: TextStyle(color: colors.success)),
                  const SizedBox(height: 8),
                ],
                if (_errorMessage != null) ...[
                  AuthError(message: _errorMessage!),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 8),
                AppButton(
                  key: const Key('login-submit'),
                  label: 'Log in',
                  onPressed: _submit,
                  isLoading: _isSubmitting,
                ),
                const SizedBox(height: 24),
                const AuthDivider(),
                const SizedBox(height: 16),
                GoogleSignInButton(onPressed: _signInWithGoogle, isLoading: _isSubmitting),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text("Don't have an account? Sign up"),
                  ),
                ),
              ],
            ),
    );
  }
}
