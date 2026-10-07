import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/pagination/paginated_list_controller.dart';
import '../../../../core/pagination/paginated_result.dart';
import '../../../../core/pagination/paginated_state.dart';
import '../../../auth/presentation/providers/active_business_provider.dart';
import '../../domain/customer.dart';
import 'customer_repository_provider.dart';

class CustomerListController extends PaginatedListController<Customer> {
  @override
  List<ProviderListenable<Object?>> get rebuildOn => [activeBusinessIdProvider];

  @override
  Future<PaginatedResult<Customer>> fetchPage({
    required String search,
    required bool includeInactive,
    required int page,
  }) {
    return ref.read(customerRepositoryProvider).list(
          search: search.isEmpty ? null : search,
          includeInactive: includeInactive,
          page: page,
          pageSize: PaginatedListController.pageSize,
        );
  }
}

final customerListControllerProvider =
    AsyncNotifierProvider<CustomerListController, PaginatedState<Customer>>(CustomerListController.new);
