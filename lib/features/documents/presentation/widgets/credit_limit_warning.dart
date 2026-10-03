import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/formatting/money.dart';
import '../../../customers/domain/customer.dart';
import '../../../customers/presentation/providers/customer_repository_provider.dart';

/// A heads-up, never a block: when the customer has a credit limit and this invoice would take what they
/// owe past it, say so before the invoice goes out. Shows nothing otherwise, and nothing when the lookup
/// fails, because that says nothing is wrong with the invoice.
class CreditLimitWarning extends ConsumerStatefulWidget {
  const CreditLimitWarning({super.key, required this.customerId, required this.invoiceTotalRwf});

  final String customerId;

  /// What this invoice adds to the balance, in RWF, because the limit and the balance are RWF.
  final int invoiceTotalRwf;

  @override
  ConsumerState<CreditLimitWarning> createState() => _CreditLimitWarningState();
}

class _CreditLimitWarningState extends ConsumerState<CreditLimitWarning> {
  Customer? _customer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant CreditLimitWarning oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.customerId != widget.customerId) {
      _customer = null;
      _load();
    }
  }

  Future<void> _load() async {
    final id = widget.customerId;
    try {
      final customer = await ref.read(customerRepositoryProvider).get(id);
      if (mounted && id == widget.customerId) setState(() => _customer = customer);
    } catch (_) {
      // The warning is a convenience, so a failed lookup just means no warning.
    }
  }

  @override
  Widget build(BuildContext context) {
    final customer = _customer;
    final limit = customer?.creditLimit;
    if (customer == null || limit == null) return const SizedBox.shrink();
    final wouldOwe = customer.outstandingBalance + widget.invoiceTotalRwf;
    if (wouldOwe <= limit) return const SizedBox.shrink();

    final colors = Theme.of(context).extension<AppColors>()!;
    return Container(
      key: const Key('credit-limit-warning'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: colors.warningBg, borderRadius: BorderRadius.circular(12)),
      child: Text(
        '${customer.name} already owes ${formatMoney(customer.outstandingBalance)}. '
        'With this invoice they would owe ${formatMoney(wouldOwe)}, which is over their ${formatMoney(limit)} limit.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.warning),
      ),
    );
  }
}
