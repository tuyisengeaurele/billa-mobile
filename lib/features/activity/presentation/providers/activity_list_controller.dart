import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/pagination/paginated_list_controller.dart';
import '../../../../core/pagination/paginated_result.dart';
import '../../../../core/pagination/paginated_state.dart';
import '../../../auth/presentation/providers/active_business_provider.dart';
import '../../domain/activity_entry.dart';
import 'activity_repository_provider.dart';

class ActivityListController extends PaginatedListController<ActivityEntry> {
  @override
  List<ProviderListenable<Object?>> get rebuildOn => [activeBusinessIdProvider];

  // The history has no search or inactive filter, so those arguments are ignored.
  @override
  Future<PaginatedResult<ActivityEntry>> fetchPage({
    required String search,
    required bool includeInactive,
    required int page,
  }) {
    return ref.read(activityRepositoryProvider).list(page: page, pageSize: PaginatedListController.pageSize);
  }
}

final activityListControllerProvider =
    AsyncNotifierProvider<ActivityListController, PaginatedState<ActivityEntry>>(ActivityListController.new);
