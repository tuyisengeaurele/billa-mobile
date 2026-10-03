import '../../../core/pagination/paginated_result.dart';
import 'customer.dart';
import 'customer_payment_stats.dart';

abstract class CustomerRepository {
  Future<PaginatedResult<Customer>> list({
    String? search,
    bool includeInactive = false,
    int page = 1,
    int pageSize = 20,
  });

  Future<Customer> get(String id);
  Future<CustomerPaymentStats> paymentStats(String id);

  /// Emails the customer their statement and returns the address it went to.
  Future<String> sendStatement(String id);

  Future<Customer> create({
    required String name,
    String? tin,
    String? address,
    String? phone,
    String? email,
    int? creditLimit,
  });

  Future<Customer> update(
    String id, {
    String? name,
    String? tin,
    String? address,
    String? phone,
    String? email,
    bool? isActive,
    int? creditLimit,
    bool clearCreditLimit = false,
  });
}
