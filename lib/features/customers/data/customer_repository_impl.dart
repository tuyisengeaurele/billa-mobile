import 'package:dio/dio.dart';
import '../../../core/pagination/paginated_result.dart';
import '../domain/customer.dart';
import '../domain/customer_payment_stats.dart';
import '../domain/customer_repository.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  CustomerRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<PaginatedResult<Customer>> list({
    String? search,
    bool includeInactive = false,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>('/customers', queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
      'includeInactive': includeInactive.toString(),
      'page': page,
      'pageSize': pageSize,
    });
    final data = response.data!;
    final results = (data['results'] as List)
        .map((json) => Customer.fromJson(json as Map<String, dynamic>))
        .toList();
    return PaginatedResult(
      results: results,
      total: data['total'] as int,
      page: data['page'] as int,
      pageSize: data['pageSize'] as int,
    );
  }

  @override
  Future<Customer> get(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/customers/$id');
    return Customer.fromJson(response.data!['customer'] as Map<String, dynamic>);
  }

  @override
  Future<CustomerPaymentStats> paymentStats(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/customers/$id/payment-stats');
    return CustomerPaymentStats.fromJson(response.data!);
  }

  @override
  Future<Customer> create({
    required String name,
    String? tin,
    String? address,
    String? phone,
    String? email,
  }) async {
    final data = <String, dynamic>{'name': name};
    if (tin != null) data['tin'] = tin;
    if (address != null) data['address'] = address;
    if (phone != null) data['phone'] = phone;
    if (email != null) data['email'] = email;

    final response = await _dio.post<Map<String, dynamic>>('/customers', data: data);
    return Customer.fromJson(response.data!['customer'] as Map<String, dynamic>);
  }

  @override
  Future<Customer> update(
    String id, {
    String? name,
    String? tin,
    String? address,
    String? phone,
    String? email,
    bool? isActive,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (tin != null) data['tin'] = tin;
    if (address != null) data['address'] = address;
    if (phone != null) data['phone'] = phone;
    if (email != null) data['email'] = email;
    if (isActive != null) data['isActive'] = isActive;

    final response = await _dio.patch<Map<String, dynamic>>('/customers/$id', data: data);
    return Customer.fromJson(response.data!['customer'] as Map<String, dynamic>);
  }
}
