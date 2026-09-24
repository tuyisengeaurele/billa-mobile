import 'package:freezed_annotation/freezed_annotation.dart';
import '../../onboarding/domain/business.dart';

part 'leave_result.freezed.dart';
part 'leave_result.g.dart';

@freezed
class LeaveResult with _$LeaveResult {
  const factory LeaveResult({
    required Business business,
    required bool createdReplacement,
  }) = _LeaveResult;

  factory LeaveResult.fromJson(Map<String, dynamic> json) => _$LeaveResultFromJson(json);
}
