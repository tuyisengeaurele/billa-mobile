import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/business_repository_impl.dart';
import '../../domain/business_repository.dart';
import '../../../../core/network/api_client_provider.dart';

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  return BusinessRepositoryImpl(ref.watch(apiClientProvider).dio);
});
