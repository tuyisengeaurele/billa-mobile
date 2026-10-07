import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/account/data/profile_repository_impl.dart';
import 'package:billa_mobile/features/account/domain/notification_type.dart';

class _MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _ok(Map<String, dynamic> data, String path) =>
    Response(statusCode: 200, data: data, requestOptions: RequestOptions(path: path));

void main() {
  late _MockDio dio;
  late ProfileRepositoryImpl repository;

  setUp(() {
    dio = _MockDio();
    repository = ProfileRepositoryImpl(dio);
  });

  test('updateProfile sends name and phone and parses the user', () async {
    when(() => dio.patch<Map<String, dynamic>>('/profile', data: {'name': 'Ada', 'phone': '0788'})).thenAnswer(
      (_) async => _ok({
        'user': {'id': 'u1', 'email': 'a@b.com', 'name': 'Ada', 'phone': '0788', 'avatarUrl': null},
      }, '/profile'),
    );

    final profile = await repository.updateProfile(name: 'Ada', phone: '0788');

    expect(profile.phone, '0788');
  });

  test('updateProfile sends a null phone to clear it', () async {
    when(() => dio.patch<Map<String, dynamic>>('/profile', data: {'name': 'Ada', 'phone': null})).thenAnswer(
      (_) async => _ok({
        'user': {'id': 'u1', 'email': 'a@b.com', 'name': 'Ada', 'phone': null, 'avatarUrl': null},
      }, '/profile'),
    );

    final profile = await repository.updateProfile(name: 'Ada');

    expect(profile.phone, isNull);
    verify(() => dio.patch<Map<String, dynamic>>('/profile', data: {'name': 'Ada', 'phone': null})).called(1);
  });

  test('uploadAvatar posts multipart data and returns the url', () async {
    when(() => dio.post<Map<String, dynamic>>('/profile/avatar', data: any(named: 'data')))
        .thenAnswer((_) async => _ok({'url': '/uploads/a.png'}, '/profile/avatar'));

    final url = await repository.uploadAvatar([1, 2, 3], 'a.png');

    expect(url, '/uploads/a.png');
    final sent = verify(() => dio.post<Map<String, dynamic>>('/profile/avatar', data: captureAny(named: 'data')))
        .captured
        .single as FormData;
    expect(sent.files.single.key, 'avatar');
  });

  test('removeAvatar sends a DELETE', () async {
    when(() => dio.delete<Map<String, dynamic>>('/profile/avatar'))
        .thenAnswer((_) async => _ok({'ok': true}, '/profile/avatar'));

    await repository.removeAvatar();

    verify(() => dio.delete<Map<String, dynamic>>('/profile/avatar')).called(1);
  });

  test('notificationPreferences maps known types and drops unknown ones', () async {
    when(() => dio.get<Map<String, dynamic>>('/profile/notification-preferences')).thenAnswer(
      (_) async => _ok({
        'preferences': {'PAYMENT_RECEIVED': false, 'INVOICE_OVERDUE': true, 'SOMETHING_NEW': true},
      }, '/profile/notification-preferences'),
    );

    final preferences = await repository.notificationPreferences();

    expect(preferences, {NotificationType.paymentReceived: false, NotificationType.invoiceOverdue: true});
  });

  test('setNotificationPreference patches one key and returns the merged set', () async {
    when(() => dio.patch<Map<String, dynamic>>('/profile/notification-preferences', data: {
          'preferences': {'PAYMENT_RECEIVED': false},
        })).thenAnswer(
      (_) async => _ok({
        'preferences': {'PAYMENT_RECEIVED': false, 'INVOICE_OVERDUE': true},
      }, '/profile/notification-preferences'),
    );

    final preferences = await repository.setNotificationPreference(NotificationType.paymentReceived, false);

    expect(preferences[NotificationType.paymentReceived], isFalse);
    expect(preferences[NotificationType.invoiceOverdue], isTrue);
  });
}
