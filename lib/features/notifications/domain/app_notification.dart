import 'package:freezed_annotation/freezed_annotation.dart';
import '../../account/domain/notification_type.dart';

part 'app_notification.freezed.dart';
part 'app_notification.g.dart';

// A type the server adds later becomes null instead of failing the whole
// list: the row still has a title and body to show.
NotificationType? _typeFromJson(String? name) => name == null ? null : NotificationType.fromWire(name);

String? _typeToJson(NotificationType? type) => type?.wireName;

@freezed
class AppNotification with _$AppNotification {
  const AppNotification._();

  const factory AppNotification({
    required String id,
    @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson) NotificationType? type,
    required String title,
    String? body,
    String? link,
    String? readAt,
    required String createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) => _$AppNotificationFromJson(json);

  bool get isUnread => readAt == null;
}
