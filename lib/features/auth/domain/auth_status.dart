import 'package:freezed_annotation/freezed_annotation.dart';
import 'auth_user.dart';
import '../../onboarding/domain/business.dart';

part 'auth_status.freezed.dart';

@freezed
class AuthStatus with _$AuthStatus {
  const factory AuthStatus.unauthenticated() = Unauthenticated;
  const factory AuthStatus.twoFactorRequired(String challengeId) = TwoFactorRequired;
  const factory AuthStatus.authenticated(AuthUser user, Business business) = Authenticated;
}
