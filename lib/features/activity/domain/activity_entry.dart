import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_entry.freezed.dart';
part 'activity_entry.g.dart';

@freezed
class ActivityActor with _$ActivityActor {
  const factory ActivityActor({String? name, String? email}) = _ActivityActor;

  factory ActivityActor.fromJson(Map<String, dynamic> json) => _$ActivityActorFromJson(json);
}

/// One line of the business's history: who did something, what, and when. The actor is missing for things the
/// system did, and the metadata for entries that have nothing more to say.
@freezed
class ActivityEntry with _$ActivityEntry {
  const factory ActivityEntry({
    required String id,
    required String action,
    String? entityType,
    Map<String, dynamic>? metadata,
    required String createdAt,
    ActivityActor? actor,
  }) = _ActivityEntry;

  factory ActivityEntry.fromJson(Map<String, dynamic> json) => _$ActivityEntryFromJson(json);
}
