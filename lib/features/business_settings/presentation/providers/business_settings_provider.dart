import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/active_business_provider.dart';
import '../../domain/business_settings.dart';
import '../../domain/document_sequence.dart';
import '../../domain/subscription_status.dart';
import 'business_settings_repository_provider.dart';

/// Watches the active business so switching never shows the previous
/// business's settings, and is invalidated after every successful save.
final businessSettingsProvider = FutureProvider.autoDispose<BusinessSettings>((ref) {
  ref.watch(activeBusinessIdProvider);
  return ref.watch(businessSettingsRepositoryProvider).get();
});

final subscriptionProvider = FutureProvider.autoDispose<SubscriptionStatus>((ref) {
  ref.watch(activeBusinessIdProvider);
  return ref.watch(businessSettingsRepositoryProvider).subscription();
});

final sequencesProvider = FutureProvider.autoDispose<List<DocumentSequence>>((ref) {
  ref.watch(activeBusinessIdProvider);
  return ref.watch(businessSettingsRepositoryProvider).sequences();
});
