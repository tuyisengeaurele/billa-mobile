import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/onboarding/data/logo_pipeline_service.dart';
import 'package:billa_mobile/features/onboarding/domain/logo_pipeline_step.dart';

class _MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _response(Map<String, dynamic> data, RequestOptions options) {
  return Response(statusCode: 200, data: data, requestOptions: options);
}

void main() {
  setUpAll(() {
    registerFallbackValue(FormData());
  });

  test('run() emits every stage in order and confirm() sends the final payload', () async {
    final dio = _MockDio();
    final uploadOptions = RequestOptions(path: '/business/logo');
    final bgOptions = RequestOptions(path: '/business/logo/remove-background');
    final colorsOptions = RequestOptions(path: '/business/logo/extract-colors');
    final confirmOptions = RequestOptions(path: '/business/logo/confirm');

    when(() => dio.post<Map<String, dynamic>>('/business/logo', data: any(named: 'data'))).thenAnswer(
      (_) async => _response({'url': 'https://cdn/logo-raw.png'}, uploadOptions),
    );
    when(() => dio.post<Map<String, dynamic>>(
      '/business/logo/remove-background',
      data: {'url': 'https://cdn/logo-raw.png'},
    )).thenAnswer(
      (_) async => _response({'url': 'https://cdn/logo-clean.png', 'backgroundRemoved': true}, bgOptions),
    );
    when(() => dio.post<Map<String, dynamic>>(
      '/business/logo/extract-colors',
      data: {'url': 'https://cdn/logo-clean.png'},
    )).thenAnswer(
      (_) async => _response({'primaryColor': '#C2185B', 'accentColors': ['#F6D7E4']}, colorsOptions),
    );
    when(() => dio.post<Map<String, dynamic>>(
      '/business/logo/confirm',
      data: {'url': 'https://cdn/logo-clean.png', 'primaryColor': '#C2185B', 'accentColors': ['#F6D7E4']},
    )).thenAnswer((_) async => _response({'business': {'id': 'b1', 'name': 'Acme'}}, confirmOptions));

    final service = LogoPipelineService(dio);
    final stages = await service.run([1, 2, 3], 'logo.png').toList();

    expect(stages, [
      LogoPipelineStage.uploading,
      LogoPipelineStage.checkingBackground,
      LogoPipelineStage.extractingColors,
      LogoPipelineStage.done,
    ]);
    expect(service.result!.url, 'https://cdn/logo-clean.png');
    expect(service.result!.primaryColor, '#C2185B');

    await service.confirm();

    verify(() => dio.post<Map<String, dynamic>>(
      '/business/logo/confirm',
      data: {'url': 'https://cdn/logo-clean.png', 'primaryColor': '#C2185B', 'accentColors': ['#F6D7E4']},
    )).called(1);
  });
}
