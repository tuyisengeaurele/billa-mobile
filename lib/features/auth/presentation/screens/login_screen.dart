import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/firebase_auth_error.dart';
import 'package:billa_mobile/features/auth/domain/auth_status.dart';
import '../providers/auth_controller.dart';
import '../providers/firebase_auth_service_provider.dart';

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
    if (_challengeId != null) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Verification code', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                const Text('Enter the 6-digit code from your authenticator app, or use a backup code.'),
                const SizedBox(height: 16),
                TextField(key: const Key('login-2fa-code'), controller: _codeController),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(_errorMessage!),
                ],
                const SizedBox(height: 16),
                AppButton(label: 'Verify', onPressed: _submitTwoFactorCode, isLoading: _isSubmitting),
                TextButton(
                  onPressed: () => setState(() => _challengeId = null),
                  child: const Text('Back to login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Log in', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextField(
                key: const Key('login-email'),
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('login-password'),
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  key: const Key('login-forgot-password'),
                  onPressed: _forgotPassword,
                  child: const Text('Forgot password?'),
                ),
              ),
              if (_infoMessage != null) Text(_infoMessage!),
              if (_errorMessage != null) Text(_errorMessage!),
              const SizedBox(height: 8),
              AppButton(key: const Key('login-submit'), label: 'Log in', onPressed: _submit, isLoading: _isSubmitting),
              const SizedBox(height: 24),
              const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('or')), Expanded(child: Divider())]),
              const SizedBox(height: 16),
              OutlinedButton(onPressed: _signInWithGoogle, child: const Text('Continue with Google')),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/register'),
                child: const Text("New to Billa? Create an account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
