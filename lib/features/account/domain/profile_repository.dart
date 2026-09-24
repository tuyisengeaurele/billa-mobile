import 'notification_type.dart';
import 'user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> updateProfile({required String name, String? phone});
  Future<String> uploadAvatar(List<int> bytes, String filename);
  Future<void> removeAvatar();
  Future<Map<NotificationType, bool>> notificationPreferences();
  Future<Map<NotificationType, bool>> setNotificationPreference(NotificationType type, bool enabled);
}
