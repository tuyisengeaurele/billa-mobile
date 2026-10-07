import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client_provider.dart';
import '../../data/receivables_repository_impl.dart';
import '../../domain/receivables_repository.dart';

final receivablesRepositoryProvider = Provider<ReceivablesRepository>((ref) {
  return ReceivablesRepositoryImpl(ref.watch(apiClientProvider).dio);
});
