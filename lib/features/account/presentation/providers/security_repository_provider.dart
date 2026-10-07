import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client_provider.dart';
import '../../data/security_repository_impl.dart';
import '../../domain/security_repository.dart';

final securityRepositoryProvider = Provider<SecurityRepository>((ref) {
  return SecurityRepositoryImpl(ref.watch(apiClientProvider).dio);
});
