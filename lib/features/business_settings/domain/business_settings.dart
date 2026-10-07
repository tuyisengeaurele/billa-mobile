import 'package:freezed_annotation/freezed_annotation.dart';
import 'document_template.dart';

part 'business_settings.freezed.dart';
part 'business_settings.g.dart';

@freezed
class BusinessSettings with _$BusinessSettings {
  const factory BusinessSettings({
    required String id,
    required String name,
    String? tin,
    String? industry,
    String? phone,
    String? email,
    String? address,
    String? rraEbmNumber,
    String? bankName,
    String? bankAccountNumber,
    String? signatoryName,
    String? signatoryTitle,
    String? signatureUrl,
    String? logoUrl,
    String? primaryColor,
    @Default([]) List<String> accentColors,
    @Default(true) bool remindersEnabled,
    @Default(7) int reminderCadenceDays,
    @Default(false) bool requireApprovalToFinalize,
    @JsonKey(fromJson: documentTemplateFromJson, toJson: documentTemplateToJson)
    @Default(DocumentTemplate.minimal)
    DocumentTemplate defaultTemplate,
  }) = _BusinessSettings;

  factory BusinessSettings.fromJson(Map<String, dynamic> json) => _$BusinessSettingsFromJson(json);
}
