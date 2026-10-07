import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/customer_repository_impl.dart';
import '../../domain/customer_repository.dart';
import '../../../../core/network/api_client_provider.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepositoryImpl(ref.watch(apiClientProvider).dio);
});
