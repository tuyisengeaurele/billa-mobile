import '../../../../core/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../../core/errors/action_errors.dart';
import '../../../../core/widgets/contact_actions.dart';
import '../../../../core/widgets/undo_snackbar.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../domain/customer.dart';
import '../../../auth/domain/auth_status.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../business_settings/presentation/providers/business_settings_repository_provider.dart';
import '../../domain/customer_payment_stats.dart';
import '../../domain/statement_message.dart';
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
    if (!confirmed || !mounted) return;
    // Captured now because the undo outlives this screen.
    final repository = ref.read(customerRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    final nowActive = !customer.isActive;
    try {
      await repository.update(customer.id, isActive: nowActive);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(describeActionError(e))));
      return;
    }
    if (!mounted) return;
    setState(() {
      _future = _load();
    });
    showUndoSnackBar(
      context,
      message: '${customer.name} ${nowActive ? 'reactivated' : 'deactivated'}',
      onUndo: () async {
        await repository.update(customer.id, isActive: !nowActive);
        if (mounted) {
          setState(() {
            _future = _load();
          });
        }
      },
    );
  }

  // The details of the business only decide the wording, so when they cannot be loaded the statement is
  // still sent, without an invitation to pay online.
  Future<void> _shareStatement(Customer customer) async {
    final status = ref.read(authControllerProvider).valueOrNull;
    var business = status is Authenticated ? status.business.name : 'us';
    var payable = false;
    try {
      final settings = await ref.read(businessSettingsRepositoryProvider).get();
      business = settings.name;
      payable = settings.momoEnabled;
    } catch (_) {
      // Fall back to what is already known.
    }
    if (!mounted) return;
    await showContactActions(
      context,
      ref,
      title: customer.name,
      phone: customer.phone,
      message: statementMessage(
        customer: customer.name,
        business: business,
        totals: customer.outstandingTotals,
        portalUrl: '$apiBaseUrl/portal/${customer.portalToken}',
        payable: payable,
      ),
    );
  }

  Future<void> _emailStatement(Customer customer) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Email the statement to ${customer.email}?',
      confirmLabel: 'Send',
    );
    if (!confirmed || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final repository = ref.read(customerRepositoryProvider);

    Future<void> attempt() async {
      try {
        final sentTo = await repository.sendStatement(customer.id);
        messenger.showSnackBar(SnackBar(content: Text('Statement sent to $sentTo')));
      } catch (e) {
        messenger.showSnackBar(SnackBar(
          content: Text(describeActionError(e)),
          action: SnackBarAction(label: 'Retry', onPressed: attempt),
        ));
      }
    }

    await attempt();
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
          // Scrolls because the statement actions made the screen taller than a small phone.
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(customer.name, style: Theme.of(context).textTheme.headlineSmall),
                if (customer.phone != null) Text(customer.phone!),
                if (customer.email != null) Text(customer.email!),
                if (customer.address != null) Text(customer.address!),
                if (customer.creditLimit != null || customer.outstandingTotals.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  if (customer.creditLimit != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [const Text('Credit limit'), MoneyText(customer.creditLimit!)],
                    ),
                  if (customer.outstandingTotals.isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Owes'),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (final total in customer.outstandingTotals)
                              MoneyText(total.amount, currency: total.currency),
                          ],
                        ),
                      ],
                    ),
                ],
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
                OutlinedButton.icon(
                  key: const Key('customer-statement'),
                  onPressed: customer.outstandingTotals.isEmpty || customer.portalToken == null
                      ? null
                      : () => _shareStatement(customer),
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: const Text('Send statement'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  key: const Key('customer-statement-email'),
                  onPressed: customer.outstandingTotals.isEmpty || (customer.email ?? '').isEmpty
                      ? null
                      : () => _emailStatement(customer),
                  icon: const Icon(Icons.mail_outline),
                  label: const Text('Email statement'),
                ),
                if (customer.outstandingTotals.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('They owe nothing right now, so there is no statement to send.'),
                  )
                else if ((customer.email ?? '').isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('Add an email address to this customer to email a statement.'),
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
