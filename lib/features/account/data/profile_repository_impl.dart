import 'package:dio/dio.dart';
import '../domain/notification_type.dart';
import '../domain/profile_repository.dart';
import '../domain/user_profile.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<UserProfile> updateProfile({required String name, String? phone}) async {
    // Phone is always sent: the backend treats null as "clear it", and the
    // form is the whole profile, so an omitted phone would be ambiguous.
    final response = await _dio.patch<Map<String, dynamic>>('/profile', data: {'name': name, 'phone': phone});
    return UserProfile.fromJson(response.data!['user'] as Map<String, dynamic>);
  }

  @override
  Future<String> uploadAvatar(List<int> bytes, String filename) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/profile/avatar',
      data: FormData.fromMap({'avatar': MultipartFile.fromBytes(bytes, filename: filename)}),
    );
    return response.data!['url'] as String;
  }

  @override
  Future<void> removeAvatar() async {
    await _dio.delete<Map<String, dynamic>>('/profile/avatar');
  }

  @override
  Future<Map<NotificationType, bool>> notificationPreferences() async {
    final response = await _dio.get<Map<String, dynamic>>('/profile/notification-preferences');
    return _parse(response.data!);
  }

  @override
  Future<Map<NotificationType, bool>> setNotificationPreference(NotificationType type, bool enabled) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/profile/notification-preferences',
      data: {
        'preferences': {type.wireName: enabled},
      },
    );
    return _parse(response.data!);
  }

  Map<NotificationType, bool> _parse(Map<String, dynamic> body) {
    final result = <NotificationType, bool>{};
    (body['preferences'] as Map<String, dynamic>).forEach((name, value) {
      final type = NotificationType.fromWire(name);
      if (type != null) result[type] = value as bool;
    });
    return result;
  }
}
