import 'package:freezed_annotation/freezed_annotation.dart';

part 'business_summary.freezed.dart';
part 'business_summary.g.dart';

@freezed
class BusinessSummary with _$BusinessSummary {
  const factory BusinessSummary({
    required String id,
    required String name,
    required bool isOwner,
  }) = _BusinessSummary;

  factory BusinessSummary.fromJson(Map<String, dynamic> json) => _$BusinessSummaryFromJson(json);
}
