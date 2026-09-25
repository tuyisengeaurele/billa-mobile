import 'package:dio/dio.dart';
import '../domain/business_settings.dart';
import '../domain/business_settings_repository.dart';
import '../domain/document_sequence.dart';
import '../domain/document_template.dart';
import '../domain/subscription_status.dart';

class BusinessSettingsRepositoryImpl implements BusinessSettingsRepository {
  BusinessSettingsRepositoryImpl(this._dio);

  final Dio _dio;

  // Every field of a section is sent, with null for a cleared one: the
  // backend clears a nullable field only on an explicit null, and a section
  // form always holds the whole truth for its fields.
  Future<BusinessSettings> _patch(Map<String, Object?> data) async {
    final response = await _dio.patch<Map<String, dynamic>>('/business', data: data);
    return BusinessSettings.fromJson(response.data!['business'] as Map<String, dynamic>);
  }

  @override
  Future<BusinessSettings> get() async {
    final response = await _dio.get<Map<String, dynamic>>('/business');
    return BusinessSettings.fromJson(response.data!['business'] as Map<String, dynamic>);
  }

  @override
  Future<BusinessSettings> updateDetails({
    required String name,
    String? tin,
    String? industry,
    String? phone,
    String? email,
    String? address,
    String? rraEbmNumber,
  }) {
    return _patch({
      'name': name,
      'tin': tin,
      'industry': industry,
      'phone': phone,
      'email': email,
      'address': address,
      'rraEbmNumber': rraEbmNumber,
    });
  }

  @override
  Future<BusinessSettings> updatePayments({
    String? bankName,
    String? bankAccountNumber,
    String? signatoryName,
    String? signatoryTitle,
  }) {
    return _patch({
      'bankName': bankName,
      'bankAccountNumber': bankAccountNumber,
      'signatoryName': signatoryName,
      'signatoryTitle': signatoryTitle,
    });
  }

  @override
  Future<BusinessSettings> updateDocumentSettings({
    required DocumentTemplate defaultTemplate,
    required bool requireApprovalToFinalize,
    required bool remindersEnabled,
    required int reminderCadenceDays,
  }) {
    return _patch({
      'defaultTemplate': documentTemplateToJson(defaultTemplate),
      'requireApprovalToFinalize': requireApprovalToFinalize,
      'remindersEnabled': remindersEnabled,
      'reminderCadenceDays': reminderCadenceDays,
    });
  }

  @override
  Future<BusinessSettings> setDefaultTemplate(DocumentTemplate template) {
    return _patch({'defaultTemplate': documentTemplateToJson(template)});
  }

  @override
  Future<String> uploadSignature(List<int> bytes, String filename) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/business/signature',
      data: FormData.fromMap({'signature': MultipartFile.fromBytes(bytes, filename: filename)}),
    );
    return response.data!['url'] as String;
  }

  @override
  Future<BusinessSettings> setSignature(String? url) => _patch({'signatureUrl': url});

  @override
  Future<List<DocumentSequence>> sequences() async {
    final response = await _dio.get<Map<String, dynamic>>('/business/sequences');
    return _parseSequences(response.data!);
  }

  @override
  Future<List<DocumentSequence>> saveSequences(List<DocumentSequence> sequences) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/business/sequences',
      data: sequences.map((sequence) => sequence.toJson()).toList(),
    );
    return _parseSequences(response.data!);
  }

  List<DocumentSequence> _parseSequences(Map<String, dynamic> body) {
    return (body['sequences'] as List)
        .map((json) => DocumentSequence.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SubscriptionStatus> subscription() async {
    final response = await _dio.get<Map<String, dynamic>>('/billing/status');
    return SubscriptionStatus.fromJson(response.data!);
  }
}
