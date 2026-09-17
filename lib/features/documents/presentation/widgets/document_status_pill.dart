import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/document_enums.dart';

class DocumentStatusPill extends StatelessWidget {
  const DocumentStatusPill({super.key, required this.status, this.paymentStatus});

  final DocumentStatus status;
  final PaymentStatus? paymentStatus;

  String get _label {
    if (status == DocumentStatus.draft) return 'Draft';
    return switch (paymentStatus) {
      null => 'Finalized',
      PaymentStatus.unpaid => 'Unpaid',
      PaymentStatus.partiallyPaid => 'Partially paid',
      PaymentStatus.paid => 'Paid',
      PaymentStatus.writtenOff => 'Written off',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final (background, foreground) = status == DocumentStatus.draft
        ? (colors.neutral200, colors.neutral600)
        : switch (paymentStatus) {
            PaymentStatus.paid => (colors.successBg, colors.success),
            PaymentStatus.writtenOff => (colors.neutral200, colors.neutral600),
            _ => (colors.warningBg, colors.warning),
          };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(_label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: foreground)),
    );
  }
}
