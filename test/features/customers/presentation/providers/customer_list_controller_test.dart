import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/core/pagination/paginated_result.dart';
import 'package:billa_mobile/features/customers/domain/customer.dart';
import 'package:billa_mobile/features/customers/domain/customer_repository.dart';
import 'package:billa_mobile/features/customers/presentation/providers/customer_list_controller.dart';
import 'package:billa_mobile/features/customers/presentation/providers/customer_repository_provider.dart';

class _MockCustomerRepository extends Mock implements CustomerRepository {}

void main() {
  test('fetchPage delegates to CustomerRepository.list with the given params', () async {
    final repository = _MockCustomerRepository();
    when(() => repository.list(search: null, includeInactive: false, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: <Customer>[], total: 0, page: 1, pageSize: 20),
    );
    when(() => repository.list(search: 'acme', includeInactive: false, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(
        results: [Customer(id: 'c1', name: 'Acme', isActive: true, createdAt: '2026-01-01T00:00:00.000Z')],
        total: 1,
        page: 1,
        pageSize: 20,
      ),
    );
    final container = ProviderContainer(overrides: [
      customerRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);

    final notifier = container.read(customerListControllerProvider.notifier);
    await container.read(customerListControllerProvider.future);
    notifier.setSearch('acme');
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final state = container.read(customerListControllerProvider).value!;
    expect(state.items.single.name, 'Acme');
  });
}
