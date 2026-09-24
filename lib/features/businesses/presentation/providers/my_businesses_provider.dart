import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/active_business_provider.dart';
import '../../domain/business_summary.dart';
import 'businesses_repository_provider.dart';

/// `GET /businesses`, refetched whenever the active business changes so the
/// ownership flags never describe a business you've since left.
final myBusinessesProvider = FutureProvider.autoDispose<List<BusinessSummary>>((ref) {
  ref.watch(activeBusinessIdProvider);
  return ref.watch(businessesRepositoryProvider).list();
});

/// The only signal the backend exposes for ownership; it says nothing about
/// member versus accountant, so owner-only UI keys off this and nothing finer.
final isOwnerOfActiveBusinessProvider = Provider.autoDispose<bool>((ref) {
  final activeId = ref.watch(activeBusinessIdProvider);
  final businesses = ref.watch(myBusinessesProvider).valueOrNull;
  return businesses?.any((b) => b.id == activeId && b.isOwner) ?? false;
});
