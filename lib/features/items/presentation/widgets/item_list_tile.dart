import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/money_text.dart';
import '../../domain/item.dart';

class ItemListTile extends StatelessWidget {
  const ItemListTile({super.key, required this.item, required this.onTap});

  final Item item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return ListTile(
      onTap: onTap,
      title: Text(item.description),
      subtitle: Text(item.unit),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MoneyText(item.unitPrice),
          if (!item.isActive) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: colors.neutral200, borderRadius: BorderRadius.circular(999)),
              child: Text('Inactive', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.neutral600)),
            ),
          ],
        ],
      ),
    );
  }
}
