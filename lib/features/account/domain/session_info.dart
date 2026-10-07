import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_info.freezed.dart';
part 'session_info.g.dart';

@freezed
class SessionInfo with _$SessionInfo {
  const factory SessionInfo({
    required String id,
    required String createdAt,
    required String expiresAt,
    required bool isCurrent,
  }) = _SessionInfo;

  factory SessionInfo.fromJson(Map<String, dynamic> json) => _$SessionInfoFromJson(json);
}
