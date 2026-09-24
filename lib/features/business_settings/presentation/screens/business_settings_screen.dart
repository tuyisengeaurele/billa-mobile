import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/subscription_status.dart';
import '../providers/business_settings_provider.dart';

class BusinessSettingsScreen extends ConsumerWidget {
  const BusinessSettingsScreen({super.key});

  static const _sections = [
    ('bs-details', Icons.business_outlined, 'Business details', '/settings/business/details'),
    ('bs-payments', Icons.account_balance_outlined, 'Payments and signatory', '/settings/business/payments'),
    ('bs-documents', Icons.description_outlined, 'Documents', '/settings/business/documents'),
    ('bs-numbering', Icons.pin_outlined, 'Numbering', '/settings/business/numbering'),
    ('bs-logo', Icons.image_outlined, 'Logo and brand', '/settings/business/logo'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(subscriptionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Business settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.workspace_premium_outlined),
              title: const Text('Subscription'),
              subtitle: switch (subscription) {
                AsyncData(:final value) => Text(_subscriptionSummary(value)),
                AsyncError() => const Text("Couldn't load your subscription"),
                _ => const Text('Loading…'),
              },
              trailing: subscription is AsyncError
                  ? TextButton(
                      key: const Key('bs-subscription-retry'),
                      onPressed: () => ref.invalidate(subscriptionProvider),
                      child: const Text('Retry'),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          for (final (key, icon, label, route) in _sections)
            ListTile(
              key: Key(key),
              leading: Icon(icon),
              title: Text(label),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(route),
            ),
        ],
      ),
    );
  }

  static String _date(String iso) => iso.split('T').first;

  static String _subscriptionSummary(SubscriptionStatus status) {
    final until = status.activeUntil;
    if (status.isPaid) {
      final plan = switch (status.plan) {
        'MONTHLY' => 'Monthly plan',
        'ANNUAL' => 'Annual plan',
        _ => 'Paid plan',
      };
      return until == null ? plan : '$plan, active until ${_date(until)}';
    }
    final trialEnd = status.trialEndsAt;
    return trialEnd == null ? 'No active subscription' : 'Free trial until ${_date(trialEnd)}';
  }
}
