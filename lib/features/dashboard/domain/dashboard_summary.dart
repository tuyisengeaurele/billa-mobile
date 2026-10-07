import 'package:freezed_annotation/freezed_annotation.dart';
import '../../documents/domain/document_enums.dart';

part 'dashboard_summary.freezed.dart';
part 'dashboard_summary.g.dart';

@freezed
class RecentDocument with _$RecentDocument {
  const factory RecentDocument({
    required String id,
    @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson) required DocumentType type,
    String? number,
    @JsonKey(fromJson: documentStatusFromJson, toJson: documentStatusToJson) required DocumentStatus status,
    required String customerName,
    required String issueDate,
    @JsonKey(fromJson: paymentStatusFromJson, toJson: paymentStatusToJson) PaymentStatus? paymentStatus,
  }) = _RecentDocument;

  factory RecentDocument.fromJson(Map<String, dynamic> json) => _$RecentDocumentFromJson(json);
}

@freezed
class DashboardSummary with _$DashboardSummary {
  const DashboardSummary._();

  const factory DashboardSummary({
    required int draftCount,
    required int overdueInvoiceCount,
    required int expiringQuoteCount,
    required List<RecentDocument> recentDocuments,
    required int documentsThisMonth,
    required int documentsLastMonth,
    required int customerCount,
    @Default(false) bool hasLogo,
  }) = _DashboardSummary;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) => _$DashboardSummaryFromJson(json);

  /// A business that has done nothing yet gets first steps instead of a
  /// screen of zeros.
  bool get isEmptyBusiness => recentDocuments.isEmpty && customerCount == 0;
}
