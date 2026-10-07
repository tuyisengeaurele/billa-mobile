import '../../../../core/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/contact_actions.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../domain/customer.dart';
import '../../domain/customer_payment_stats.dart';
import '../providers/customer_repository_provider.dart';

class CustomerDetailScreen extends ConsumerStatefulWidget {
  const CustomerDetailScreen({super.key, required this.customerId});

  final String customerId;

  @override
  ConsumerState<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen> {
  late Future<(Customer, CustomerPaymentStats)> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(Customer, CustomerPaymentStats)> _load() async {
    final repository = ref.read(customerRepositoryProvider);
    final customer = await repository.get(widget.customerId);
    final stats = await repository.paymentStats(widget.customerId);
    return (customer, stats);
  }

  Future<void> _toggleActive(Customer customer) async {
    final action = customer.isActive ? 'Deactivate' : 'Reactivate';
    final confirmed = await showConfirmDialog(
      context,
      title: '$action ${customer.name}?',
      content: customer.isActive
          ? 'Hidden from lists. Their existing documents are not affected.'
          : 'They will appear in lists again.',
      confirmLabel: action,
    );
    if (!confirmed) return;
    await ref.read(customerRepositoryProvider).update(customer.id, isActive: !customer.isActive);
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer')),
      body: FutureBuilder<(Customer, CustomerPaymentStats)>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorState(
              message: "Couldn't load this customer",
              onRetry: () => setState(() {
                _future = _load();
              }),
            );
          }
          if (!snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Column(children: [LoadingSkeleton(height: 24), SizedBox(height: 12), LoadingSkeleton(height: 100)]),
            );
          }
          final (customer, stats) = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(customer.name, style: Theme.of(context).textTheme.headlineSmall),
                if (customer.phone != null) Text(customer.phone!),
                if (customer.email != null) Text(customer.email!),
                if (customer.address != null) Text(customer.address!),
                const SizedBox(height: 24),
                Text('Payment history', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('${stats.paidInvoiceCount} paid invoices'),
                if (stats.averageDaysToPay != null) Text('Average ${stats.averageDaysToPay} days to pay'),
                if (stats.onTimeRate != null) Text('${stats.onTimeRate}% paid on time'),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  key: const Key('customer-contact'),
                  onPressed: () => showContactActions(
                    context,
                    ref,
                    title: customer.name,
                    phone: customer.phone,
                    message: 'Hello ${customer.name},',
                  ),
                  icon: const Icon(Icons.chat_outlined),
                  label: const Text('Contact'),
                ),
                const SizedBox(height: 8),
                AppButton(
                  key: const Key('customer-toggle-active'),
                  label: customer.isActive ? 'Deactivate customer' : 'Reactivate customer',
                  onPressed: () => _toggleActive(customer),
                ),
                TextButton(
                  onPressed: () => context.push('/customers/${customer.id}/edit', extra: customer),
                  child: const Text('Edit'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
