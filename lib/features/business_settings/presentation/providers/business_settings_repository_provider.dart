import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client_provider.dart';
import '../../data/business_settings_repository_impl.dart';
import '../../domain/business_settings_repository.dart';

final businessSettingsRepositoryProvider = Provider<BusinessSettingsRepository>((ref) {
  return BusinessSettingsRepositoryImpl(ref.watch(apiClientProvider).dio);
});
