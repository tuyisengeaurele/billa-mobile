import 'business_settings.dart';
import 'document_sequence.dart';
import 'document_template.dart';
import 'subscription_status.dart';

abstract class BusinessSettingsRepository {
  Future<BusinessSettings> get();

  Future<BusinessSettings> updateDetails({
    required String name,
    String? tin,
    String? industry,
    String? phone,
    String? email,
    String? address,
    String? rraEbmNumber,
  });

  Future<BusinessSettings> updatePayments({
    String? bankName,
    String? bankAccountNumber,
    String? signatoryName,
    String? signatoryTitle,
  });

  Future<BusinessSettings> updateDocumentSettings({
    required DocumentTemplate defaultTemplate,
    required bool requireApprovalToFinalize,
    required bool remindersEnabled,
    required int reminderCadenceDays,
  });

  Future<String> uploadSignature(List<int> bytes, String filename);
  Future<BusinessSettings> setSignature(String? url);

  Future<List<DocumentSequence>> sequences();
  Future<List<DocumentSequence>> saveSequences(List<DocumentSequence> sequences);

  Future<SubscriptionStatus> subscription();
}
