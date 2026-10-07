import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/auth/domain/auth_status.dart';
import 'package:billa_mobile/features/auth/domain/auth_user.dart';
import 'package:billa_mobile/features/onboarding/domain/business.dart';

void main() {
  test('unauthenticated and twoFactorRequired are distinct, equal by value', () {
    expect(const AuthStatus.unauthenticated(), const AuthStatus.unauthenticated());
    expect(const AuthStatus.twoFactorRequired('c1'), const AuthStatus.twoFactorRequired('c1'));
    expect(const AuthStatus.twoFactorRequired('c1') == const AuthStatus.twoFactorRequired('c2'), isFalse);
  });

  test('authenticated pattern-matches out user and business', () {
    const user = AuthUser(id: 'u1', email: 'a@b.com', totpEnabled: false, isAdmin: false);
    const business = Business(id: 'b1', name: 'Acme');
    const status = AuthStatus.authenticated(user, business);

    final label = status.when(
      unauthenticated: () => 'out',
      twoFactorRequired: (challengeId) => '2fa',
      authenticated: (u, b) => '${u.email}/${b.name}',
    );
    expect(label, 'a@b.com/Acme');
  });

  test('Business.fromJson maps a null onboardingCompletedAt', () {
    final business = Business.fromJson({'id': 'b1', 'name': 'Acme', 'onboardingCompletedAt': null});
    expect(business.onboardingCompletedAt, isNull);
    expect(business.accentColors, isEmpty);
  });
}
