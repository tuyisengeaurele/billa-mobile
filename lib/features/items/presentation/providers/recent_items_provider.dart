import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../auth/presentation/providers/active_business_provider.dart';
import '../../domain/item.dart';

/// Where the recently used items are kept between launches, per business, so
/// one business's catalogue never suggests another's.
abstract class RecentItemsStore {
  List<Item> read(String businessId);
  Future<void> write(String businessId, List<Item> items);
}

class InMemoryRecentItemsStore implements RecentItemsStore {
  final _items = <String, List<Item>>{};

  @override
  List<Item> read(String businessId) => _items[businessId] ?? const [];

  @override
  Future<void> write(String businessId, List<Item> items) async => _items[businessId] = items;
}

class SharedPreferencesRecentItemsStore implements RecentItemsStore {
  SharedPreferencesRecentItemsStore(this._preferences);

  final SharedPreferences _preferences;

  String _key(String businessId) => 'recent_items_$businessId';

  @override
  List<Item> read(String businessId) {
    final raw = _preferences.getString(_key(businessId));
    if (raw == null) return const [];
    try {
      return [for (final json in jsonDecode(raw) as List) Item.fromJson(json as Map<String, dynamic>)];
    } catch (_) {
      // Suggestions are a convenience; an unreadable list is simply empty.
      return const [];
    }
  }

  @override
  Future<void> write(String businessId, List<Item> items) {
    return _preferences.setString(_key(businessId), jsonEncode([for (final item in items) item.toJson()]));
  }
}

final recentItemsStoreProvider = Provider<RecentItemsStore>((ref) => InMemoryRecentItemsStore());

class RecentItemsNotifier extends Notifier<List<Item>> {
  static const maxItems = 8;

  @override
  List<Item> build() {
    final businessId = ref.watch(activeBusinessIdProvider);
    if (businessId == null) return const [];
    return ref.read(recentItemsStoreProvider).read(businessId);
  }

  /// Newest first, no repeats, capped so the chips stay a short row.
  void remember(Item item) {
    final businessId = ref.read(activeBusinessIdProvider);
    if (businessId == null) return;
    final next = [item, ...state.where((existing) => existing.id != item.id)].take(maxItems).toList();
    state = next;
    ref.read(recentItemsStoreProvider).write(businessId, next);
  }
}

final recentItemsProvider = NotifierProvider<RecentItemsNotifier, List<Item>>(RecentItemsNotifier.new);
