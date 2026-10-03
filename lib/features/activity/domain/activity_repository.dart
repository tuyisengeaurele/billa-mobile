import '../../../core/pagination/paginated_result.dart';
import 'activity_entry.dart';

abstract class ActivityRepository {
  /// One page of the business's history, newest first.
  Future<PaginatedResult<ActivityEntry>> list({int page = 1, int pageSize = 20});
}
