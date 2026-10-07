import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client_provider.dart';
import '../../data/businesses_repository_impl.dart';
import '../../domain/businesses_repository.dart';

final businessesRepositoryProvider = Provider<BusinessesRepository>((ref) {
  return BusinessesRepositoryImpl(ref.watch(apiClientProvider).dio);
});
