import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'auth_interceptor.dart';
import 'cache_interceptor.dart';
import 'cookie_jar_provider.dart';
import 'response_cache.dart';

const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:4000');

class ApiClient {
  ApiClient._(this.dio);

  final Dio dio;

  static Future<ApiClient> create({required ResponseCache cache, required CacheScope scope}) async {
    final dio = Dio(BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ));
    final jar = await createCookieJar();
    dio.interceptors.add(CookieManager(jar));
    dio.interceptors.add(AuthInterceptor(dio));
    dio.interceptors.add(CacheInterceptor(cache: cache, scope: scope));
    return ApiClient._(dio);
  }
}
