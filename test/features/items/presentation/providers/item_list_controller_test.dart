import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/core/pagination/paginated_result.dart';
import 'package:billa_mobile/features/items/domain/item.dart';
import 'package:billa_mobile/features/items/domain/item_repository.dart';
import 'package:billa_mobile/features/items/presentation/providers/item_list_controller.dart';
import 'package:billa_mobile/features/items/presentation/providers/item_repository_provider.dart';

class _MockItemRepository extends Mock implements ItemRepository {}

void main() {
  test('setCategory refetches from page 1 with the given category', () async {
    final repository = _MockItemRepository();
    when(() => repository.list(search: null, category: null, includeInactive: false, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: <Item>[], total: 0, page: 1, pageSize: 20),
    );
    when(() => repository.list(search: null, category: 'Materials', includeInactive: false, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(
        results: [Item(id: 'i1', description: 'Cement', unitPrice: 13000, unit: 'bag', taxRate: 18, category: 'Materials', isActive: true)],
        total: 1,
        page: 1,
        pageSize: 20,
      ),
    );
    final container = ProviderContainer(overrides: [
      itemRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);
    await container.read(itemListControllerProvider.future);

    await container.read(itemListControllerProvider.notifier).setCategory('Materials');

    final state = container.read(itemListControllerProvider).value!;
    expect(state.items.single.description, 'Cement');
  });
}
