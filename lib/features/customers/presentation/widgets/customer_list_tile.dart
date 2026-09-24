import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/customer.dart';

class CustomerListTile extends StatelessWidget {
  const CustomerListTile({super.key, required this.customer, required this.onTap});

  final Customer customer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return ListTile(
      onTap: onTap,
      title: Text(customer.name),
      subtitle: customer.phone != null ? Text(customer.phone!) : null,
      trailing: customer.isActive
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: colors.neutral200, borderRadius: BorderRadius.circular(999)),
              child: Text('Inactive', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.neutral600)),
            ),
    );
  }
}
