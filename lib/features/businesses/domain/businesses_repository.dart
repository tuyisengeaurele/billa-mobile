import '../../onboarding/domain/business.dart';
import 'business_summary.dart';
import 'invite_preview.dart';
import 'leave_result.dart';

abstract class BusinessesRepository {
  Future<List<BusinessSummary>> list();
  Future<Business> create(String name);
  Future<Business> switchTo(String businessId);
  Future<InvitePreview> previewInvite(String token);
  Future<Business> acceptInvite(String token);
  Future<LeaveResult> leaveCurrent();
}
