import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/account/domain/notification_type.dart';
import 'package:billa_mobile/features/account/domain/session_info.dart';
import 'package:billa_mobile/features/account/domain/two_factor_setup.dart';
import 'package:billa_mobile/features/account/domain/user_profile.dart';

void main() {
  test('UserProfile.fromJson tolerates a null phone and avatar', () {
    final profile = UserProfile.fromJson({
      'id': 'u1',
      'email': 'a@b.com',
      'name': 'Ada',
      'phone': null,
      'avatarUrl': null,
    });

    expect(profile.name, 'Ada');
    expect(profile.phone, isNull);
    expect(profile.avatarUrl, isNull);
  });

  test('SessionInfo.fromJson parses the current-session flag', () {
    final session = SessionInfo.fromJson({
      'id': 's1',
      'createdAt': '2026-01-01T00:00:00.000Z',
      'expiresAt': '2026-02-01T00:00:00.000Z',
      'isCurrent': true,
    });

    expect(session.isCurrent, isTrue);
  });

  test('TwoFactorSetup.fromJson parses the QR data URI', () {
    final setup = TwoFactorSetup.fromJson({
      'secret': 'ABC',
      'otpauthUrl': 'otpauth://totp/x',
      'qrCodeDataUri': 'data:image/png;base64,AAAA',
    });

    expect(setup.secret, 'ABC');
    expect(setup.qrCodeDataUri, startsWith('data:image/png'));
  });

  test('NotificationType.fromWire round-trips every type and skips unknown ones', () {
    for (final type in NotificationType.values) {
      expect(NotificationType.fromWire(type.wireName), type);
    }
    expect(NotificationType.fromWire('SOMETHING_NEW'), isNull);
  });
}
