import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/businesses/data/businesses_repository_impl.dart';

class _MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _response(int status, Map<String, dynamic> data, String path) =>
    Response(statusCode: status, data: data, requestOptions: RequestOptions(path: path));

void main() {
  late _MockDio dio;
  late BusinessesRepositoryImpl repository;

  setUp(() {
    dio = _MockDio();
    repository = BusinessesRepositoryImpl(dio);
  });

  test('list maps owned and member businesses', () async {
    when(() => dio.get<Map<String, dynamic>>('/businesses')).thenAnswer((_) async => _response(200, {
          'businesses': [
            {'id': 'b1', 'name': 'Acme', 'isOwner': true},
            {'id': 'b2', 'name': 'Other', 'isOwner': false},
          ],
        }, '/businesses'));

    final businesses = await repository.list();

    expect(businesses.map((b) => b.isOwner), [true, false]);
  });

  test('create posts the name and returns the new business', () async {
    when(() => dio.post<Map<String, dynamic>>('/businesses', data: {'name': 'New Co'})).thenAnswer(
      (_) async => _response(201, {'business': {'id': 'b3', 'name': 'New Co'}}, '/businesses'),
    );

    final business = await repository.create('New Co');

    expect(business.id, 'b3');
    expect(business.onboardingCompletedAt, isNull);
  });

  test('switchTo posts the business id', () async {
    when(() => dio.post<Map<String, dynamic>>('/auth/switch-business', data: {'businessId': 'b2'})).thenAnswer(
      (_) async => _response(200, {
        'business': {'id': 'b2', 'name': 'Other', 'onboardingCompletedAt': '2026-01-01T00:00:00.000Z'},
      }, '/auth/switch-business'),
    );

    final business = await repository.switchTo('b2');

    expect(business.name, 'Other');
    expect(business.onboardingCompletedAt, isNotNull);
  });

  test('previewInvite fetches the public preview', () async {
    when(() => dio.get<Map<String, dynamic>>('/invites/tok123')).thenAnswer((_) async => _response(200, {
          'email': 'a@b.com',
          'businessName': 'Acme',
          'expired': false,
          'alreadyAccepted': false,
        }, '/invites/tok123'));

    final preview = await repository.previewInvite('tok123');

    expect(preview.businessName, 'Acme');
  });

  test('acceptInvite posts to the token and returns the joined business', () async {
    when(() => dio.post<Map<String, dynamic>>('/invites/tok123/accept')).thenAnswer(
      (_) async => _response(200, {'business': {'id': 'b2', 'name': 'Acme'}}, '/invites/tok123/accept'),
    );

    final business = await repository.acceptInvite('tok123');

    expect(business.id, 'b2');
  });

  test('leaveCurrent posts to /business/leave', () async {
    when(() => dio.post<Map<String, dynamic>>('/business/leave')).thenAnswer((_) async => _response(200, {
          'business': {'id': 'b9', 'name': 'My Business'},
          'createdReplacement': true,
        }, '/business/leave'));

    final result = await repository.leaveCurrent();

    expect(result.createdReplacement, isTrue);
  });
}
