import 'package:dio/dio.dart';
import '../domain/logo_pipeline_step.dart';

class LogoPipelineService {
  LogoPipelineService(this._dio);

  final Dio _dio;
  LogoPipelineResult? result;

  Stream<LogoPipelineStage> run(List<int> imageBytes, String filename) async* {
    yield LogoPipelineStage.uploading;
    final uploadResponse = await _dio.post<Map<String, dynamic>>(
      '/business/logo',
      data: FormData.fromMap({'logo': MultipartFile.fromBytes(imageBytes, filename: filename)}),
    );
    var url = uploadResponse.data!['url'] as String;

    yield LogoPipelineStage.checkingBackground;
    final bgResponse = await _dio.post<Map<String, dynamic>>('/business/logo/remove-background', data: {'url': url});
    url = bgResponse.data!['url'] as String;

    yield LogoPipelineStage.extractingColors;
    final colorsResponse = await _dio.post<Map<String, dynamic>>('/business/logo/extract-colors', data: {'url': url});
    final primaryColor = colorsResponse.data!['primaryColor'] as String;
    final accentColors = List<String>.from(colorsResponse.data!['accentColors'] as List);

    result = LogoPipelineResult(url: url, primaryColor: primaryColor, accentColors: accentColors);
    yield LogoPipelineStage.done;
  }

  Future<void> confirm() async {
    final current = result;
    if (current == null) {
      throw StateError('confirm() called before run() completed');
    }
    await _dio.post<Map<String, dynamic>>('/business/logo/confirm', data: {
      'url': current.url,
      'primaryColor': current.primaryColor,
      'accentColors': current.accentColors,
    });
  }
}
