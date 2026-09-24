import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/onboarding/data/business_repository_impl.dart';

class _MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _response(int statusCode, Map<String, dynamic> data, RequestOptions options) {
  return Response(statusCode: statusCode, data: data, requestOptions: options);
}

void main() {
  late _MockDio dio;
  late BusinessRepositoryImpl repository;

  setUp(() {
    dio = _MockDio();
    repository = BusinessRepositoryImpl(dio);
  });

  test('updateProfile PATCHes only the provided fields and returns the business', () async {
    final options = RequestOptions(path: '/business');
    when(() => dio.patch<Map<String, dynamic>>('/business', data: {'name': 'Acme', 'tin': '123'})).thenAnswer(
      (_) async => _response(200, {
        'business': {'id': 'b1', 'name': 'Acme', 'tin': '123', 'onboardingCompletedAt': null},
      }, options),
    );

    final business = await repository.updateProfile(name: 'Acme', tin: '123');

    expect(business.name, 'Acme');
    expect(business.tin, '123');
  });

  test('completeOnboarding posts to /business/onboarding/complete', () async {
    final options = RequestOptions(path: '/business/onboarding/complete');
    when(() => dio.post<Map<String, dynamic>>('/business/onboarding/complete')).thenAnswer(
      (_) async => _response(200, {
        'business': {'id': 'b1', 'name': 'Acme', 'onboardingCompletedAt': '2026-01-01T00:00:00.000Z'},
      }, options),
    );

    final business = await repository.completeOnboarding();

    expect(business.onboardingCompletedAt, isNotNull);
  });
}
