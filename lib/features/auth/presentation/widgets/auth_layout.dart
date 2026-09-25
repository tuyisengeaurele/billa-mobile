import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';

/// Shared frame for the signed-out screens: brand mark, heading, and one
/// consistent rhythm, so login, register, and the verification step read as
/// one flow.
class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.title, this.subtitle, required this.children});

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Image.asset('assets/logo.png', height: 44, semanticLabel: 'Billa'),
              ),
              const SizedBox(height: 32),
              Text(title, style: textTheme.headlineMedium),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(subtitle!, style: textTheme.bodyMedium?.copyWith(color: colors.neutral600)),
              ],
              const SizedBox(height: 32),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class AuthError extends StatelessWidget {
  const AuthError({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: colors.errorBg, borderRadius: BorderRadius.circular(AppRadii.small)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 18, color: colors.error),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: TextStyle(color: colors.error))),
        ],
      ),
    );
  }
}

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, this.label = 'or continue with'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: colors.neutral500)),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
