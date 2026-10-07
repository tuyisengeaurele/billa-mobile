import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client_provider.dart';
import '../../data/activity_repository_impl.dart';
import '../../domain/activity_repository.dart';

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepositoryImpl(ref.watch(apiClientProvider).dio);
});
