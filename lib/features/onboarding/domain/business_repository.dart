import 'business.dart';

abstract class BusinessRepository {
  Future<Business> updateProfile({
    required String name,
    String? tin,
    String? industry,
    String? phone,
    String? email,
    String? address,
    String? rraEbmNumber,
  });

  Future<Business> completeOnboarding();
}
