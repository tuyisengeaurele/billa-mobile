import 'package:freezed_annotation/freezed_annotation.dart';

part 'invite_preview.freezed.dart';
part 'invite_preview.g.dart';

@freezed
class InvitePreview with _$InvitePreview {
  const factory InvitePreview({
    required String email,
    required String businessName,
    required bool expired,
    required bool alreadyAccepted,
  }) = _InvitePreview;

  factory InvitePreview.fromJson(Map<String, dynamic> json) => _$InvitePreviewFromJson(json);
}
