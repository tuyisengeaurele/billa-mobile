import 'package:freezed_annotation/freezed_annotation.dart';
import '../../documents/domain/document_enums.dart';

part 'document_sequence.freezed.dart';
part 'document_sequence.g.dart';

@freezed
class DocumentSequence with _$DocumentSequence {
  const factory DocumentSequence({
    @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson) required DocumentType type,
    required String prefix,
    required int nextNumber,
    required bool resetYearly,
  }) = _DocumentSequence;

  factory DocumentSequence.fromJson(Map<String, dynamic> json) => _$DocumentSequenceFromJson(json);
}
