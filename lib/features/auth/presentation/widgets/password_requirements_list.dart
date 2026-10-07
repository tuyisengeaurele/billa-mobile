import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class _Requirement {
  const _Requirement(this.label, this.test);
  final String label;
  final bool Function(String) test;
}

final _requirements = [
  _Requirement('At least 8 characters', (v) => v.length >= 8),
  _Requirement('One lowercase letter', (v) => RegExp(r'[a-z]').hasMatch(v)),
  _Requirement('One uppercase letter', (v) => RegExp(r'[A-Z]').hasMatch(v)),
  _Requirement('One number', (v) => RegExp(r'[0-9]').hasMatch(v)),
  _Requirement('One special character', (v) => RegExp(r'[^A-Za-z0-9]').hasMatch(v)),
];

class PasswordRequirementsList extends StatelessWidget {
  const PasswordRequirementsList({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final requirement in _requirements)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Icon(
                  requirement.test(password) ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 16,
                  color: requirement.test(password) ? colors.success : colors.neutral400,
                ),
                const SizedBox(width: 8),
                Text(requirement.label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
      ],
    );
  }
}
