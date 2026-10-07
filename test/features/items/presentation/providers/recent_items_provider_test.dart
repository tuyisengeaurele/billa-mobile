import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:billa_mobile/features/auth/presentation/providers/active_business_provider.dart';
import 'package:billa_mobile/features/items/domain/item.dart';
import 'package:billa_mobile/features/items/presentation/providers/recent_items_provider.dart';

Item _item(String id) => Item(id: id, description: 'Item $id', unitPrice: 100, unit: 'unit', taxRate: 18, isActive: true);

void main() {
  late RecentItemsStore store;
  late String? businessId;

  ProviderContainer make() {
    final container = ProviderContainer(overrides: [
      recentItemsStoreProvider.overrideWithValue(store),
      activeBusinessIdProvider.overrideWith((ref) => businessId),
    ]);
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    store = InMemoryRecentItemsStore();
    businessId = 'b1';
  });

  test('starts empty', () {
    expect(make().read(recentItemsProvider), isEmpty);
  });

  test('puts the newest first and never repeats an item', () {
    final container = make();
    final notifier = container.read(recentItemsProvider.notifier);

    notifier.remember(_item('a'));
    notifier.remember(_item('b'));
    notifier.remember(_item('a'));

    expect(container.read(recentItemsProvider).map((i) => i.id), ['a', 'b']);
  });

  test('keeps only the eight most recent', () {
    final container = make();
    final notifier = container.read(recentItemsProvider.notifier);

    for (var i = 0; i < 10; i++) {
      notifier.remember(_item('$i'));
    }

    final ids = container.read(recentItemsProvider).map((i) => i.id).toList();
    expect(ids, hasLength(8));
    expect(ids.first, '9');
    expect(ids.contains('0'), isFalse);
  });

  test('is remembered for the next launch, per business', () {
    make().read(recentItemsProvider.notifier).remember(_item('a'));

    expect(make().read(recentItemsProvider).map((i) => i.id), ['a']);

    businessId = 'b2';
    expect(make().read(recentItemsProvider), isEmpty);
  });

  test('does nothing without an active business', () {
    businessId = null;
    final container = make();

    container.read(recentItemsProvider.notifier).remember(_item('a'));

    expect(container.read(recentItemsProvider), isEmpty);
  });

  group('preferences store', () {
    test('round-trips items and ignores unreadable data', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final shared = SharedPreferencesRecentItemsStore(preferences);

      await shared.write('b1', [_item('a')]);
      expect(shared.read('b1').single.id, 'a');

      await preferences.setString('recent_items_b1', 'nonsense');
      expect(shared.read('b1'), isEmpty);
    });
  });
}
