import 'package:dio/dio.dart';
import '../domain/business.dart';
import '../domain/business_repository.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  BusinessRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Business> updateProfile({
    required String name,
    String? tin,
    String? industry,
    String? phone,
    String? email,
    String? address,
    String? rraEbmNumber,
  }) async {
    final data = <String, dynamic>{'name': name};
    if (tin != null) data['tin'] = tin;
    if (industry != null) data['industry'] = industry;
    if (phone != null) data['phone'] = phone;
    if (email != null) data['email'] = email;
    if (address != null) data['address'] = address;
    if (rraEbmNumber != null) data['rraEbmNumber'] = rraEbmNumber;

    final response = await _dio.patch<Map<String, dynamic>>('/business', data: data);
    return Business.fromJson(response.data!['business'] as Map<String, dynamic>);
  }

  @override
  Future<Business> completeOnboarding() async {
    final response = await _dio.post<Map<String, dynamic>>('/business/onboarding/complete');
    return Business.fromJson(response.data!['business'] as Map<String, dynamic>);
  }
}
