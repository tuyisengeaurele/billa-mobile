import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/firebase_auth_error.dart';
import '../providers/auth_controller.dart';
import '../providers/firebase_auth_service_provider.dart';
import '../widgets/password_requirements_list.dart';

const _defaultBusinessName = 'My Business';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  String? _errorMessage;
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_passwordController.text != _confirmController.text) {
      setState(() => _errorMessage = "Passwords don't match");
      return;
    }
    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });
    try {
      final idToken = await ref
          .read(firebaseAuthServiceProvider)
          .registerWithEmailAndPassword(_emailController.text.trim(), _passwordController.text);
      await ref
          .read(authControllerProvider.notifier)
          .exchangeSession(idToken: idToken, businessName: _defaultBusinessName);
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = mapFirebaseAuthError(e.code));
    } catch (e) {
      // Firebase accepted the sign-in but our own session request failed
      // (offline, server error); that has its own cause and message.
      setState(() => _errorMessage = describeActionError(e));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });
    try {
      final idToken = await ref.read(firebaseAuthServiceProvider).signInWithGoogle();
      await ref
          .read(authControllerProvider.notifier)
          .exchangeSession(idToken: idToken, businessName: _defaultBusinessName);
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = mapFirebaseAuthError(e.code));
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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Create an account', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextField(
                key: const Key('register-email'),
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('register-password'),
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 4),
              PasswordRequirementsList(password: _passwordController.text),
              const SizedBox(height: 12),
              TextField(
                key: const Key('register-confirm-password'),
                controller: _confirmController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirm password'),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(_errorMessage!),
              ],
              const SizedBox(height: 16),
              AppButton(key: const Key('register-submit'), label: 'Create account', onPressed: _submit, isLoading: _isSubmitting),
              const SizedBox(height: 24),
              const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('or')), Expanded(child: Divider())]),
              const SizedBox(height: 16),
              OutlinedButton(onPressed: _signUpWithGoogle, child: const Text('Continue with Google')),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Already have one? Log in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
